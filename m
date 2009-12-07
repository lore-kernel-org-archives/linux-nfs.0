From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 4/5] nfs41: New NFS4CLNT_RECLAIM_COMPLETE_PENDING state
Date: Mon, 07 Dec 2009 13:11:50 -0500
Message-ID: <1260209510.32136.23.camel@localhost>
References: <C742809B.10A71%ricardo.labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28315 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964869AbZLGSLp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 13:11:45 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB7IBps5023864
	for <linux-nfs@vger.kernel.org>; Mon, 7 Dec 2009 10:11:51 -0800 (PST)
In-Reply-To: <C742809B.10A71%ricardo.labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-12-07 at 09:51 -0800, Labiaga, Ricardo wrote: 
> On 12/7/09 6:47 AM, "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
> 
> > Looking at the code, I'm not convinced that we need a separate
> > 'RECLAIM_COMPLETE_PENDING' state. It should be pretty much identical to
> > the existing NFS4CLNT_RECLAIM_REBOOT state.
> > The only difference is that in the NFSv4.1 case we want to be able to
> > call RECLAIM_COMPLETE even in the case where we have no state to
> > reclaim.
> > 
> 
> Yes, this would be the case if my interpretation of the spec is incorrect.

I don't see how your interpretation changes anything w.r.t the question
of whether we need a new state or not. You can still set
NFS4CLNT_RECLAIM_REBOOT and get it to do the right thing...

Trond
