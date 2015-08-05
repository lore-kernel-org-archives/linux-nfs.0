Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:33008 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbbHEOqO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 10:46:14 -0400
Received: by qged69 with SMTP id d69so31330923qge.0
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 07:46:14 -0700 (PDT)
Subject: [PATCH v2 5/6] nfsidmap: Fix error handling in name_lookup()
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 05 Aug 2015 10:46:12 -0400
Message-ID: <20150805144612.13266.17288.stgit@manet.1015granger.net>
In-Reply-To: <20150805143258.13266.92369.stgit@manet.1015granger.net>
References: <20150805143258.13266.92369.stgit@manet.1015granger.net>
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
 utils/nfsidmap/nfsidmap.c |   21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 9468c08..dbfac9b 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -235,7 +235,7 @@ static int id_lookup(char *name_at_domain, key_serial_t key, int type)
 /*
  * Find the name@domain string from either a user or group id
  */
-int name_lookup(char *id, key_serial_t key, int type)
+static int name_lookup(char *id, key_serial_t key, int type)
 {
 	char name[IDMAP_NAMESZ];
 	char domain[NFS4_MAX_DOMAIN_LEN];
@@ -244,11 +244,10 @@ int name_lookup(char *id, key_serial_t key, int type)
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
@@ -258,16 +257,18 @@ int name_lookup(char *id, key_serial_t key, int type)
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
 

