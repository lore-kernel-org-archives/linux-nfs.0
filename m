Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:43510 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbaG3B2G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:28:06 -0400
Received: by mail-qg0-f53.google.com with SMTP id q107so673859qgd.12
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:28:05 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 29 Jul 2014 21:28:00 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 03/38] nfsd: Add a struct nfs4_file field to struct
 nfs4_stid
Message-ID: <20140729212800.5133178a@tlielax.poochiereds.net>
In-Reply-To: <20140730005433.GA26316@fieldses.org>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
	<1406666061-14175-4-git-send-email-jlayton@primarydata.com>
	<20140730005433.GA26316@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 29 Jul 2014 20:54:33 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> As of this patch (11138e6bbd34 in my tree) I see
> 
> [   90.780805] BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
> [   90.780812] IP: [<ffffffff810b5ed8>] __lock_acquire+0x158/0x1e20
> [   90.780822] PGD 0 
> [   90.780826] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [   90.780832] Modules linked in: rpcsec_gss_krb5 nfsd auth_rpcgss oid_registry nfs_acl lockd sunrpc
> [   90.780846] CPU: 1 PID: 3926 Comm: nfsd Not tainted 3.16.0-rc2-00092-g11138e6 #3162
> [   90.780849] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [   90.780852] task: ffff880021465690 ti: ffff880021468000 task.ti: ffff880021468000
> [   90.780855] RIP: 0010:[<ffffffff810b5ed8>]  [<ffffffff810b5ed8>] __lock_acquire+0x158/0x1e20
> [   90.780860] RSP: 0018:ffff88002146bb40  EFLAGS: 00010002
> [   90.780863] RAX: 0000000000000001 RBX: 0000000000000020 RCX: 0000000000000000
> [   90.780865] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000020
> [   90.780867] RBP: ffff88002146bbf0 R08: 0000000000000001 R09: 0000000000000000
> [   90.780870] R10: ffff880021465690 R11: 0000000000000001 R12: 0000000000000000
> [   90.780872] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
> [   90.780875] FS:  0000000000000000(0000) GS:ffff88003fa80000(0000) knlGS:0000000000000000
> [   90.780878] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   90.780885] CR2: 0000000000000020 CR3: 000000002d477000 CR4: 00000000000006e0
> [   90.780887] Stack:
> [   90.780889]  00000000000220cf 0000000000000000 00000000000220ce ffff8800a20ce000
> [   90.780895]  0000000000000001 0000000000000046 0000000000000000 0000000000000000
> [   90.780900]  0000000000000001 0000000000000000 ffff88002146bbf8 0000000000000046
> [   90.780907] Call Trace:
> [   90.780916]  [<ffffffff810b5cec>] ? debug_check_no_locks_freed+0xbc/0x150
> [   90.780923]  [<ffffffff810b83dd>] lock_acquire+0x8d/0x130
> [   90.780946]  [<ffffffffa0113385>] ? __nfs4_file_put_access+0x5/0xe0 [nfsd]
> [   90.780966]  [<ffffffffa01133c0>] __nfs4_file_put_access+0x40/0xe0 [nfsd]
> [   90.781003]  [<ffffffffa0113385>] ? __nfs4_file_put_access+0x5/0xe0 [nfsd]
> [   90.781025]  [<ffffffffa01134a5>] nfs4_file_put_access+0x45/0x70 [nfsd]
> [   90.781046]  [<ffffffffa011353b>] release_all_access+0x6b/0x80 [nfsd]
> [   90.781068]  [<ffffffffa011a79f>] nfsd4_close+0x22f/0x360 [nfsd]
> [   90.781086]  [<ffffffffa011a6e9>] ? nfsd4_close+0x179/0x360 [nfsd]
> [   90.781100]  [<ffffffffa01083cf>] nfsd4_proc_compound+0x4ff/0x810 [nfsd]
> [   90.781109]  [<ffffffffa00f41bb>] nfsd_dispatch+0xbb/0x200 [nfsd]
> [   90.781129]  [<ffffffffa0010460>] svc_process_common+0x440/0x6d0 [sunrpc]
> [   90.781147]  [<ffffffffa00107f3>] svc_process+0x103/0x170 [sunrpc]
> [   90.781156]  [<ffffffffa00f3a47>] nfsd+0x167/0x1e0 [nfsd]
> [   90.781164]  [<ffffffffa00f38e5>] ? nfsd+0x5/0x1e0 [nfsd]
> [   90.781173]  [<ffffffffa00f38e0>] ? nfsd_destroy+0xd0/0xd0 [nfsd]
> [   90.781178]  [<ffffffff8108e2d4>] kthread+0xe4/0x100
> [   90.781184]  [<ffffffff8108e1f0>] ? kthread_create_on_node+0x200/0x200
> [   90.781189]  [<ffffffff81a1acec>] ret_from_fork+0x7c/0xb0
> [   90.781194]  [<ffffffff8108e1f0>] ? kthread_create_on_node+0x200/0x200
> [   90.781197] Code: 7d 28 0f 85 c3 15 00 00 4d 85 ed 75 49 66 0f 1f 44 00 00 45 31 e4 48 8d 65 d8 44 89 e0 5b 41 5c 41 5d 41 5e 41 5f 5d c3 0f 1f 00 <48> 81 3b a0 f5 47 82 b8 00 00 00 00 44 0f 44 c0 41 83 ff 01 44 
> [   90.781263] RIP  [<ffffffff810b5ed8>] __lock_acquire+0x158/0x1e20
> [   90.781268]  RSP <ffff88002146bb40>
> [   90.781271] CR2: 0000000000000020
> [   90.781274] ---[ end trace d1ba2642f707d537 ]---
> 
> I haven't yet done anything further to look into it.--b.
> 

