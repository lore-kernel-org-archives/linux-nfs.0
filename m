From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 8] knfsd: rpcgss : RPC_GSS_PROC_ DESTROY
	request will get a bad rpc
Date: Mon, 7 May 2007 10:35:38 +1000
Message-ID: <1070507003538.24137@suse.de>
References: <20070507103211.23855.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HkrCr-00051j-SH
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:01 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HkrCu-0002kY-2n
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:04 -0700
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


From: Wei Yongjun <yjwei@cn.fujitsu.com>


If I send a RPC_GSS_PROC_DESTROY message to NFSv4 server, it will reply
with a bad rpc reply which lacks an authentication verifier.
Maybe this patch is needed.

Send/recv packets as following:

send:

RemoteProcedureCall
    xid
    rpcvers = 2
    prog = 100003
    vers = 4
    proc = 0
    cred = AUTH_GSS
        version = 1
        gss_proc = 3 (RPCSEC_GSS_DESTROY)
        service  = 1 (RPC_GSS_SVC_NONE)
    verf = AUTH_GSS
        checksum

reply:

RemoteProcedureReply
    xid
    msg_type
    reply_stat
    accepted_reply

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/auth_gss/svcauth_gss.c |    2 ++
 1 file changed, 2 insertions(+)

diff .prev/net/sunrpc/auth_gss/svcauth_gss.c ./net/sunrpc/auth_gss/svcauth_gss.c
--- .prev/net/sunrpc/auth_gss/svcauth_gss.c	2007-05-07 10:31:03.000000000 +1000
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2007-05-07 10:31:04.000000000 +1000
@@ -1106,6 +1106,8 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		}
 		goto complete;
 	case RPC_GSS_PROC_DESTROY:
+		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
+			goto auth_err;
 		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
 		if (resv->iov_len + 4 > PAGE_SIZE)
 			goto drop;

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
