From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] mount.nfs: eliminate a double unlock_mtab
Date: Tue, 15 Jan 2008 12:48:16 -0500
Message-ID: <20080115174816.30730.13131.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:57116 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900AbYAORs4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 12:48:56 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

add_mtab() calls unlock_mtab() twice in one of its error exit paths.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 6ae6b79..cc00bf7 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -246,7 +246,6 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 	lock_mtab();
 
 	if ((mtab = setmntent(MOUNTED, "a+")) == NULL) {
-		unlock_mtab();
 		nfs_error(_("Can't open mtab: %s"),
 				strerror(errno));
 		goto fail_unlock;

