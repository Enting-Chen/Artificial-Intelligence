classdef app2 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        Image           matlab.ui.control.Image
        Button          matlab.ui.control.Button
        TextAreaLabel   matlab.ui.control.Label
        TextArea        matlab.ui.control.TextArea
        TextArea2Label  matlab.ui.control.Label
        TextArea2       matlab.ui.control.TextArea
    end

    % Component initialization
    methods (Access = private)

        % Button pushed function
        function Click_callback(app, event)
            % browse Image
            [filename, pathname] = uigetfile({'*.jpg;*.png;*.gif;*.bmp'}, 'Pick an Image');
            figure(app.UIFigure)
            if isequal(filename,0) || isequal(pathname,0)
                %disp('User pressed cancel');
                return;
            else
                %disp(['User selected ', fullfile(pathname, filename)]);
                app.Image.ImageSource = fullfile(pathname, filename);
            end
            image = imread(fullfile(pathname, filename));
            image = reshape(double(image), numel(image), 1);
            load BP.mat w1 w2 b1 b2;
            size(image)
            [~, result] = BP_classify(image, w1, w2, b1, b2);
            app.TextArea.Value = string(result);
            load CNN.mat net;
            result = classify(net, reshape(image, 28, 28, 1));
            app.TextArea2.Value = string(result);
        end

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'Handwritten Digits Recognition';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [78 135 194 193];

            % Create Button
            app.Button = uibutton(app.UIFigure, 'push');
            app.Button.Position = [125 92 100 22];
            app.Button.Text = 'Browse Image';
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @Click_callback, true);

            % Create TextAreaLabel
            app.TextAreaLabel = uilabel(app.UIFigure);
            app.TextAreaLabel.HorizontalAlignment = 'right';
            app.TextAreaLabel.Position = [300,304,100,22];
            app.TextAreaLabel.Text = 'BP prediction';
            app.TextAreaLabel.FontWeight = 'bold';
            app.TextAreaLabel.FontSize = 14;

            % Create TextArea
            app.TextArea = uitextarea(app.UIFigure);
            app.TextArea.Position = [444 268 150 60];
            app.TextArea.FontWeight = 'bold';
            app.TextArea.FontSize = 17;
            app.TextArea.Editable = 'off';

            % Create TextArea2Label
            app.TextArea2Label = uilabel(app.UIFigure);
            app.TextArea2Label.HorizontalAlignment = 'right';
            app.TextArea2Label.Position = [300,171,110,22];
            app.TextArea2Label.Text = 'CNN prediction';
            app.TextArea2Label.FontWeight = 'bold';
            app.TextArea2Label.FontSize = 14;

            % Create TextArea2
            app.TextArea2 = uitextarea(app.UIFigure);
            app.TextArea2.Position = [444 135 150 60];
            app.TextArea2.FontWeight = 'bold';
            app.TextArea2.FontSize = 17;
            app.TextArea2.Editable = 'off';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
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