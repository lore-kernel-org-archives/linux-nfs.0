Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:52301 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932323AbcJaKqy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2016 06:46:54 -0400
Date: Mon, 31 Oct 2016 11:46:41 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        List Linux Kernel Mailing <linux-kernel@vger.kernel.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>
Subject: Re: [PATCH v2] NFSv4: replace seqcount_t with a seqlock_t
Message-ID: <20161031104641.3rdkonbyxgs6azec@linutronix.de>
References: <20161021164727.24485-1-bigeasy@linutronix.de>
 <20161028210511.k7hrsfxovti7gqtu@linutronix.de>
 <747E2CCB-3D83-40FD-8B31-46AB5A5E8592@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <747E2CCB-3D83-40FD-8B31-46AB5A5E8592@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2016-10-28 22:24:52 [+0000], Trond Myklebust wrote:
> > diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> > index 5f4281ec5f72..a442d9867942 100644
> > --- a/fs/nfs/nfs4state.c
> > +++ b/fs/nfs/nfs4state.c
> > @@ -1497,8 +1498,18 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
> > 	 * recovering after a network partition or a reboot from a
> > 	 * server that doesn't support a grace period.
> > 	 */
> > +	/*
> > +	 * XXX
> > +	 * This mutex is wrong. It protects against multiple writer. However
> 
> There is only 1 recovery thread per client/server pair, which is why we know there is only a single writer. No need for a mutex here.

This isn't documented but it should.

> > +	 * write_seqlock() should have been used for this task. This would avoid
> > +	 * preemption while the seqlock is held which is good because the writer
> > +	 * shouldn't be preempted as it would let the reader spin for no good
> 
> Recovery involves sending RPC calls to a server. There is no avoiding preemption if we have to recover state. The point of the sequence counter is to signal to processes that may have raced with this recovery thread that they may need to replay their locks.

Then the sequence counter is the wrong mechanism used here. As I
explained: the call can be preempted and once it is, the reader will
spin and waste cycles.
What is wrong with a rwsem? Are the reader not preemptible?

> > +	 * reason. There are a few memory allocations and kthread_run() so we
> > +	 * have this mutex now.
> > +	 */
> > +	mutex_lock(&sp->so_reclaim_seqlock_mutex);
> > +	write_seqcount_begin(&sp->so_reclaim_seqlock.seqcount);
> > 	spin_lock(&sp->so_lock);
> > -	raw_write_seqcount_begin(&sp->so_reclaim_seqcount);
> > restart:
> > 	list_for_each_entry(state, &sp->so_states, open_states) {
> > 		if (!test_and_clear_bit(ops->state_flag_bit, &state->flags))
> > @@ -1566,14 +1577,14 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
> > 		spin_lock(&sp->so_lock);
> > 		goto restart;
> > 	}
> > -	raw_write_seqcount_end(&sp->so_reclaim_seqcount);
> > 	spin_unlock(&sp->so_lock);
> > +	write_seqcount_end(&sp->so_reclaim_seqlock.seqcount);
> 
> This will reintroduce lockdep checking. We don’t need or want that...

Why isn't lockdep welcome? And what kind warning will it introduce? How
do I trigger this? I tried various things but never got close to this.

Sebastian
