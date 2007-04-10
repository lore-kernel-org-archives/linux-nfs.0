From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: =?windows-1252?Q?=5BPATCH=5D_rpcgss_=3A_RPC=5FGSS=5FPROC=5F?=
	=?windows-1252?Q?DESTROY_request_will_get_a_bad_rpc_reply_?=
	=?windows-1252?Q?message?=
Date: Tue, 10 Apr 2007 17:53:17 +0800
Message-ID: <461B5E8D.6070005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, NFSv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

If I send a RPC_GSS_PROC_DESTROY message to NFSv4 server, I will reply 
us a bad rpc reply which without an authentication verifier in it.
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

--- net/sunrpc/auth_gss/svcauth_gss.c.orig	2007-04-09 08:17:55.000000000 -0400
+++ net/sunrpc/auth_gss/svcauth_gss.c	2007-04-09 08:18:37.000000000 -0400
@@ -1088,6 +1088,8 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		}
 		goto complete;
 	case RPC_GSS_PROC_DESTROY:
+		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
+			goto auth_err;
 		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
 		if (resv->iov_len + 4 > PAGE_SIZE)
 			goto drop;
