Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ares07.inai.de ([5.9.24.206]:54027 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911Ab3CALoC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Mar 2013 06:44:02 -0500
Date: Fri, 1 Mar 2013 12:43:58 +0100 (CET)
From: Jan Engelhardt <jengelh@inai.de>
To: "J. Bruce Fields" <bfields@redhat.com>
cc: linux-nfs@vger.kernel.org
Subject: Inconsistent error codes between NFSv4 and v3 on network issues
Message-ID: <alpine.LNX.2.01.1303011240350.11154@nerf07.vanv.qr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.


I had here a case with a Linux 3.7.9 system, a virtual machine in a
RFC1918 range, that did not want to mount NFS.

linux-3lzm:~ # strace -fe mount mount -t nfs 134.76.12.5:/X /mnt
Process 1477 attached
[pid  1515] mount("134.76.12.5:/X", "/mnt", "nfs", 0, "vers=4,addr=134.76.12.5,clientaddr=0.0.0.0") = -1 EIO (Input/output error)
mount.nfs: mount system call failed
[pid  1477] +++ exited with 32 +++
--- SIGCHLD {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=1477, si_status=32, si_utime=0, si_stime=0} ---
+++ exited with 32 +++

Nothing in dmesg...

[   84.202243] RPC: Registered named UNIX socket transport module.
[   84.202246] RPC: Registered udp transport module.
[   84.202248] RPC: Registered tcp transport module.
[   84.202249] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   84.205909] FS-Cache: Loaded
[   84.208782] FS-Cache: Netfs 'nfs' registered for caching
[   84.215733] NFS: Registering the id_resolver key type
[   84.215762] Key type id_resolver registered
[   84.215763] Key type id_legacy registered

When mounting with NFSv3, the error became clear:

# strace -fe mount -s 65536 mount -t nfs 134.76.12.5:/X /mnt -o nfsvers=3,nolock
Process 1550 attached
mount.nfs: Network is unreachable
[pid  1550] +++ exited with 32 +++
--- SIGCHLD {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=1550, si_status=32, si_utime=0, si_stime=0} ---
+++ exited with 32 +++

Can NFSv4 be made to return -ENETUNREACH as well?
