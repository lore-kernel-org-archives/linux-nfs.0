From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH] nfs-utils: NFSv4 pseudofilesystem mount of missing
 directory fails (take 2)
Date: Fri, 04 Feb 2005 17:07:19 -0800
Message-ID: <1107565639.4412.177.camel@w-bwa3.beaverton.ibm.com>
Reply-To: bwa@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CxEQ7-00071c-Of
	for nfs@lists.sourceforge.net; Fri, 04 Feb 2005 17:07:31 -0800
Received: from e3.ny.us.ibm.com ([32.97.182.143])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CxEQ7-0002KX-4k
	for nfs@lists.sourceforge.net; Fri, 04 Feb 2005 17:07:31 -0800
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id j1517KEI018969
	for <nfs@lists.sourceforge.net>; Fri, 4 Feb 2005 20:07:20 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1517KQ7278404
	for <nfs@lists.sourceforge.net>; Fri, 4 Feb 2005 20:07:20 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1517JUO027724
	for <nfs@lists.sourceforge.net>; Fri, 4 Feb 2005 20:07:19 -0500
To: linux-nfs <nfs@lists.sourceforge.net>, nfsv4@linux-nfs.org
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

When attempting to mount an NFSv4 pseudofilesystem (fsid=0) and the
actual exported directory does not exist on the server, rpc.mountd
doesn't check the directory exists (when fsidtype=1, i.e. using fsid,
but does check for fsidtype=0, i.e. using dev/ino).  The non-existent
exported directory path with fsid=0 is written to the kernel via
/proc/net/rpc/nfsd.export/channel, which leads to path_lookup() to
return ENOENT (seems appropriate).  Unfortunately, the new_cache
approach ignores errors returned when writing via the channel file so
that particular error is lost and the mount request is silently ignored.

Assuming it doesn't make sense to revamp the new_cache/up-call method to
not ignore returned errors, it seems appropriate to fix the case where
rpc.mountd doesn't check for the existence of an exported directory with
fsid= semantics.  The following patch does this by moving the stat() up
so it is done for both fsidtype's.  I'm not certain whether the other
tests need to be executed for fsidtype=1, but it doesn't appear to hurt
[Not exactly true: the comparison of inode numbers caused problems so
now it's kept for fsidtype=0 only].

Would it be also desirable to log a warning for every error, if any,
returned by a write to any of the /proc/net/rpc/*/channel files which
would otherwise be ignored (maybe under a debug flag)?

Patch applies to nfs-utils-1.0.7 (and same with latest CITI patch, i.e.
nfs-utils-1.0.7-CITI_NFS4_ALL-1.dif).

Signed-off-by: Bruce Allan <bwa@us.ibm.com>

diff -Nurp nfs-utils-1.0.7/utils/mountd/cache.c nfs-utils-1.0.7-CITI_NFS4_ALL-1/utils/mountd/cache.c
--- nfs-utils-1.0.7/utils/mountd/cache.c	2004-08-30 23:37:21.000000000 -0700
+++ nfs-utils-1.0.7-CITI_NFS4_ALL-1/utils/mountd/cache.c	2005-02-04 16:54:21.000000000 -0800
@@ -145,21 +145,22 @@ void nfsd_fh(FILE *f)
 	/* Now determine export point for this fsid/domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+			struct stat stb;
+
 			if (!client_member(dom, exp->m_client->m_hostname))
 				continue;
+			if (exp->m_export.e_mountpoint &&
+			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
+					   exp->m_export.e_mountpoint:
+					   exp->m_export.e_path))
+				dev_missing ++;
+			if (stat(exp->m_export.e_path, &stb) != 0)
+				continue;
 			if (fsidtype == 1 &&
 			    ((exp->m_export.e_flags & NFSEXP_FSID) == 0 ||
 			     exp->m_export.e_fsid != fsidnum))
 				continue;
 			if (fsidtype == 0) {
-				struct stat stb;
-				if (exp->m_export.e_mountpoint &&
-				    !is_mountpoint(exp->m_export.e_mountpoint[0]?
-						   exp->m_export.e_mountpoint:
-						   exp->m_export.e_path))
-					dev_missing ++;
-				if (stat(exp->m_export.e_path, &stb) != 0)
-					continue;
 				if (stb.st_ino != inode)
 					continue;
 				if (major != major(stb.st_dev) ||




-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
