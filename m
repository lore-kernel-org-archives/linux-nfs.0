From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv3+ACL
Date: Wed, 01 Mar 2006 16:41:58 -0800
Message-ID: <1141260118.26382.15.camel@netapplinux-10.connectathon.org>
References: <200602241547.49425.gopal@nerur.com>
	 <200603010800.08604.gopal@nerur.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FEbtX-0001r3-Lq
	for nfs@lists.sourceforge.net; Wed, 01 Mar 2006 16:42:15 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FEbtW-0004uP-Qq
	for nfs@lists.sourceforge.net; Wed, 01 Mar 2006 16:42:15 -0800
To: Gopal Santhanam <gopal@nerur.com>
In-Reply-To: <200603010800.08604.gopal@nerur.com>
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

On Wed, 2006-03-01 at 08:00 -0800, Gopal Santhanam wrote:
> Hi all,
> 
> I have found out the following with some testing:
> 
> 1) It appears that FC4 kernel 2.6.15-1.1831 does not seem to 
> properly support ACL support in NFSD.  However, ACL support does 
> seem to work as a client.
> 
> 2) I tried running an older known-good version of a kernel 
> (2.6.12-rc3 with appropriate CITI patches).  NFSv3+ACL on the 
> server works great when running with the latest userland 
> utilities in FC4.  I am able to export a directory with ACLs and 
> mount it through the loopback interface and see the ACLs.
> 
> 3) Clients running FC4 are able to connect to the server above 
> without problems.  The ACLs show up nicely.
> 
> Is this a known issue?  What are the plans to get NFSD+ACL server 
> into the mainstream kernel distributions?

NFSv2/v3 ACLs on the server were broken by Linux-2.6.15. Here is a patch
that ought to fix them.

Cheers,
  Trond

------------------------------
diff-tree 3fb803a990cd17546bd89c38e0e29a891f71ce7d (from 3a2ca64496cc1c9aeab1076e06d092b3ec74a43d)
Author: Andreas Gruenbacher <agruen@suse.de>
Date:   Wed Feb 1 03:04:34 2006 -0800

    [PATCH] knfsd: Restore recently broken ACL functionality to NFS server
    
    A recent patch to
       Allow run-time selection of NFS versions to export
    
    meant that NO nfsacl service versions were exported.  This patch restored
    that functionality.
    
    Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 89ed046..1d163b6 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
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
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
