From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/23] Make sure nfs_call_umount's callers are
	handling its	return code correctly
Date: Sat, 28 Jul 2007 17:49:49 -0400
Message-ID: <20070728214948.21871.32026.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuAZ-0007Qz-4D
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:51 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuAd-00039C-1D
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:55 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

umount.nfs is treating nfs_call_umount's return code like a standard mount
return code (EX_SOMETHING) when its really an RPC return code.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   27 ++++++++++++++++++++-------
 1 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index b04491c..12fc762 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -363,6 +363,17 @@ int start_statd(void)
 	return 0;
 }
 
+/*
+ * nfs_call_umount - ask the server to remove a share from it's rmtab
+ * @mnt_server: address of RPC MNT program server
+ * @argp: directory path of share to "unmount"
+ *
+ * Returns one if the unmount call succeeded; zero if the unmount
+ * failed for any reason.
+ *
+ * Note that a side effect of calling this function is that rpccreateerr
+ * is set.
+ */
 int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 {
 	CLIENT *clnt;
@@ -374,22 +385,24 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 	case 2:
 	case 1:
 		if (!probe_mntport(mnt_server))
-			goto out_bad;
+			return 0;
 		clnt = mnt_openclnt(mnt_server, &msock);
 		if (!clnt)
-			goto out_bad;
+			return 0;
 		res = clnt_call(clnt, MOUNTPROC_UMNT,
-				(xdrproc_t) xdr_dirpath, (caddr_t)argp,
-				(xdrproc_t) xdr_void, NULL,
+				(xdrproc_t)xdr_dirpath, (caddr_t)argp,
+				(xdrproc_t)xdr_void, NULL,
 				TIMEOUT);
 		mnt_closeclnt(clnt, msock);
 		if (res == RPC_SUCCESS)
 			return 1;
 		break;
 	default:
-		res = 1;
+		res = RPC_SUCCESS;
 		break;
 	}
- out_bad:
-	return res;
+
+	if (res == RPC_SUCCESS)
+		return 1;
+	return 0;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
