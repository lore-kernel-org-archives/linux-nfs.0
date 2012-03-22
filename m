Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34405 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759824Ab2CVUrH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 16:47:07 -0400
Date: Thu, 22 Mar 2012 16:47:05 -0400
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSv4: Change the default setting of the
 nfs4_disable_idmapping parameter
Message-ID: <20120322204705.GA23737@fieldses.org>
References: <1326138354-8138-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1326138354-8138-1-git-send-email-Trond.Myklebust@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way, I finally got around to looking at the server side.

We don't have any way to negotiate with the client--we don't get an
error back if the name we return in a getattr reply isn't one the client
likes--so I don't think I can default the new behavior to "on" without
breaking existing setups.

Other than that I think I'll just copy the client, module parameter and
all.  That allows us to do the numeric case in-kernel and avoid
polluting our mapping cache with lots of "obvious" 123<->"123" mappings.

(OK, maybe I shouldn't copy the same parameter name, though--even if it
works it might be confusing.)

(Untested.)

--b.

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 0d79a88..aa90574 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1686,6 +1686,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			The default is to send the implementation identification
 			information.
 
+	nfsd.nfs4_disable_idmapping=
+			[NFSv4] When set to to '1', the NFSv4 server
+			will return only numeric uids and gids to clients
+			using auth_sys, and will expect numeric uids and
+			gids from such clients.  This intended to ease
+			migration from NFSv2/v3.  The default is '0' for
+			backwards-compatibility reasons, but '1' is
+			recommended for any newly set up server.
 
 	objlayoutdriver.osd_login_prog=
 			[NFS] [OBJLAYOUT] sets the pathname to the program which
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 9409627..4a1e3ce 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -41,6 +41,14 @@
 #include "nfsd.h"
 
 /*
+ * Turn off idmapping when using AUTH_SYS.
+ */
+static bool nfs4_disable_idmapping = false;
+module_param(nfs4_disable_idmapping, bool, 0644);
+MODULE_PARM_DESC(nfs4_disable_idmapping,
+		"Turn off server's NFSv4 idmapping when using 'sec=sys'");
+
+/*
  * Cache entry
  */
 
@@ -561,28 +569,60 @@ idmap_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
 	return ret;
 }
 
+static __be32
+numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, uid_t *id)
+{
+	int ret;
+	char buf[11];
+
+	if (namelen + 1 > sizeof(buf))
+		/* too long to represent a 32-bit id: */
+		return nfserr_badowner;
+	/* Just to make sure it's null-terminated: */
+	memcpy(buf, name, namelen);
+	buf[namelen] = '\0';
+	ret = strict_strtoul(name, 10, (unsigned long *)id);
+	return ret ? nfserr_badowner : 0;
+}
+
+static __be32
+do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, uid_t *id)
+{
+	if (nfs4_disable_idmapping && rqstp->rq_flavor < RPC_AUTH_GSS)
+		return numeric_name_to_id(rqstp, type, name, namelen, id);
+	return idmap_name_to_id(rqstp, type, name, namelen, id);
+}
+
+static int
+do_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
+{
+	if (nfs4_disable_idmapping && rqstp->rq_flavor < RPC_AUTH_GSS)
+		return sprintf(name, "%u", id);
+	return idmap_id_to_name(rqstp, type, id, name);
+}
+
 __be32
 nfsd_map_name_to_uid(struct svc_rqst *rqstp, const char *name, size_t namelen,
 		__u32 *id)
 {
-	return idmap_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, id);
+	return do_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, id);
 }
 
 __be32
 nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name, size_t namelen,
 		__u32 *id)
 {
-	return idmap_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, id);
+	return do_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, id);
 }
 
 int
 nfsd_map_uid_to_name(struct svc_rqst *rqstp, __u32 id, char *name)
 {
-	return idmap_id_to_name(rqstp, IDMAP_TYPE_USER, id, name);
+	return do_id_to_name(rqstp, IDMAP_TYPE_USER, id, name);
 }
 
 int
 nfsd_map_gid_to_name(struct svc_rqst *rqstp, __u32 id, char *name)
 {
-	return idmap_id_to_name(rqstp, IDMAP_TYPE_GROUP, id, name);
+	return do_id_to_name(rqstp, IDMAP_TYPE_GROUP, id, name);
 }
