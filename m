From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] [PATCH 6/7] SUNRPC: Make call_status()/call_decode()	call
	xprt_force_disconnect()
Date: Wed, 07 Nov 2007 18:15:43 -0500
Message-ID: <4732471F.3070301@oracle.com>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107004006.13713.47336.stgit@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000307040803030702000600"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20071107004006.13713.47336.stgit@heimdal.trondhjem.org>
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

This is a multi-part message in MIME format.
--------------000307040803030702000600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Move the calls to xprt_disconnect() over to xprt_force_disconnect() in
> order to enable the transport layer to manage the state of the
> XPRT_CONNECTED flag.

Should xs_tcp_read_fraghdr() also use the new force disconnect?

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  net/sunrpc/clnt.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 76be83e..046d8f6 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1137,7 +1137,7 @@ call_status(struct rpc_task *task)
>  	case -ETIMEDOUT:
>  		task->tk_action = call_timeout;
>  		if (task->tk_client->cl_discrtry)
> -			xprt_disconnect(task->tk_xprt);
> +			xprt_force_disconnect(task->tk_xprt);
>  		break;
>  	case -ECONNREFUSED:
>  	case -ENOTCONN:
> @@ -1260,7 +1260,7 @@ out_retry:
>  	req->rq_received = req->rq_private_buf.len = 0;
>  	task->tk_status = 0;
>  	if (task->tk_client->cl_discrtry)
> -		xprt_disconnect(task->tk_xprt);
> +		xprt_force_disconnect(task->tk_xprt);
>  }
>  
>  /*

--------------000307040803030702000600
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------000307040803030702000600
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--------------000307040803030702000600--
