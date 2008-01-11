From: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Subject: EBADCOOKIE problem?
Date: Thu, 10 Jan 2008 23:59:51 -0500
Message-ID: <20080111045951.GA20079@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv03.macroped.com ([74.52.9.226]:54869 "EHLO
	srv03.macroped.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbYAKFFK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jan 2008 00:05:10 -0500
Received: from newbie (c-75-67-251-249.hsd1.nh.comcast.net [75.67.251.249])
	(authenticated bits=0)
	by srv03.macroped.com (8.13.8/8.13.8) with ESMTP id m0B51eew017540
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jan 2008 00:01:40 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In testing, we're seeing a problem where an ls of a directory over NFSv3 
reports "File not found" for one of the sub-directories.  With some 
tracing turned on, I can see that there is an -EBADCOOKIE error returned 
from find_dirent().  The error is persistent; it doesn't go away with 
time.  I do have one report that says that by adding another file to the 
directory, the error went away.

The directory structure it something like the following:
    /mnt/lun43/storage/blobs
    /mnt/lun43/storage/pool-0
/mnt/lun43 is the mount point for the NFS share.  /mnt/lun43/storage is 
the working directory when ls is run.  The "blobs" directory is listed 
fine.  However, the pool-0 directory reported "File not found", and 
apparent has an bad cookie.

We'd be very grateful is someone with more knowledge of the Linux NFS 
client could take a look at this.  This problem has been reproducible 
(it seems to elude me, but my colleagues can cause it somewhat readily).

I captured the network traffic from the ls command using tcpdump and 
analyzed it with wireshark.  First, there is an ACCESS RPC for 
/mnt/lun43/storage.  Then there is a GETATTR RPC /mnt/lun43, followed by 
one for /mnt/lun43/storage.  That's it; the rest must be pulled from the 
client's cache, including the problematic cookie.

I have some debugging output available.  http://n01se.net/paste/zDk is 
the NFS debug output from running ls.  inode #2 is the /mnt/lun43 mount 
point.  inode #48001 is the /mnt/lun43/storage directory.

I also have NFS and RPC debug output from when the problem was 
reproduced on another client (and another server).  
http://n01se.net/paste/qUc is the output from stat-ing the 
storage/blobs/ directory under the mount point (/mnt/lun<something>/), 
which behaves normally.  inode #2 is the mount point.  I believe inode 
#80001 is the storage/ directory and inode #80002 is the storage/blobs/ 
directory.  http://n01se.net/paste/rdL is the output from stat-ing the 
storage/pool-0/ directory, which reports an error.

We do have one bit of speculation at to what could be causing the 
problem, but we're newbies to the Linux NFS client code.  What would 
happen if the /mnt/lun43/storage/blobs directory was created, then the 
client started reading the /mnt/lun43/storage/ directory, then the 
/mnt/lun43/storage/pool-0 directory was created, all within the same 
second (we are using ext3 on the server, so our mtime granularity is 
only one second).  Could that situation cause any problems?

I probably should have noted much earlier that we are using SLES10 SP1 
x86_64, which is based on a 2.6.16 kernel.

-- 
Bob Bell

-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.

