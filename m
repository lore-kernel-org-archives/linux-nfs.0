From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 02/29] knfsd: Add stats table infrastructure.
Date: Fri, 24 Apr 2009 23:56:24 -0400
Message-ID: <20090425035624.GC24770@fieldses.org>
References: <20090331202800.739621000@sgi.com> <20090331202938.445359000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42200 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbZDYD40 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2009 23:56:26 -0400
In-Reply-To: <20090331202938.445359000@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2009 at 07:28:02AM +1100, Greg Banks wrote:
> This infrastructure will be used to implement per-client and per-export
> serverside stats.  Multiple stats objects are kept in a hashtable,
> keyed by a string name (e.g. client IP address or export path).
> Old entries are pruned from the table using a timer.  The function
> nfsd_stats_find() can be used to find an entry and create it if
> necessary.
> 
> Signed-off-by: Greg Banks <gnb@sgi.com>
> ---
> 
>  fs/nfsd/stats.c            |  231 ++++++++++++++++++++++++++++++++++
>  include/linux/nfsd/debug.h |    1 
>  include/linux/nfsd/stats.h |   43 ++++++
>  3 files changed, 275 insertions(+)
> 
> Index: bfields/fs/nfsd/stats.c
> ===================================================================
> --- bfields.orig/fs/nfsd/stats.c
> +++ bfields/fs/nfsd/stats.c
> @@ -29,17 +29,29 @@
>  #include <linux/seq_file.h>
>  #include <linux/stat.h>
>  #include <linux/module.h>
> +#include <linux/jhash.h>
> +#include <linux/list.h>
> +#include <linux/swap.h>
> +#include <linux/log2.h>
>  
>  #include <linux/sunrpc/svc.h>
>  #include <linux/sunrpc/stats.h>
>  #include <linux/nfsd/nfsd.h>
>  #include <linux/nfsd/stats.h>
>  
> +#define NFSDDBG_FACILITY		NFSDDBG_STATS
> +
> +#define hentry_from_hnode(hn) \
> +	hlist_entry((hn), nfsd_stats_hentry_t, se_node)
> +
>  struct nfsd_stats	nfsdstats;
>  struct svc_stat		nfsd_svcstats = {
>  	.program	= &nfsd_program,
>  };
>  
> +int nfsd_stats_enabled = 1;
> +int nfsd_stats_prune_period = 2*86400;

For those of us that don't immediately recognize 86400 as the number of
seconds in a day, writing that out as " = 2*24*60*60;" could be a useful
hint.

Also nice: a comment with any rationale (however minor) for the choice
of period.

