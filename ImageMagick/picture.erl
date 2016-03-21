-module(picture).
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
	

new(X, Circles) when X > 0 ->
	lists:flatten(Circles),
	new(X-1, createCircle() ++ Circles);
new(0, Circles) -> [Circles].
	
createCircle() ->
	seed(),
	[#circle{xpos=random:uniform(1024), ypos=random:uniform(1024), radius = random:uniform(400), 
		red=random:uniform(256), blue=random:uniform(256), green=random:uniform(256), alpha=random:uniform()}].
		
createSVG({picture, ID, Circles}) ->	
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
		
breed(From, {picture, _Fit2, X}, {picture, _Fit1, Y }, [], ID) -> 
		lists:flatten(X),
		lists:flatten(Y),
		Picture = breed(X, Y, []),
		createSVG({picture, ID, Picture}),
		Fitness = os:cmd("compare -metric PSNR ..//pictures//image" ++ integer_to_list(ID) ++ ".png" ++ " ..//goal//goal.png null: 2>&1"),
		os:cmd("DEL ..\\svg\\image" ++ integer_to_list(ID) ++ ".svg"),
		Test = os:cmd("DEL ..\\pictures\\image" ++ integer_to_list(ID) ++ ".png"),
		From ! {picture, list_to_float(Fitness), Picture}.
	
breed([[#circle{xpos = X1, ypos = Y1, radius = RADIUS1, red = R1, blue = B1, green = G1, alpha = A1} | Xs]], 
				[[#circle{xpos = X2, ypos = Y2, radius = RADIUS2, red = R2, blue = B2, green = G2, alpha = A2} | Ys]], List) -> 
	lists:flatten(List),
	seed(), 
	Random1 = random:uniform(100),
	Random2 = random:uniform(100),
	Random3 = random:uniform(100),
	Random4 = random:uniform(100),
	Random5 = random:uniform(100),
	Random6 = random:uniform(100),
	Random7 = random:uniform(100),
	
	if 
		Random1 < 45 -> X = X1;
		Random1 < 90 -> X = X2;
		true		 -> X = random:uniform(1024)
	end,
	if 
		Random2 < 45 -> Y = Y1;
		Random2 < 90 -> Y = Y2;
		true		 -> Y = random:uniform(1024)
	end,
	if 
		Random3 < 45 -> RADIUS = RADIUS1;
		Random3 < 90 -> RADIUS = RADIUS2;
		true		 -> RADIUS = random:uniform(400)
	end,
	if 
		Random4 < 45 -> R = R1;
		Random4 < 90 -> R = R2;
		true		 -> R = random:uniform(256)
	end,
	if 
		Random5 < 45 -> B = B1;
		Random5 < 90 -> B = B2;
		true		 -> B = random:uniform(256)
	end,
	if 
		Random6 < 45 -> G = G1;
		Random6 < 90 -> G = G2;
		true		 -> G = random:uniform(256)
	end,
	if 
		Random7 < 45 -> A = A1;
		Random7 < 90 -> A = A2;
		true		 -> A = random:uniform()
	end,
	Child = #circle{xpos = X, ypos = Y, radius = RADIUS, red = R, blue = B, green = G, alpha = A},
	breed(Xs, Ys, [Child] ++ lists:flatten(List));
	
	
breed([#circle{xpos = X1, ypos = Y1, radius = RADIUS1, red = R1, blue = B1, green = G1, alpha = A1} | Xs], 
				[#circle{xpos = X2, ypos = Y2, radius = RADIUS2, red = R2, blue = B2, green = G2, alpha = A2} | Ys], List) -> 
	seed(), 
	Random1 = random:uniform(100),
	Random2 = random:uniform(100),
	Random3 = random:uniform(100),
	Random4 = random:uniform(100),
	Random5 = random:uniform(100),
	Random6 = random:uniform(100),
	Random7 = random:uniform(100),
	
	if 
		Random1 < 45 -> X = X1;
		Random1 < 90 -> X = X2;
		true		 -> X = random:uniform(1000)
	end,
	if 
		Random2 < 45 -> Y = Y1;
		Random2 < 90 -> Y = Y2;
		true		 -> Y = random:uniform(1000)
	end,
	if 
		Random3 < 45 -> RADIUS = RADIUS1;
		Random3 < 90 -> RADIUS = RADIUS2;
		true		 -> RADIUS = random:uniform(400)
	end,
	if 
		Random4 < 45 -> R = R1;
		Random4 < 90 -> R = R2;
		true		 -> R = random:uniform(256)
	end,
	if 
		Random5 < 45 -> B = B1;
		Random5 < 90 -> B = B2;
		true		 -> B = random:uniform(256)
	end,
	if 
		Random6 < 45 -> G = G1;
		Random6 < 90 -> G = G2;
		true		 -> G = random:uniform(256)
	end,
	if 
		Random7 < 45 -> A = A1;
		Random7 < 90 -> A = A2;
		true		 -> A = random:uniform()
	end,
	Child = #circle{xpos = X, ypos = Y, radius = RADIUS, red = R, blue = B, green = G, alpha = A},
	breed(Xs, Ys, [Child] ++ lists:flatten(List));
	
breed([#circle{xpos = X1, ypos = Y1, radius = RADIUS1, red = R1, blue = B1, green = G1, alpha = A1}], 
				[#circle{xpos = X2, ypos = Y2, radius = RADIUS2, red = R2, blue = B2, green = G2, alpha = A2}], List) -> 
	lists:flatten(List),
	seed(), 
	Random1 = random:uniform(100),
	Random2 = random:uniform(100),
	Random3 = random:uniform(100),
	Random4 = random:uniform(100),
	Random5 = random:uniform(100),
	Random6 = random:uniform(100),
	Random7 = random:uniform(100),
	
	if 
		Random1 < 45 -> X = X1;
		Random1 < 90 -> X = X2;
		true		 -> X = random:uniform(1000)
	end,
	if 
		Random2 < 45 -> Y = Y1;
		Random2 < 90 -> Y = Y2;
		true		 -> Y = random:uniform(1000)
	end,
	if 
		Random3 < 45 -> RADIUS = RADIUS1;
		Random3 < 90 -> RADIUS = RADIUS2;
		true		 -> RADIUS = random:uniform(400)
	end,
	if 
		Random4 < 45 -> R = R1;
		Random4 < 90 -> R = R2;
		true		 -> R = random:uniform(256)
	end,
	if 
		Random5 < 45 -> B = B1;
		Random5 < 90 -> B = B2;
		true		 -> B = random:uniform(256)
	end,
	if 
		Random6 < 45 -> G = G1;
		Random6 < 90 -> G = G2;
		true		 -> G = random:uniform(256)
	end,
	if 
		Random7 < 45 -> A = A1;
		Random7 < 90 -> A = A2;
		true		 -> A = random:uniform()
	end,
	Child = #circle{xpos = X, ypos = Y, radius = RADIUS, red = R, blue = B, green = G, alpha = A},
	[Child] ++ lists:flatten(List);

breed([], [], Picture) -> 
	lists:flatten(Picture).

seed() ->
	<<A:32, B:32, C:32>> = crypto:rand_bytes(12),
	random:seed(A, B, C).
	
	