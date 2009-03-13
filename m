Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:1408 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbZCMUmC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2009 16:42:02 -0400
Received: by wf-out-1314.google.com with SMTP id 28so638114wfa.4
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2009 13:42:00 -0700 (PDT)
Date: Fri, 13 Mar 2009 13:36:22 -0700
Message-ID: <72dbd3150903131336m78526d4ao1308052d6233b70@mail.gmail.com>
Subject: Horrible NFS Client Performance During Heavy Server IO
From: David Rees <drees76@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've been trying to troubleshoot/tune around a problem I have been
experiencing where if the NFS server is under heavy write load (the
disks are saturated), client side NFS performance drops to nearly 0.
As soon as the load is lifted so that there is no significant IO wait
time on the server, the clients start acting responsively again.

Server setup:
Fedora 9 kernel 2.6.27.15-78.2.23.fc9.x86_64
NFS tuning - none
Disk system - 230GB SATA RAID1 array on a basic AACRAID adapter
Dual XEONs, 8GB RAM
Network GigE

Client setup:
Fedora 10 kernel 2.6.27.19-170.2.35.fc10.x86_64
NFS tuning - none
Network GigE

Things I have tried:

I have tried playing with the disk scheduler, switching to deadline
from cfq = no difference.
I have tried playing with rsize/wsize settings on the client = no difference.

Steps to reproduce:

1. Write a big file to the same partition that is exported on the server:
dd if=/dev/zero of=/opt/export/bigfile bs=1M count=5000 conv=fdatasync
2. Write a small file to the same partition from the client:
dd if=/dev/zero of=/opt/export/bigfile bs=16k count=8 conf=fdatasync

I am seeing slightly less than 2kBps (yes, 1000-2000 bytes per second)
from the client while this is happening.

It really looks like the nfs daemons on the server just get no
priority when compared to the local process.

Any ideas?  This is something I have noticed for quite some time.
Only thing I can think of trying is to upgrade the disk array so that
the disks are no longer a bottleneck.

-Dave
