Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:52335 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762348Ab3JQUmT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Oct 2013 16:42:19 -0400
Received: from [192.168.178.60] ([84.173.47.244]) by mail.gmx.com (mrgmx102)
 with ESMTPSA (Nemesis) id 0La2Xx-1W130Z0HpF-00lpth for
 <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 22:42:18 +0200
Message-ID: <52604BA9.20104@gmx.de>
Date: Thu, 17 Oct 2013 22:42:17 +0200
From: Helge Deller <deller@gmx.de>
MIME-Version: 1.0
To: Linux Kernel Development <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        list parisc-linux <parisc-linux@lists.parisc-linux.org>
Subject: 3.12-rcX - NFS regression - kswapd0 / kswapd1 stays using 100% CPU?
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm seeing a regression with current kernel git head when using NFS-mounts.
Architecture in my case is parisc, although I don't think that this is relevant.
At least kernel 3.10 (and I think 3.11) didn't showed that problem.

The symtom is, that "top" shows high usage of either kswapd0 or kswapd1.
Here is an output with kswapd1:
  PID USER      PR  NI  VIRT  RES  SHR S  %CPU %MEM     TIME+ COMMAND
   37 root      20   0     0    0    0 R  91.8  0.0  63:00.40 kswapd1
28448 root      20   0  3252 1428 1060 R  15.3  0.0   0:00.09 top
    1 root      20   0  2784  988  852 S   0.0  0.0   0:09.95 init

This is what ps shows:
lsXXXX:~# ps -ef |  grep mount
root      1181     1  0 14:51 ?        00:00:18 /usr/sbin/automount --pid-file /var/run/autofs.pid
root     25331  1181  0 21:25 ?        00:00:00 /bin/mount -n -t nfs -s -o nolock,rw,hard,intr homes:/unixhome1 /net/home1
root     25332 25331  0 21:25 ?        00:00:00 /sbin/mount.nfs homes:/unixhome1 /net/home1 -s -n -o rw,nolock,hard,intr

And using sysrq to show the blocked tasks I get in syslog:
SysRq : Show Blocked State
mount.nfs       D 00000000401040c0     0 25332  25331 0x00000010
Backtrace:
[<0000000040113a68>] __schedule+0x500/0x810

I know it's not a problem of the NFS server, since the same mount is still ok on other machines.
The NFS directory was already mounted and in use when this mount happened again (called by cron-job). 
 
Any ideas?

Helge
