Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56818 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754562AbbLQB6a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2015 20:58:30 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 17 Dec 2015 12:56:34 +1100
Subject: [PATCH 2/2] Fix protocol minor version fall-back
Cc: linux-nfs@vger.kernel.org, Takashi Iwai <tiwai@suse.com>
Message-ID: <20151217015634.19978.65001.stgit@noble>
In-Reply-To: <20151217015524.19978.63114.stgit@noble>
References: <20151217015524.19978.63114.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mount.nfs currently expects mount(2) to fail with EPROTONOSUPPORT if
the kernel doesn't understand the requested NFS version.

Unfortunately if the requested minor is not known to the kernel
it returns -EINVAL.
In kernels since 3.11 this can happen in nfs4_alloc_client(), if
compiled without NFS_V4_2.

More generally it can happen in in nfs_validate_text_mount_data()
when nfs_parse_mount_options() returns 0 because nfs_parse_version_string()
didn't recognise the version.

EPROTONOSUPPORT is only returned if NFSv4 support is completely compiled out.

So nfs_autonegotiate needs to check for EINVAL as well as EPROTONOSUPPORT.

URL: https://bugzilla.opensuse.org/show_bug.cgi?id=959211
Reported-by: Takashi Iwai <tiwai@suse.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/stropts.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c8f5a6d223e7..86829a902bfd 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -841,6 +841,9 @@ check_result:
 	case EPROTONOSUPPORT:
 		/* A clear indication that the server or our
 		 * client does not support NFS version 4 and minor */
+	case EINVAL:
+		/* A less clear indication that our client
+		 * does not support NFSv4 minor version. */
 		if (mi->version.v_mode == V_GENERAL &&
 			mi->version.minor == 0)
 				return result;


