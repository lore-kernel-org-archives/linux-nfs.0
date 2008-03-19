From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/2] nfs: don't ignore return value from
	nfs_pageio_add_request
Date: Wed, 19 Mar 2008 11:14:35 -0400
Message-ID: <1205939675.8388.61.camel@heimdal.trondhjem.org>
References: <1205936000-9336-1-git-send-email-iisaman@citi.umich.edu>
	 <1205936000-9336-2-git-send-email-iisaman@citi.umich.edu>
	 <1205938696.8388.53.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35439 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756510AbYCSTfa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 15:35:30 -0400
In-Reply-To: <1205938696.8388.53.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-19 at 10:58 -0400, Trond Myklebust wrote:
> On Wed, 2008-03-19 at 10:13 -0400, Fred Isaman wrote:
> > Ignoring the return value from nfs_pageio_add_request can cause deadlocks.
> > 
> > In read path:
> >   call nfs_pageio_add_request from readpage_async_filler
> >   assume at this point that there are requests already in desc, that
> >     can't be merged with the current request.
> >   so nfs_pageio_doio is fired up to clear out desc.
> >   assume something goes wrong in setting up the io, so desc->pg_error is set.
> >   This causes nfs_pageio_add_request to return 0, *WITHOUT* adding the original
> >     request.
> >   BUT, since return code is ignored, readpage_async_filler assumes it has
> >     been added, and does nothing further, leaving page locked.
> >   do_generic_mapping_read will eventually call lock_page, resulting in deadlock
> 
> BTW: the same bug may occur in nfs_readpage_async(). I'll add a fixup
> for that to your patch.

Oops... My bad. nfs_readpage_async() appears to be fine. I'll go have
another coffee...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