I think the bug is actually in the previous patch. In
nfsd4_close_open_stateid, I changed it to call release_all_access
*after* putting the nfs4_file.

It's a recent regression that gets fixed up later in the series so I
didn't spot it in testing. Looks like it crept in when I refactored
this code to address HCH's comments. Mea culpa...

I have it fixed now in my tree, and some of the later patches in the
series need fixups to deal with merge conflicts due to that change.

Bruce, would you prefer that I repost the set?

> 
> On Tue, Jul 29, 2014 at 04:33:46PM -0400, Jeff Layton wrote:
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > All stateids are associated with a nfs4_file. Let's consolidate.
> > Start by replacing delegation->dl_file with the dl_stid.sc_file
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  fs/nfsd/nfs4callback.c |  2 +-
> >  fs/nfsd/nfs4state.c    | 21 ++++++++++-----------
> >  fs/nfsd/state.h        |  2 +-
> >  3 files changed, 12 insertions(+), 13 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > index 8574c708cf8c..e0be57b0f79b 100644
> > --- a/fs/nfsd/nfs4callback.c
> > +++ b/fs/nfsd/nfs4callback.c
> > @@ -337,7 +337,7 @@ static void encode_cb_recall4args(struct xdr_stream *xdr,
> >  	p = xdr_reserve_space(xdr, 4);
> >  	*p++ = xdr_zero;			/* truncate */
> >  
> > -	encode_nfs_fh4(xdr, &dp->dl_file->fi_fhandle);
> > +	encode_nfs_fh4(xdr, &dp->dl_stid.sc_file->fi_fhandle);
> >  
> >  	hdr->nops++;
> >  }
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 7ade2499294a..c52ca9f65b4c 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -515,10 +515,6 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
> >  
> >  static void nfs4_free_deleg(struct nfs4_stid *stid)
> >  {
> > -	struct nfs4_delegation *dp = delegstateid(stid);
> > -
> > -	if (dp->dl_file)
> > -		put_nfs4_file(dp->dl_file);
> >  	kmem_cache_free(deleg_slab, stid);
> >  	atomic_long_dec(&num_delegations);
> >  }
> > @@ -636,12 +632,15 @@ out_dec:
> >  void
> >  nfs4_put_stid(struct nfs4_stid *s)
> >  {
> > +	struct nfs4_file *fp = s->sc_file;
> >  	struct nfs4_client *clp = s->sc_client;
> >  
> >  	if (!atomic_dec_and_test(&s->sc_count))
> >  		return;
> >  	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
> >  	s->sc_free(s);
> > +	if (fp)
> > +		put_nfs4_file(fp);
> >  }
> >  
> >  static void nfs4_put_deleg_lease(struct nfs4_file *fp)
> > @@ -677,7 +676,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
> >  static void
> >  unhash_delegation_locked(struct nfs4_delegation *dp)
> >  {
> > -	struct nfs4_file *fp = dp->dl_file;
> > +	struct nfs4_file *fp = dp->dl_stid.sc_file;
> >  
> >  	lockdep_assert_held(&state_lock);
> >  
> > @@ -3097,10 +3096,10 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
> >  
> >  void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
> >  {
> > -	struct nfs4_client *clp = dp->dl_stid.sc_client;
> > -	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> > +	struct nfsd_net *nn = net_generic(dp->dl_stid.sc_client->net,
> > +					  nfsd_net_id);
> >  
> > -	block_delegations(&dp->dl_file->fi_fhandle);
> > +	block_delegations(&dp->dl_stid.sc_file->fi_fhandle);
> >  
> >  	/*
> >  	 * We can't do this in nfsd_break_deleg_cb because it is
> > @@ -3508,7 +3507,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_file *fp, int flag)
> >  
> >  static int nfs4_setlease(struct nfs4_delegation *dp)
> >  {
> > -	struct nfs4_file *fp = dp->dl_file;
> > +	struct nfs4_file *fp = dp->dl_stid.sc_file;
> >  	struct file_lock *fl;
> >  	struct file *filp;
> >  	int status = 0;
> > @@ -3573,7 +3572,7 @@ nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
> >  	get_nfs4_file(fp);
> >  	spin_lock(&state_lock);
> >  	spin_lock(&fp->fi_lock);
> > -	dp->dl_file = fp;
> > +	dp->dl_stid.sc_file = fp;
> >  	if (!fp->fi_lease) {
> >  		spin_unlock(&fp->fi_lock);
> >  		spin_unlock(&state_lock);
> > @@ -4167,7 +4166,7 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
> >  		if (status)
> >  			goto out;
> >  		if (filpp) {
> > -			file = dp->dl_file->fi_deleg_file;
> > +			file = dp->dl_stid.sc_file->fi_deleg_file;
> >  			if (!file) {
> >  				WARN_ON_ONCE(1);
> >  				status = nfserr_serverfault;
> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > index 32c466265ac1..c856601c15f6 100644
> > --- a/fs/nfsd/state.h
> > +++ b/fs/nfsd/state.h
> > @@ -85,6 +85,7 @@ struct nfs4_stid {
> >  	unsigned char sc_type;
> >  	stateid_t sc_stateid;
> >  	struct nfs4_client *sc_client;
> > +	struct nfs4_file *sc_file;
> >  	void (*sc_free)(struct nfs4_stid *);
> >  };
> >  
> > @@ -93,7 +94,6 @@ struct nfs4_delegation {
> >  	struct list_head	dl_perfile;
> >  	struct list_head	dl_perclnt;
> >  	struct list_head	dl_recall_lru;  /* delegation recalled */
> > -	struct nfs4_file	*dl_file;
> >  	u32			dl_type;
> >  	time_t			dl_time;
> >  /* For recall: */
> > -- 
> > 1.9.3
> > 


-- 
Jeff Layton <jlayton@primarydata.com>
