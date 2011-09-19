Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41759 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752085Ab1ISBJ6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Sep 2011 21:09:58 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH] pnfsblock: add missing rpc_put_mount and path_put
Date: Sun, 18 Sep 2011 18:09:40 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B356025@SACMVEXC2-PRD.hq.netapp.com>
In-reply-to: <4E707FC1.2020607@tonian.com>
References: <1315945452-1575-1-git-send-email-rees@umich.edu> <4E707FC1.2020607@tonian.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Benny Halevy" <bhalevy@tonian.com>, "Jim Rees" <rees@umich.edu>,
        "Peng Tao" <bergwolf@gmail.com>
Cc: <linux-nfs@vger.kernel.org>, "peter honeyman" <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Benny Halevy [mailto:bhalevy@tonian.com]
> Sent: Wednesday, September 14, 2011 6:20 AM
> To: Jim Rees; Peng Tao; Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org; peter honeyman
> Subject: Re: [PATCH] pnfsblock: add missing rpc_put_mount and path_put
> 
> We need to decide on a process here :)
> If we would like to maintain a staging tree in front of Trond's then
to simplify
> merging and rebasing, fixes to code that's already upstream, i.e. in
linux-2.6
> or already queued in nfs-2.6, that we decide to send to Trond ahead of
> queue need to be queued in front of stuff in the staging tree and the
latter
> should be rebased on top of them.

Unless we're talking about a large merge, I tend to prefer patches. They
are much easier to review...

Cheers
  Trond
