Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47481 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932353Ab1JRQ07 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 12:26:59 -0400
Subject: Re: The patch that wouldn't die
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 18 Oct 2011 09:26:43 -0700
In-Reply-To: <20111018134935.GA17831@umich.edu>
References: <20111018134935.GA17831@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1318955203.3213.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixed. I haven't yet cut an official nfs-for-3.2, so I've just rebased
nfs-for-next and removed that particular patch.

Cheers
  Trond


On Tue, 2011-10-18 at 09:49 -0400, Jim Rees wrote: 
> Boaz, try to remain calm.
> 
> Trond, please remove this patch from your nfs-for-next branch.  I can send a
> revert patch if you like.
> 
> Uh-oh, I see it's been sent to stable too.
> 
> commit f0574a5592deb1f99fa583c525d01e7fa131f430
> Author: Peng Tao <bergwolf@gmail.com>
> Date:   Thu Sep 22 21:50:13 2011 -0400
> 
>     pnfsblock: init pg_bsize properly
>     
>     pg_bsize is server->wsize/rsize by default. We would want to use the lseg
>     length.
>     
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Cc: stable@kernel.org [3.0]
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Explanation follows:
> 
> Date: Fri, 23 Sep 2011 08:22:45 -0400
> From: Jim Rees <rees@umich.edu>
> Subject: Re: [PATCH 06/10] pnfsblock: init pg_bsize properly
> To: Boaz Harrosh <bharrosh@panasas.com>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
>         peter honeyman <honey@citi.umich.edu>
> 
> Boaz Harrosh wrote:
> 
>   On 09/23/2011 04:50 AM, Jim Rees wrote:
>   > From: Peng Tao <bergwolf@gmail.com>
>   >
>   > pg_bsize is server->wsize/rsize by default. We would want to use the lseg
>   > length.
>   >
>   > Signed-off-by: Peng Tao <peng_tao@emc.com>
>   > Signed-off-by: Jim Rees <rees@umich.edu>
> 
>   If you want to get lazy about this patch and take the easy way out.
>   The least you can do is supply the same fix to that other place
>   that has the same bug.
> 
>   This is not nice. You have identified a deficiency in the generic
>   layer, You know that objects would have the same bug, (because I told you)
>   and you just don't care. I have spent plenty of times slaving over
>   blocks code when changing or fixing generic layer. (And Benny even more
>   then me)
> 
>   And when you will actually send a patch that does exactly the same in
>   two places, which access only generic members, you might see that it
>   might be better to fix it in a single place at the generic layer.
> 
>   NACK. I'm ok with getting lazy like below, but only if you also
>   add the same code to objio_osd.c
> 
> Sorry, I sent the wrong patch.  Trond, please drop this one.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

