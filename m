Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54522 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819Ab0LIEhT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 23:37:19 -0500
Subject: Re: System CPU increasing on idle 2.6.36
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101208223622.GA3796@hostway.ca>
References: <20101208212505.GA18192@hostway.ca>
	 <1291845189.3067.31.camel@heimdal.trondhjem.org>
	 <20101208223622.GA3796@hostway.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Dec 2010 23:37:17 -0500
Message-ID: <1291869437.2821.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-08 at 14:36 -0800, Simon Kirby wrote:
> On Wed, Dec 08, 2010 at 04:53:09PM -0500, Trond Myklebust wrote:
> 
> > Possibly a side effect of the fs/fs-writeback.c changes in 2.6.36? You
> > do appear to be hitting a lot of spinlock contention, but I suspect that
> > a lot of it is coming from writeback_sb_inodes, writeback_single_inode
> > and queue_io, all of which seem unnaturally high on your stats above.
> > 
> > I don't see how you can be seeing no traffic on the wire. You are
> > certainly hitting some page writeout (0.2% nfs_pageio_doio).
> 
> It really seems to not be doing anything.  I ran nfsstat -Zcv for 5
> minutes, and the only non-zero counters are rpc calls and authrefrsh,
> even though perf top shows similar profiles the whole time.

That sounds like a bug in nfsstat, then. As I said, your trace results
definitely indicate that you are doing page writeout. I'd cross check
using wireshark...

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

