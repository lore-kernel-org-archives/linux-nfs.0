Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33808 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751544AbeBHRNc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Feb 2018 12:13:32 -0500
Received: by mail-io0-f196.google.com with SMTP id x188so19426iod.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Feb 2018 09:13:32 -0800 (PST)
Subject: [PATCH 1/2] Remove nsdb_display_fedfsconnectionsec()
From: Chuck Lever <chuck.lever@oracle.com>
To: SteveD@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 08 Feb 2018 12:13:30 -0500
Message-ID: <20180208171330.12952.22508.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a display helper function that is not needed in nfs-utils
because nfs-utils does not implement the FedFS ADMIN protocol (and
therefore does not need to display ADMIN protocol-related security
settings).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 support/include/junction.h |    1 -
 support/junction/display.c |   20 --------------------
 2 files changed, 21 deletions(-)

diff --git a/support/include/junction.h b/support/include/junction.h
index a5f3844..67cf017 100644
--- a/support/include/junction.h
+++ b/support/include/junction.h
@@ -118,7 +118,6 @@ FedFsStatus	 nsdb_posix_to_path_array(const char *pathname,
  ** Readability helpers
  **/
 
-const char      *nsdb_display_fedfsconnectionsec(const FedFsConnectionSec sectype);
 const char      *nsdb_display_fedfsstatus(const FedFsStatus status);
 void             nsdb_print_fedfsstatus(const FedFsStatus status);
 
diff --git a/support/junction/display.c b/support/junction/display.c
index 77b131f..e1e1af1 100644
--- a/support/junction/display.c
+++ b/support/junction/display.c
@@ -32,26 +32,6 @@
 #include "junction.h"
 
 /**
- * Return human-readable equivalent of a FedFsConnectionSec value
- *
- * @param sectype FedFsConneccionSec value
- * @return a static NUL-terminated C string
- */
-const char *
-nsdb_display_fedfsconnectionsec(const FedFsConnectionSec sectype)
-{
-	switch (sectype) {
-	case FEDFS_SEC_NONE:
-		return "FEDFS_SEC_NONE";
-	case FEDFS_SEC_TLS:
-		return "FEDFS_SEC_TLS";
-	default:
-		break;
-	}
-	return "unrecognized security type";
-}
-
-/**
  * Return human-readable equivalent of a FedFsStatus value
  *
  * @param status FedFsStatus code

