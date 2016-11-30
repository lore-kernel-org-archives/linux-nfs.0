Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56741 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755177AbcK3AzY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 19:55:24 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 30 Nov 2016 11:53:52 +1100
Subject: [PATCH 1/2] mount: don't hide temporary error code on timeout.
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <148046723196.21092.14059956601089626164.stgit@noble>
In-Reply-To: <148046718451.21092.10685567606499960786.stgit@noble>
References: <148046718451.21092.10685567606499960786.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a mount attempt times out due to repeated non-permanent errors, we
always report ETIMEDOUT rather than the actual error.
Errors like "ECONNREFUSED" or "EHOSTUNREACH" or "ESTALE" might be more
useful than the generic "ETIMEDOUT".

So preserve the error code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/stropts.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d5dfb5e4a669..7b1ad93effc0 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -990,10 +990,8 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 		if (nfs_is_permanent_error(errno))
 			break;
 
-		if (time(NULL) > timeout) {
-			errno = ETIMEDOUT;
+		if (time(NULL) > timeout)
 			break;
-		}
 
 		if (errno != ETIMEDOUT) {
 			if (sleep(secs))


