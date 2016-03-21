-module(breeder).
-compile(export_all).

-record(circle,
	{
		xpos = 0,
		ypos = 0,
		radius = 0,
		red = 0,
		blue = 0,
		green = 0,
		alpha = 0
	}).
	

start() ->
	ID = 1,
	PopSize = 100,
	NumOfCircles = 150,
	NumOfProcesses = 5,
	InitialPopulation = createPopulation(PopSize, NumOfCircles, [], ID),
	FinalPopulation = sort(InitialPopulation),
	%Displayer = spawn(displayer, start, [[{frame, Frame}, {from, self()}]]),
	beginBreedLoop(PopSize + 1, FinalPopulation, NumOfProcesses).

createPopulation(PopSize, PicSize, X, ID) when PopSize > 0 ->
	lists:flatten(X),
	Circles = picture:new(PicSize, []),
	Picture = {picture, ID, Circles},
	createSVG(Picture),
	Fitness = os:cmd("compare -metric PSNR ..//pictures//image" ++ integer_to_list(ID) ++ ".png" ++ " ..//goal//goal.png null: 2>&1"),
	os:cmd("DEL ..\\svg\\image" ++ integer_to_list(ID) ++ ".svg"),
	Test = os:cmd("DEL ..\\pictures\\image" ++ integer_to_list(ID) ++ ".png"),
	createPopulation(PopSize-1, PicSize, [{picture, list_to_float(Fitness), Circles}] ++ X, ID + 1);
	
createPopulation(_PopSize , _PicSize, X, _ID) -> X.
	
createSVG({picture, ID, [Circles]}) ->
	{ok, WriteIODevice} = file:open("..//svg//image" ++ integer_to_list(ID) ++ ".svg", [append]),
	file:write(WriteIODevice, "<svg height=\"1024\" width=\"1024\">\n"),
	createSVG(WriteIODevice, Circles),
	file:write(WriteIODevice, "</svg>\n"),
	file:close(WriteIODevice),
	os:cmd("START convert.exe ..//svg//image" ++ integer_to_list(ID) ++ ".svg" ++  " ..//pictures//image" ++ integer_to_list(ID) ++ ".png").
	
createSVG(IODevice, [#circle{xpos = X, ypos = Y, radius = RADIUS, red = R, blue = B, green = G, alpha = A} | Xs]) ->
	Circle = "<circle cx=\" " ++ integer_to_list(X) ++ "\" cy=\"" ++ integer_to_list(Y) ++ "\" r=\""  ++ integer_to_list(RADIUS) ++ "\" fill=\"rgb(" ++ integer_to_list(R) ++ ", " ++ integer_to_list(G) ++ ", " ++ integer_to_list(B) ++ ")\" fill-opacity = \"" ++ float_to_list(A) ++ "\" />\n",
	file:write(IODevice, Circle),
	createSVG(IODevice, Xs);
	
createSVG(_IODevice, []) -> ok.
		
sort(X) ->
	lists:flatten(X),
	Compare = fun({picture, Fitness1, _}, {picture, Fitness2, _}) ->
		if
			Fitness1 >= Fitness2 -> true;
			true				 -> false
		end
	end,
	lists:sort(Compare, X).


%beginBreedLoop(_ID, [], NumOfProcesses)->
%	NumOfProcesses;
	
beginBreedLoop(ID, Population, NumOfProcesses) when NumOfProcesses > 0->
	lists:flatten(Population),
	Parent1 = lists:nth(random:uniform(lists:flatlength(Population)), Population),
	Parent2 = lists:nth(random:uniform(lists:flatlength(Population)), Population),
	spawn(picture, breed, [self(), Parent1, Parent2, [], ID]),
	beginBreedLoop(ID+1, Population, NumOfProcesses - 1);
	
beginBreedLoop(_ID, Population, NumOfProcesses) when NumOfProcesses == 0->
	breedLoop(_ID, Population, 0).
		
breedLoop(ID, Population, Alpha) ->
	receive
	{picture, Fitness, Picture} -> 
		NewPop1 = lists:delete(lists:last(Population), Population),
		NewPop2 = NewPop1 ++ [{picture, Fitness, [Picture]}],	
		NewPop3 = sort(NewPop2),
		Parent1 = lists:nth(random:uniform(lists:flatlength(Population)), Population),
		Parent2 = lists:nth(random:uniform(lists:flatlength(Population)), Population),
		spawn(picture, breed, [self(), Parent1, Parent2, [], ID]),
		{picture, AlphaFitness, Circles} = lists:nth(1, Population),
		if 
			AlphaFitness > Alpha -> 
				spawn(breeder, createAlphaSVG, [{picture, ID, Circles}]),
				breedLoop(ID+1, NewPop3, AlphaFitness);
			true ->
				breedLoop(ID+1, NewPop3, Alpha)
		end;
	_Other -> {message, _Other}
	end.
	
createAlphaSVG({picture, ID, [Circles]}) ->
	{ok, WriteIODevice} = file:open("..//alpha//svg//image" ++ integer_to_list(ID) ++ ".svg", [append]),
	file:write(WriteIODevice, "<svg height=\"1024\" width=\"1024\">\n"),
	createAlphaSVG(WriteIODevice, Circles),
	file:write(WriteIODevice, "</svg>\n"),
	file:close(WriteIODevice),
	os:cmd("START convert.exe ..//alpha//svg//image" ++ integer_to_list(ID) ++ ".svg" ++  " ..//alpha//pictures//image" ++ integer_to_list(ID) ++ ".png").
	%calculate fitness here
	
createAlphaSVG(IODevice, [#circle{xpos = X, ypos = Y, radius = RADIUS, red = R, blue = B, green = G, alpha = A} | Xs]) ->
	Circle = "<circle cx=\" " ++ integer_to_list(X) ++ "\" cy=\"" ++ integer_to_list(Y) ++ "\" r=\""  ++ integer_to_list(RADIUS) ++ "\" fill=\"rgb(" ++ integer_to_list(R) ++ ", " ++ integer_to_list(G) ++ ", " ++ integer_to_list(B) ++ ")\" fill-opacity = \"" ++ float_to_list(A) ++ "\" />\n",
	file:write(IODevice, Circle),
	createAlphaSVG(IODevice, Xs);
	
createAlphaSVG(_IODevice, []) -> ok.

seed() ->
	<<A:32, B:32, C:32>> = crypto:rand_bytes(12),
	random:seed(A, B, C).
