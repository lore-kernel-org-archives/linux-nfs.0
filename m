Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34350 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755487AbbLBVUN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2015 16:20:13 -0500
Received: by ioir85 with SMTP id r85so60256020ioi.1
        for <linux-nfs@vger.kernel.org>; Wed, 02 Dec 2015 13:20:12 -0800 (PST)
Subject: [PATCH] nfsidmap: keyring_clear() should succeed if id_resolver
 keyring not found
From: Chuck Lever <chuck.lever@oracle.com>
To: steve.dickson@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 02 Dec 2015 16:20:10 -0500
Message-ID: <20151202212010.5614.82182.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

root#nfsvmb10:~# nfsidmap -c
nfsidmap: 'id_resolver' keyring was not found.
root#nfsvmb10:~# echo $?
1

If the id_resolver keyring doesn't exist, the kernel has no cached
idmap information to expunge. AFAIK it's not an error.

If nfsidmap is run by a non-privileged user, the id_resolver keyring
is never visible. IMO that should be reported, but the error message
should report the privilege problem, not the missing keyring.

Reported-by: Amy Shi <amy.shi@oracle.com>
Fixes: 69aa69e7de80 ('nfsidmap: Allow keys to be cleared from the ')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/nfsidmap/nfsidmap.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 507193b..15b4a51 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -80,8 +80,9 @@ static int keyring_clear(const char *keyring)
 
 	key = find_key_by_type_and_desc("keyring", keyring, 0);
 	if (key == -1) {
-		xlog_err("'%s' keyring was not found.", keyring);
-		return EXIT_FAILURE;
+		if (verbose)
+			xlog_warn("'%s' keyring was not found.", keyring);
+		return EXIT_SUCCESS;
 	}
 
 	if (keyctl_clear(key) < 0) {
@@ -89,10 +90,9 @@ static int keyring_clear(const char *keyring)
 				(unsigned int)key);
 		return EXIT_FAILURE;
 	}
-	
+
 	if (verbose)
 		xlog_warn("'%s' cleared", keyring);
-
 	return EXIT_SUCCESS;
 }
 
@@ -404,6 +404,11 @@ int main(int argc, char **argv)
 		}
 	}
 
+	if (geteuid() != 0) {
+		xlog_err("Must be run as root.");
+		return EXIT_FAILURE;
+	}
+
 	if ((rc = nfs4_init_name_mapping(PATH_IDMAPDCONF)))  {
 		xlog_errno(rc, "Unable to create name to user id mappings.");
 		return EXIT_FAILURE;

