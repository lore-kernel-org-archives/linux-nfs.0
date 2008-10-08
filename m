From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 03/15] RPC/RDMA: check selected memory registration
	mode at runtime.
Date: Wed, 08 Oct 2008 13:40:02 -0400
Message-ID: <1223487603.7361.24.camel@localhost>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
	 <20081008154723.1336.57976.stgit@tmt3.nane.netapp.com>
	 <1223486569.7361.8.camel@localhost>
	 <RTPCLUEXC1-PRD8yfog00000071@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50354 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754572AbYJHRkG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 13:40:06 -0400
In-Reply-To: <RTPCLUEXC1-PRD8yfog00000071-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-10-08 at 13:29 -0400, Talpey, Thomas wrote:
> At 01:22 PM 10/8/2008, Trond Myklebust wrote:
> >On Wed, 2008-10-08 at 11:47 -0400, Tom Talpey wrote:
> >> At transport creation, check for, and use, any local dma lkey.
> >> Then, check that the selected memory registration mode is in fact
> >> supported by the RDMA adapter selected for the mount. Fall back
> >> to best alternative if not.
> >> 
> >> Signed-off-by: Tom Talpey <talpey@netapp.com>
> >> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> >
> >I'm confused... Who is signing off on what? AFAICS, Tom Talpey is the
> >author and is the one sending this patch series. Where does Tom Tucker
> >come into the picture?
> 
> Tom Tucker wrote the initial version of some of the FRMR series, he
> had emailed them to linux-nfs a while back. I left his sign-off in place
> on those, as a co-author, and then signed for my own contributions.

Hmm... Tricky...

I'd do something along the lines of

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
[Heavily rewritten by Tom Talpey <talpey@netapp.com>]
Signed-off-by: Tom Talpey <talpey@netapp.com>

Maybe with an extra description of why you rewrote stuff in between the
square brackets.

