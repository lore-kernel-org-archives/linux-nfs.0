From: Art Haas <ahaas@airmail.net>
Subject: [PATCH] Convert fs/nfsctl.c to use C99 named initiailzers
Date: Tue, 11 Feb 2003 20:41:27 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030212024127.GA914@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from covert.brown-ring.iadfw.net ([209.196.123.142])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18inDJ-0004EQ-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Feb 2003 19:05:33 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi.

The following patch converts the file to use C99 named initializers.
These change make the file compile with fewer warnings if '-W' is added
to the compile flags, and may enhance code readability. Let me know if
you think this should be sent to Linus.

Art Haas

===== fs/nfsctl.c 1.5 vs edited =====
--- 1.5/fs/nfsctl.c	Sun Jan  5 17:19:30 2003
+++ edited/fs/nfsctl.c	Tue Feb 11 09:38:42 2003
@@ -54,13 +54,36 @@
 static struct {
 	char *name; int wsize; int rsize;
 } map[] = {
-	[NFSCTL_SVC]={".svc", sizeof(struct nfsctl_svc)},
-	[NFSCTL_ADDCLIENT]={".add", sizeof(struct nfsctl_client)},
-	[NFSCTL_DELCLIENT]={".del", sizeof(struct nfsctl_client)},
-	[NFSCTL_EXPORT]={".export", sizeof(struct nfsctl_export)},
-	[NFSCTL_UNEXPORT]={".unexport", sizeof(struct nfsctl_export)},
-	[NFSCTL_GETFD]={".getfd", sizeof(struct nfsctl_fdparm), NFS_FHSIZE},
-	[NFSCTL_GETFS]={".getfs", sizeof(struct nfsctl_fsparm), sizeof(struct knfsd_fh)},
+	[NFSCTL_SVC] = {
+		.name	= ".svc",
+		.wsize	= sizeof(struct nfsctl_svc)
+	},
+	[NFSCTL_ADDCLIENT] = {
+		.name	= ".add",
+		.wsize	= sizeof(struct nfsctl_client)
+	},
+	[NFSCTL_DELCLIENT] = {
+		.name	= ".del",
+		.wsize	= sizeof(struct nfsctl_client)
+	},
+	[NFSCTL_EXPORT] = {
+		.name	= ".export",
+		.wsize	= sizeof(struct nfsctl_export)
+	},
+	[NFSCTL_UNEXPORT] = {
+		.name	= ".unexport",
+		.wsize	= sizeof(struct nfsctl_export)
+	},
+	[NFSCTL_GETFD] = {
+		.name	= ".getfd",
+		.wsize	= sizeof(struct nfsctl_fdparm),
+		.rsize	= NFS_FHSIZE
+	},
+	[NFSCTL_GETFS] = {
+		.name	= ".getfs",
+		.wsize	= sizeof(struct nfsctl_fsparm),
+		.rsize	= sizeof(struct knfsd_fh)
+	},
 };
 
 long
-- 
They that can give up essential liberty to obtain a little temporary safety
deserve neither liberty nor safety.
 -- Benjamin Franklin, Historical Review of Pennsylvania, 1759


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
