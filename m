From: Neil Brown <neilb@suse.de>
Subject: [PATCH] nfs-utils:  "nfsstat -m" should report nfsv4 mounts too.
Date: Thu, 5 Jun 2008 14:56:22 +1000
Message-ID: <18503.29174.373900.73302@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:37396 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402AbYFEE4a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 00:56:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


nfsstat -m lists all current nfs mounts, with the mount options.
It does this by reading /proc/mounts and looking for mounts of type
"nfs".
It really should check for "nfs4" as well.  For simplicity, just check
the first 3 characters of the type.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index aa6c961..488c845 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -716,7 +716,7 @@ mounts(const char *name)
 		if (!(type = strtok(NULL, " \t")))
 			continue;
 
-		if (strcmp(type, "nfs")) {
+		if (strncmp(type, "nfs", 3)) {
 		    continue;
 		}
 
