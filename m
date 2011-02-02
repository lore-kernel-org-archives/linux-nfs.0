Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:52083 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750771Ab1BBD4h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Feb 2011 22:56:37 -0500
Date: 1 Feb 2011 22:56:36 -0500
Message-ID: <20110202035636.32013.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: linux-nfs@vger.kernel.org
Subject: Re: persistent, quasi-random -ESTALE at mount time
Cc: bfields@fieldses.org, linux@horizon.com, nix@esperi.org.uk
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

For what it's worth, I'm seeing the same problem.

The server was just rebooted with 2.6.38-rc3, and the client reported
"STALE NFS file handle".  I wish I understood why; I thought the point
of a stateless protocol was that it could survive server reboots.

Anyway, I found all the affected processes, killed them, unmounted,
tried to remount, and lo and behold:

mount("server:/path/dir", "/client/dir", "nfs", MS_RDONLY|MS_NOSUID|MS_NODEV|MS_NOEXEC, "addr=ww.xx.yy.zz,vers=3,proto=tcp,mountvers=3,mountproto=tcp,mountport=2050") = -1 ESTALE (Stale NFS file handle)

The server is just logging
send(10, "<29>Feb  1 22:39:49 mountd[4167]: authenticated mount request from $CLIENT:912 for /path/dir (/path/dir)", 125, MSG_NOSIGNAL) = 125

/proc/fs/nfs/exports is reporting:
/path/dir   *.dom.ain,client.dom.ain(ro,root_squash,async,wdelay,no_subtree_check,uuid=3210ba59:586b43f2:8780109f:d915f4ab)

Debian packaged nfs utilities 1.2.2-4 on both server and client.  32 bits in both cases.  (Server is
running a 64-bit kernel, but 32-bit userland.)

It worked immediately before the reboot (when the server was runnign 2.6.26-rcX).


"exportfs -a" several times did NOT fix it, but restarting mountd and nfsd
("/etc/init.d/nfs-kernel-server restart") fixed it.


Anyway, quite annoying.  Unfortunately, that's a server I don't like to reboot.
(But I can restart the NFS server safely if that would help testing.)
