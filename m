Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36187 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907Ab2BOQQc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 11:16:32 -0500
Date: Wed, 15 Feb 2012 11:16:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Tom Tucker <tom@ogc.us>, trond.myklebust@netapp.com,
        dan.carpenter@oracle.com, linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] svcrdma: Cleanup sparse warnings in the svcrdma module
Message-ID: <20120215161625.GC12490@fieldses.org>
References: <1329260485-16994-1-git-send-email-tom@ogc.us>
 <20120214232342.GB23916@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120214232342.GB23916@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK, Tom could you fix up these small things and repost?

--b.

On Tue, Feb 14, 2012 at 11:23:42PM +0000, Al Viro wrote:
> On Tue, Feb 14, 2012 at 05:01:25PM -0600, Tom Tucker wrote:
> 
> > -	if (ch->rc_discrim == 0)
> > +	if (ch->rc_discrim == xdr_zero)
> 
> Mostly, ACK, modulo this and similar sillyness.  sparse is just fine with
> use of constant 0 in bitwise contexts; it's also just fine with use of
> bitwise in logical ones.
> 
> > +	nchunks = ntohl(ary->wc_nchunks);
> >  	if (((unsigned long)&ary->wc_array[0] +
> > -	     (sizeof(struct rpcrdma_write_chunk) * ary->wc_nchunks)) >
> > +	     (sizeof(struct rpcrdma_write_chunk) * nchunks)) >
> 
> BTW, this still can overflow.  With less painful consequences than before that
> patch, but...
> 
> > -			BUG_ON(0 == virt_to_page(vec[i].iov_base));
> > +			BUG_ON(NULL == virt_to_page(vec[i].iov_base));
> 
> Egads...  What, "!virt_to_page(...)" would have been too pedestrian?
