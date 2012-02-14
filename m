Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:32923 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757285Ab2BNXXv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Feb 2012 18:23:51 -0500
Date: Tue, 14 Feb 2012 23:23:42 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Tom Tucker <tom@ogc.us>
Cc: bfields@fieldses.org, trond.myklebust@netapp.com, dan.carpenter@oracle.com,
        linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] svcrdma: Cleanup sparse warnings in the svcrdma module
Message-ID: <20120214232342.GB23916@ZenIV.linux.org.uk>
References: <1329260485-16994-1-git-send-email-tom@ogc.us>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1329260485-16994-1-git-send-email-tom@ogc.us>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 14, 2012 at 05:01:25PM -0600, Tom Tucker wrote:

> -	if (ch->rc_discrim == 0)
> +	if (ch->rc_discrim == xdr_zero)

Mostly, ACK, modulo this and similar sillyness.  sparse is just fine with
use of constant 0 in bitwise contexts; it's also just fine with use of
bitwise in logical ones.

> +	nchunks = ntohl(ary->wc_nchunks);
>  	if (((unsigned long)&ary->wc_array[0] +
> -	     (sizeof(struct rpcrdma_write_chunk) * ary->wc_nchunks)) >
> +	     (sizeof(struct rpcrdma_write_chunk) * nchunks)) >

BTW, this still can overflow.  With less painful consequences than before that
patch, but...

> -			BUG_ON(0 == virt_to_page(vec[i].iov_base));
> +			BUG_ON(NULL == virt_to_page(vec[i].iov_base));

Egads...  What, "!virt_to_page(...)" would have been too pedestrian?
