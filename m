Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:35481 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715Ab1IUCot convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 22:44:49 -0400
From: <tao.peng@emc.com>
To: <Trond.Myklebust@netapp.com>
CC: <bhalevy@tonian.com>, <linux-nfs@vger.kernel.org>, <honey@citi.umich.edu>,
        <rees@umich.edu>
Date: Tue, 20 Sep 2011 22:44:27 -0400
Subject: RE: [PATCH 2/3] pnfs: introduce pnfs private workqueue
Message-ID: <F19688880B763E40B28B2B462677FBF805C4952916@MX09A.corp.emc.com>
References: <1316488728-24912-1-git-send-email-rees@umich.edu>
 <1316488728-24912-3-git-send-email-rees@umich.edu>
 <1316558461.15093.4.camel@lade.trondhjem.org>
 <20110921002917.GA30770@merit.edu>
In-Reply-To: <20110921002917.GA30770@merit.edu>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
> On Behalf Of Jim Rees
> Sent: Wednesday, September 21, 2011 8:29 AM
> To: Trond Myklebust
> Cc: Benny Halevy; linux-nfs@vger.kernel.org; peter honeyman
> Subject: Re: [PATCH 2/3] pnfs: introduce pnfs private workqueue
> 
> Trond Myklebust wrote:
> 
>   On Mon, 2011-09-19 at 23:18 -0400, Jim Rees wrote:
>   > From: Peng Tao <bergwolf@gmail.com>
>   >
>   > For layoutdriver io done functions, default workqueue is not a good place as
>   > the code is executed in IO path. So add a pnfs private workqueue to handle
>   > them.
>   >
>   > Also change block and object layout code to make use of this private
>   > workqueue.
>   >
> 
>   Wait, what????
> 
>   Why is the I/O path (i.e. the nfsiod queue) inappropriate for
>   layoutdriver io_done functions?
The current code uses the system_wq to handle io_done functions. If any function allocates memory in system_wq and causes dirty writeback in nfs path, the io_done function can never be called because it is after the original function in the system_wq. And you said that the rpciod/nfsiod is not the ideal place because of memory allocation. So I suggested pnfs private workqueue and Benny agreed on it.

> 
> I thought you were the one who asked for this, here:
> http://www.spinics.net/lists/linux-nfs/msg22771.html
> 
> But looking back on it now, the IO path has changed and I can't tell if the
> argument still holds.
I believe it still holds. The recollapse path still involves memory allocation.

Cheers,
Tao
