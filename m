Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39935 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753650Ab2BOTDN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 14:03:13 -0500
Date: Wed, 15 Feb 2012 14:03:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Tucker <tom@opengridcomputing.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Tom Tucker <tom@ogc.us>,
        trond.myklebust@netapp.com, dan.carpenter@oracle.com,
        linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] svcrdma: Cleanup sparse warnings in the svcrdma module
Message-ID: <20120215190308.GB14687@fieldses.org>
References: <1329260485-16994-1-git-send-email-tom@ogc.us>
 <20120214232342.GB23916@ZenIV.linux.org.uk>
 <20120215161625.GC12490@fieldses.org>
 <4F3BE6B0.2090200@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F3BE6B0.2090200@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 15, 2012 at 11:09:04AM -0600, Tom Tucker wrote:
> On 2/15/12 10:16 AM, J. Bruce Fields wrote:
> >OK, Tom could you fix up these small things and repost?
> 
> Sure, but just to be certain I understand fully,
> 
> >--b.
> >
> >On Tue, Feb 14, 2012 at 11:23:42PM +0000, Al Viro wrote:
> >>On Tue, Feb 14, 2012 at 05:01:25PM -0600, Tom Tucker wrote:
> >>
> >>>-	if (ch->rc_discrim == 0)
> >>>+	if (ch->rc_discrim == xdr_zero)
> 
> You don't want this? It is true that sparse didn't complain, I was
> simply making it obvious that this value is NBO and be consistent
> across the code. Other places were using xdr_zero.

Mainly it's a matter of "Al bothered to review it, and it sounded like a
reasonable request."

But, yes, I think I do agree with Al, a special constant for
network-order zero seems like mild overkill, I'd be happier removing it.

--b.

> 
> >>Mostly, ACK, modulo this and similar sillyness.  sparse is just fine with
> >>use of constant 0 in bitwise contexts; it's also just fine with use of
> >>bitwise in logical ones.
> >>
> >>>+	nchunks = ntohl(ary->wc_nchunks);
> >>>  	if (((unsigned long)&ary->wc_array[0] +
> >>>-	     (sizeof(struct rpcrdma_write_chunk) * ary->wc_nchunks))>
> >>>+	     (sizeof(struct rpcrdma_write_chunk) * nchunks))>
> >>BTW, this still can overflow.  With less painful consequences than before that
> >>patch, but...
> >>
> >>>-			BUG_ON(0 == virt_to_page(vec[i].iov_base));
> >>>+			BUG_ON(NULL == virt_to_page(vec[i].iov_base));
> >>Egads...  What, "!virt_to_page(...)" would have been too pedestrian?
> 
