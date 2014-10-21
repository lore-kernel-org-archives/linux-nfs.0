Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:55919 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755156AbaJULQO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Oct 2014 07:16:14 -0400
Received: by mail-qc0-f175.google.com with SMTP id b13so727465qcw.20
        for <linux-nfs@vger.kernel.org>; Tue, 21 Oct 2014 04:16:09 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 21 Oct 2014 07:16:06 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: convert nfs4_file searches to use RCU
Message-ID: <20141021071606.17f2513f@tlielax.poochiereds.net>
In-Reply-To: <20141021104013.GC21863@infradead.org>
References: <1413541275-3884-1-git-send-email-jlayton@primarydata.com>
	<20141021104013.GC21863@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 21 Oct 2014 03:40:13 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Fri, Oct 17, 2014 at 06:21:15AM -0400, Jeff Layton wrote:
> > The global state_lock protects the file_hashtbl, and that has the
> > potential to be a scalability bottleneck.
> > 
> > Address this by making the file_hashtbl use RCU. Add a rcu_head to the
> > nfs4_file and use that when freeing ones that have been hashed.
> > 
> > Convert find_file to use a lockless lookup. Convert find_or_add_file to
> > attempt a lockless lookup first, and then fall back to doing the
> > "normal" locked search and insert if that fails to find anything.
> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfsd/nfs4state.c | 36 +++++++++++++++++++++++++++---------
> >  fs/nfsd/state.h     |  1 +
> >  2 files changed, 28 insertions(+), 9 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index e9c3afe4b5d3..9bd3bcfee3c2 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -280,15 +280,22 @@ static void nfsd4_free_file(struct nfs4_file *f)
> >  	kmem_cache_free(file_slab, f);
> >  }
> >  
> > +static void nfsd4_free_file_rcu(struct rcu_head *rcu)
> > +{
> > +	struct nfs4_file *fp = container_of(rcu, struct nfs4_file, fi_rcu);
> > +
> > +	nfsd4_free_file(fp);
> 
> You might as well kill the pointless nfsd4_free_file wrapper while
> you're at it.
> 

Hmm, ok. There is one place that still calls it, but we can just make
that use kmem_cache_free.

> > @@ -3313,12 +3320,19 @@ find_file_locked(struct knfsd_fh *fh)
> >  static struct nfs4_file *
> >  find_file(struct knfsd_fh *fh)
> >  {
> > -	struct nfs4_file *fp;
> > +	struct nfs4_file *fp, *ret = NULL;
> > +	unsigned int hashval = file_hashval(fh);
> >  
> > -	spin_lock(&state_lock);
> > -	fp = find_file_locked(fh);
> > -	spin_unlock(&state_lock);
> > -	return fp;
> > +	rcu_read_lock();
> > +	hlist_for_each_entry_rcu(fp, &file_hashtbl[hashval], fi_hash) {
> > +		if (nfsd_fh_match(&fp->fi_fhandle, fh)) {
> > +			if (atomic_inc_not_zero(&fp->fi_ref))
> > +				ret = fp;
> > +			break;
> > +		}
> > +	}
> > +	rcu_read_unlock();
> > +	return ret;
> 
> I think it would be better to just switch find_file_locked ti use
> hlist_for_each_entry_rcu instead of duplicating it.
> 

I'll have to think about that. We do have to do an atomic_inc_not_zero
if we're doing an unlocked search, but that's not really necessary if
the spinlock is held. I guess it won't hurt in that case, so we should
be able to merge the two functions. I'll respin and do that...

> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > index 8e85e07efce6..530470a35ecd 100644
> > --- a/fs/nfsd/state.h
> > +++ b/fs/nfsd/state.h
> > @@ -490,6 +490,7 @@ struct nfs4_file {
> >  	atomic_t		fi_access[2];
> >  	u32			fi_share_deny;
> >  	struct file		*fi_deleg_file;
> > +	struct rcu_head		fi_rcu;
> 
> Can we union this over a field that's guaranteed to be unused on
> a file that has been unhashed?
> 

Yeah, that's probably fine. Suggestions on what to union it with?

struct callback_head is two pointers, so maybe we can use one of the
list_heads (fi_delegations maybe?).

> 
> Also a slightly related question:  Is the small fixes size hash table
> still fine for the workloads where the RCU access matters?  It seems
> like we should aim for a more scalable data structure to look up the
> files.  It also irks me a bit how this duplicates the inode cache,
> which for some filesystems (e.g. XFS) already is very scalable.
> 

TBH, I haven't done any real performance measurements on this
hashtable. The main impetus for this patch was to clear the way for
some changes that I'm doing for some pnfsd-related work (I need to be
able to walk a list of nfs4_files w/o holding a spinlock).

I think it makes sense to allow searching for nfs4_files w/o holding
a lock. It's unlikely to hurt performance, and may help it.

If we do want to change to a different type of structure I'd be fine
with that, but would prefer that it be RCU-friendly. What sort of
structure did you have in mind?

Thanks for the review so far!
-- 
Jeff Layton <jlayton@primarydata.com>
