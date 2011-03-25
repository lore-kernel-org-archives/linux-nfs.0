Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:56020 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006Ab1CYOXo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2011 10:23:44 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Revert NFSROOT default mount options
To: marek.belisko@gmail.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Fri, 25 Mar 2011 10:23:40 -0400
Message-ID: <20110325141947.3236.83222.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Marek Belisko <marek.belisko@gmail.com> reports that recent attempts
to fix regressions in NFSROOT have broken his configuration:

> After update from 2.6.38-rc8 to 2.6.38 is mounting rootfs over nfs not possible.
> Log:
> VFS: Mounted root (nfs filesystem) on device 0:14.
> Freeing init memory: 132K
> nfs: server 10.146.1.21 not responding, still trying
> nfs: server 10.146.1.21 not responding, still trying
>
> This is never ending. I make short bisect (not too much commits
> between versions)
> and bad commit was reported: 53d4737580535e073963b91ce87d4216e434fab5
>
> NFS: NFSROOT should default to "proto=udp"
>
> I've tested on mini2440 board (DM9000, static IP).
> Is there some missing option or something else to be checked?

An examination of a network trace captured during the failure shows
that the mount is actually succeeding, but that the client is not
seeing READ replies larger than 16KB.

Last fall we removed the ad hoc mount option parser in fs/nfs/nfsroot.c
in favor of using the main parser in fs/nfs/super.c (see commit
56463e50 "NFS: Use super.c for NFSROOT mount option parsing").  That
commit changed the default NFSROOT mount options to be the same as
those employed by user space mounts.  As it turns out, that change is
not tolerated by many embedded systems.

Subsequently, commit 53d47375 introduced a clean way to specify
default mount options for NFSROOT, so we can restore the traditional
defaults for NFSROOT easily now:

   vers=2,udp,rsize=4096,wsize=4096

This should revert the changed default NFSROOT mount options
introduced with commit 56463e50.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Hi-

Please test this, as I no longer have an NFSROOT rig here.

Can some responsible maintainer type see that this gets into
linux-next quickly for broader testing?

 fs/nfs/nfsroot.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index c541093..c4744e1 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -87,7 +87,7 @@
 #define NFS_ROOT		"/tftpboot/%s"
 
 /* Default NFSROOT mount options. */
-#define NFS_DEF_OPTIONS		"udp"
+#define NFS_DEF_OPTIONS		"vers=2,udp,rsize=4096,wsize=4096"
 
 /* Parameters passed from the kernel command line */
 static char nfs_root_parms[256] __initdata = "";

