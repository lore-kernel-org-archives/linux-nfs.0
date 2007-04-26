From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: supress warnings about NFS4ERR_OLD_STATEID
	in	nfs4_handle_exception
Date: Thu, 26 Apr 2007 15:13:37 -0400
Message-ID: <20070426191336.GB31081@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: ffilz@us.ibm.com
To: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hh9PO-0003XY-0J
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 12:13:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hh9PP-0005Rp-B2
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 12:13:40 -0700
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

I recently posted this patch to the nfs mailing list, but got no comment.
Reposting with an actual "[PATCH]" subject...

In certain situations, a NFSv4 client can end up with a set of racing calls
that cause the server to return a NFS4ERR_OLD_STATEID error. When this occurs,
the only real recourse that the client has is to retry the call. In the
current code, when this occurs, it triggers a useless printk (in
nfs4_map_errors):

    nfs4_map_errors could not handle NFSv4 error 10024

Trond recently mentioned that we really don't need to worry users with that
info. The following patch is based on a suggestion by Frank Filz and supresses
this error. Changing the return code here to 0 should be safe since all callers
of nfs4_handle_exception are expected to retry the call in this situation
anyway.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Frank Filz <ffilz@us.ibm.com>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f52cf5c..b456783 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2774,6 +2774,7 @@ int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct
 				break;
 		case -NFS4ERR_OLD_STATEID:
 			exception->retry = 1;
+			ret = 0;
 	}
 	/* We failed to handle the error */
 	return nfs4_map_errors(ret);

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
