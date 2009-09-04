From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Reading NFS file without copying to user-space?
Date: Fri, 04 Sep 2009 16:35:43 -0400
Message-ID: <1252096543.2402.4.camel@heimdal.trondhjem.org>
References: <4AA16F25.6050700@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:55472 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933903AbZIDUfp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 16:35:45 -0400
In-Reply-To: <4AA16F25.6050700@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-09-04 at 12:48 -0700, Ben Greear wrote:
> I'm trying to optimize a tool that should do NFS reads as fast as possible
> from a server in order to stress test the server.
> 
> Currently, I open the file as normal and read into a pre-allocated buffer.
> 
> This causes a copy of the data to user-space.
> 
> Is there any way to cause the nfs client logic to still request the file-read,
> but not actually copy anything to user-space?
> 
> Maybe some trick with mmap would do this?

How about using O_DIRECT? That just copies the data directly into user
pages and avoids all the overhead of using the page cache?

Note that you can combine O_DIRECT with aio in order to further increase
the speeds.

Cheers
  Trond

