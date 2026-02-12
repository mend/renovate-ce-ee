# Prometheus metrics

A number of default metrics are exposed by Node.JS for the Mend Renovate Self-Hosted Server respondng to the API request, _not_ the worker(s)

Additionally, the following custom metrics are exposed:

<table>
  <thead>
    <tr>
      <th>Metric</th>
      <th>Type</th>
      <th>Description</th>
      <th>Comments</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <code>mend_renovate_queue_size</code>
      </td>
      <td>
        <code>gauge</code>
      </td>
      <td>
        Current size of various queue types.
      </td>
      <td>
        Contains a number of queue types:
        <!-- don't indent further or add a newline above this line, as Markdown rendering will make it a code block -->
        <ul>
          <li>
            <code>scheduledAll</code>
          </li>
          <li>
            <code>scheduledHot</code>
          </li>
          <li>
            <code>scheduledCold</code>
          </li>
          <li>
            <code>scheduledCapped</code>
          </li>
          <li>
            <code>requested</code>
          </li>
        </ul>
        <!-- don't indent further -->
      </td>
    </tr>
    <tr>
      <td>
        <code>mend_renovate_queue_max_wait</code>
      </td>
      <td>
        <code>gauge</code>
      </td>
      <td>
        Current age in seconds of the oldest entry in each queue type.
      </td>
      <td>
        Contains a number of queue types:
        <!-- don't indent further or add a newline above this line, as Markdown rendering will make it a code block -->
        <ul>
          <li>
            <code>scheduledAll</code>
          </li>
          <li>
            <code>scheduledHot</code>
          </li>
          <li>
            <code>scheduledCold</code>
          </li>
          <li>
            <code>scheduledCapped</code>
          </li>
          <li>
            <code>requested</code>
          </li>
        </ul>
        <!-- don't indent further -->
      </td>
    </tr>
    <tr>
      <td>
        <code>mend_renovate_job_wait_time</code>
      </td>
      <td>
        <code>summary</code>
      </td>
      <td>
        Total time taken for a job from being enqueued to execution.
      </td>
      <td>
      </td>
    </tr>
  </tbody>
</table>
