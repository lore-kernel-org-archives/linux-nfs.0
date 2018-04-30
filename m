Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:37498 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751938AbeD3PRo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Apr 2018 11:17:44 -0400
Date: Mon, 30 Apr 2018 11:17:41 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: NeilBrown <neilb@suse.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, Lai Jiangshan <jiangshanlai@gmail.com>,
        Josh Triplett <josh@joshtriplett.org>,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/4] NFS: slight optimization for walking list for
 delegations
Message-ID: <20180430111741.561df374@gandalf.local.home>
In-Reply-To: <152506269054.7246.3941740801391514623.stgit@noble>
References: <152506256513.7246.13171564155614823841.stgit@noble>
        <152506269054.7246.3941740801391514623.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Apr 2018 14:31:30 +1000
NeilBrown <neilb@suse.com> wrote:

> There are 3 places where we walk the list of delegations
> for an nfs_client.
> In each case there are two nested loops, one for nfs_servers
> and one for nfs_delegations.
> 
> When we find an interesting delegation we try to get an active
> reference to the server.  If that fails, it is pointless to
> continue to look at the other delegation for the server as
> we will never be able to get an active reference.
> So instead of continuing in the inner loop, break out
> and continue in the outer loop.
> ---
>  fs/nfs/delegation.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 1819d0d0ba4b..af32365894c8 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -495,7 +495,7 @@ int nfs_client_return_marked_delegations(struct nfs_client *clp)
>  			if (!nfs_delegation_need_return(delegation))
>  				continue;
>  			if (!nfs_sb_active(server->super))
> -				continue;
> +				break;

For documentation purposes, what I usually do when using a break inside
a inner loop to continue the outer loop, I add a comment:

				break; /* continue outer loop */

Such that in the future, people will know exactly what you mean and
don't think it's a bug (thinking it breaks out of all loops).

-- Steve


>  			inode = nfs_delegation_grab_inode(delegation);
>  			if (inode == NULL) {
>  				rcu_read_unlock();
> @@ -887,7 +887,7 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp)
>  						&delegation->flags) == 0)
>  				continue;
>  			if (!nfs_sb_active(server->super))
> -				continue;
> +				break;
>  			inode = nfs_delegation_grab_inode(delegation);
>  			if (inode == NULL) {
>  				rcu_read_unlock();
> @@ -995,7 +995,7 @@ void nfs_reap_expired_delegations(struct nfs_client *clp)
>  						&delegation->flags) == 0)
>  				continue;
>  			if (!nfs_sb_active(server->super))
> -				continue;
> +				break;
>  			inode = nfs_delegation_grab_inode(delegation);
>  			if (inode == NULL) {
>  				rcu_read_unlock();
> 

