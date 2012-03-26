Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58276 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932722Ab2CZPhB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Mar 2012 11:37:01 -0400
Date: Mon, 26 Mar 2012 11:36:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Change the default setting of the
 nfs4_disable_idmapping parameter
Message-ID: <20120326153657.GB22783@fieldses.org>
References: <1326138354-8138-1-git-send-email-Trond.Myklebust@netapp.com>
 <20120322204705.GA23737@fieldses.org>
 <1332449607.8976.9.camel@lade.trondhjem.org>
 <1332450074.8976.13.camel@lade.trondhjem.org>
 <20120322212616.GD23737@fieldses.org>
 <4F6BA3A2.1090501@panasas.com>
 <4F6BA4CA.8040308@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F6BA4CA.8040308@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 22, 2012 at 03:16:42PM -0700, Boaz Harrosh wrote:
> On 03/22/2012 03:11 PM, Boaz Harrosh wrote:
> > I fail to see an opposite scenario where
> > the brokenness was good, and now it will be bad.
> > 
> 
> I might be wrong in this regard, Though. I'm not totally
> on top of all the possible cases.
> 
> Is there a way to Bata test this on large setups? What
> if you make the default Kconfig(urable) so DISTROs can
> compile with a new default and have a large scale testing
> like in a rawhide version.

That'll be easy enough to patch if it turns out to be useful.

But if we're going to default to on, then let's keep it simple for now.
And increase the chance that we get any complaints early.

So I flipped the default, added a missing fallback in the case the
client gives us a name when we're expecting a number, and tested.

And decided to keep the same parameter name as on the client after all,
since it really does do pretty much the same thing.

Comitting for 3.4 absent objections.

--b.

commit 3516a947e59fb635ddd5c42d70bd4274f61daa8a
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Mar 22 16:07:18 2012 -0400

    nfsd4: allow numeric idmapping
    
    Mimic the client side by providing a module parameter that turns off
    idmapping in the auth_sys case, for backwards compatibility with NFSv2
    and NFSv3.
    
    Unlike in the client case, we don't have any way to negotiate, since the
    client can return an error to us if it doesn't like the id that we
    return to it in (for example) a getattr call.
    
    However, it has always been possible for servers to return numeric id's,
    and as far as we're aware clients have always been able to handle them.
    
    Also, in the auth_sys case clients already need to have numeric id's the
    same between client and server.
    
    Therefore we believe it's safe to default this to on; but the module
    parameter is available to return to previous behavior if this proves to
    be a problem in some unexpected setup.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 0d79a88..e4f84f0 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1686,6 +1686,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			The default is to send the implementation identification
 			information.
 
+	nfsd.nfs4_disable_idmapping=
+			[NFSv4] When set to the default of '1', the NFSv4
+			server will return only numeric uids and gids to
+			clients using auth_sys, and will accept numeric uids
+			and gids from such clients.  This is intended to ease
+			migration from NFSv2/v3.
 
 	objlayoutdriver.osd_login_prog=
 			[NFS] [OBJLAYOUT] sets the pathname to the program which
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 9409627..69ca9c5 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -41,6 +41,14 @@
 #include "nfsd.h"
 
 /*
+ * Turn off idmapping when using AUTH_SYS.
+ */
+static bool nfs4_disable_idmapping = true;
+module_param(nfs4_disable_idmapping, bool, 0644);
+MODULE_PARM_DESC(nfs4_disable_idmapping,
+		"Turn off server's NFSv4 idmapping when using 'sec=sys'");
+
+/*
  * Cache entry
  */
 
@@ -561,28 +569,65 @@ idmap_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
 	return ret;
 }
 
+static bool
+numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, uid_t *id)
+{
+	int ret;
+	char buf[11];
+
+	if (namelen + 1 > sizeof(buf))
+		/* too long to represent a 32-bit id: */
+		return false;
+	/* Just to make sure it's null-terminated: */
+	memcpy(buf, name, namelen);
+	buf[namelen] = '\0';
+	ret = strict_strtoul(name, 10, (unsigned long *)id);
+	return ret == 0;
+}
+
+static __be32
+do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, uid_t *id)
+{
+	if (nfs4_disable_idmapping && rqstp->rq_flavor < RPC_AUTH_GSS)
+		if (numeric_name_to_id(rqstp, type, name, namelen, id))
+			return 0;
+		/*
+		 * otherwise, fall through and try idmapping, for
+		 * backwards compatibility with clients sending names:
+		 */
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
