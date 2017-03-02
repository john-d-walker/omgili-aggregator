# omgili-aggregator
<p>Aggregates news data from omgili.com and publishes it to a Redis list.</p>

<h2>Getting started</h2>

<p>To install omgili-aggregator, navigate to the 'omgili-aggregator' directory and run the following command:</p>
<pre><code>bundle install</code></pre>

<p>Then, to run omgili-aggregator, run the following command:</p>
<pre><code>ruby lib/omgili_aggregator.rb</code></pre>

<h2>Configuring</h2>

<p>There are a few ways to configure the behavior of omgili-aggregator. In order to do so, modify the 'config.yaml' file in the 'omgili-aggregator' directory.</p>

<p>Possible configurations include:</p>
<ul>
<li>Redis server connection settings</li>
<li>Number of threads the program will use</li>
<li>Limit the amount of data downloaded from omgili</li>
</ul>

<p>Please see the 'config.yaml' file for more details and instructions.</p>

<h2>Idempotence</h2>

<p>When you first run omgili-aggregator, a file will be generated called 'previous_downloads.csv'. This file is compared to all the currently available files found at feed.omgili.com on all future executions. In order to prevent duplicate data from being downloaded and pushed to the Redis server, it is very important not to delete or modify this file in any way.</p>

<h2>Testing</h2>

<p>This library is tested using <a href="https://github.com/seattlerb/minitest">Minitest</a>. All tests can be run simultaneously from the 'omgili-aggregator' directory by running the following command:</p>
<pre><code>rake</code></pre>

<h2>Code Consistency (linting) and Code Complexity (ABC)</h2>

<p>All ruby scripts were analyzed and determined to have no offenses by <a href="https://github.com/bbatsov/rubocop">Rubocop</a>, which enforces many of the guidelines outlined in the <a href="https://github.com/bbatsov/ruby-style-guide">community Ruby Style Guide</a>, as well as calculates ABC metrics.</p>

<h2>Contributors</h2>
<ul>
<li>John Walker</li>
</ul>
