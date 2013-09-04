Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61563 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761920Ab3IDDRn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Sep 2013 23:17:43 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Neil Brown <neilb@suse.de>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: Re: [PATCH/RFC]  Don't try to recover NFS locks when they are lost.
Date: Wed, 4 Sep 2013 03:17:41 +0000
Message-ID: <prdkh3xt7a0mituyt7v2xpmw.1378264657975@email.android.com>
References: <20130815123604.47755509@notabene.brown>
	<1378233802.6410.34.camel@leira.trondhjem.org>,<20130904104946.1be45e52@notabene.brown>
In-Reply-To: <20130904104946.1be45e52@notabene.brown>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

That looks better, but we still want to send the delegation stateid in the case where we have both a lock and a delegation.

Cheers
  Trond

Sent from my tablet.

NeilBrown <neilb@suse.de> wrote:


On Tue, 3 Sep 2013 18:43:23 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-08-15 at 12:36 +1000, NeilBrown wrote:
> >
> > When an NFS (V4 specifically) client loses contact with the server it can
> > lose any locks that it holds.
> > Currently when it reconnects to the server it simply tries to reclaim
> > those locks.  This might succeed even though some other client has held and
> > released a lock in the mean time.  So the first client might think the file
> > is unchanged, but it isn't.  This isn't good.
> >
> > If, when recovery happens, the locks cannot be claimed because some other
> > client still holds the lock, then  we get a message in the kernel logs, but
> > the client can still write.  So two clients can both think they have a lock
> > and can both write at the same time.  This is equally not good.
> >
> > There was a patch a while ago
> >   http://comments.gmane.org/gmane.linux.nfs/41917
> >
> > which tried to address some of this, but it didn't seem to go anywhere.
> > That patch would also send a signal to the process.  That might be useful
> > but I'm really just interested in failing the writes.
> > For NFSv4 (unlike v2/v3) there is a strong link between the lock and the
> > write request so we can fairly easily fail an IO of the lock is gone.
> >
> > The patch below attempts to do this.  Does it make sense?
> > Because this is a fairly big change I introduces a module parameter
> > "recover_locks" which defaults to true (the current behaviour) but can be set
> > to "false" to tell the client not to try to recover things that were lost.
> >
> > Comments?
>
> I think this patch is close to being usable. A couple of questions,
> though:
>
>      1. What happens if another process' open() causes us to receive a
>         delegation after NFS_LOCK_LOST has been set on our lock stateid,
>         but before we call nfs4_set_rw_stateid()?

Good point.  I think we need to check for NFS_LOCK_LOST before checking for a
delegation.  Does the incremental patch below look OK?
It takes a spinlock in the case where we have a delegation and  hold some
locks which it didn't have to take before.  Is that a concern?


>      2. Shouldn't we clear NFS_LOCK_LOST at some point? It looks to me
>         as if a process which sees the EIO, and decides to recover by
>         calling close(), reopen()ing the file and then locking it again,
>         might find NFS_LOCK_LOST still being set.


NFS_LOCK_LOST is per nfs4_lock_state which should be freed by
nfs4_fl_release_lock().
So when the files is closed, the locks a dropped, and the structure holding
the NFS_LOCK_LOST flag will go away.
Or did I miss something?

Thanks,
NeilBrown


diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4d103ff..bb1fd5d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1040,10 +1040,11 @@ static int nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
                fmode_t fmode, const struct nfs_lockowner *lockowner)
 {
-       int ret = 0;
+       int ret = nfs4_copy_lock_stateid(dst, state, lockowner);
+       if (ret == -EIO)
+               goto out;
        if (nfs4_copy_delegation_stateid(dst, state->inode, fmode))
                goto out;
-       ret = nfs4_copy_lock_stateid(dst, state, lockowner);
        if (ret != -ENOENT)
                goto out;
        ret = nfs4_copy_open_stateid(dst, state);
