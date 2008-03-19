From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/2] nfs: don't ignore return value from
	nfs_pageio_add_request
Date: Wed, 19 Mar 2008 10:58:16 -0400
Message-ID: <1205938696.8388.53.camel@heimdal.trondhjem.org>
References: <1205936000-9336-1-git-send-email-iisaman@citi.umich.edu>
	 <1205936000-9336-2-git-send-email-iisaman@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:46066 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755169AbYCSTgi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 15:36:38 -0400
In-Reply-To: <1205936000-9336-2-git-send-email-iisaman@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-19 at 10:13 -0400, Fred Isaman wrote:
> Ignoring the return value from nfs_pageio_add_request can cause deadlocks.
> 
> In read path:
>   call nfs_pageio_add_request from readpage_async_filler
>   assume at this point that there are requests already in desc, that
>     can't be merged with the current request.
>   so nfs_pageio_doio is fired up to clear out desc.
>   assume something goes wrong in setting up the io, so desc->pg_error is set.
>   This causes nfs_pageio_add_request to return 0, *WITHOUT* adding the original
>     request.
>   BUT, since return code is ignored, readpage_async_filler assumes it has
>     been added, and does nothing further, leaving page locked.
>   do_generic_mapping_read will eventually call lock_page, resulting in deadlock

BTW: the same bug may occur in nfs_readpage_async(). I'll add a fixup
for that to your patch.

Cheers
  Trond

