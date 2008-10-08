From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 12/15] RPC/RDMA: correct a 5 second pause on
	reconnecting to an idle server.
Date: Wed, 08 Oct 2008 14:04:20 -0400
Message-ID: <1223489060.7361.38.camel@localhost>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
	 <20081008154856.1336.18339.stgit@tmt3.nane.netapp.com>
	 <1223487348.7361.20.camel@localhost>
	 <RTPCLUEXC1-PRDjbDt300000076@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:33085 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbYJHSEX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 14:04:23 -0400
In-Reply-To: <RTPCLUEXC1-PRDjbDt300000076-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-10-08 at 13:51 -0400, Talpey, Thomas wrote:
> At 01:35 PM 10/8/2008, Trond Myklebust wrote:
> >Hmm... Why not rather do the same as the socket code: have the
> >disconnect handler paths that don't require exponential backoff just
> >reset xprt->reestablish_timeout to 0?
> 
> Because we do want a non-zero reestablishment timeout in general, and
> the RDMA client has not implemented a connection backoff. So in effect
> the value is constant for this code, and I thought treating it as such is
> the safer fix. 
> 
> I'm not 100% convinced the TCP code is correct, btw. It appears to
> zero out the reestablish timeout on idle-disconnect, but it's not obvious
> to me where it sets it back to a non-zero value. It does try to double
> it in xs_connect() though! :-)

The TCP code sets the xprt->reestablish_timeout to a non-zero value
whenever the _server_ closes the connection (i.e. if ever we enter a
SYN_SENT state followed by a reset, a CLOSE_WAIT state or a CLOSING
state.
Why would the RDMA client want to do anything different?


