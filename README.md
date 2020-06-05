# CleanRxReportTableDemo
This iOS app demonstrates an architectual solution to a fairly complex banking report scene.

This is a refactoring of the  [CleanReportTableDemo](https://github.com/lyleresnick/CleanReportTableDemo) into an Reactive VIPER Architecture.

It shows how Reactive VIPER can be used to break up a potentially very Massive View Controller by introducing the following classes:

- a Use Case which transforms its input entity models to an output stream of enums -- there are two transformers: one processes data originating from two separate input streams, the other processes data originating from a single stream,
- a Presenter, which transforms the input stream of enums from the Use Case into a ViewModel of Rows. The presenter retains the ViewModel to act as data source for the TableView. 

