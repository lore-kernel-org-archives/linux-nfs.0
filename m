From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol
 for mount.
Date: Thu, 17 Jul 2008 12:25:18 +1000
Message-ID: <18558.44430.959865.662592@notabene.brown>
References: <18556.40594.897682.204554@notabene.brown>
	<76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
	<487E2BE6.5050500@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41370 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557AbYGQCZV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2008 22:25:21 -0400
In-Reply-To: message from Steve Dickson on Wednesday July 16
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday July 16, SteveD@redhat.com wrote:
> >>  Enable retry if the mount call returns EIO, as that is what happens
> >>    if the UDP requests to portmap get no response.
> > 
> > I would rather see this one addressed in the kernel.  I think the EIO
> > return is a kernel bug.  If the server doesn't support a particular
> > transport protocol for portmap, mountd, or NFS, the mount(2) system
> > call should always return EPROTONOSUPPORT.
> Since EIO has so many meanings... I think it should stay as a fatal 
> error as well...
> 

That would be best.  But the reality is that there are kernels in the
wild where -EIO indicates and error that isn't really fatal.

We already do kernel-detection in mount.  How about extending it like
this?

Thanks,
NeilBrown

From: Neil Brown <neilb@suse.de>
Date: Thu, 17 Jul 2008 12:23:03 +1000
Subject: [PATCH] mount: Recognised EIO from early kernels as possibly indicating a protocol error.

In kernels up to and including 2.6.26, mount reports "connection
refused" type messages as EIO rather than EPROTONOSUPPORT.
So detect those kernels and don't treat EIO as so fatal.

Signed-off-by: Neil Brown <neilb@suse.de>
---
 utils/mount/mount.c   |    8 +++++++-
 utils/mount/stropts.c |    7 +++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 06e2804..2163e4e 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -174,9 +174,15 @@ static void discover_nfs_mount_data_version(void)
 	}
 	if (nfs_mount_data_version > NFS_MOUNT_VERSION)
 		nfs_mount_data_version = NFS_MOUNT_VERSION;
-	else
+	else {
 		if (kernel_version > MAKE_VERSION(2, 6, 22))
 			string++;
+		/* up to and including 2.6.26, mount might return EIO
+		 * when it means EPROTONOSUPPORT
+		 */
+		if (kernel_version > MAKE_VERSION(2, 6, 26))
+			string++;
+	}
 }
 
 static void print_one(char *spec, char *node, char *type, char *opts)
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 09fca86..df4d9c1 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -552,9 +552,12 @@ static int nfs_try_nfs23mount(struct nfsmount_info *mi)
 
 	/*
 	 * The kernel returns EOPNOTSUPP if the RPC bind failed,
-	 * and EPROTONOSUPPORT if the version isn't supported.
+	 * and EPROTONOSUPPORT if the version isn't supported,
+	 * or the protocol isn't accepted.
+	 * Up to 2.6.26, the later causes EIO.
 	 */
-	if (errno != EOPNOTSUPP && errno != EPROTONOSUPPORT)
+	if (errno != EOPNOTSUPP && errno != EPROTONOSUPPORT &&
+	    (string >= 2 || errno != EIO))
 		return 0;
 
 	return nfs_retry_nfs23mount(mi);
-- 
1.5.6.2

