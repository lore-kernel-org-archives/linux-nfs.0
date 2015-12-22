Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37236 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752117AbbLVJJ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Dec 2015 04:09:27 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id CBC218CF6F
	for <linux-nfs@vger.kernel.org>; Tue, 22 Dec 2015 09:09:27 +0000 (UTC)
Message-ID: <56791344.9050900@redhat.com>
Date: Tue, 22 Dec 2015 14:39:24 +0530
From: Rinku Kothiya <rkothiya@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
CC: Mohit Agrawal <moagrawa@redhat.com>
Subject: [nfs-utils PATCH] Set right error after getaddrinfo fails bz 1287468,
 Please find the same patch attached to this email as well
References: <567782F6.4010306@redhat.com>
In-Reply-To: <567782F6.4010306@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------030507050302030601030000"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030507050302030601030000
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit


From: Rinku Kothiya <rkothiya@redhat.com>

Signed-off-by: Rinku Kothiya <rkothiya@redhat.com>
Signed-off-by: Mohit Agrawal <moagrawa@redhat.com>
---
  nfs-utils-1.3.0-set-errno.patch | 29 +++++++++++++++++++++++++++++
  nfs-utils.spec                  | 23 ++++++++++++-----------
  2 files changed, 41 insertions(+), 11 deletions(-)
  create mode 100644 nfs-utils-1.3.0-set-errno.patch

diff --git a/nfs-utils-1.3.0-set-errno.patch b/nfs-utils-1.3.0-set-errno.patch
new file mode 100644
index 0000000..7c9d381
--- /dev/null
+++ b/nfs-utils-1.3.0-set-errno.patch
@@ -0,0 +1,29 @@
+diff -up nfs-utils-1.3.0/support/export/hostname.c.orig nfs-utils-1.3.0/support/export/hostname.c
+--- nfs-utils-1.3.0/support/export/hostname.c.orig	2015-12-08 15:24:36.705047453 +0530
++++ nfs-utils-1.3.0/support/export/hostname.c	2015-12-08 15:25:46.614047453 +0530
+@@ -179,11 +179,11 @@
+ 	case 0:
+ 		return ai;
+ 	case EAI_SYSTEM:
+-		xlog(D_GENERAL, "%s: failed to resolve %s: (%d) %m",
++		xlog(L_WARNING, "%s: failed to resolve %s: (%d) %m",
+ 				__func__, hostname, errno);
+ 		break;
+ 	default:
+-		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
++		xlog(L_WARNING, "%s: failed to resolve %s: %s",
+ 				__func__, hostname, gai_strerror(error));
+ 		break;
+ 	}
+diff -up nfs-utils-1.3.0/support/nfs/client.c.orig nfs-utils-1.3.0/support/nfs/client.c
+--- nfs-utils-1.3.0/support/export/client.c.orig	2015-12-08 17:08:45.469047453 +0530
++++ nfs-utils-1.3.0/support/export/client.c	2015-12-08 17:09:01.159047453 +0530
+@@ -277,7 +277,7 @@
+ 	if (htype == MCL_FQDN && !canonical) {
+ 		ai = host_addrinfo(hname);
+ 		if (!ai) {
+-			xlog(L_ERROR, "Failed to resolve %s", hname);
++			xlog(L_WARNING, "Failed to resolve %s", hname);
+ 			goto out;
+ 		}
+ 		hname = ai->ai_canonname;


--------------030507050302030601030000
Content-Type: text/x-patch;
 name="nfs-utils-1.3.0-set-errno.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs-utils-1.3.0-set-errno.patch"

diff -up nfs-utils-1.3.0/support/nfs/hostname.c.orig nfs-utils-1.3.0/support/nfs/hostname.c 
--- nfs-utils-1.3.0/support/export/hostname.c.orig	2015-12-08 15:24:36.705047453 +0530
+++ nfs-utils-1.3.0/support/export/hostname.c	2015-12-08 15:25:46.614047453 +0530
@@ -179,11 +179,11 @@
 	case 0:
 		return ai;
 	case EAI_SYSTEM:
-		xlog(D_GENERAL, "%s: failed to resolve %s: (%d) %m",
+		xlog(L_WARNING, "%s: failed to resolve %s: (%d) %m",
 				__func__, hostname, errno);
 		break;
 	default:
-		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
+		xlog(L_WARNING, "%s: failed to resolve %s: %s",
 				__func__, hostname, gai_strerror(error));
 		break;
 	}
diff -up nfs-utils-1.3.0/support/nfs/client.c.orig nfs-utils-1.3.0/support/nfs/client.c 
--- nfs-utils-1.3.0/support/export/client.c.orig	2015-12-08 17:08:45.469047453 +0530
+++ nfs-utils-1.3.0/support/export/client.c	2015-12-08 17:09:01.159047453 +0530
@@ -277,7 +277,7 @@
 	if (htype == MCL_FQDN && !canonical) {
 		ai = host_addrinfo(hname);
 		if (!ai) {
-			xlog(L_ERROR, "Failed to resolve %s", hname);
+			xlog(L_WARNING, "Failed to resolve %s", hname);
 			goto out;
 		}
 		hname = ai->ai_canonname;

--------------030507050302030601030000--
