Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39983 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005Ab1FATjA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 15:39:00 -0400
Subject: Re: [PATCH] NFS: filelayout should use nfs_generic_pg_test
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        Weston Andros Adamson <dros@netapp.com>, trond@netapp.com,
        linux-nfs@vger.kernel.org
Date: Wed, 01 Jun 2011 15:38:58 -0400
In-Reply-To: <4DE69333.4020302@panasas.com>
References: <1306898310-9229-1-git-send-email-dros@netapp.com>
			<4DE5D287.603@panasas.com>
			<09816808-BA7B-4EAF-A18A-866B5A98BF25@netapp.com>
			<4DE65202.2010502@panasas.com>
		 <BANLkTi=Bwuuar76phVyEguB1Amqn4Q70Fw@mail.gmail.com>
		 <4DE68B59.3030402@panasas.com>
	 <1306955827.3873.60.camel@lade.trondhjem.org>
	 <4DE69333.4020302@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306957138.3873.75.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-06-01 at 22:29 +0300, Boaz Harrosh wrote: 
> On 06/01/2011 10:17 PM, Trond Myklebust wrote:
> > On Wed, 2011-06-01 at 21:56 +0300, Benny Halevy wrote:
> > 
> >> For pnfs, we need to ignore wsize, meaning we first need to try
> >> to coalesce the pages and then decide if we're going the nfs_flush_multi
> >> or the nfs_flush_one way, based on the coalesced length.
> > 
> > No! Ignoring the wsize is definitely wrong... If the stripe size is
> > larger than the 'maxwrite' recommended attribute, then the DS is allowed
> > to do a short write, in which case we have to resend.
> > 
> 
> As far as I could understand the current code, desc->bsize which derives
> from wsize/rsize is negotiated with the MDS. But the wsize in question
> is the DS's one. So I think in pnfs it is only the layout-driver that
> can check this properly against the filer in question. Only if IO is
> to go through MDS the bsize check is relevant.

There is no distinction between the MDS's idea of the wsize and the DS's
idea of the wsize. The DS has to support the same wsize as the MDS,
since the client has no way of querying the wsize from the DS (GETATTR
maxwrite is not on the allowed set of DS operations)...

> BTW: The BUG_ON() Andy hit, does not look like an hard bug to fix ;-)
> 
> > In any case, nfs_flush_multi and nfs_flush_one need a rewrite in order
> > to deal properly with O_DIRECT writes, and so I'm expecting to get rid
> > of the single nfs_page limit for the r/wsize<PAGE_SIZE case.
> > Please don't make any large changes to this code at this time.
> > 
> 
> Amen, Good riddance

:-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

