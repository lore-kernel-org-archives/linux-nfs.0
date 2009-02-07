From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: processes in D State too long too often
Date: Fri, 6 Feb 2009 22:45:51 -0800
Message-ID: <20090206224551.7bbef0e4.akpm@linux-foundation.org>
References: <W8783110601149981233988222@webmail54>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: "Gary L. Grobe" <gary-QhKe0p0S2m1eoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42140 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753106AbZBGGqR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Feb 2009 01:46:17 -0500
In-Reply-To: <W8783110601149981233988222@webmail54>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(cc linux-nfs)

On Sat, 07 Feb 2009 06:30:22 +0000 "Gary L. Grobe" <gary-QhKe0p0S2m1eoWH0uzbU5w@public.gmane.org> wrote:

> I'm currently running 2.6.27-r7 with ether and myrinet interconnects on slave quad and dual-quad dell 1950's w/ 16-32Gb's ram and a master node that is a Dell 6850 w/ 32Gb.
> 
> I've got processes running on diskless nodes mounted to a master node via NFS. I see that several of these processes are in a D state, yet they recover in a very short time back to running (a few seconds) and then the CPU goes from 0% to 100% usage (which is correct, these CPU's should be running @ 100% as they're running some number crunching simulations, but when in D state CPU usage goes to 0%).
> 
> So why they are in a D state and waiting on I/O? Then I look on the master node and see that several nfsd's are also in a D state, and shortly recover back to running (I see this shown as '-' if using ps, or R in 'top').
> 
> Running 'ps -eal', I see in the WCHAN column for the processes in a D state the following (which I believe is what the processes are waiting on). It can be a mix of these. I usually see 'sync_p', 'nfs_wa', 'lmGrou', and 'txLock'. My file system type is JFS.
> 
> Here's a snipped 'ps -eal' listing on the master node.
> 
> 1 D     0 26709     2  0  75  -5 -     0 lmGrou ?        00:00:07 nfsd
> 1 S     0 26710     2  0  75  -5 -     0 -      ?        00:00:07 nfsd
> 1 S     0 26711     2  0  75  -5 -     0 -      ?        00:00:04 nfsd
> 1 S     0 26712     2  0  75  -5 -     0 -      ?        00:00:08 nfsd
> 1 D     0 26713     2  0  75  -5 -     0 lmGrou ?        00:00:10 nfsd
> 1 S     0 26714     2  0  75  -5 -     0 -      ?        00:00:09 nfsd
> 1 D     0 26715     2  0  75  -5 -     0 txLock ?        00:00:08 nfsd
> 1 D     0 26716     2  0  75  -5 -     0 -      ?        00:00:09 nfsd
> 1 D     0 26717     2  0  75  -5 -     0 txLock ?        00:00:09 nfsd
> 1 S     0 26718     2  0  75  -5 -     0 -      ?        00:00:07 nfsd
> 1 D     0 26719     2  0  75  -5 -     0 -      ?        00:00:08 nfsd
> 1 D     0 26720     2  0  75  -5 -     0 sync_p ?        00:00:09 nfsd
> 1 S     0 26721     2  0  75  -5 -     0 -      ?        00:00:09 nfsd
> 1 S     0 26722     2  0  75  -5 -     0 -      ?        00:00:09 nfsd
> 
> And here's the same command on a diskless node which shows that my processes are in a D state w/ what seems to be nfs_wait (and from which they recover quite quickly, a few seconds later) ...
> 
> # ps -eal
> F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
> ...
> 1 S  1001  6145     1  0  80   0 -  6560 924758 ?        00:00:01 orted
> 0 D  1001  6146  6145 71  80   0 - 941316 nfs_wa ?       19:27:10 lve_1
> 0 D  1001  6147  6145 58  80   0 - 894594 nfs_wa ?       15:57:56 lve_1
> 0 R  1001  6148  6145 57  80   0 - 901343 -     ?        15:33:07 lve_1
> 0 R  1001  6149  6145 78  80   0 - 896065 -     ?        21:31:32 lve_1
> ...
> 
> 'rpcinfo -p master_node' shows that I have portmapper, mountd, nlockmgr, and nfs running w/ all the correct normal info.
> 
> It would seem as if NFS was dropping out intermittently, but I've really gone all throughout the NFS config and see nothing wrong, my DNS servers are working fine, it's all running on a local LAN (no firewall issues), and I see the same results on many different diskless nodes so I don't believe it's a hardware issues. All my previous installations have run fine w/ this same NFS config.
> 
> Others have suggested this may be a 2.6.27-r7 kernel bug. I must note that I did not have this same problem running a 2.6.17 kernel w/ XFS. The hold up seems to be in the kernel and I'm looking for any advice is this might be the case.
> 
> Because these processes are going into a D state so often, a simulation that might normally run for 6 hours now takes 2 days to complete. I've tested the myrinet and ether interconnects and I see no issues from node to node or switch. I can reproduce the problem every time between any one node and the master.
> 
> So I'm looking for thoughts as to what might be going on and how to further investigate if this is in fact a kernel issue.
> 

I guess it would help if you can run

	echo w > /proc/sysrq-trigger

and manage to hit enter when this is happening.

Then run

	dmesg -c -s 1000000 > foo

then check `foo' to see that you caught some nice traces of the stuck tasks.

Then send us those traces.  Please try to avoid wordwrapping them in
the email.

