Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11851 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758484Ab2FADcR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 23:32:17 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Subject: [PATCH 1/2] Define ENOAUTHSERVICE to indicate "Authentication service unavailable"
Date: Thu, 31 May 2012 23:32:07 -0400
Message-Id: <1338521528-2490-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Howells <dhowells@redhat.com>

As the kernel has or will have filesystems (and possibly other services) that
want to obtain authentication tokens and/or encryption data on demand (via
GSSAPI for example), it would seem useful to provide an additional error code
to indicate a problem with the lookup, rather than overloading some other error
code.

We already have EKEYREJECTED, EKEYREVOKED and EKEYEXPIRED to indicate problems
with a token that we already have, but what if the authentication server just
isn't available?

Define ENOAUTHSERVICE to indicate "Authentication service unavailable".  This
can be used to indicate, for example, that an attempt was made by request_key()
to retrieve a key, but the authentication server (e.g. a KDC) it is supposed to
contact didn't answer or that it couldn't determine the location of a suitable
server.

One way this can be used is that the user of a network filesystem can get a TGT
from the KDC and stash it in their session keyring, then the filesystem can
attempt to automatically get a ticket for accessing the filesystem - but if the
server is uncontactable then the ticket can be negatively instantiated with
KEYCTL_REJECT, giving the error to be handed to future requests as
ENOAUTHSERVICE and a small timeout so that the key will expire from the cache
and allow a retry after a short while to prevent thrashing.

Signed-off-by: David Howells <dhowells@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 arch/alpha/include/asm/errno.h  |    2 ++
 arch/mips/include/asm/errno.h   |    1 +
 arch/parisc/include/asm/errno.h |    1 +
 arch/sparc/include/asm/errno.h  |    1 +
 include/asm-generic/errno.h     |    1 +
 5 files changed, 6 insertions(+)

diff --git a/arch/alpha/include/asm/errno.h b/arch/alpha/include/asm/errno.h
index e5f29ca..dce5fc9 100644
--- a/arch/alpha/include/asm/errno.h
+++ b/arch/alpha/include/asm/errno.h
@@ -124,4 +124,6 @@
 
 #define EHWPOISON	139	/* Memory page has hardware error */
 
+#define	ENOAUTHSERVICE	140	/* Authentication service not available */
+
 #endif
diff --git a/arch/mips/include/asm/errno.h b/arch/mips/include/asm/errno.h
index 6dcd358..67c46bd 100644
--- a/arch/mips/include/asm/errno.h
+++ b/arch/mips/include/asm/errno.h
@@ -122,6 +122,7 @@
 #define	ERFKILL		167	/* Operation not possible due to RF-kill */
 
 #define EHWPOISON	168	/* Memory page has hardware error */
+#define	ENOAUTHSERVICE	169	/* Authentication service not available */
 
 #define EDQUOT		1133	/* Quota exceeded */
 
diff --git a/arch/parisc/include/asm/errno.h b/arch/parisc/include/asm/errno.h
index 135ad60..3a6ffcd 100644
--- a/arch/parisc/include/asm/errno.h
+++ b/arch/parisc/include/asm/errno.h
@@ -123,5 +123,6 @@
 #define	ERFKILL		256	/* Operation not possible due to RF-kill */
 
 #define EHWPOISON	257	/* Memory page has hardware error */
+#define	ENOAUTHSERVICE	258	/* Authentication service not available */
 
 #endif
diff --git a/arch/sparc/include/asm/errno.h b/arch/sparc/include/asm/errno.h
index c351aba..94a878f 100644
--- a/arch/sparc/include/asm/errno.h
+++ b/arch/sparc/include/asm/errno.h
@@ -113,5 +113,6 @@
 #define	ERFKILL		134	/* Operation not possible due to RF-kill */
 
 #define EHWPOISON	135	/* Memory page has hardware error */
+#define	ENOAUTHSERVICE	136	/* Authentication service not available */
 
 #endif
diff --git a/include/asm-generic/errno.h b/include/asm-generic/errno.h
index a1331ce..5e2b296 100644
--- a/include/asm-generic/errno.h
+++ b/include/asm-generic/errno.h
@@ -109,5 +109,6 @@
 #define ERFKILL		132	/* Operation not possible due to RF-kill */
 
 #define EHWPOISON	133	/* Memory page has hardware error */
+#define	ENOAUTHSERVICE	134	/* Authentication service not available */
 
 #endif
-- 
1.7.10.2

