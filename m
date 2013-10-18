Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:16035 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757224Ab3JRTgZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Oct 2013 15:36:25 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Helge Deller <deller@gmx.de>
CC: Linux Kernel Development <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        linux-parisc <linux-parisc@vger.kernel.org>
Subject: Re: 3.12-rcX - NFS regression - kswapd0 / kswapd1 stays using 100%
 CPU?
Date: Fri, 18 Oct 2013 19:36:22 +0000
Message-ID: <1382124981.20461.4.camel@leira.trondhjem.org>
References: <52604BA9.20104@gmx.de>
	 <1382044045.3216.44.camel@leira.trondhjem.org> <52618B5F.4000508@gmx.de>
In-Reply-To: <52618B5F.4000508@gmx.de>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-10-18 at 21:26 +-0200, Helge Deller wrote:
+AD4- On 10/17/2013 11:07 PM, Myklebust, Trond wrote:
+AD4- +AD4- On Thu, 2013-10-17 at 22:42 +020-, Helge Deller wrote:
+AD4- +AD4APg- I'm seeing a regression with current kernel git head when using NFS-mounts.
+AD4- +AD4APg- Architecture in my case is parisc, although I don't think that this is relevant.
+AD4- +AD4APg- At least kernel 3.10 (and I think 3.11) didn't showed that problem.
+AD4- +AD4APg-
+AD4- +AD4APg- The symtom is, that +ACI-top+ACI- shows high usage of either kswapd0 or kswapd1.
+AD4- +AD4APg- Here is an output with kswapd1:
+AD4- +AD4APg-   PID USER      PR  NI  VIRT  RES  SHR S  +ACU-CPU +ACU-MEM     TIME COMMAND
+AD4- +AD4APg-    37 root      20   0     0    0    0 R  91.8  0.0  63:00.40 kswapd1
+AD4- +AD4APg- 28448 root      20   0  3252 1428 1060 R  15.3  0.0   0:00.09 top
+AD4- +AD4APg-     1 root      20   0  2784  988  852 S   0.0  0.0   0:09.95 init
+AD4- +AD4APg-
+AD4- +AD4APg- This is what ps shows:
+AD4- +AD4APg- lsXXXX:+AH4AIw- ps -ef +AHw-  grep mount
+AD4- +AD4APg- root      1181     1  0 14:51 ?        00:00:18 /usr/sbin/automount --pid-file /var/run/autofs.pid
+AD4- +AD4APg- root     25331  1181  0 21:25 ?        00:00:00 /bin/mount -n -t nfs -s -o nolock,rw,hard,intr homes:/unixhome1 /net/home1
+AD4- +AD4APg- root     25332 25331  0 21:25 ?        00:00:00 /sbin/mount.nfs homes:/unixhome1 /net/home1 -s -n -o rw,nolock,hard,intr
+AD4- +AD4APg-
+AD4- +AD4APg- And using sysrq to show the blocked tasks I get in syslog:
+AD4- +AD4APg- SysRq : Show Blocked State
+AD4- +AD4APg- mount.nfs       D 00000000401040c0     0 25332  25331 0x00000010
+AD4- +AD4APg- Backtrace:
+AD4- +AD4APg- +AFsAPA-0000000040113a68+AD4AXQ- +AF8AXw-schedule+0x500/0x810-
+AD4- +AD4APg-
+AD4- +AD4APg- I know it's not a problem of the NFS server, since the same mount is still ok on other machines.
+AD4- +AD4APg- The NFS directory was already mounted and in use when this mount happened again (called by cron-job). 
+AD4- +AD4APg-  
+AD4- +AD4APg- Any ideas?
+AD4- +AD4- 
+AD4- +AD4- If the NFS directory is already mounted, then why is the automounter
+AD4- +AD4- trying to mount it a second time?
+AD4- 
+AD4- I was wrong in this.
+AD4- The directory wasn't mounted yet (or at least it was unmounted in the meantime before the new
+AD4- mount.nfs was called).
+AD4- 
+AD4- I'm now not even sure, that the high kswapd is really triggered by the NFS problem,
+AD4- because I now have another machine with the blocked NFS-mount, but without
+AD4- the high kswapd usage.
+AD4- 
+AD4- Nevertheless, the blocked nfs mount tasks really make me wonder. There is clearly
+AD4- some kind of regression since it doesn't happen with older kernels.

Have you ever reproduced it without the automounter?

Also, could you please try a sysRQ-t the next time it happens, so that
we can get a trace of where the mount program is hanging. Knowing that
the mount is stuck in +ACIAXwBf-schedule()+ACI- is not really interesting unless we
know from where that was called.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
