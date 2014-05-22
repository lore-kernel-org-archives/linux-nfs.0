Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43365 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbaEVT7h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:59:37 -0400
Date: Thu, 22 May 2014 15:59:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] NFSD: restrict PF_LESS_THROTTLE to loop-back
 requests.
Message-ID: <20140522195935.GG25423@fieldses.org>
References: <20140512012120.20840.68685.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140512012120.20840.68685.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 12, 2014 at 11:22:47AM +1000, NeilBrown wrote:
> As PF_LESS_THROTTLE now has a slightly broader meaning it makes sense
> to restrict it to only the times it is actually needed - when write
> requests come from the local host.

Both look good to me, thanks.  Applying for 3.16.

--b.

> 
> Thanks,
> NeilBrown
> 
> ---
> 
> NeilBrown (2):
>       SUNRPC: track whether a request is coming from a loop-back interface.
>       nfsd: Only set PF_LESS_THROTTLE when really needed.
> 
> 
>  fs/nfsd/nfssvc.c                |    6 ------
>  fs/nfsd/vfs.c                   |   12 ++++++++++++
>  include/linux/sunrpc/svc.h      |    1 +
>  include/linux/sunrpc/svc_xprt.h |    1 +
>  net/sunrpc/sunrpc.h             |   13 +++++++++++++
>  net/sunrpc/svcsock.c            |    5 +++++
>  6 files changed, 32 insertions(+), 6 deletions(-)
> 
> -- 
> Signature
> 
