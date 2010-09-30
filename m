Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30358 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932366Ab0I3SQw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 14:16:52 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 17/17] autofs4 - bump version
To: viro@ftp.linux.org.uk, jmoyer@redhat.com
Cc: linux-fs@vger.kernel.org, autofs@linux.kernel.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Ian Kent <raven@themaw.net>, David Howells <dhowells@redhat.com>
Date: Thu, 30 Sep 2010 19:16:22 +0100
Message-ID: <20100930181622.30939.55468.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ian Kent <raven@themaw.net>

Increase the autofs module sub-version so we can tell what kernel
implementation is being used from user space debug logging.

Signed-off-by: Ian Kent <raven@themaw.net>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/auto_fs4.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/auto_fs4.h b/include/linux/auto_fs4.h
index 8b49ac4..e02982f 100644
--- a/include/linux/auto_fs4.h
+++ b/include/linux/auto_fs4.h
@@ -24,7 +24,7 @@
 #define AUTOFS_MIN_PROTO_VERSION	3
 #define AUTOFS_MAX_PROTO_VERSION	5
 
-#define AUTOFS_PROTO_SUBVERSION		1
+#define AUTOFS_PROTO_SUBVERSION		2
 
 /* Mask for expire behaviour */
 #define AUTOFS_EXP_IMMEDIATE		1

