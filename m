Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53668 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab0JZP56 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Oct 2010 11:57:58 -0400
Received: by mail-iw0-f174.google.com with SMTP id 10so2336058iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Oct 2010 08:57:58 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] nfs-utils: Remove all uses of AI_ADDRCONFIG
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 Oct 2010 11:57:54 -0400
Message-ID: <20101026155754.19184.40056.stgit@matisse.1015granger.net>
In-Reply-To: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
References: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve Dickson reports that, if only "lo" is up,

  mount.nfs 127.0.0.1:/export /mount

fails with "Name or service not known".

"man 3 getaddrinfo" says this:

  If hints.ai_flags includes the AI_ADDRCONFIG flag, then IPv4
  addresses are returned in the list pointed to by res only if the
  local system has at least one IPv4 address configured, and IPv6
  addresses are only returned if the local system has at least
  one IPv6 address configured.

The man page oversimplifies here.  A review of glibc shows that
getaddrinfo(3) explicitly ignores loopback addresses when deciding
whether an IPv4 or IPv6 address is configured.

This behavior around loopback is a problem not just for mount.nfs,
but also for RPC daemons that have to start up before a system's
networking is fully configured and started.  Given the history of
other problems with AI_ADDRCONFIG and the unpredictable behavior it
introduces, let's just remove it everywhere in nfs-utils.

This fix addresses:

  https://bugzilla.linux-nfs.org/show_bug.cgi?id=191

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/hostname.c     |    6 +-----
 tests/nsm_client/nsm_client.c |    2 +-
 utils/mount/network.c         |    3 ---
 utils/mount/stropts.c         |    5 -----
 utils/statd/hostname.c        |    4 ----
 utils/statd/sm-notify.c       |    5 -----
 6 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/support/export/hostname.c b/support/export/hostname.c
index 3c55ce7..efcb75c 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -30,10 +30,6 @@
 #include "sockaddr.h"
 #include "exportfs.h"
 
-#ifndef HAVE_DECL_AI_ADDRCONFIG
-#define AI_ADDRCONFIG	0
-#endif
-
 /**
  * host_ntop - generate presentation address given a sockaddr
  * @sap: pointer to socket address
@@ -170,7 +166,7 @@ host_addrinfo(const char *hostname)
 #endif
 		/* don't return duplicates */
 		.ai_protocol	= (int)IPPROTO_UDP,
-		.ai_flags	= AI_ADDRCONFIG | AI_CANONNAME,
+		.ai_flags	= AI_CANONNAME,
 	};
 	int error;
 
diff --git a/tests/nsm_client/nsm_client.c b/tests/nsm_client/nsm_client.c
index 0d1159a..0fa3422 100644
--- a/tests/nsm_client/nsm_client.c
+++ b/tests/nsm_client/nsm_client.c
@@ -205,7 +205,7 @@ nsm_client_get_rpcclient(const char *node)
 {
 	unsigned short		port;
 	struct addrinfo		*ai;
-	struct addrinfo		hints = { .ai_flags	= AI_ADDRCONFIG };
+	struct addrinfo		hints = { };
 	int			err;
 	CLIENT			*client = NULL;
 
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 5b515c3..21a7a2c 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -210,9 +210,6 @@ int nfs_lookup(const char *hostname, const sa_family_t family,
 {
 	struct addrinfo *gai_results;
 	struct addrinfo gai_hint = {
-#ifdef HAVE_DECL_AI_ADDRCONFIG
-		.ai_flags	= AI_ADDRCONFIG,
-#endif	/* HAVE_DECL_AI_ADDRCONFIG */
 		.ai_family	= family,
 	};
 	socklen_t len = *salen;
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 50a1a2a..bcc36f3 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -49,10 +49,6 @@
 #include "parse_dev.h"
 #include "conffile.h"
 
-#ifndef HAVE_DECL_AI_ADDRCONFIG
-#define AI_ADDRCONFIG	0
-#endif
-
 #ifndef NFS_PROGRAM
 #define NFS_PROGRAM	(100003)
 #endif
@@ -343,7 +339,6 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 {
 	struct addrinfo hint = {
 		.ai_protocol	= (int)IPPROTO_UDP,
-		.ai_flags	= AI_ADDRCONFIG,
 	};
 	sa_family_t family;
 	int error;
diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
index 38f2265..616a3cb 100644
--- a/utils/statd/hostname.c
+++ b/utils/statd/hostname.c
@@ -39,10 +39,6 @@
 #include "statd.h"
 #include "xlog.h"
 
-#ifndef HAVE_DECL_AI_ADDRCONFIG
-#define AI_ADDRCONFIG	0
-#endif
-
 /**
  * statd_present_address - convert sockaddr to presentation address
  * @sap: pointer to socket address to convert
diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 437e37a..b7f4371 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -34,10 +34,6 @@
 #include "nsm.h"
 #include "nfsrpc.h"
 
-#ifndef HAVE_DECL_AI_ADDRCONFIG
-#define AI_ADDRCONFIG	0
-#endif
-
 #define NSM_TIMEOUT	2
 #define NSM_MAX_TIMEOUT	120	/* don't make this too big */
 
@@ -78,7 +74,6 @@ smn_lookup(const char *name)
 {
 	struct addrinfo	*ai = NULL;
 	struct addrinfo hint = {
-		.ai_flags	= AI_ADDRCONFIG,
 		.ai_family	= (nsm_family == AF_INET ? AF_INET: AF_UNSPEC),
 		.ai_protocol	= (int)IPPROTO_UDP,
 	};

