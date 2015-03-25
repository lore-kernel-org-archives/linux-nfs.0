Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dot.freshdot.net ([213.154.236.176]:55431 "EHLO
	dot.freshdot.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbCYJ73 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 05:59:29 -0400
Date: Wed, 25 Mar 2015 10:37:07 +0100
From: Sander Smeenk <ssmeenk@freshdot.net>
To: linux-nfs@vger.kernel.org
Subject: rpc.mountd reads /etc/mtab 17028 times, 100% CPU.
Message-ID: <20150325093707.GC26088@dot.freshdot.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm running a server that has 1500+ mounted local filesystems.
All of these local filesystems are exported through NFS by this server.

When an NFS-client tries to access one of these exported filesystems,
for example doing a simple 'ls' in a mounted NFS, rpc.mountd on the
server takes 100% CPU and starts to spin over reading /etc/mtab which is
linked to /proc/mounts and totals to about 200KB in size. The client
stalls all the while rpc.mountd is busy reading /etc/mtab for every
filesystem mounted, and then some more.

I made a strace of rpc.mountd during such a run to gather some stats:

# cut -d'(' -f1 straceout.25103 | sort | uniq -c | sort -n
      3 fadvise64
      6 ioctl
     11 lseek
     33 readlink
     43 select
     53 write
    809 statfs
    814 lstat
   1282 stat
  17043 mmap
  17043 munmap
  17088 fstat
  17895 open
  21728 openat
  37295 close
  40352 getdents
 458616 newfstatat
3763233 read

# grep -c "open.*mtab" straceout.25103 
17028
 
This entire process of reading /etc/mtab 17028 times takes a lot of time
during which the client stalls, but in the end 'it just works fine'.
It just takes ages when you try to tab-complete on a client.

What would be needed to debug and optimise this?
Could someone point me to the code that is involved in doing this?
I'm not a good C-coder but perhaps i can debug more...

Any insights appreciated!

With regards,
-Sander.
-- 
| Happiness isn't enough for me. I demand EUPHORIA!
| 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
