Return-Path: linux-nfs-owner@vger.kernel.org
Received: from maui.cs.washington.edu ([128.208.5.86]:35988 "EHLO
	maui.cs.washington.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186Ab2JSV1X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2012 17:27:23 -0400
Received: from maui.cs.washington.edu (localhost [127.0.0.1])
	by maui.cs.washington.edu (8.14.1/8.14.1/1.10) with ESMTP id q9JKrv0m009348
	for <linux-nfs@vger.kernel.org>; Fri, 19 Oct 2012 13:53:57 -0700
	(envelope-from oystr@maui.cs.washington.edu)
Date: 19 Oct 2012 13:53 PDT
From: Jan Sanislo <oystr@cs.washington.edu>
Subject: nfsidmap and NFS key timeouts and quotas
To: linux-nfs@vger.kernel.org
Message-Id: <1350679987/oystr@maui.cs.washington.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The man page for nfsidmap says that it will set a default timeout
of 600 seconds on keys requested by the NFS client.  But the
keys instantiated are listed a permanent in /proc/keys and it's
easily possible to run out of key quota in an NFS environment with
100s/1000s of uids/gids.

Nfsidmap's call to keyctl_set_timeout fails with a permission
error because the call is made *after* the key is instantiated
and permission to modify the key attributes has been revoked as
a result.  The following patch seems to be more effective in
actually setting the key timeout:

====================================

--- nfsidmap.c_orig	2012-10-19 11:32:29.806374240 -0700
+++ nfsidmap.c	2012-10-19 11:40:06.334674363 -0700
@@ -320,6 +320,16 @@
 			key, type, value, timeout);
 	}
 
+	/*
+	 * Set timeout before instantiation revokes our rights
+	 * over the key.
+	 */
+	if ( timeout > 0 ) {
+		rc = keyctl_set_timeout(key, timeout);
+		if ( rc != 0 )
+			xlog_warn("keyctl_set_timeout key 0x%x failed: %m",key);
+	}
+
 	if (strcmp(type, "uid") == 0)
 		rc = id_lookup(value, key, USER);
 	else if (strcmp(type, "gid") == 0)
@@ -329,10 +339,6 @@
 	else if (strcmp(type, "group") == 0)
 		rc = name_lookup(value, key, GROUP);
 
-	/* Set timeout to 10 (600 seconds) minutes */
-	if (rc == 0)
-		keyctl_set_timeout(key, timeout);
-
 	free(arg);
 	return rc;
 }

====================================

Also, it appears that the check for EDQUOT/ENFILE/ENOMEM after the
keyctl_instantiate call is ineffective.  Those errors seem to be
handled within the kernel a key_alloc time -- if one of them occurs
an upcall to nfsidmap is not made.

Finally, the key LRU discard patch: http://lkml.org/lkml/2012/3/28/144
looks promising for managing key quotas.  But it only seems to be
invoked when a key is linked into a destination keyring. fs/nfs/idmap.c
uses a call to security/keys/request_key which by default provides an
NULL dest_keyring. Might consider changing the request_key call in nfs/idmap.c
to request_key_and_link (although I don't pretend to know all the
implications of making such a change).
