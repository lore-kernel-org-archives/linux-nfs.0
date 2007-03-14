From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: [PATCH 2/4] Fix nfs4 umount to not used umount procedure
Date: Wed, 14 Mar 2007 14:47:08 +0800
Message-ID: <45F79A6C.1030508@nanjing-fnst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRNL3-0002Kl-8g
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 23:51:59 -0700
Received: from [221.6.14.228] (helo=proxy.fnst.com.cn)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HRNL4-0006Ed-Pn
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 23:51:59 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This fix umount.nfs4's BUG, patch cleanup some useless code.

1. Combine nfs3_umount() and nfs2_umount() to nfs_umount()
2. If it is a nfs4 remote file system or unkown mount version, do not 
probe remote mount port and not send UMNT request wich is not necessary

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- utils/mount/nfsumount.c.orig	2007-03-05 03:11:48.000000000 -0500
+++ utils/mount/nfsumount.c	2007-03-04 03:09:31.000000000 -0500
@@ -55,24 +55,11 @@
 extern int nfs_gethostbyname(const char *, struct sockaddr_in *);
 
 static inline enum clnt_stat
-nfs3_umount(dirpath *argp, CLIENT *clnt)
+nfs_umount(dirpath *argp, CLIENT *clnt)
 {
-	static char clnt_res;
-	memset (&clnt_res, 0, sizeof(clnt_res));
 	return clnt_call(clnt, MOUNTPROC_UMNT,
 			 (xdrproc_t) xdr_dirpath, (caddr_t)argp,
-			 (xdrproc_t) xdr_void, (caddr_t) &clnt_res,
-			 TIMEOUT);
-}
-
-static inline enum clnt_stat
-nfs2_umount(dirpath *argp, CLIENT *clnt)
-{
-	static char clnt_res;
-	memset (&clnt_res, 0, sizeof(clnt_res));
-	return clnt_call(clnt, MOUNTPROC_UMNT,
-			 (xdrproc_t) xdr_dirpath, (caddr_t)argp,
-			 (xdrproc_t) xdr_void, (caddr_t) &clnt_res,
+			 (xdrproc_t) xdr_void, NULL,
 			 TIMEOUT);
 }
 
@@ -82,25 +69,25 @@
 	enum clnt_stat res = 0;
 	int msock;
 
-	clnt = mnt_openclnt(mnt_server, &msock);
-	if (!clnt)
-		goto out_bad;
 	switch (mnt_server->pmap.pm_vers) {
 	case 3:
-		res = nfs3_umount(argp, clnt);
-		break;
 	case 2:
 	case 1:
-		res = nfs2_umount(argp, clnt);
+		if (!probe_mntport(mnt_server))
+			goto out_bad;
+		clnt = mnt_openclnt(mnt_server, &msock);
+		if (!clnt)
+			goto out_bad;
+		res = nfs_umount(argp, clnt);
+		mnt_closeclnt(clnt, msock);
+		if (res == RPC_SUCCESS)
+			return 1;
 		break;
 	default:
 		break;
 	}
-	mnt_closeclnt(clnt, msock);
-	if (res == RPC_SUCCESS)
-		return 1;
  out_bad:
-	return 0;
+	return res;
 }
 
 u_int get_mntproto(const char *);
@@ -303,8 +290,6 @@
 
 	if (!nfs_gethostbyname(hostname, &mnt_server.saddr))
 		goto out_bad;
-	if (!probe_mntport(&mnt_server))
-		goto out_bad;
 	return nfs_call_umount(&mnt_server, &dirname);
  out_bad:
 	printf("%s: %s: not found or not mounted\n", progname, spec);



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
