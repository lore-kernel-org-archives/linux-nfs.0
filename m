From: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Subject: Re: [patch 02/29] knfsd: Add stats table infrastructure.
Date: Sun, 26 Apr 2009 14:12:23 +1000
Message-ID: <ac442c870904252112u707f00den889fbe839799a36a@mail.gmail.com>
References: <20090331202800.739621000@sgi.com>
	 <20090331202938.445359000@sgi.com>
	 <20090425035624.GC24770@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f112.google.com ([209.85.221.112]:40864 "EHLO
	mail-qy0-f112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbZDZEUI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Apr 2009 00:20:08 -0400
Received: by qyk10 with SMTP id 10so549303qyk.33
        for <linux-nfs@vger.kernel.org>; Sat, 25 Apr 2009 21:20:06 -0700 (PDT)
In-Reply-To: <20090425035624.GC24770@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 25, 2009 at 1:56 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Apr 01, 2009 at 07:28:02AM +1100, Greg Banks wrote:

>> +int nfsd_stats_enabled = 1;
>> +int nfsd_stats_prune_period = 2*86400;
>
> For those of us that don't immediately recognize 86400 as the number of
> seconds in a day, writing that out as " = 2*24*60*60;" could be a useful
> hint.

Done.

>
> Also nice: a comment with any rationale (however minor) for the choice
> of period.

I've added this comment

/*
 * This number provides a bound on how long a record for a particular
 * stats entry survives after it's last use (an entry will die between
 * 1x and 2x the prune period after it's last use).  This is really only
 * particularly useful if a system admin is going to be trawling through
 * the /proc files manually and wants to see entries for (e.g.) clients
 * which have since unmounted.  If instead he uses some userspace
 * stats infrastructure which can handle rate conversion and instance
 * management, the prune period doesn't really matter.  The choice of
 * 2 days is really quite arbitrary.
 */



>> + * Stats hash pruning works thus.  A scan is run every prune period.
>> + * On every scan, hentries with the OLD flag are detached and
>> + * a reference dropped (usually that will be the last reference
>> + * and the hentry will be deleted).  Hentries without the OLD flag
>> + * have the OLD flag set; the flag is reset in nfsd_stats_get().
>> + * So hentries with active traffic in the last 2 prune periods
>> + * are not candidates for pruning.
>
> s/2 prune periods/prune period/ ?
>
> (From the description above: on exit from nfsd_stats_prune() all
> remaining entries have OLD set.  Therefore if an entry is not touched in
> the single period between two nfsd_stats_prune()'s, the second
> nfsd_stats_prune() run will drop it.)

Yeah, that was poorly phrased.  Fixed.

>
>> + */
>> +static void nfsd_stats_prune(unsigned long closure)
>> +{
>> +     nfsd_stats_hash_t *sh = (nfsd_stats_hash_t *)closure;
>> +     unsigned int i;
>> +     nfsd_stats_hentry_t *se;
>> +     struct hlist_node *hn, *next;
>> +     struct hlist_head to_be_dropped = HLIST_HEAD_INIT;
>> +
>> +     dprintk("nfsd_stats_prune\n");
>> +
>> +     if (!down_write_trylock(&sh->sh_sem)) {
>> +             /* hash is busy...try again in a second */
>> +             dprintk("nfsd_stats_prune: busy\n");
>> +             mod_timer(&sh->sh_prune_timer, jiffies + HZ);
>
> Could we make sh_sem a spinlock?  It doesn't look the the critical
> sections ever need to sleep.
>
> (Or even consider rcu, if we need the read lock on every rpc?  OK, I'm
> mostly ignorant of rcu.)

So was I way back when I wrote this patch, and it was written for an
antique kernel which was missing some useful locking bits.  So I'm not
too surprised that the locking scheme could do with a rethink.  I'll
take another look and get back to you.

>
>> +             return;
>> +     }
>> +
>> +     for (i = 0 ; i < sh->sh_size ; i++) {
>> +             hlist_for_each_entry_safe(se, hn, next, &sh->sh_hash[i], se_node) {
>> +                     if (!test_and_set_bit(NFSD_STATS_HENTRY_OLD, &se->se_flags))
>
> It looks like this is only ever used under the lock, so the
> test_and_set_bit() is overkill.

It's cleared in nfsd_stats_get() without the sh_sem lock.

>
>> +                             continue;
>> +                     hlist_del_init(&se->se_node);
>> +                     hlist_add_head(&se->se_node, &to_be_dropped);
>
> Replace those two by hlist_move_list?

If I read hlist_move_list() correctly, it moves an entire chain from
one hlist_head to another.  Here we want instead to move a single
hlist_node from one chain to another.  So, no.

>
>> +             }
>> +     }
>> +
>> +     up_write(&sh->sh_sem);
>> +
>> +     dprintk("nfsd_stats_prune: deleting\n");
>> +     hlist_for_each_entry_safe(se, hn, next, &to_be_dropped, se_node)
>> +             nfsd_stats_put(se);
>
> nfsd_stats_put() can down a semaphore, which we probably don't want in a
> timer.

Ouch.  What the hell was I thinking <kicks self>

>
>> +
>> +     mod_timer(&sh->sh_prune_timer, jiffies + nfsd_stats_prune_period * HZ);
>> +}
>> +
>> +/*
>> + * Initialise a stats hash.  Array size scales with
>> + * server memory, as a loose heuristic for how many
>> + * clients or exports a server is likely to have.
>> + */
>> +static void nfsd_stats_hash_init(nfsd_stats_hash_t *sh, const char *which)
>> +{
>> +     unsigned int nbits;
>> +     unsigned int i;
>> +
>> +     init_rwsem(&sh->sh_sem);
>> +
>> +     nbits = 5 + ilog2(totalram_pages >> (30-PAGE_SHIFT));
>> +     sh->sh_size = (1<<nbits);
>> +     sh->sh_mask = (sh->sh_size-1);
>
> Some comment on the choice of scale factor?  Also, see:
>
>        http://marc.info/?l=linux-kernel&m=118299825922287&w=2
>
> and followups.

Ok, I'll look into those.

>
> Might consider a little helper function to do this kind of
> fraction-of-total-memory calculation since I think the server does it in
> 3 or 4 places.
>
>> +
>> +     sh->sh_hash = kmalloc(sizeof(struct hlist_head) * sh->sh_size, GFP_KERNEL);
>
> Can this be a more than a page?

Yes, but it would need to be a fairly large-memory machine.  With 4K
pages and 8B pointers, totalram_pages would need to be 16G.  With 4B
pointers, we'd need 32G.

> (If so, could we just cap it at that
> size to avoid >order-0 allocations and keep the kmalloc failure
> unlikely?)

Well...I have no problem with capping it, but I don't think it's a
likely failure mode.  Firstly, there *two* allocations, which are
probably only order 1, and they happen at nfsd module load time.
Secondly, the allocation order scales, really quite slowly, with
available RAM.  Thirdly, machines which have a lowmem split will hit
the >0 order later than more modern machines with flat address spaces.

>
>> +     if (sh->sh_hash == NULL) {
>> +             printk(KERN_ERR "failed to allocate knfsd %s stats hashtable\n", which);
>> +             /* struggle on... */
>> +             return;
>> +     }
>> +     printk(KERN_INFO "knfsd %s stats hashtable, %u entries\n", which, sh->sh_size);
>
> Eh.  Make it a dprintk?

I don't think a dprintk() is useful.  This happens once during nfsd
module load, so there's no chance for an admin to enable dprintks
before it happens.

>  Or maybe expose this in the nfsd filesystem if
> it's not already?

There will be two files in the nfsd filesystem.  I'll remove the printk()


>> +     if (sh->sh_hash != NULL) {
>
> Drop the NULL check.

Done.


>> + * Drop a reference to a hentry, deleting the hentry if this
>> + * was the last reference.  Does it's own locking using the
>
> s/it's/its/

Done.

>
> (Contending for the nitpick-of-the-day award.)

:-)


>> +
>> +     if (atomic_read(&se->se_refcount)) {
>> +             /*
>> +              * We lost a race getting the write lock, and
>> +              * now there's a reference again.  Whatever.
>> +              */
>
> Some kind of atomic_dec_and_lock() might close the race.

Yep.  I'll address this when I rethink locking.

>> +
>> +typedef struct nfsd_stats_hash               nfsd_stats_hash_t;
>> +typedef struct nfsd_stats_hentry     nfsd_stats_hentry_t;
>
> Absent unusual circumstances, standard kernel style is to drop the
> typedefs and use "struct nfsd_stats_{hash,hentry}" everywhere.

Sorry, it's a disgusting habit and I'll stop it right now.

-- 
Greg.
