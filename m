From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] rpcgss : RPC_GSS_PROC_DESTROY request will get a bad
	rpc reply message
Date: Tue, 17 Apr 2007 16:04:32 +0800
Message-ID: <46247F90.8030106@cn.fujitsu.com>
References: <461B5E8D.6070005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFSv4@linux-nfs.org
To: nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <461B5E8D.6070005@cn.fujitsu.com>
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

Does anyone think this is a BUG of kernel RPCGSS? Although this seems 
not be used yet.

> If I send a RPC_GSS_PROC_DESTROY message to NFSv4 server, I will reply 
> us a bad rpc reply which without an authentication verifier in it.
> Maybe this patch is needed.
>
> Send/recv packets as following:
>
> send:
>
> RemoteProcedureCall
>     xid
>     rpcvers = 2
>     prog = 100003
>     vers = 4
>     proc = 0
>     cred = AUTH_GSS
>         version = 1
>         gss_proc = 3 (RPCSEC_GSS_DESTROY)
>         service  = 1 (RPC_GSS_SVC_NONE)
>     verf = AUTH_GSS
>         checksum
>
> reply:
>
> RemoteProcedureReply
>     xid
>     msg_type
>     reply_stat
>     accepted_reply
>
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>
> --- net/sunrpc/auth_gss/svcauth_gss.c.orig	2007-04-09 08:17:55.000000000 -0400
> +++ net/sunrpc/auth_gss/svcauth_gss.c	2007-04-09 08:18:37.000000000 -0400
> @@ -1088,6 +1088,8 @@ svcauth_gss_accept(struct svc_rqst *rqst
>  		}
>  		goto complete;
>  	case RPC_GSS_PROC_DESTROY:
> +		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
> +			goto auth_err;
>  		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
>  		if (resv->iov_len + 4 > PAGE_SIZE)
>  			goto drop;
>   
-- 

A new email address of FJWAN is launched from Apr.1 2007.
The updated address is: yjwei@cn.fujitsu.com 
--------------------------------------------------
Wei Yongjun
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL: +86+25-86630523-858
COINS: 79955-858
FAX: +86+25-83317685
MAIL: yjwei@cn.fujitsu.com
--------------------------------------------------
