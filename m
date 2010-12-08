Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:55550 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752974Ab0LHWgZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Dec 2010 17:36:25 -0500
Date: Wed, 8 Dec 2010 14:36:22 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: System CPU increasing on idle 2.6.36
Message-ID: <20101208223622.GA3796@hostway.ca>
References: <20101208212505.GA18192@hostway.ca> <1291845189.3067.31.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291845189.3067.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 08, 2010 at 04:53:09PM -0500, Trond Myklebust wrote:

> Possibly a side effect of the fs/fs-writeback.c changes in 2.6.36? You
> do appear to be hitting a lot of spinlock contention, but I suspect that
> a lot of it is coming from writeback_sb_inodes, writeback_single_inode
> and queue_io, all of which seem unnaturally high on your stats above.
> 
> I don't see how you can be seeing no traffic on the wire. You are
> certainly hitting some page writeout (0.2% nfs_pageio_doio).

It really seems to not be doing anything.  I ran nfsstat -Zcv for 5
minutes, and the only non-zero counters are rpc calls and authrefrsh,
even though perf top shows similar profiles the whole time.

Simon-