> +
>  static int nfsd_proc_show(struct seq_file *seq, void *v)
>  {
>  	int i;
> @@ -98,6 +110,225 @@ static const struct file_operations nfsd
>  	.release = single_release,
>  };
>  
> +
> +/*
> + * Stats hash pruning works thus.  A scan is run every prune period.
> + * On every scan, hentries with the OLD flag are detached and
> + * a reference dropped (usually that will be the last reference
> + * and the hentry will be deleted).  Hentries without the OLD flag
> + * have the OLD flag set; the flag is reset in nfsd_stats_get().
> + * So hentries with active traffic in the last 2 prune periods
> + * are not candidates for pruning.

s/2 prune periods/prune period/ ?

(From the description above: on exit from nfsd_stats_prune() all
remaining entries have OLD set.  Therefore if an entry is not touched in
the single period between two nfsd_stats_prune()'s, the second
nfsd_stats_prune() run will drop it.)

> + */
> +static void nfsd_stats_prune(unsigned long closure)
> +{
> +	nfsd_stats_hash_t *sh = (nfsd_stats_hash_t *)closure;
> +	unsigned int i;
> +	nfsd_stats_hentry_t *se;
> +	struct hlist_node *hn, *next;
> +	struct hlist_head to_be_dropped = HLIST_HEAD_INIT;
> +
> +	dprintk("nfsd_stats_prune\n");
> +
> +	if (!down_write_trylock(&sh->sh_sem)) {
> +		/* hash is busy...try again in a second */
> +		dprintk("nfsd_stats_prune: busy\n");
> +		mod_timer(&sh->sh_prune_timer, jiffies + HZ);

Could we make sh_sem a spinlock?  It doesn't look the the critical
sections ever need to sleep.

(Or even consider rcu, if we need the read lock on every rpc?  OK, I'm
mostly ignorant of rcu.)

> +		return;
> +	}
> +
> +	for (i = 0 ; i < sh->sh_size ; i++) {
> +		hlist_for_each_entry_safe(se, hn, next, &sh->sh_hash[i], se_node) {
> +			if (!test_and_set_bit(NFSD_STATS_HENTRY_OLD, &se->se_flags))

It looks like this is only ever used under the lock, so the
test_and_set_bit() is overkill.

> +				continue;
> +			hlist_del_init(&se->se_node);
> +			hlist_add_head(&se->se_node, &to_be_dropped);

Replace those two by hlist_move_list?

> +		}
> +	}
> +
> +	up_write(&sh->sh_sem);
> +
> +	dprintk("nfsd_stats_prune: deleting\n");
> +	hlist_for_each_entry_safe(se, hn, next, &to_be_dropped, se_node)
> +		nfsd_stats_put(se);

nfsd_stats_put() can down a semaphore, which we probably don't want in a
timer.  (So: make sh_sem a spinlock?)

> +
> +	mod_timer(&sh->sh_prune_timer, jiffies + nfsd_stats_prune_period * HZ);
> +}
> +
> +/*
> + * Initialise a stats hash.  Array size scales with
> + * server memory, as a loose heuristic for how many
> + * clients or exports a server is likely to have.
> + */
> +static void nfsd_stats_hash_init(nfsd_stats_hash_t *sh, const char *which)
> +{
> +	unsigned int nbits;
> +	unsigned int i;
> +
> +	init_rwsem(&sh->sh_sem);
> +
> +	nbits = 5 + ilog2(totalram_pages >> (30-PAGE_SHIFT));
> +	sh->sh_size = (1<<nbits);
> +	sh->sh_mask = (sh->sh_size-1);

Some comment on the choice of scale factor?  Also, see:

	http://marc.info/?l=linux-kernel&m=118299825922287&w=2

and followups.

Might consider a little helper function to do this kind of
fraction-of-total-memory calculation since I think the server does it in
3 or 4 places.

> +
> +	sh->sh_hash = kmalloc(sizeof(struct hlist_head) * sh->sh_size, GFP_KERNEL);

Can this be a more than a page?  (If so, could we just cap it at that
size to avoid >order-0 allocations and keep the kmalloc failure
unlikely?)

> +	if (sh->sh_hash == NULL) {
> +		printk(KERN_ERR "failed to allocate knfsd %s stats hashtable\n", which);
> +		/* struggle on... */
> +		return;
> +	}
> +	printk(KERN_INFO "knfsd %s stats hashtable, %u entries\n", which, sh->sh_size);

Eh.  Make it a dprintk?  Or maybe expose this in the nfsd filesystem if
it's not already?

> +
> +	for (i = 0 ; i < sh->sh_size ; i++)
> +		INIT_HLIST_HEAD(&sh->sh_hash[i]);
> +
> +	/* start the prune timer */
> +	init_timer(&sh->sh_prune_timer);
> +	sh->sh_prune_timer.function = nfsd_stats_prune;
> +	sh->sh_prune_timer.expires = jiffies + nfsd_stats_prune_period * HZ;
> +	sh->sh_prune_timer.data = (unsigned long)sh;
> +}
> +
> +/*
> + * Destroy a stats hash.  Drop what should be the last
> + * reference on all hentries, clean up the timer, and
> + * free the hash array.
> + */
> +static void nfsd_stats_hash_destroy(nfsd_stats_hash_t *sh)
> +{
> +	unsigned int i;
> +	nfsd_stats_hentry_t *se;
> +
> +	del_timer_sync(&sh->sh_prune_timer);
> +
> +	/* drop the last reference for all remaining hentries */
> +	for (i = 0 ; i < sh->sh_size ; i++) {
> +		struct hlist_head *hh = &sh->sh_hash[i];
> +
> +		while (hh->first != NULL) {
> +			se = hentry_from_hnode(hh->first);
> +			BUG_ON(atomic_read(&se->se_refcount) != 1);
> +			nfsd_stats_put(se);
> +		}
> +	}
> +
> +	if (sh->sh_hash != NULL) {

Drop the NULL check.

> +		kfree(sh->sh_hash);
> +	}
> +}
> +
> +/*
> + * Find and return a hentry for the given name, with a new refcount,
> + * creating it if necessary.  Will only return NULL on OOM or if
> + * stats are disabled.  Does it's own locking using the hash rwsem;
> + * may sleep.
> + */
> +nfsd_stats_hentry_t *nfsd_stats_find(nfsd_stats_hash_t *sh,
> +				     const char *name, int len)
> +{
> +	u32 hash;
> +	nfsd_stats_hentry_t *se, *new = NULL;
> +	struct hlist_node *hn;
> +
> +	dprintk("nfsd_stats_find: name %s len %d\n", name, len);
> +
> +	if (!nfsd_stats_enabled || sh->sh_hash == NULL)
> +		return NULL;
> +
> +
> +	/* search the hash table */
> +	hash = jhash(name, len, 0xfeedbeef) & sh->sh_mask;
> +	down_read(&sh->sh_sem);
> +	hlist_for_each_entry(se, hn, &sh->sh_hash[hash], se_node) {
> +		if (!strcmp(se->se_name, name)) {
> +			/* found matching */
> +			dprintk("nfsd_stats_find: found %s\n", se->se_name);
> +			nfsd_stats_get(se);
> +			up_read(&sh->sh_sem);
> +			return se;
> +		}
> +	}
> +	up_read(&sh->sh_sem);
> +
> +	/* not found, create a new one */
> +	dprintk("nfsd_stats_find: allocating new for %s\n", name);
> +	new = (nfsd_stats_hentry_t *)kmalloc(sizeof(*new), GFP_KERNEL);
> +	if (new == NULL)
> +		return NULL;
> +	/* initialise */
> +
> +	new->se_name = kmalloc(len+1, GFP_KERNEL);
> +	if (new->se_name == NULL) {
> +		kfree(new);
> +		return NULL;
> +	}
> +
> +	memcpy(new->se_name, name, len+1);
> +	atomic_set(&new->se_refcount, 2);/* 1 for the caller, 1 for the hash */
> +	new->se_hash = sh;
> +	new->se_flags = 0;
> +	INIT_HLIST_NODE(&new->se_node);
> +	memset(&new->se_data, 0, sizeof(new->se_data));
> +
> +	/* attach to the hash datastructure */
> +
> +	/*
> +	 * first check to see if we lost a race and some
> +	 * other thread already added a matching hentry.
> +	 */
> +	down_write(&sh->sh_sem);
> +	hlist_for_each_entry(se, hn, &sh->sh_hash[hash], se_node) {
> +		if (!strcmp(se->se_name, name)) {
> +			/* found matching, use that instead */
> +			dprintk("nfsd_stats_find: found(2) %s\n", name);
> +			kfree(new->se_name);
> +			kfree(new);
> +			nfsd_stats_get(se);
> +			up_write(&sh->sh_sem);
> +			return se;
> +		}
> +	}
> +	/* still not there, insert new one into the hash */
> +	hlist_add_head(&new->se_node, &sh->sh_hash[hash]);
> +
> +	up_write(&sh->sh_sem);
> +	return new;
> +}
> +
> +/*
> + * Drop a reference to a hentry, deleting the hentry if this
> + * was the last reference.  Does it's own locking using the

s/it's/its/

(Contending for the nitpick-of-the-day award.)

> + * hash rwsem; may sleep.
> + */
> +void
> +nfsd_stats_put(nfsd_stats_hentry_t *se)
> +{
> +	nfsd_stats_hash_t *sh = se->se_hash;
> +
> +	if (!atomic_dec_and_test(&se->se_refcount))
> +		return;
> +
> +	/* just dropped the last reference */
> +	down_write(&sh->sh_sem);
> +
> +	if (atomic_read(&se->se_refcount)) {
> +		/*
> +		 * We lost a race getting the write lock, and
> +		 * now there's a reference again.  Whatever.
> +		 */

Some kind of atomic_dec_and_lock() might close the race.

> +		goto out_unlock;
> +	}
> +
> +	dprintk("nfsd_stats_put: freeing %s\n", se->se_name);
> +	hlist_del(&se->se_node);
> +	kfree(se->se_name);
> +	kfree(se);
> +
> +out_unlock:
> +	up_write(&sh->sh_sem);
> +}
> +
> +
>  void
>  nfsd_stat_init(void)
>  {
> Index: bfields/include/linux/nfsd/stats.h
> ===================================================================
> --- bfields.orig/include/linux/nfsd/stats.h
> +++ bfields/include/linux/nfsd/stats.h
> @@ -40,6 +40,37 @@ struct nfsd_stats {
>  
>  };
>  
> +struct nfsd_op_stats {
> +	/* nothing to see here, yet */
> +};
> +
> +
> +typedef struct nfsd_stats_hash		nfsd_stats_hash_t;
> +typedef struct nfsd_stats_hentry	nfsd_stats_hentry_t;

Absent unusual circumstances, standard kernel style is to drop the
typedefs and use "struct nfsd_stats_{hash,hentry}" everywhere.

--b.

> +
> +/* Entry in the export and client stats hashtables */
> +struct nfsd_stats_hentry {
> +	struct hlist_node	se_node;	/* links hash chains */
> +	char			*se_name;
> +	atomic_t		se_refcount;	/* 1 for each user + 1 for hash */
> +#define NFSD_STATS_HENTRY_OLD	0
> +	unsigned long		se_flags;
> +	nfsd_stats_hash_t	*se_hash;
> +	struct nfsd_op_stats	se_data;
> +};
> +
> +/*
> + * Hashtable structure for export and client stats.
> + * Table width is chosen at boot time to scale with
> + * the size of the server.
> + */
> +struct nfsd_stats_hash {
> +	struct rw_semaphore	sh_sem;
> +	unsigned int		sh_size;
> +	unsigned int		sh_mask;
> +	struct hlist_head	*sh_hash;
> +	struct timer_list	sh_prune_timer;
> +};
>  
>  extern struct nfsd_stats	nfsdstats;
>  extern struct svc_stat		nfsd_svcstats;
> @@ -47,5 +78,17 @@ extern struct svc_stat		nfsd_svcstats;
>  void	nfsd_stat_init(void);
>  void	nfsd_stat_shutdown(void);
>  
> +extern nfsd_stats_hentry_t *nfsd_stats_find(nfsd_stats_hash_t *,
> +					    const char *name, int len);
> +static inline void
> +nfsd_stats_get(nfsd_stats_hentry_t *se)
> +{
> +	atomic_inc(&se->se_refcount);
> +	clear_bit(NFSD_STATS_HENTRY_OLD, &se->se_flags);
> +}
> +extern void nfsd_stats_put(nfsd_stats_hentry_t *se);
> +
> +
> +
>  #endif /* __KERNEL__ */
>  #endif /* LINUX_NFSD_STATS_H */
> Index: bfields/include/linux/nfsd/debug.h
> ===================================================================
> --- bfields.orig/include/linux/nfsd/debug.h
> +++ bfields/include/linux/nfsd/debug.h
> @@ -32,6 +32,7 @@
>  #define NFSDDBG_REPCACHE	0x0080
>  #define NFSDDBG_XDR		0x0100
>  #define NFSDDBG_LOCKD		0x0200
> +#define NFSDDBG_STATS		0x0400
>  #define NFSDDBG_ALL		0x7FFF
>  #define NFSDDBG_NOCHANGE	0xFFFF
>  
> 
> --
> Greg
