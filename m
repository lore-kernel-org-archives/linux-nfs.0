Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:44194 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752350AbaCNBFG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2014 21:05:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1WOGYZ-0004kw-PQ
	for linux-nfs@vger.kernel.org; Fri, 14 Mar 2014 02:05:04 +0100
Received: from 173-228-91-47.dsl.static.sonic.net ([173.228.91.47])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2014 02:05:03 +0100
Received: from deepak.jagtap by 173-228-91-47.dsl.static.sonic.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2014 02:05:03 +0100
To: linux-nfs@vger.kernel.org
From: Deepak Jagtap <deepak.jagtap@maxta.com>
Subject: Nfs server per mount point IOPS limit
Date: Fri, 14 Mar 2014 00:59:10 +0000 (UTC)
Message-ID: <loom.20140314T015822-835@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I order to get performance stats with Linux nfs server and client, I ran 
following experiments:

Linux Nfs Server version 3: exporting ext3 filesystem directory.
Linux Nfs Client :  64 IO threads doing IO on nfs mount point .

I am doing random reads on 30GB sparse file (emty), to figure out how much 
max IOPS this IO stack supports.

I observed 30K random read IOPS using single client IO process. Nfs server 
is configured to spawn 64 threads, but not all nfs threads are busy in this 
case.

In order to maxout nfs server thread usage I spawn another IO process on the 
client doing IO though same mount point, but cumulative read IOPS stays same 
(15K IOPS per IO process)

But when I mount same export on another mount point on the same client, IOPS 
scale.
ie.

Nfs server exports /share/export directory.

NfsClient mounts:
MountPoint1: mount server:/share/export at  /mnt/exportMount1 
MountPoint2: mount server:/share/export at  /mnt/exportMount2

IOProcess1 does IO on MountPoint1 while IOProcess2 does IO on MountPoint2, 
reads in this case
scale and nfs server CPU usage doubles.

But if 2 IOProcesses use same mount point for IO then IOPS for each process 
drops to half.

Please advise if  I am hitting some per mount point limit in this case.
Also how can I figure out if bottleneck is on nfs client side or nfs server 
side.

Thanks & Regards,
Deepak

