Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:21371 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762372Ab3JQVHb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 17:07:31 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Helge Deller <deller@gmx.de>
CC: Linux Kernel Development <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        list parisc-linux <parisc-linux@lists.parisc-linux.org>
Subject: Re: 3.12-rcX - NFS regression - kswapd0 / kswapd1 stays using 100%
 CPU?
Date: Thu, 17 Oct 2013 21:07:30 +0000
Message-ID: <1382044045.3216.44.camel@leira.trondhjem.org>
References: <52604BA9.20104@gmx.de>
In-Reply-To: <52604BA9.20104@gmx.de>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-17 at 22:42 +-0200, Helge Deller wrote:
+AD4- I'm seeing a regression with current kernel git head when using NFS-mounts.
+AD4- Architecture in my case is parisc, although I don't think that this is relevant.
+AD4- At least kernel 3.10 (and I think 3.11) didn't showed that problem.
+AD4- 
+AD4- The symtom is, that +ACI-top+ACI- shows high usage of either kswapd0 or kswapd1.
+AD4- Here is an output with kswapd1:
+AD4-   PID USER      PR  NI  VIRT  RES  SHR S  +ACU-CPU +ACU-MEM     TIME+- COMMAND
+AD4-    37 root      20   0     0    0    0 R  91.8  0.0  63:00.40 kswapd1
+AD4- 28448 root      20   0  3252 1428 1060 R  15.3  0.0   0:00.09 top
+AD4-     1 root      20   0  2784  988  852 S   0.0  0.0   0:09.95 init
+AD4- 
+AD4- This is what ps shows:
+AD4- lsXXXX:+AH4AIw- ps -ef +AHw-  grep mount
+AD4- root      1181     1  0 14:51 ?        00:00:18 /usr/sbin/automount --pid-file /var/run/autofs.pid
+AD4- root     25331  1181  0 21:25 ?        00:00:00 /bin/mount -n -t nfs -s -o nolock,rw,hard,intr homes:/unixhome1 /net/home1
+AD4- root     25332 25331  0 21:25 ?        00:00:00 /sbin/mount.nfs homes:/unixhome1 /net/home1 -s -n -o rw,nolock,hard,intr
+AD4- 
+AD4- And using sysrq to show the blocked tasks I get in syslog:
+AD4- SysRq : Show Blocked State
+AD4- mount.nfs       D 00000000401040c0     0 25332  25331 0x00000010
+AD4- Backtrace:
+AD4- +AFsAPA-0000000040113a68+AD4AXQ- +AF8AXw-schedule+-0x500/0x810
+AD4- 
+AD4- I know it's not a problem of the NFS server, since the same mount is still ok on other machines.
+AD4- The NFS directory was already mounted and in use when this mount happened again (called by cron-job). 
+AD4-  
+AD4- Any ideas?

If the NFS directory is already mounted, then why is the automounter
trying to mount it a second time?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
