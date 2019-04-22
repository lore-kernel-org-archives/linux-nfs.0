Return-Path: <SRS0=DK+G=SY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4390C10F11
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 20:03:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 92913204EC
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 20:03:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729924AbfDVUDQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Apr 2019 16:03:16 -0400
Received: from fieldses.org ([173.255.197.46]:46498 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729921AbfDVTqJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Apr 2019 15:46:09 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 169FF1C9D; Mon, 22 Apr 2019 15:46:08 -0400 (EDT)
Date:   Mon, 22 Apr 2019 15:46:08 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     slawek1211@gmail.com, neilb@suse.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] nfsd: wake blocked file lock waiters before
 sending callback
Message-ID: <20190422194608.GB25280@fieldses.org>
References: <20190422163424.19402-1-jlayton@kernel.org>
 <20190422163424.19402-3-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190422163424.19402-3-jlayton@kernel.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Apr 22, 2019 at 12:34:24PM -0400, Jeff Layton wrote:
> When a blocked NFS lock is "awoken" we send a callback to the server and
> then wake any hosts waiting on it. If a client attempts to get a lock
> and then drops off the net, we could end up waiting for a long time
> until we end up waking locks blocked on that request.
> 
> Add a new "prepare" phase for CB_NOTIFY_LOCK callbacks, and have it
> call locks_delete_block to wake any lock requests waiting on the
> one for which we're sending the callback before it is sent.

How about this for the wording of that last sentence:

	So, wake any other waiting lock requests before sending the
	callback.  Do this by calling locks_delete_block in a new
	"prepare" phase for CB_NOTIFY_LOCK callbacks.

Come to think of that, the second sentence is redundant with the code; I
think I'll just go with the first.

Committing with that.

Thanks for working this out, and thanks to Slawomir Pryczek for the
reproducer.

--b.

> 
> URL: https://bugzilla.kernel.org/show_bug.cgi?id=203363
> Fixes: 16306a61d3b7 ("fs/locks: always delete_block after waiting.")
> Reported-by: Slawomir Pryczek <slawek1211@gmail.com>
> Cc: Neil Brown <neilb@suse.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/nfs4state.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e87e15df2044..f056b1d3fecd 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -298,6 +298,14 @@ remove_blocked_locks(struct nfs4_lockowner *lo)
>  	}
>  }
>  
> +static void
> +nfsd4_cb_notify_lock_prepare(struct nfsd4_callback *cb)
> +{
> +	struct nfsd4_blocked_lock	*nbl = container_of(cb,
> +						struct nfsd4_blocked_lock, nbl_cb);
> +	locks_delete_block(&nbl->nbl_lock);
> +}
> +
>  static int
>  nfsd4_cb_notify_lock_done(struct nfsd4_callback *cb, struct rpc_task *task)
>  {
> @@ -325,6 +333,7 @@ nfsd4_cb_notify_lock_release(struct nfsd4_callback *cb)
>  }
>  
>  static const struct nfsd4_callback_ops nfsd4_cb_notify_lock_ops = {
> +	.prepare	= nfsd4_cb_notify_lock_prepare,
>  	.done		= nfsd4_cb_notify_lock_done,
>  	.release	= nfsd4_cb_notify_lock_release,
>  };
> -- 
> 2.20.1
