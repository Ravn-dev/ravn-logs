<script>
  import { onMount } from 'svelte';

  let visible = false;
  let rows = [];
  let cursor = null;
  let error = '';
  let loading = false;
  let type = '';
  let player = '';
  let text = '';
  let from = '';
  let to = '';

  const nui = (name, body = {}) => fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' }, body: JSON.stringify(body)
  });
  const seconds = value => value ? Math.floor(new Date(value).getTime() / 1000) : undefined;

  async function search(next = false) {
    if (loading) return;
    loading = true;
    error = '';
    if (!next) { rows = []; cursor = null; }
    try {
      await nui('searchLogs', {
        type, player, text, from: seconds(from), to: seconds(to), cursor: next ? cursor : undefined, limit: 25
      });
    } catch (e) { error = 'Could not request logs.'; loading = false; }
  }

  function receive(event) {
    if (event.data?.action === 'visible') { visible = event.data.visible; if (visible) search(); }
    if (event.data?.action === 'results') {
      loading = false;
      if (event.data.error) { error = event.data.error; return; }
      const payload = event.data.result || {};
      rows = [...rows, ...(payload.rows || [])];
      cursor = payload.cursor || null;
    }
  }

  function close() { visible = false; nui('close'); }
  function onKey(event) { if (event.key === 'Escape' && visible) close(); }
  onMount(() => {
    window.addEventListener('message', receive);
    window.addEventListener('keydown', onKey);
    return () => { window.removeEventListener('message', receive); window.removeEventListener('keydown', onKey); };
  });
</script>

{#if visible}
  <main class="shell">
    <header><div><p class="eyebrow">STAFF TOOLS</p><h1>Ravn Logs</h1></div><button class="close" on:click={close} aria-label="Close">×</button></header>
    <form on:submit|preventDefault={() => search()}>
      <label>Event type<input bind:value={type} maxlength="64" placeholder="Any event type"></label>
      <label>Player ID or name<input bind:value={player} maxlength="64" placeholder="Search player"></label>
      <label>Text search<input bind:value={text} maxlength="160" placeholder="Search log content"></label>
      <label>From<input type="datetime-local" bind:value={from}></label>
      <label>To<input type="datetime-local" bind:value={to}></label>
      <button class="search" type="submit">Search</button>
    </form>
    {#if error}<p class="error">{error}</p>{/if}
    <section class="results" aria-live="polite">
      {#each rows as row (row.id)}
        <article><div class="meta"><strong>{row.type}</strong><time>{new Date(row.timestamp * 1000).toLocaleString()}</time><small>#{row.id}</small></div><pre>{JSON.stringify(row.data, null, 2)}</pre></article>
      {:else}{#if !loading}<p class="empty">No matching log entries.</p>{/if}{/each}
      {#if loading}<p class="empty">Loading logs…</p>{/if}
    </section>
    {#if cursor && !loading}<button class="more" on:click={() => search(true)}>Load more</button>{/if}
  </main>
{/if}
