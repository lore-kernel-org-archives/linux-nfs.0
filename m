Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756987Ab2BHM3o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 07:29:44 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/2] Define ENONAMESERVICE and ENAMEUNKNOWN to indicate name
 service errors
To: jmorris@namei.org
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Date: Wed, 08 Feb 2012 12:29:18 +0000
Message-ID: <20120208122917.8902.78395.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208122905.8902.65762.stgit@warthog.procyon.org.uk>
References: <20120208122905.8902.65762.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
index 5edc21e..d6e8582 100644
--- a/arch/alpha/include/asm/errno.h
+++ b/arch/alpha/include/asm/errno.h
@@ -122,6 +122,8 @@
 
 #define	ERFKILL		138	/* Operation not possible due to RF-kill */
 #define	ENOAUTHSERVICE	139	/* Authentication service not available */
+#define	ENONAMESERVICE	140	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	141	/* Network name unknown */
 
 #define EHWPOISON	139	/* Memory page has hardware error */
 
diff --git a/arch/mips/include/asm/errno.h b/arch/mips/include/asm/errno.h
index 9e0b83f..5ae25aa 100644
--- a/arch/mips/include/asm/errno.h
+++ b/arch/mips/include/asm/errno.h
@@ -121,6 +121,8 @@
 
 #define	ERFKILL		167	/* Operation not possible due to RF-kill */
 #define	ENOAUTHSERVICE	168	/* Authentication service not available */
+#define	ENONAMESERVICE	169	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	170	/* Network name unknown */
 
 #define EHWPOISON	168	/* Memory page has hardware error */
 
diff --git a/arch/parisc/include/asm/errno.h b/arch/parisc/include/asm/errno.h
index c4598b6..6b3bc7f 100644
--- a/arch/parisc/include/asm/errno.h
+++ b/arch/parisc/include/asm/errno.h
@@ -122,6 +122,8 @@
 
 #define	ERFKILL		256	/* Operation not possible due to RF-kill */
 #define	ENOAUTHSERVICE	257	/* Authentication service not available */
+#define	ENONAMESERVICE	258	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	259	/* Network name unknown */
 
 #define EHWPOISON	257	/* Memory page has hardware error */
 
diff --git a/arch/sparc/include/asm/errno.h b/arch/sparc/include/asm/errno.h
index ab4f9f5..5fab088 100644
--- a/arch/sparc/include/asm/errno.h
+++ b/arch/sparc/include/asm/errno.h
@@ -112,6 +112,8 @@
 
 #define	ERFKILL		134	/* Operation not possible due to RF-kill */
 #define	ENOAUTHSERVICE	135	/* Authentication service not available */
+#define	ENONAMESERVICE	136	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	137	/* Network name unknown */
 
 #define EHWPOISON	135	/* Memory page has hardware error */
 
diff --git a/include/asm-generic/errno.h b/include/asm-generic/errno.h
index 52325ca..719f60c 100644
--- a/include/asm-generic/errno.h
+++ b/include/asm-generic/errno.h
@@ -108,6 +108,8 @@
 
 #define ERFKILL		132	/* Operation not possible due to RF-kill */
 #define	ENOAUTHSERVICE	133	/* Authentication service not available */
+#define	ENONAMESERVICE	134	/* Network name service unavailable */
+#define	ENAMEUNKNOWN	135	/* Network name unknown */
 
 #define EHWPOISON	133	/* Memory page has hardware error */
 

