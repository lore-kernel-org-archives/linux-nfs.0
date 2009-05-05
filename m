From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: [PATCH 2/2] Allow nfs/vers=4 option in text-based mount commands
Date: Tue,  5 May 2009 14:46:44 -0700
Message-ID: <1241560004-16787-3-git-send-email-kevin.constantine@disneyanimation.com>
References: <1241560004-16787-1-git-send-email-kevin.constantine@disneyanimation.com>
 <1241560004-16787-2-git-send-email-kevin.constantine@disneyanimation.com>
Cc: Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:48078 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758995AbZEEVqp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2009 17:46:45 -0400
In-Reply-To: <1241560004-16787-2-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This allows a user to specify nfsvers=4, or vers=4 on the mount
commandline and have mount.nfs4 called as though fstype=nfs4 were
specified.  This patch handles the nfsmount_string case in
mount.c's try_mount().

We get the value of the "vers=" or "nfsvers=" from the nfsmount_info
structure, and if the value equals 4, we set the fstype to nfs4, and
remove the nfsvers/vers options from the structure since it shouldn't
be there in the first place, and we don't want to pass it along down
the stack.

po_get_numeric returns the rightmost instance, so we honor the last
value of nfsvers/vers in the event that it is overridden later in the
options string.

Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
---
 utils/mount/stropts.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c369136..72b0d13 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -754,6 +754,15 @@ static const char *nfs_background_opttbl[] = {
 
 static int nfsmount_start(struct nfsmount_info *mi)
 {
+	long tmp;
+	po_get_numeric(mi->options, "vers", &tmp);
+	po_get_numeric(mi->options, "nfsvers", &tmp);
+	if (tmp == 4) {
+		mi->type = "nfs4";
+		po_remove_all(mi->options, "vers");
+		po_remove_all(mi->options, "nfsvers");
+	}
+
 	if (!nfs_validate_options(mi))
 		return EX_FAIL;
 
-- 
1.6.2.1

