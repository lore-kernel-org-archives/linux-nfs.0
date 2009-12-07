From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [PATCH 4/5] nfs41: New NFS4CLNT_RECLAIM_COMPLETE_PENDING state
Date: Mon, 7 Dec 2009 13:41:30 -0800
Message-ID: <273FE88A07F5D445824060902F70034408A1A7F8@SACMVEXC1-PRD.hq.netapp.com>
References: <1260209510.32136.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12016 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965064AbZLGVku convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 16:40:50 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB7LeuuX010784
	for <linux-nfs@vger.kernel.org>; Mon, 7 Dec 2009 13:40:56 -0800 (PST)
In-Reply-To: <1260209510.32136.23.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Myklebust, Trond
> Sent: Monday, December 07, 2009 10:12 AM
> To: Labiaga, Ricardo
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: [PATCH 4/5] nfs41: New NFS4CLNT_RECLAIM_COMPLETE_PENDING
> state
> 
> On Mon, 2009-12-07 at 09:51 -0800, Labiaga, Ricardo wrote:
> > On 12/7/09 6:47 AM, "Trond Myklebust" <Trond.Myklebust@netapp.com>
> wrote:
> >
> > > Looking at the code, I'm not convinced that we need a separate
> > > 'RECLAIM_COMPLETE_PENDING' state. It should be pretty much
identical
> to
> > > the existing NFS4CLNT_RECLAIM_REBOOT state.
> > > The only difference is that in the NFSv4.1 case we want to be able
to
> > > call RECLAIM_COMPLETE even in the case where we have no state to
> > > reclaim.
> > >
> >
> > Yes, this would be the case if my interpretation of the spec is
> incorrect.
> 
> I don't see how your interpretation changes anything w.r.t the
question
> of whether we need a new state or not. You can still set
> NFS4CLNT_RECLAIM_REBOOT and get it to do the right thing...
> 

Agreed, I was trying to avoid calling nfs4_do_reclaim() and friends when
there was no work to do.  I agree the optimization does not warrant the
extra state complexity since NFS4CLNT_RECLAIM_REBOOT will indeed do the
job.

I'll make the change after we reach agreement on the NFSv4 IETF list.

- ricardo
