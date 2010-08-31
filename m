Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:57561 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404Ab0HaTLm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 15:11:42 -0400
Received: by gwj17 with SMTP id 17so2686673gwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 31 Aug 2010 12:11:41 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] mount.nfs: Don't try NFSv4 if UDP was requested
To: neilb@suse.de
Cc: linux-nfs@vger.kernel.org
Date: Tue, 31 Aug 2010 15:11:39 -0400
Message-ID: <20100831191138.10685.75509.stgit@matisse.1015granger.net>
In-Reply-To: <20100831191006.10685.66951.stgit@matisse.1015granger.net>
References: <20100831191006.10685.66951.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If no version was specified on the command line, but UDP is requested,
don't attempt an NFSv4 mount.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 94e75be..17ba48a 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -92,7 +92,8 @@ struct nfsmount_info {
 	struct mount_options	*options;	/* parsed mount options */
 	char			**extra_opts;	/* string for /etc/mtab */
 
-	unsigned long		version;	/* NFS version */
+	unsigned long		version,	/* NFS version */
+				protocol;	/* transport protocol */
 	int			flags,		/* MS_ flags */
 				fake,		/* actually do the mount? */
 				child;		/* forked bg child? */
@@ -361,6 +362,9 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_set_version(mi))
 		return 0;
 
+	if (!nfs_nfs_protocol(mi->options, &mi->protocol))
+		return 0;
+
 	if (!nfs_append_sloppy_option(mi->options))
 		return 0;
 
@@ -761,6 +765,13 @@ static int nfs_autonegotiate(struct nfsmount_info *mi)
 	int result;
 
 	/*
+	 * Try only NFSv2/v3 if a transport protocol was
+	 * specified on the command line.
+	 */
+	if (mi->protocol == IPPROTO_UDP)
+		goto fall_back;
+
+	/*
 	 * Before 2.6.31, the kernel NFS client didn't support
 	 * "-t nfs vers=4" mounts, so we can't include NFSv4
 	 * when autonegotiating.

