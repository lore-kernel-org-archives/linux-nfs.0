Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f67.google.com ([209.85.216.67]:48364 "EHLO
	mail-qa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbaGVRwJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 13:52:09 -0400
Received: by mail-qa0-f67.google.com with SMTP id v10so2433129qac.10
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 10:52:09 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 22 Jul 2014 13:52:06 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: bump dp->dl_time when unhashing delegation
Message-ID: <20140722135206.7dbfbac5@tlielax.poochiereds.net>
In-Reply-To: <20140722174552.GA27277@fieldses.org>
References: <1406047291-1279-1-git-send-email-jlayton@primarydata.com>
	<20140722174552.GA27277@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 22 Jul 2014 13:45:52 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jul 22, 2014 at 12:41:31PM -0400, Jeff Layton wrote:
> > There's a potential race between a lease break and DELEGRETURN call.
> > 
> > Suppose a lease break comes in and queues the workqueue job for a
> > delegation, but it doesn't run just yet. Then, a DELEGRETURN comes in
> > finds the delegation and calls destroy_delegation on it to unhash it and
> > put its primary reference.
> > 
> > Next, the workqueue job runs and queues the delegation back onto the
> > del_recall_lru list, issues the CB_RECALL and puts the final reference.
> > With that, the final reference to the delegation is put, but it's still
> > on the LRU list.
> > 
> > When we go to unhash a delegation, it's because we intend to get rid of
> > it soon afterward, so we don't want lease breaks to mess with it once
> > that occurs. Fix this by bumping the dl_time whenever we unhash a
> > delegation, to ensure that lease breaks don't monkey with it.
> 
> Makes sense, thanks.  Repeating from IRC: this fixes a regression from
> 02e1215f9f7 "nfsd: Avoid taking state_lock while holding inode lock in
> nfsd_break_one_deleg".  (In my tree only.)
> 
> --b.
> 
> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfsd/nfs4state.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 72da0d44e66b..a3a828d17563 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -660,6 +660,8 @@ unhash_delegation(struct nfs4_delegation *dp)
> >  
> >  	spin_lock(&state_lock);
> >  	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
> > +	/* Ensure that deleg break won't try to requeue it */
> > +	++dp->dl_time;
> >  	spin_lock(&fp->fi_lock);
> >  	list_del_init(&dp->dl_perclnt);
> >  	list_del_init(&dp->dl_recall_lru);
> > -- 
> > 1.9.3
> > 

Sorry, I think I sent you a version with an earlier description. Here's
the one I meant to send:

--------------------[snip]---------------------

[PATCH] nfsd: bump dl_time when unhashing delegation

There's a potential race between a lease break and DELEGRETURN call.

Suppose a lease break comes in and queues the workqueue job for a
delegation, but it doesn't run just yet. Then, a DELEGRETURN comes in
finds the delegation and calls destroy_delegation on it to unhash it and
put its primary reference.

Next, the workqueue job runs and queues the delegation back onto the
del_recall_lru list, issues the CB_RECALL and puts the final reference.
With that, the final reference to the delegation is put, but it's still
on the LRU list.

When we go to unhash a delegation, it's because we intend to get rid of
it soon afterward, so we don't want lease breaks to mess with it once
that occurs. Fix this by bumping the dl_time whenever we unhash a
delegation, to ensure that lease breaks don't monkey with it.

I believe this is a regression due to commit 02e1215f9f7 (nfsd: Avoid
taking state_lock while holding inode lock in nfsd_break_one_deleg).
Prior to that, the state_lock was held in the lm_break callback itself,
and that would have prevented this race.

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 72da0d44e66b..a3a828d17563 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -660,6 +660,8 @@ unhash_delegation(struct nfs4_delegation *dp)
 
 	spin_lock(&state_lock);
 	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
+	/* Ensure that deleg break won't try to requeue it */
+	++dp->dl_time;
 	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_recall_lru);
-- 
1.9.3

