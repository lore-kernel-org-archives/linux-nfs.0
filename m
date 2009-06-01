From: Simon Kirby <sim@netnation.com>
Subject: Re: [Oops] EXT3 / journal / possibly NFS-tickled issues
Date: Mon, 1 Jun 2009 12:58:01 -0700
Message-ID: <20090601195801.GA23986@hostway.ca>
References: <20090529231455.GA14665@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:55781 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754754AbZFAT6D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jun 2009 15:58:03 -0400
In-Reply-To: <20090529231455.GA14665@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 29, 2009 at 04:14:55PM -0700, Simon Kirby wrote:

> Hello!  Happy Friday...
> 
> We have a Linux HA NFS "NAS" setup (with heartbeat et al) that has been
> backended with about 40 TB of storage.  LVM and AOE are in use, and
> there are about 40 1 TB EXT3 file systems.  The kernel is vanilla amd64
> 2.6.28.10 except that I've built DRBD (unused) and newer AOE into it
> (sorry).

Ok, I have now seen "EXT3 Inode ...: orphan list check failed!" on four
separate HA pairs (8 different boxes), the other three without AOE (using
DRBD instead).  One of them has never crashed or failed over, and has had
the FS mounted since mkfs.ext3 was run.  They are running 2.6.28.7.

I will try to set up a test box and reproduce this without DRBD or AOE,
but with AOE used in one case and DRBD in another, I think the problem
may be unrelated to them.  The common pattern here is lots of I/O via
knfsd (NFSv3).

I did not see this message on kernel 2.6.27 and older kernels.
Hopefully I can get a reproducible case easily enough.  Is anyone else
seeing this error?

Simon-
