Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55428 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754922Ab1JaNyc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 09:54:32 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH-RFC] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
Date: Mon, 31 Oct 2011 06:54:15 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7515@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <4EAE9B60.9040903@tonian.com>
References: <1319426747-2179-1-git-send-email-bergwolf@gmail.com> <4EAE9B60.9040903@tonian.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Benny Halevy" <bhalevy@tonian.com>, "Peng Tao" <bergwolf@gmail.com>
Cc: <linux-nfs@vger.kernel.org>, "Peng Tao" <peng_tao@emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@tonian.com]
> Sent: Monday, October 31, 2011 8:58 AM
> To: Peng Tao
> Cc: linux-nfs@vger.kernel.org; Myklebust, Trond; Peng Tao
> Subject: Re: [PATCH-RFC] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
> 
> On 2011-10-24 05:25, Peng Tao wrote:
> > Hi, Trond and Benny,
> >
> > The patch depends on the pnfs private workqueue for now. So I want
to
> > consult you about where to put the work. Is pnfs private workqueue
> > dropped? If yes, where should I put this kind of work?
> 
> I'll defer this to Trond.
> I'm OK with having a workqueue for pnfs.

I've already commented on this: I see no justification whatsoever for a
private pnfs workqueue.

Cheers
   Trond
