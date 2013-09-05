Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:38893 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704Ab3IERSx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Sep 2013 13:18:53 -0400
Received: from smtp6-g21.free.fr (smtp6-g21.free.fr [212.27.42.6])
	by smtpfb2-g21.free.fr (Postfix) with ESMTP id 1D49FD1A2FF
	for <linux-nfs@vger.kernel.org>; Thu,  5 Sep 2013 19:18:48 +0200 (CEST)
Received: from harpe.intellique.com (unknown [82.225.196.72])
	by smtp6-g21.free.fr (Postfix) with ESMTP id 8FD6182425
	for <linux-nfs@vger.kernel.org>; Thu,  5 Sep 2013 19:17:58 +0200 (CEST)
Date: Thu, 5 Sep 2013 19:18:00 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: linux-nfs@vger.kernel.org
Subject: Hard to debug NFS loss of connectivity
Message-ID: <20130905191800.1c75b2fb@harpe.intellique.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi list, I have a serious problem I've never met before. Here is the
setup:

The NFS server is running Debian 6 amd64 but with a plain vanilla 3.2.50
kernel. it shares a large 81 TB volume (XFS over LVM on hardware RAID6)
through nfs without any particular options. Here is a glimpse
of /etc/exports:

/mnt/raid 10.1.1.0/255.255.255.128(fsid=1,rw,no_root_squash,async,no_subtree_check)

On the other side is a VMWare ESX VM running Ubuntu 12.04LTS, kernel 3.2.0-52 Ubuntu 
amd64 mounting the share. From the fstab:

10.1.1.99:/mnt/raid          /server         nfs  rw,hard,intr            0    0

The problem is as follow: stat'ing files on the VM makes the 
NFS connection drop. For instance:

find /server -type f -ls

It works for a while, then stops responding. The NFS mount is frozen. 
The network link is OK; I still can ssh from the server to the VM 
and back, I can wget from the VM to the server, ping the server 
from the VM, etc. Only NFS is affected.

Restarting NFS on the server does nothing to unfreeze the mount. 
Using nfs4 instead of nfs3 does nothing. The only remedy is to reboot the VM.
There isn't any error in dmesg, /var/log/syslog or 
/var/log/messages in the VM nor the server.

I've tried rebooting the server on a 3.9.7 kernel. Same thing. 
Of course there isn't any data corruption of any sort. 
Running "find /mnt/raid -type f -ls" on the server works 
perfectly and lists about 25000 files without the slightest trouble.

It works equally well if I mount the NFS share on the server itself.


Now it's becoming crazier: When I run the find command as
previously said, it freezes always on the same file, for
instance :

/server/folder1/folder2/folder3/folder4/.svn/somefile

However, if after a fresh reboot I do

stat /server/folder1/folder2/folder3/folder4/.svn/somefile

no problem. Even doing this:

cd /server/folder1/folder2/folder3/folder4/ && find . -type f -ls

works. However this

cd /server/folder1/folder2/folder3/ && find . -type f -ls

doesn't fly. It freezes at exactly the same point.
In the first test (running directly from /server) it
freezes after successfully listing 10000 files. In the last
test it freezes after only 25 files. 
So apparently it's not about the number of files.


Now I'm stuck. Out of going through tcpdump, I have absolutely 
not the faintest idea about what's going on, except I tend to 
think that's some Ubuntu kernel bug.

Any hint, idea, etc would be extremely welcome. Even some
debugging method less painful than digging through huge 
tcpdumps would be nice :)

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
