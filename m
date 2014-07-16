Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54006 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934637AbaGPSas (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 14:30:48 -0400
Date: Wed, 16 Jul 2014 11:30:47 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 09/10] nfsd: Fix delegation revocation
Message-ID: <20140716183047.GA19002@infradead.org>
References: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
 <1405521125-2303-10-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405521125-2303-10-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -/* Called under the state lock. */

You're removing a comment hat only becomes true after your patch :)

But I agree that it's obsolete, the lockdep_assert_held is better than
the comment.

> @@ -685,11 +686,10 @@ static void revoke_delegation(struct nfs4_delegation *dp)
>  	struct nfs4_client *clp = dp->dl_stid.sc_client;
>  
>  	if (clp->cl_minorversion == 0)
> -		destroy_delegation(dp);
> +		destroy_revoked_delegation(dp);

Seems a little confusing as we didn't turn the code into a REVOKED_DELEG
stateid type yet, but given that destroy_revoked_delegation doesn't
care this is probably fine.

>  	else {
> -		unhash_delegation(dp);
>  		dp->dl_stid.sc_type = NFS4_REVOKED_DELEG_STID;
> -		list_add(&dp->dl_recall_lru, &clp->cl_revoked);
> +		list_move(&dp->dl_recall_lru, &clp->cl_revoked);

What protects access to cl_revoked, btw?

Otherwise this looks fine to me,

Reviewed-by: Christoph Hellwig <hch@lst.de>

(would have been a little nicer to read if you had kept
destroy_revoked_delegation, otherwise diff obsfucates the fact that it
didn't change at all..
