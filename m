Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932144Ab1CCRu4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 12:50:56 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/3] KEYS: Define error codes to indicate a name service errors
To: linux-security-module@vger.kernel.org, keyrings@linux-nfs.org
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        David Howells <dhowells@redhat.com>
Date: Thu, 03 Mar 2011 17:50:50 +0000
Message-ID: <20110303175050.21702.69089.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110303175030.21702.31104.stgit@warthog.procyon.org.uk>
References: <20110303175030.21702.31104.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Now that the kernel has filesystems (and possibly other services) that want to
look up internet addresses corresponding to arbitrary hostnames retrieved from
the server, it would seem useful to provide a couple of error codes to indicate
problems with the look up, rather than overloading some other error code.

Define ENONAMESERVICE to indicate "Network name service unavailable".  This can
be used to indicate, for example, that an attempt was made by dns_query() to
make a query, but the name server (e.g. a DNS server) it is supposed to contact
didn't answer or that it couldn't determine the location of a suitable server.

Define ENAMEUNKNOWN to indicate "Network name unknown".  This can be used to
indicate, for example, that an attempt was made by dns_query() to make a query,
but the name server (e.g. a DNS server) replied indicating that it had no
matching records.

The DNS query upcall program can report these to keyctl_reject() so that cached
failed queries will respond with these errors until they expire.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/alpha/include/asm/errno.h  |    2 ++
 arch/mips/include/asm/errno.h   |    2 ++
 arch/parisc/include/asm/errno.h |    2 ++
 arch/sparc/include/asm/errno.h  |    2 ++
 include/asm-generic/errno.h     |    2 ++
 5 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/arch/alpha/include/asm/errno.h b/arch/alpha/include/asm/errno.h
index 519663c..ee8a3f0 100644
--- a/arch/alpha/include/asm/errno.h
+++ b/arch/alpha/include/asm/errno.h
@@ -122,5 +122,7 @@
 
 #define	ERFKILL		138	/* Operation not possible due to RF-kill */
 #define	ENOAUTHSERVICE	139	/* Authentication service not available */
+#define	ENONAMESERVICE	140	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	141	/* Network name unknown */
 
 #endif
diff --git a/arch/mips/include/asm/errno.h b/arch/mips/include/asm/errno.h
index 5fa7fed..faed965 100644
--- a/arch/mips/include/asm/errno.h
+++ b/arch/mips/include/asm/errno.h
@@ -121,6 +121,8 @@
 
 #define	ERFKILL		167	/* Operation not possible due to RF-kill */
 #define	ENOAUTHSERVICE	168	/* Authentication service not available */
+#define	ENONAMESERVICE	169	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	170	/* Network name unknown */
 
 #define EDQUOT		1133	/* Quota exceeded */
 
diff --git a/arch/parisc/include/asm/errno.h b/arch/parisc/include/asm/errno.h
index 6a19346..63ee0bc 100644
--- a/arch/parisc/include/asm/errno.h
+++ b/arch/parisc/include/asm/errno.h
@@ -122,5 +122,7 @@
 
 #define	ERFKILL		256	/* Operation not possible due to RF-kill */
 #define	ENOAUTHSERVICE	257	/* Authentication service not available */
+#define	ENONAMESERVICE	258	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	259	/* Network name unknown */
 
 #endif
diff --git a/arch/sparc/include/asm/errno.h b/arch/sparc/include/asm/errno.h
index ab3a26a..f40d5ae 100644
--- a/arch/sparc/include/asm/errno.h
+++ b/arch/sparc/include/asm/errno.h
@@ -112,5 +112,7 @@
 
 #define	ERFKILL		134	/* Operation not possible due to RF-kill */
 #define	ENOAUTHSERVICE	135	/* Authentication service not available */
+#define	ENONAMESERVICE	136	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	137	/* Network name unknown */
 
 #endif
diff --git a/include/asm-generic/errno.h b/include/asm-generic/errno.h
index bcf1908..25878f1 100644
--- a/include/asm-generic/errno.h
+++ b/include/asm-generic/errno.h
@@ -108,5 +108,7 @@
 
 #define ERFKILL		132	/* Operation not possible due to RF-kill */
 #define	ENOAUTHSERVICE	133	/* Authentication service not available */
+#define	ENONAMESERVICE	134	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	135	/* Network name unknown */
 
 #endif

