Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11851 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758863Ab2FADcS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 23:32:18 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Subject: [PATCH 2/2] Define ENONAMESERVICE and ENAMEUNKNOWN to indicate name service errors
Date: Thu, 31 May 2012 23:32:08 -0400
Message-Id: <1338521528-2490-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1338521528-2490-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1338521528-2490-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Howells <dhowells@redhat.com>

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
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 arch/alpha/include/asm/errno.h  |    2 ++
 arch/mips/include/asm/errno.h   |    2 ++
 arch/parisc/include/asm/errno.h |    2 ++
 arch/sparc/include/asm/errno.h  |    2 ++
 include/asm-generic/errno.h     |    2 ++
 5 files changed, 10 insertions(+)

diff --git a/arch/alpha/include/asm/errno.h b/arch/alpha/include/asm/errno.h
index dce5fc9..a4fc77e 100644
--- a/arch/alpha/include/asm/errno.h
+++ b/arch/alpha/include/asm/errno.h
@@ -125,5 +125,7 @@
 #define EHWPOISON	139	/* Memory page has hardware error */
 
 #define	ENOAUTHSERVICE	140	/* Authentication service not available */
+#define	ENONAMESERVICE	141	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	142	/* Network name unknown */
 
 #endif
diff --git a/arch/mips/include/asm/errno.h b/arch/mips/include/asm/errno.h
index 67c46bd..ac95669 100644
--- a/arch/mips/include/asm/errno.h
+++ b/arch/mips/include/asm/errno.h
@@ -123,6 +123,8 @@
 
 #define EHWPOISON	168	/* Memory page has hardware error */
 #define	ENOAUTHSERVICE	169	/* Authentication service not available */
+#define	ENONAMESERVICE	170	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	171	/* Network name unknown */
 
 #define EDQUOT		1133	/* Quota exceeded */
 
diff --git a/arch/parisc/include/asm/errno.h b/arch/parisc/include/asm/errno.h
index 3a6ffcd..753cc5c 100644
--- a/arch/parisc/include/asm/errno.h
+++ b/arch/parisc/include/asm/errno.h
@@ -124,5 +124,7 @@
 
 #define EHWPOISON	257	/* Memory page has hardware error */
 #define	ENOAUTHSERVICE	258	/* Authentication service not available */
+#define	ENONAMESERVICE	259	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	260	/* Network name unknown */
 
 #endif
diff --git a/arch/sparc/include/asm/errno.h b/arch/sparc/include/asm/errno.h
index 94a878f..01c9769 100644
--- a/arch/sparc/include/asm/errno.h
+++ b/arch/sparc/include/asm/errno.h
@@ -114,5 +114,7 @@
 
 #define EHWPOISON	135	/* Memory page has hardware error */
 #define	ENOAUTHSERVICE	136	/* Authentication service not available */
+#define	ENONAMESERVICE	137	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	138	/* Network name unknown */
 
 #endif
diff --git a/include/asm-generic/errno.h b/include/asm-generic/errno.h
index 5e2b296..5d012c1 100644
--- a/include/asm-generic/errno.h
+++ b/include/asm-generic/errno.h
@@ -110,5 +110,7 @@
 
 #define EHWPOISON	133	/* Memory page has hardware error */
 #define	ENOAUTHSERVICE	134	/* Authentication service not available */
+#define	ENONAMESERVICE	135	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	136	/* Network name unknown */
 
 #endif
-- 
1.7.10.2

