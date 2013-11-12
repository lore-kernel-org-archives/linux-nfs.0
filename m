Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:41878 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753978Ab3KLAPw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Nov 2013 19:15:52 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 11 Nov 2013 19:15:51 -0500
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id D9F366E803C
	for <linux-nfs@vger.kernel.org>; Mon, 11 Nov 2013 19:15:45 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAC0Fl7M60621054
	for <linux-nfs@vger.kernel.org>; Tue, 12 Nov 2013 00:15:47 GMT
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAC0FkBa016975
	for <linux-nfs@vger.kernel.org>; Mon, 11 Nov 2013 17:15:47 -0700
Date: Mon, 11 Nov 2013 18:15:45 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix a data corruption issue when
 retransmitting RPC calls
Message-ID: <20131112001545.GB31826@us.ibm.com>
References: <1384021209-2586-1-git-send-email-Trond.Myklebust@netapp.com>
 <20131111231541.GA31826@us.ibm.com>
 <1384212310.7614.29.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1384212310.7614.29.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond [Trond.Myklebust@netapp.com] wrote:
> On Mon, 2013-11-11 at 17:15 -0600, Malahal Naineni wrote:
> > Trond Myklebust [Trond.Myklebust@netapp.com] wrote:
> > > @@ -700,13 +707,20 @@ static int xs_tcp_send_request(struct rpc_task *task)
> > >  	xs_pktdump("packet data:",
> > >  				req->rq_svec->iov_base,
> > >  				req->rq_svec->iov_len);
> > > +	/* Don't use zero copy if this is a resend. If the RPC call
> > > +	 * completes while the socket holds a reference to the pages,
> > > +	 * then we may end up resending corrupted data.
> > > +	 */
> > > +	if (task->tk_flags & RPC_TASK_SENT)
> > 
> > How about RPC_WAS_SENT() ?
> 
> <shrug>that evaluates to the same</shrug>

Yes, but what is the point of having a macro then?

Regards, Malahal.

