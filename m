Return-Path: linux-nfs-owner@vger.kernel.org
Received: from trent.utfs.org ([94.185.90.103]:55238 "EHLO trent.utfs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965460Ab3HJHi6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Aug 2013 03:38:58 -0400
Date: Sat, 10 Aug 2013 00:28:30 -0700 (PDT)
From: Christian Kujau <lists@nerdbynature.de>
To: Karl Schmidt <karl@xtronics.com>
cc: Ben Hutchings <ben@decadent.org.uk>, 714974@bugs.debian.org,
        jfs-discussion@lists.sourceforge.net,
        Jonathan McDowell <noodles@earth.li>, linux-nfs@vger.kernel.org
Subject: Re: [Jfs-discussion] NFS 'readdir loop' error on JFS
In-Reply-To: <520554A5.3060401@xtronics.com>
Message-ID: <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org>
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Interesting stuff. Out of curiosity I just tried this myself, both client 
& server are virtual machines running Debian/stable (3.2.0-4-amd64) and I 
was able to reproduce this. A test case would be:

## server:
$ apt-get install nfs-kernel-server jfsutils
$ dd if=/dev/zero bs=1M count=256 > /var/test.img
$ losetup -f /var/test.img
$ mkfs.jfs /dev/loop0
$ mount -t jfs /dev/loop0  /mnt/disk
$ tar -C / -cf - usr/share | tar -C /mnt/disk/ -xf -
$ tail -1 /etc/exports
/mnt/disk  192.168.0.0/24(rw,sync,no_root_squash,no_subtree_check)
$ service nfs-kernel-server restart

## client
$ apt-get install nfs-common
$ showmount -e server | tail -1
/mnt/disk 192.168.0.0/24
$ tail -1 /etc/fstab
server:/mnt/disk /mnt/nfs  nfs  rsize=8192,wsize=8192,intr 0 0
$ mount /mnt/nfs
$ mount | tail -1
server:/mnt/disk on /mnt/nfs type nfs4 (rw,relatime,vers=4,rsize=8192,wsize=8192,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.0.137,minorversion=0,local_lock=none,addr=192.168.0.138)

$ tar -cf - /mnt/nfs/ > /dev/null
tar: Removing leading `/' from member names
tar: Removing leading `/' from hard link targets
tar: /mnt/nfs/usr/share/perl/5.14.2/Pod/: Cannot savedir: Too many levels of symbolic links
tar: Exiting with failure status due to previous errors

$ dmesg | tail
[   63.912327] RPC: Registered named UNIX socket transport module.
[   63.913801] RPC: Registered udp transport module.
[   63.914713] RPC: Registered tcp transport module.
[   63.915644] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   63.949485] FS-Cache: Loaded
[   63.972688] FS-Cache: Netfs 'nfs' registered for caching
[   63.993300] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[  284.733629] loop: module loaded
[  840.372846] NFS: directory 5.14.2/Pod contains a readdir loop.Please contact your server vendor.  The file: Simple has duplicate cookie 18
[  840.375842] NFS: directory 5.14.2/Pod contains a readdir loop.Please contact your server vendor.  The file: Simple has duplicate cookie 18

There are no messages on the server when this happens. The message on the 
client repeats on every attempt, this "Cannot savedir" above may be 
triggering it.
