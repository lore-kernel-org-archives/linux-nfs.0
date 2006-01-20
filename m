From: NeilBrown <neilb@suse.de>
Subject: [PATCH] knfsd: Restore recently broken ACL functionality to NFS server
Date: Fri, 20 Jan 2006 17:49:36 +1100
Message-ID: <1060120064936.9440@suse.de>
References: <20060120174858.9422.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ezq5n-0004uD-L3
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 22:49:51 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ezq5l-0006ZI-7J
	for nfs@lists.sourceforge.net; Thu, 19 Jan 2006 22:49:51 -0800
To: Andrew Morton <akpm@osdl.org>
Cc: Andreas Gruenbacher <agruen@suse.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


From: Andreas Gruenbacher <agruen@suse.de>

A recent patch to 
   Allow run-time selection of NFS versions to export  

meant that NO nfsacl service versions were exported.
This patch restored that functionality.

Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfssvc.c |   76 ++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 49 insertions(+), 27 deletions(-)

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2006-01-20 17:41:12.000000000 +1100
+++ ./fs/nfsd/nfssvc.c	2006-01-20 17:46:24.000000000 +1100
@@ -64,6 +64,32 @@ struct nfsd_list {
 };
 static struct list_head nfsd_list = LIST_HEAD_INIT(nfsd_list);
 
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+static struct svc_stat	nfsd_acl_svcstats;
+static struct svc_version *	nfsd_acl_version[] = {
+	[2] = &nfsd_acl_version2,
+	[3] = &nfsd_acl_version3,
+};
+
+#define NFSD_ACL_MINVERS            2
+#define NFSD_ACL_NRVERS		(sizeof(nfsd_acl_version)/sizeof(nfsd_acl_version[0]))
+static struct svc_version *nfsd_acl_versions[NFSD_ACL_NRVERS];
+
+static struct svc_program	nfsd_acl_program = {
+	.pg_prog		= NFS_ACL_PROGRAM,
+	.pg_nvers		= NFSD_ACL_NRVERS,
+	.pg_vers		= nfsd_acl_versions,
+	.pg_name		= "nfsd",
+	.pg_class		= "nfsd",
+	.pg_stats		= &nfsd_acl_svcstats,
+	.pg_authenticate	= &svc_set_client,
+};
+
+static struct svc_stat	nfsd_acl_svcstats = {
+	.program	= &nfsd_acl_program,
+};
+#endif /* defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) */
+
 static struct svc_version *	nfsd_version[] = {
 	[2] = &nfsd_version2,
 #if defined(CONFIG_NFSD_V3)
@@ -79,6 +105,9 @@ static struct svc_version *	nfsd_version
 static struct svc_version *nfsd_versions[NFSD_NRVERS];
 
 struct svc_program		nfsd_program = {
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+	.pg_next		= &nfsd_acl_program,
+#endif
 	.pg_prog		= NFS_PROGRAM,		/* program number */
 	.pg_nvers		= NFSD_NRVERS,		/* nr of entries in nfsd_version */
 	.pg_vers		= nfsd_versions,	/* version table */
@@ -147,6 +176,26 @@ nfsd_svc(unsigned short port, int nrserv
 				nfsd_program.pg_vers[i] = nfsd_version[i];
 		}
 
+
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+		found_one = 0;
+
+		for (i = NFSD_ACL_MINVERS; i < NFSD_ACL_NRVERS; i++) {
+			if (NFSCTL_VERISSET(nfsd_versbits, i)) {
+				nfsd_acl_program.pg_vers[i] =
+					nfsd_acl_version[i];
+				found_one = 1;
+			} else
+				nfsd_acl_program.pg_vers[i] = NULL;
+		}
+
+		if (!found_one) {
+			for (i = NFSD_ACL_MINVERS; i < NFSD_ACL_NRVERS; i++)
+				nfsd_acl_program.pg_vers[i] =
+					nfsd_acl_version[i];
+		}
+#endif
+
 		atomic_set(&nfsd_busy, 0);
 		error = -ENOMEM;
 		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE);
@@ -411,30 +460,3 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 	nfsd_cache_update(rqstp, proc->pc_cachetype, statp + 1);
 	return 1;
 }
-
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
-static struct svc_stat	nfsd_acl_svcstats;
-static struct svc_version *	nfsd_acl_version[] = {
-	[2] = &nfsd_acl_version2,
-	[3] = &nfsd_acl_version3,
-};
-
-#define NFSD_ACL_NRVERS		(sizeof(nfsd_acl_version)/sizeof(nfsd_acl_version[0]))
-static struct svc_program	nfsd_acl_program = {
-	.pg_prog		= NFS_ACL_PROGRAM,
-	.pg_nvers		= NFSD_ACL_NRVERS,
-	.pg_vers		= nfsd_acl_version,
-	.pg_name		= "nfsd",
-	.pg_class		= "nfsd",
-	.pg_stats		= &nfsd_acl_svcstats,
-	.pg_authenticate	= &svc_set_client,
-};
-
-static struct svc_stat	nfsd_acl_svcstats = {
-	.program	= &nfsd_acl_program,
-};
-
-#define nfsd_acl_program_p	&nfsd_acl_program
-#else
-#define nfsd_acl_program_p	NULL
-#endif /* defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) */


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
