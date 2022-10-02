classdef app2 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        GridLayout      matlab.ui.container.GridLayout
        Button(10, 9)   matlab.ui.control.Button
        Pieces(16, 2)   matlab.ui.control.Image
        Background      matlab.ui.control.Image
    end

    % Component initialization
    methods (Access = private)
        
        function Highlight_button(app, x, y)
            Moves = MoveChess(app.UIFigure.UserData.Board, -1, x, y);
            for i = 1:10
                for j = 1:9
                    app.Button(i, j).Visible = 'off';
                end
            end
            app.Button(x, y).Visible = 'on';
            app.Button(x, y).BackgroundColor = [173 132 74]/200;
            for i = 1:size(Moves, 1)
                app.Button(Moves(i, 3), Moves(i, 4)).Visible = 'on';
                app.Button(Moves(i, 3), Moves(i, 4)).BackgroundColor = [173 132 74]/300;
            end
        end
            
        % Button pushed function
        function Click_callback(app, event)
        disp("Clicked!\n");
        x = event.Source.Layout.Row;
        y = event.Source.Layout.Column;
        if size(app.UIFigure.UserData.Move, 1) == 0 && app.UIFigure.UserData.Board(x, y) < 0
            app.UIFigure.UserData.Move = [x y];
            Highlight_button(app, x, y);
        else
            disp("check\n");
            if size(app.UIFigure.UserData.Move, 2) == 2 
            if app.UIFigure.UserData.Board(x, y) >= 0
            app.UIFigure.UserData.Move = [app.UIFigure.UserData.Move x y];
            Moves = MoveChess(app.UIFigure.UserData.Board, -1, app.UIFigure.UserData.Move(1, 1), app.UIFigure.UserData.Move(1, 2))
            Acceptable = arrayfun(@(i) isequal(Moves(i, :), app.UIFigure.UserData.Move), 1:size(Moves,1))
            ~numel(find(Acceptable))
            if ~numel(find(Acceptable))
                app.UIFigure.UserData.Move = [app.UIFigure.UserData.Move(1, 1) app.UIFigure.UserData.Move(1, 2)];
            end
  
            else
                app.UIFigure.UserData.Move = [x y];
                Highlight_button(app, x, y);
            end
            
            end
        end
        if size(app.UIFigure.UserData.Move, 2) == 4
            app.UIFigure.UserData.Move
            Update_board(app, app.UIFigure.UserData.Move);
            app.UIFigure.UserData.Move = [];
            for i = 1:10
                for j = 1:9
                    app.Button(i, j).Visible = 'off';
                end
            end
            if ~ismember(1, app.UIFigure.UserData.Board)
                msg = "Fuiyoh! You win";
                title = "Game Ended";    
                selection = uiconfirm(app.UIFigure,msg,title, ...
                'Options',{'OK'});
                close(app.UIFigure);
                return;
            end
                
            [~, Best_move] = AlphaBeta(app.UIFigure.UserData.Board, 3, -inf, +inf, 1);
            Update_board(app, Best_move);
            
            if ~ismember(-1, app.UIFigure.UserData.Board)
                msg = "Haiyaa! You lost";
                title = "Game Ended";    
                selection = uiconfirm(app.UIFigure,msg,title, ...
                'Options',{'OK'});
                close(app.UIFigure);
                return;
            end
        end
        end 
        
        % Create UIFigure and components
        function createComponents(app)
            
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 507 564];
            app.UIFigure.Name = 'Chinese Chess';
            
            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {45, 45, 45, 45, 45, 45, 45, 45, 45};
            app.GridLayout.RowHeight = {45, 45, 45, 45, 45, 45, 45, 45, 45, 45};            
            
            app.Background = uiimage(app.GridLayout);
            app.Background.Layout.Row = [1 10];
            app.Background.Layout.Column = [1 9];
            app.Background.ImageSource = 'bg.png';

            project = [1, 2, 2, 3, 3, 5, 5, 6, 6, 4, 4, 7, 7, 7, 7, 7]';
            load Board.mat Board;
            app.UIFigure.UserData.Board = Board; 
            load Board_unique.mat Board_unique;
            app.UIFigure.UserData.Board_unique = Board_unique; 
            
            % Create Button
            for i = 1:10
                for j = 1:9
                    app.Button(i, j) = uibutton(app.GridLayout, 'push');
                    app.Button(i, j).Text = '';
                    app.Button(i, j).Layout.Row = i;
                    app.Button(i, j).Layout.Column = j;
                    app.Button(i, j).ButtonPushedFcn = createCallbackFcn(app, @Click_callback, true);
                    app.Button(i, j).Visible = 'off';
                end
            end
            
            for i = 1:16
                app.Pieces(i, 1) = uiimage(app.GridLayout);
                app.Pieces(i, 1).ImageSource = strcat(string(project(i, :)), '.png');
                app.Pieces(i, 1).ImageClickedFcn = createCallbackFcn(app, @Click_callback, true);
                app.Pieces(i, 2) = uiimage(app.GridLayout);
                app.Pieces(i, 2).ImageSource = strcat(string(project(i, :)+7), '.png');
                app.Pieces(i, 2).ImageClickedFcn = createCallbackFcn(app, @Click_callback, true);     
            end
            
            for i = 1:10
                for j = 1:9 
                    if Board(i, j)
                        if Board(i, j) > 0
                            app.Pieces(Board_unique(i, j), 1).Layout.Row = i;
                            app.Pieces(Board_unique(i, j), 1).Layout.Column = j;
                        else
                            app.Pieces((-1)*Board_unique(i, j), 2).Layout.Row = i;
                            app.Pieces((-1)*Board_unique(i, j), 2).Layout.Column = j;
                        end
                    end
                end
            end
            app.UIFigure.UserData.Move = [];
            
            %app.UIFigure.CloseRequestFcn = @Gameover_callback;
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
            
        end
        
        function Update_board(app, Move)
            disp("Update board\n");
            Move
            app.UIFigure.UserData.Board(Move(1, 3), Move(1, 4)) = app.UIFigure.UserData.Board(Move(1, 1), Move(1, 2));
            app.UIFigure.UserData.Board(Move(1, 1), Move(1, 2)) = 0;
            if app.UIFigure.UserData.Board_unique(Move(1, 3), Move(1, 4)) ~= 0
                if app.UIFigure.UserData.Board_unique(Move(1, 3), Move(1, 4)) > 0
                    app.Pieces(app.UIFigure.UserData.Board_unique(Move(1, 3), Move(1, 4)), 1).Visible = 'off';
                else
                    app.Pieces(abs(app.UIFigure.UserData.Board_unique(Move(1, 3), Move(1, 4))), 2).Visible = 'off';
                end
            end
            if app.UIFigure.UserData.Board_unique(Move(1, 1), Move(1, 2)) > 0 
                app.Pieces(app.UIFigure.UserData.Board_unique(Move(1, 1), Move(1, 2)), 1).Layout.Row = Move(1, 3);
                app.Pieces(app.UIFigure.UserData.Board_unique(Move(1, 1), Move(1, 2)), 1).Layout.Column = Move(1, 4);
            else
                disp(app.UIFigure.UserData.Board_unique(Move(1, 1), Move(1, 2)));
                app.Pieces(abs(app.UIFigure.UserData.Board_unique(Move(1, 1), Move(1, 2))), 2).Layout.Row = Move(1, 3);
                app.Pieces(abs(app.UIFigure.UserData.Board_unique(Move(1, 1), Move(1, 2))), 2).Layout.Column = Move(1, 4);
            end
            app.UIFigure.UserData.Board_unique(Move(1, 3), Move(1, 4)) = app.UIFigure.UserData.Board_unique(Move(1, 1), Move(1, 2));
            app.UIFigure.UserData.Board_unique(Move(1, 1), Move(1, 2)) = 0;
        end
            
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app2

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end