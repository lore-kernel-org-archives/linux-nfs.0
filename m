Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:49888 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754541AbaFNJnl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 14 Jun 2014 05:43:41 -0400
Date: Sat, 14 Jun 2014 10:37:14 +0100
From: Alex Bligh <alex@alex.org.uk>
Reply-To: Alex Bligh <alex@alex.org.uk>
To: linux-nfs@vger.kernel.org
cc: Alex Bligh <alex@alex.org.uk>
Subject: Peculiarity in handling NFSv4 mount paths with fsid=0
Message-ID: <EB04E1C061D36F087D431E74@nimrod.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've discovered I think a peculiarity with handling mount paths with fsid=0.
This is on Ubuntu Precise (old) but I've used 3.13 too with the same
problem.

I have an exports line like this:
/storage/local 
*(rw,sync,wdelay,nohide,crossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,fsid=0,anonuid=65534,anongid=65534)


And mounted a directory like this (which succeeded)

# mount -t nfs4 10.157.208.1:nfs-01 /mnt

And unmount did this:

# umount 10.157.208.1:nfs-01
/mnt was not found in /proc/mounts
/mnt was not found in /proc/mounts

Examination showed /proc/mounts contained the line:

10.157.208.1:/nfs-01 /mnt nfs4 
rw,relatime,vers=4.0,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=10.157.208.1,local_lock=none,addr=10.157.208.1 
0 0

Whereas the outptut of 'mount' contained the line:

10.157.208.1:nfs-01 on /mnt type nfs4 
(rw,addr=10.157.208.1,clientaddr=10.157.208.1)

There is a difference here between "/nfs-01" and "nfs-01".

This might merely be an annoying bug, where it not for the fact that as
far as I can tell the mount is now cannot be unmounted with userspace
tools. No amount of --fake and -n appears to help. System reset required.

Of course had I typed:

# mount -t nfs4 10.157.208.1:/nfs-01 /mnt

all would have been well.

I suspect something should be canonicalising the path consistently.

-- 
Alex Bligh
