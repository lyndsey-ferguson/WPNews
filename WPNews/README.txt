A couple of notes:

1. I used NSAttributedString to display the content in a UITextView in the detail
view. It would have been better if I had just used a UIWebView to display the
content as it contains HTML. I realized that the content contained HTML after I saw
options to view videos but I wanted to complete the exercise first before coming back
to fix that. It would be quite straight forward to replace the UITextView with
a UIWebView and update the unit tests to get the content and looks for
2. The functionality to convert the text to an NSAttributedString should be done
on the main thread, currently it is not enforcing that.
3. I do not have any protection against a failed download. The right thing would
be to parse the response and display an error that corresponds to the failure.
4. I have the basic unit tests for the interactions in WPNewsUITests.m
5. You should be able to peruse the git history as I will include the .git directory
in the zip archive.
