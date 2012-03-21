Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58094 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760217Ab2CUUlo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 16:41:44 -0400
Date: Wed, 21 Mar 2012 16:41:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v10 1/8] nfsd: convert nfs4_client->cl_cb_flags to a
 generic flags field
Message-ID: <20120321204142.GB12309@fieldses.org>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
 <1332337929-18580-2-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1332337929-18580-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 21, 2012 at 09:52:02AM -0400, Jeff Layton wrote:
> @@ -2779,12 +2780,6 @@ static void
>  nfs4_set_claim_prev(struct nfsd4_open *open, bool has_session)
>  {
>  	open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
> -	/*
> -	 * On a 4.1+ client, we don't create a state record for a client
> -	 * until it performs RECLAIM_COMPLETE:
> -	 */
> -	if (!has_session)
> -		open->op_openowner->oo_owner.so_client->cl_firststate = 1;

That doesn't look right.  Sure you didn't mean to just make that a
set_bit, at least for now?

--b.
