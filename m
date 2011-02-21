Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:63534 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755384Ab1BUAyR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Feb 2011 19:54:17 -0500
Received: by iwn8 with SMTP id 8so1374765iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 20 Feb 2011 16:54:17 -0800 (PST)
Date: Mon, 21 Feb 2011 02:54:17 +0200
Message-ID: <AANLkTikGAHBEKxeQqVegtW3VmZcJScMPkzGOyWfvD9h7@mail.gmail.com>
Subject: 2.6.32, NFSv4, "Stale NFS file handle" problem
From: Nick Patavalis <npat@efault.net>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I don't know if this is an NFS bug, but seems a lot like it... My
server-host exports a few NTFS filesystems (read-only exports) using
NFSv4. Two client-hosts mount these file-systems.

Client A runs 2.6.31, and client B 2.6.32. Client A works fine. Client
B, while it initially mounts everything ok, and for some time
everything works ok (or so it seems), after a while it starts
returning "Stale NFS file hande" errors for random files and
directories. Client A NEVER returns stale errors, EVEN after a server
reboot.

Has anyone seen something like this before? Is it a known problem?
Who's to blame (probably me... but anyway).

Any additional information you may require I will try to provide.

Thanks in advance.
/npat

Some additional details:

On the server

  # uname -a

  Linux moviesserver 2.6.32-26-generic #48-Ubuntu SMP Wed Nov 24
  09:00:03 UTC 2010 i686 GNU/Linux

  # cat /etc/exports

  /mnt             *(fsid=0,ro,crossmnt,async,insecure,
                               all_squash,no_subtree_check)
  /mnt/mydvds8     *(fsid=1,ro,async,insecure,all_squash,no_subtree_check)
  /mnt/mydvds1-2-7 *(fsid=2,ro,async,insecure,all_squash,no_subtree_check)
  /mnt/mydvds3-4   *(fsid=3,ro,async,insecure,all_squash,no_subtree_check)
  /mnt/mydvds5-6   *(fsid=4,ro,async,insecure,all_squash,no_subtree_check)
  /mnt/mydvds9     *(fsid=5,ro,async,insecure,all_squash,no_subtree_check)

The /mnt/mydvdsXXX directories are mountpoints of NTFS filesystems on
USB drives (if this has any relevance).

On client A:

  # uname -a

  Linux XBMCLive 2.6.31-17-generic #54-Ubuntu SMP Thu Dec 10 16:20:31
  UTC 2009 i686 GNU/Linux

  # cat /etc/fstab

  192.168.150.2:/mydvds1-2-7 /mnt/thepat/mydvds1-2-7 nfs4 soft,ro,
      nocto,actimeo=300 0 0
  192.168.150.2:/mydvds3-4 /mnt/thepat/mydvds3-4 nfs4 soft,ro,
      nocto,actimeo=300 0 0
  192.168.150.2:/mydvds5-6 /mnt/thepat/mydvds5-6 nfs4
soft,ro,nocto,actimeo=300 0 0
  192.168.150.2:/mydvds8 /mnt/thepat/mydvds8 nfs4 soft,ro,
      nocto,actimeo=300 0 0
  192.168.150.2:/mydvds9 /mnt/thepat/mydvds9 nfs4 soft,ro,
      nocto,actimeo=300 0 0

On Client B:

  # uname -a

  Linux azure 2.6.32-28-generic #55-Ubuntu SMP Mon Jan 10 21:21:01 UTC
  2011 i686 GNU/Linux

  # cat /etc/fstab

  ... same as above ...

On client B, after the problem appears:

  # ls /mnt/thepat/*
  /mnt/thepat/mydvds1-2-7:
  msdownld.tmp  MyDVDs1  MyDVDs2  MyDVDs7  RECYCLER  System Volume Information

  /mnt/thepat/mydvds3-4:
  MyDVDs3  MyDVDs4  RECYCLER  System Volume Information
  ls: cannot access /mnt/thepat/mydvds5-6/MyDVDs5: Stale NFS file handle
  ls: cannot access /mnt/thepat/mydvds5-6/MyDVDs6: Stale NFS file handle
  ls: cannot access /mnt/thepat/mydvds5-6/Recycled: Stale NFS file handle
  ls: cannot access /mnt/thepat/mydvds5-6/RECYCLER: Stale NFS file handle
  ls: cannot access /mnt/thepat/mydvds5-6/System Volume Information:
Stale NFS file handle

  ... etc ...
