Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5456 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869Ab1IUEUO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 00:20:14 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH 2/3] pnfs: introduce pnfs private workqueue
Date: Tue, 20 Sep 2011 21:20:12 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480226@SACMVEXC2-PRD.hq.netapp.com>
In-reply-to: <F19688880B763E40B28B2B462677FBF805C4952916@MX09A.corp.emc.com>
References: <1316488728-24912-1-git-send-email-rees@umich.edu> <1316488728-24912-3-git-send-email-rees@umich.edu> <1316558461.15093.4.camel@lade.trondhjem.org> <20110921002917.GA30770@merit.edu> <F19688880B763E40B28B2B462677FBF805C4952916@MX09A.corp.emc.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: <tao.peng@emc.com>
Cc: <bhalevy@tonian.com>, <linux-nfs@vger.kernel.org>, <honey@citi.umich.edu>,
        <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: tao.peng@emc.com [mailto:tao.peng@emc.com]
> Sent: Tuesday, September 20, 2011 10:44 PM
> To: Myklebust, Trond
> Cc: bhalevy@tonian.com; linux-nfs@vger.kernel.org;
honey@citi.umich.edu;
> rees@umich.edu
> Subject: RE: [PATCH 2/3] pnfs: introduce pnfs private workqueue
> 
> 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org
> > [mailto:linux-nfs-owner@vger.kernel.org]
> > On Behalf Of Jim Rees
> > Sent: Wednesday, September 21, 2011 8:29 AM
> > To: Trond Myklebust
> > Cc: Benny Halevy; linux-nfs@vger.kernel.org; peter honeyman
> > Subject: Re: [PATCH 2/3] pnfs: introduce pnfs private workqueue
> >
> > Trond Myklebust wrote:
> >
> >   On Mon, 2011-09-19 at 23:18 -0400, Jim Rees wrote:
> >   > From: Peng Tao <bergwolf@gmail.com>
> >   >
> >   > For layoutdriver io done functions, default workqueue is not a
good
> place as
> >   > the code is executed in IO path. So add a pnfs private workqueue
to
> handle
> >   > them.
> >   >
> >   > Also change block and object layout code to make use of this
private
> >   > workqueue.
> >   >
> >
> >   Wait, what????
> >
> >   Why is the I/O path (i.e. the nfsiod queue) inappropriate for
> >   layoutdriver io_done functions?
> The current code uses the system_wq to handle io_done functions. If
any
> function allocates memory in system_wq and causes dirty writeback in
nfs
> path, the io_done function can never be called because it is after the
original
> function in the system_wq. And you said that the rpciod/nfsiod is not
the
> ideal place because of memory allocation. So I suggested pnfs private
> workqueue and Benny agreed on it.

You appear to be optimizing for a corner case. Why?

IOW: why do we need a whole new workqueue for something which is
supposed to be extremely rare? Why can't we just use standard keventd or
allocate a perfectly normal thread (e.g. the state recovery thread)?

Trond
