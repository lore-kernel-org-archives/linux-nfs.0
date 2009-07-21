From: Jeff Garzik <jeff@garzik.org>
Subject: Re: 2.6.31-rc3 nfsv4 client regression (oops)
Date: Tue, 21 Jul 2009 19:08:38 -0400
Message-ID: <4A664A76.5000902@garzik.org>
References: <4A5C3858.6070303@garzik.org> <1247571788.19099.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux NFS ML <linux-nfs@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40710 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756366AbZGUXIn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2009 19:08:43 -0400
In-Reply-To: <1247571788.19099.32.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> NFSv4: Fix an Oops in nfs4_free_lock_state
> 
> The oops http://www.kerneloops.org/raw.php?rawid=537858&msgid= appears to
> be due to the nfs4_lock_state->ls_state field being uninitialised. This
> happens if the call to nfs4_free_lock_state() is triggered at the end of
> nfs4_get_lock_state().
> 
> The fixe is to move the initialisation of ls_state into the allocator.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/nfs4state.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index b73c5a7..65ca8c1 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -553,6 +553,7 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
>  	INIT_LIST_HEAD(&lsp->ls_sequence.list);
>  	lsp->ls_seqid.sequence = &lsp->ls_sequence;
>  	atomic_set(&lsp->ls_count, 1);
> +	lsp->ls_state = state;
>  	lsp->ls_owner = fl_owner;
>  	spin_lock(&clp->cl_lock);
>  	nfs_alloc_unique_id(&clp->cl_lockowner_id, &lsp->ls_id, 1, 64);
> @@ -587,7 +588,6 @@ static struct nfs4_lock_state *nfs4_get_lock_state(struct nfs4_state *state, fl_
>  		if (lsp != NULL)
>  			break;
>  		if (new != NULL) {
> -			new->ls_state = state;
>  			list_add(&new->ls_locks, &state->lock_states);
>  			set_bit(LK_STATE_IN_USE, &state->flags);

Ping?  This is headed upstream, right?

This oops fix has lived outside the tree for at least a week now, and 
IMO needs to move upstream...

	Jeff



