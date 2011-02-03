Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38185 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754799Ab1BCDsq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Feb 2011 22:48:46 -0500
Date: Wed, 2 Feb 2011 22:48:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: George Spelvin <linux@horizon.com>
Cc: linux-nfs@vger.kernel.org, nix@esperi.org.uk
Subject: Re: persistent, quasi-random -ESTALE at mount time
Message-ID: <20110203034844.GA30641@fieldses.org>
References: <20110202035636.32013.qmail@science.horizon.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110202035636.32013.qmail@science.horizon.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 01, 2011 at 10:56:36PM -0500, George Spelvin wrote:
> For what it's worth, I'm seeing the same problem.
> 
> The server was just rebooted with 2.6.38-rc3, and the client reported
> "STALE NFS file handle".  I wish I understood why; I thought the point
> of a stateless protocol was that it could survive server reboots.
> 
> Anyway, I found all the affected processes, killed them, unmounted,
> tried to remount, and lo and behold:
> 
> mount("server:/path/dir", "/client/dir", "nfs", MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC, "addr=ww.xx.yy.zz,vers=3,proto=tcp,mountvers=3,mountproto=tcp,mountport=2050") = -1 ESTALE (Stale NFS file handle)
> 
> The server is just logging
> send(10, "<29>Feb  1 22:39:49 mountd[4167]: authenticated mount request from $CLIENT:912 for /path/dir (/path/dir)", 125, MSG_NOSIGNAL) = 125
> 
> /proc/fs/nfs/exports is reporting:
> /path/dir   *.dom.ain,client.dom.ain(ro,root_squash,async,wdelay,no_subtree_check,uuid=3210ba59:586b43f2:8780109f:d915f4ab)
> 
> Debian packaged nfs utilities 1.2.2-4 on both server and client.  32 bits in both cases.  (Server is
> running a 64-bit kernel, but 32-bit userland.)
> 
> It worked immediately before the reboot (when the server was runnign 2.6.26-rcX).
> 
> 
> "exportfs -a" several times did NOT fix it, but restarting mountd and nfsd
> ("/etc/init.d/nfs-kernel-server restart") fixed it.
> 
> 
> Anyway, quite annoying.  Unfortunately, that's a server I don't like to reboot.
> (But I can restart the NFS server safely if that would help testing.)

So the reboot was for an upgrade from 2.6.26-rcX to 2.6.38-rc3?  I
wonder if a reboot (or just a server restart) without changing kernels
would see the same problem?

In which case some change in the filehandle format or perhaps in the way
the uuid's are calculated might explain the problem.

We work quite hard to ensure that filehandles returned from older nfsd's
will still be accepted by newer ones.  But that doesn't mean there
couldn't failed at that somehow in some case....

If you manage to reproduce the problem, /proc/fs/nfs/exports before and
after the reboot would be interesting, and ideally also a network trace
showing traffic before and after the reboot (including the operation
that returned the STALE error).

--b.
