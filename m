Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41248 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937Ab1IUEWt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 00:22:49 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH 2/3] pnfs: introduce pnfs private workqueue
Date: Tue, 20 Sep 2011 21:22:47 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480227@SACMVEXC2-PRD.hq.netapp.com>
In-reply-to: <20110921002917.GA30770@merit.edu>
References: <1316488728-24912-1-git-send-email-rees@umich.edu> <1316488728-24912-3-git-send-email-rees@umich.edu> <1316558461.15093.4.camel@lade.trondhjem.org> <20110921002917.GA30770@merit.edu>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Jim Rees" <rees@umich.edu>
Cc: "Benny Halevy" <bhalevy@tonian.com>, <linux-nfs@vger.kernel.org>,
        "peter honeyman" <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Jim Rees [mailto:rees@umich.edu]
> Sent: Tuesday, September 20, 2011 8:29 PM
> To: Myklebust, Trond
> Cc: Benny Halevy; linux-nfs@vger.kernel.org; peter honeyman
> Subject: Re: [PATCH 2/3] pnfs: introduce pnfs private workqueue
> 
> Trond Myklebust wrote:
> 
>   On Mon, 2011-09-19 at 23:18 -0400, Jim Rees wrote:
>   > From: Peng Tao <bergwolf@gmail.com>
>   >
>   > For layoutdriver io done functions, default workqueue is not a
good place
> as
>   > the code is executed in IO path. So add a pnfs private workqueue
to
> handle
>   > them.
>   >
>   > Also change block and object layout code to make use of this
private
>   > workqueue.
>   >
> 
>   Wait, what????
> 
>   Why is the I/O path (i.e. the nfsiod queue) inappropriate for
>   layoutdriver io_done functions?
> 
> I thought you were the one who asked for this, here:
> http://www.spinics.net/lists/linux-nfs/msg22771.html
> 
> But looking back on it now, the IO path has changed and I can't tell
if the
> argument still holds.

You are reading too much into what I said. The fact that we shouldn't
use the 'hot' nfs/rpciod workqueues doesn't imply that we need a
completely separate pnfs workqueue. We already have plenty of generic
workqueues and even context threads: why aren't they sufficient?

Trond
