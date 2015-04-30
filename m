Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44319 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbbD3Uf5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2015 16:35:57 -0400
Date: Thu, 30 Apr 2015 16:35:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] nfsd: fix callback restarts
Message-ID: <20150430203556.GA9509@fieldses.org>
References: <1430387365-24348-1-git-send-email-hch@lst.de>
 <1430387365-24348-3-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1430387365-24348-3-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good to me, just a changelog nit:

On Thu, Apr 30, 2015 at 11:49:24AM +0200, Christoph Hellwig wrote:
> Checking the rpc_client pointer is not a reliable way to detect a backchannel
> connetion failure, as the likelyhood of reusing the same slab object is
> very high.

I don't think that's true, if it's this comparison you're talking about:

> @@ -907,16 +900,21 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
>  			clp->cl_cb_session->se_cb_seq_nr);
>  	}
>  
> -	if (clp->cl_cb_client != task->tk_client) {
> -		/* We're shutting down or changing cl_cb_client; leave
> -		 * it to nfsd4_process_cb_update to restart the call if
> -		 * necessary. */

This is an rpc callback, so tk_client better still be allocated.
cl_cb_client too, since as far as I can tell that's never changed
without shutting down the rpc client first (which will wait for all
tasks to exit).

So I agree that this is wrong, but I think the reason it's actually
wrong is that the condition is just never true....

--b.
