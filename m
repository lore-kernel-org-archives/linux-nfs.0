Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20014 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756807Ab2BHLDe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 06:03:34 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 4/9] KEYS: Reorganise keys Makefile
To: steved@redhat.com, jmorris@namei.org
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 08 Feb 2012 11:03:27 +0000
Message-ID: <20120208110327.4050.11227.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
References: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reorganise the keys directory Makefile to put all the core bits together and
the type-specific bits after.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Mimi Zohar <zohar@us.ibm.com>
---

 security/keys/Makefile |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/security/keys/Makefile b/security/keys/Makefile
index a56f1ff..504aaa0 100644
--- a/security/keys/Makefile
+++ b/security/keys/Makefile
@@ -2,6 +2,9 @@
 # Makefile for key management
 #
 
+#
+# Core
+#
 obj-y := \
 	gc.o \
 	key.o \
@@ -12,9 +15,12 @@ obj-y := \
 	request_key.o \
 	request_key_auth.o \
 	user_defined.o
-
-obj-$(CONFIG_TRUSTED_KEYS) += trusted.o
-obj-$(CONFIG_ENCRYPTED_KEYS) += encrypted-keys/
 obj-$(CONFIG_KEYS_COMPAT) += compat.o
 obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_SYSCTL) += sysctl.o
+
+#
+# Key types
+#
+obj-$(CONFIG_TRUSTED_KEYS) += trusted.o
+obj-$(CONFIG_ENCRYPTED_KEYS) += encrypted-keys/

