From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] text-based mount: Replace nfs_lookup() with getaddrinfo(3)
Date: Fri, 22 Jan 2010 16:06:29 -0500
Message-ID: <20100122210629.10598.19990.stgit@localhost.localdomain>
References: <20100122210221.10598.84522.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: jlayton@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:27528 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403Ab0AVVHY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2010 16:07:24 -0500
In-Reply-To: <20100122210221.10598.84522.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Originally I thought it would be best to share the DNS query code
between the legacy mount code and the new text-based code, hence
the introduction of nfs_lookup().  However, it now appears we want
the text-based code to do a little more than take the first address
returned by the query.

So, let's invoke getaddrinfo(3) directly in stropts.c, and save
the returned addrinfo struct until the end of processing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   32 ++++++++++++++++++++++++--------
 1 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 74224ff..4ffee48 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -49,6 +49,10 @@
 #include "parse_dev.h"
 #include "conffile.h"
 
+#ifndef HAVE_DECL_AI_ADDRCONFIG
+#define AI_ADDRCONFIG	0
+#endif
+
 #ifndef NFS_PROGRAM
 #define NFS_PROGRAM	(100003)
 #endif
@@ -83,8 +87,7 @@ struct nfsmount_info {
 				*node,		/* mounted-on dir */
 				*type;		/* "nfs" or "nfs4" */
 	char			*hostname;	/* server's hostname */
-	union nfs_sockaddr	address;
-	socklen_t		salen;		/* size of server's address */
+	struct addrinfo		*address;	/* server's addresses */
 
 	struct mount_options	*options;	/* parsed mount options */
 	char			**extra_opts;	/* string for /etc/mtab */
@@ -333,17 +336,27 @@ static int nfs_set_version(struct nfsmount_info *mi)
  */
 static int nfs_validate_options(struct nfsmount_info *mi)
 {
-	struct sockaddr *sap = &mi->address.sa;
+	struct addrinfo hint = {
+		.ai_protocol	= (int)IPPROTO_UDP,
+		.ai_flags	= AI_ADDRCONFIG,
+	};
 	sa_family_t family;
+	int error;
 
 	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
 		return 0;
 
 	if (!nfs_nfs_proto_family(mi->options, &family))
 		return 0;
-	mi->salen = sizeof(mi->address);
-	if (!nfs_lookup(mi->hostname, family, sap, &mi->salen))
+
+	hint.ai_family = (int)family;
+	error = getaddrinfo(mi->hostname, NULL, &hint, &mi->address);
+	if (error != 0) {
+		nfs_error(_("%s: Failed to resolve server %s: %s"),
+			progname, mi->hostname, gai_strerror(error));
+		mi->address = NULL;
 		return 0;
+	}
 
 	if (!nfs_set_version(mi))
 		return 0;
@@ -351,7 +364,8 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_append_sloppy_option(mi->options))
 		return 0;
 
-	if (!nfs_append_addr_option(sap, mi->salen, mi->options))
+	if (!nfs_append_addr_option(mi->address->ai_addr,
+					mi->address->ai_addrlen, mi->options))
 		return 0;
 
 	return 1;
@@ -614,7 +628,7 @@ out_fail:
  */
 static int nfs_try_mount_v4(struct nfsmount_info *mi)
 {
-	struct sockaddr *sap = &mi->address.sa;
+	struct addrinfo *ai = mi->address;
 	struct mount_options *options = po_dup(mi->options);
 	int result = 0;
 
@@ -642,7 +656,7 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
 		}
 	}
 
-	if (!nfs_append_clientaddr_option(sap, mi->salen, options)) {
+	if (!nfs_append_clientaddr_option(ai->ai_addr, ai->ai_addrlen, options)) {
 		errno = EINVAL;
 		goto out_fail;
 	}
@@ -882,6 +896,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 	struct nfsmount_info mi = {
 		.spec		= spec,
 		.node		= node,
+		.address	= NULL,
 		.type		= type,
 		.extra_opts	= extra_opts,
 		.flags		= flags,
@@ -897,6 +912,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 	} else
 		nfs_error(_("%s: internal option parsing error"), progname);
 
+	freeaddrinfo(mi.address);
 	free(mi.hostname);
 	return retval;
 }

