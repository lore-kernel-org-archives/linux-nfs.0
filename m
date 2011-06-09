Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34695 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897Ab1FISNH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 14:13:07 -0400
Subject: Re: [PATCH 2/3] NFS: Cleanup of the nfs_pageio code in preparation
 for a pnfs bugfix
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
Date: Thu, 09 Jun 2011 14:13:15 -0400
In-Reply-To: <4DF10804.7000104@panasas.com>
References: <1307399551-17489-1-git-send-email-Trond.Myklebust@netapp.com>
		 <1307399551-17489-2-git-send-email-Trond.Myklebust@netapp.com>
		 <4DEEDECF.4090104@panasas.com>
	 <1307637452.20245.11.camel@lade.trondhjem.org>
	 <4DF10804.7000104@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1307643195.25848.10.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-06-09 at 10:51 -0700, Boaz Harrosh wrote:

> 1. We will then need to go through the ld in .pg_init

No. I'll fix nfs_pageio_init_read() and friends by replacing
pnfs_get_read_ops() by something more appropriate.

> 2. What happens in the none pnfs-IO error case pg_bsize will need to be
>    saved and restored to MDS value.

Yes, but if you are falling back to read/write-through-mds, then you
need to re-run the coalescing _anyway_, since the total length of the
request needs to fit in an rsize/wsize sized request.

> 3. At least in objects there is no such constant limit, it all depends on
>    the layout, start and end. I thought the all point of .pg_test was
>    exactly for avoiding a constant pg_bsize. (This is what we had before)
> 4. All "the tests make no sense..." should be moved to the no-pnfs case
>    please point these you found out, we'll need to fix them.
> 
> Please understand that for none-files layouts pg_bsize is when IO goes
> through MDS only.

As I said, I don't see how fallback to MDS can work correctly today for
the objects case for arbitrary values of rsize/wsize.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

