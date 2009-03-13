Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39193 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752339AbZCMVKO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Mar 2009 17:10:14 -0400
Subject: Re: Horrible NFS Client Performance During Heavy Server IO
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: David Rees <drees76@gmail.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <72dbd3150903131336m78526d4ao1308052d6233b70@mail.gmail.com>
References: <72dbd3150903131336m78526d4ao1308052d6233b70@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 13 Mar 2009 17:10:08 -0400
Message-Id: <1236978608.7265.41.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-03-13 at 13:36 -0700, David Rees wrote:
> I've been trying to troubleshoot/tune around a problem I have been
> experiencing where if the NFS server is under heavy write load (the
> disks are saturated), client side NFS performance drops to nearly 0.
> As soon as the load is lifted so that there is no significant IO wait
> time on the server, the clients start acting responsively again.
> 
> Server setup:
> Fedora 9 kernel 2.6.27.15-78.2.23.fc9.x86_64
> NFS tuning - none
> Disk system - 230GB SATA RAID1 array on a basic AACRAID adapter
> Dual XEONs, 8GB RAM
> Network GigE
> 
> Client setup:
> Fedora 10 kernel 2.6.27.19-170.2.35.fc10.x86_64
> NFS tuning - none
> Network GigE
> 
> Things I have tried:
> 
> I have tried playing with the disk scheduler, switching to deadline
> from cfq = no difference.
> I have tried playing with rsize/wsize settings on the client = no difference.
> 
> Steps to reproduce:
> 
> 1. Write a big file to the same partition that is exported on the server:
> dd if=/dev/zero of=/opt/export/bigfile bs=1M count=5000 conv=fdatasync
> 2. Write a small file to the same partition from the client:
> dd if=/dev/zero of=/opt/export/bigfile bs=16k count=8 conf=fdatasync

You don't need conv=fdatasync when writing to NFS. The close-to-open
cache consistency automatically guarantees fdatasync on close().

> I am seeing slightly less than 2kBps (yes, 1000-2000 bytes per second)
> from the client while this is happening.

UDP transport, or TCP? If the former, then definitely switch to the
latter, since you're probably pounding the server with unnecessary RPC
retries while it is busy with the I/O.

For the same reason, also make sure that -otimeo=600 (the default for
TCP).

Trond

