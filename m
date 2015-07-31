Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:34247 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbGaWOQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Jul 2015 18:14:16 -0400
Received: by qgeu79 with SMTP id u79so55694367qge.1
        for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2015 15:14:16 -0700 (PDT)
Subject: [PATCH 5/6] nfsidmap: Fix error handling in name_lookup()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: dhowells@redhat.com
Date: Fri, 31 Jul 2015 15:14:14 -0700
Message-ID: <20150731221414.50685.74550.stgit@seurat.1015granger.net>
In-Reply-To: <20150731220914.50685.32887.stgit@seurat.1015granger.net>
References: <20150731220914.50685.32887.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As near as I can tell, the exit status of nfsidmap is supposed to be
zero (success) or one (failure).

The return value of name_lookup() becomes the exit status, so it
should return only zero or one.

The libnfsidmap calls return a signed integer, either 0 or negative
errno values. These have to be translated to an exit status.

libkeyutils calls return a signed long, either 0 or -1. These also
have to be translated to an exit status.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/nfsidmap/nfsidmap.c |   19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 9881694..e9941b4 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -244,11 +244,10 @@ static int name_lookup(char *id, key_serial_t key, int type)
 	int rc;
 
 	rc = nfs4_get_default_domain(NULL, domain, NFS4_MAX_DOMAIN_LEN);
-	if (rc != 0) {
+	if (rc) {
 		xlog_errno(rc,
 			"name_lookup: nfs4_get_default_domain failed: %m");
-		rc = -1;
-		goto out;
+		return EXIT_FAILURE;
 	}
 
 	if (type == USER) {
@@ -258,16 +257,18 @@ static int name_lookup(char *id, key_serial_t key, int type)
 		gid = atoi(id);
 		rc = nfs4_gid_to_name(gid, domain, name, IDMAP_NAMESZ);
 	}
-	if (rc < 0)
+	if (rc) {
 		xlog_errno(rc, "name_lookup: %s: failed: %m",
 			(type == USER ? "nfs4_uid_to_name" : "nfs4_gid_to_name"));
+		return EXIT_FAILURE;
+	}
 
-	if (rc == 0) {
-		rc = keyctl_instantiate(key, &name, strlen(name), 0);
-		if (rc < 0)
-			xlog_err("name_lookup: keyctl_instantiate failed: %m");
+	rc = EXIT_SUCCESS;
+	if (keyctl_instantiate(key, &name, strlen(name), 0)) {
+		rc = EXIT_FAILURE;
+		xlog_err("name_lookup: keyctl_instantiate failed: %m");
 	}
-out:
+
 	return rc;
 }
 

