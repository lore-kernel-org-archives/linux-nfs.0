Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38786 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806AbaFWNyU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 09:54:20 -0400
Date: Mon, 23 Jun 2014 06:54:18 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 002/104] NFSd: Avoid taking state_lock while holding
 inode lock in nfsd_break_one_deleg
Message-ID: <20140623135418.GA10464@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <1403189450-18729-3-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403189450-18729-3-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 19, 2014 at 10:49:08AM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> state_lock is a heavily contended global lock. We don't want to grab
> that while simultaneously holding the inode->i_lock
> Instead do the list manipulations from the work queue context prior to
> starting the rpc call.

The description should mention that a new lock is added to facilitate this.

>  void nfsd4_init_callback(struct nfsd4_callback *cb)
>  {
>  	INIT_WORK(&cb->cb_work, nfsd4_do_callback_rpc);
>  }

We still call nfsd4_init_callback for delegations after this patch,
and thus first initialize the work item to nfsd4_do_callback_rpc
and later overide it.  But I think initializing the work item
before queueing up the callback is pretty silly anyway, so I'd suggest
adding a patch before this one to just kill nfsd4_init_callback and
initialize the item in do_probe_callback and nfsd4_cb_recall directly.

> -static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
> +void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp)
>  {
>  	struct nfs4_client *clp = dp->dl_stid.sc_client;
>  	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
>  
> -	lockdep_assert_held(&state_lock);
> +	/*
> +	 * We can't do this in nfsd_break_deleg_cb because it is
> +	 * already holding inode->i_lock
> +	 */

Can't is a little too strong given that it did indeed work before.

