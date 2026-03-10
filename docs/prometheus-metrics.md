# Prometheus metrics

A number of default metrics are exposed by Node.js for the Mend Renovate Self-Hosted Server responding to the API request, _not_ the worker(s).

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
            <code>schedule-all</code>
          </li>
          <li>
            <code>schedule-hot</code>
          </li>
          <li>
            <code>schedule-cold</code>
          </li>
          <li>
            <code>schedule-capped</code>
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
            <code>schedule-all</code>
          </li>
          <li>
            <code>schedule-hot</code>
          </li>
          <li>
            <code>schedule-cold</code>
          </li>
          <li>
            <code>schedule-capped</code>
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
        <code>mend_renovate_worker_queue_size</code>
      </td>
      <td>
        <code>gauge</code>
      </td>
      <td>
        Current number of jobs by worker queue, schedule, and status.
      </td>
      <td>
        Labels:
        <!-- don't indent further or add a newline above this line, as Markdown rendering will make it a code block -->
        <ul>
          <li>
            <code>queue</code>: worker queue name, for example <code>main</code> or <code>foo</code>
          </li>
          <li>
            <code>schedule</code>: scheduler queue name, for example <code>schedule-all</code>
          </li>
          <li>
            <code>status</code>: <code>pending</code> or <code>running</code>
          </li>
        </ul>
        <!-- don't indent further -->
      </td>
    </tr>
    <tr>
      <td>
        <code>mend_renovate_worker_queue_max_wait</code>
      </td>
      <td>
        <code>gauge</code>
      </td>
      <td>
        Current age in seconds of the oldest pending job by worker queue and schedule.
      </td>
      <td>
        Labels:
        <!-- don't indent further or add a newline above this line, as Markdown rendering will make it a code block -->
        <ul>
          <li>
            <code>queue</code>: worker queue name, for example <code>main</code> or <code>foo</code>
          </li>
          <li>
            <code>schedule</code>: scheduler queue name, for example <code>schedule-all</code>
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
