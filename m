From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC Patch 08/09] NFS/RDMA client - rpcrdma protocol
 handling
Date: Fri, 24 Aug 2007 14:44:49 -0400
Message-ID: <46CF2721.4010403@oracle.com>
References: <EXNANE01jOuF1Qp4hZD00000c67@exnane01.hq.netapp.com>
	<4697A9DE.50703@oracle.com>
	<EXNANE01D8z9tTx7e4V00000c83@exnane01.hq.netapp.com>
	<4697B233.8040205@oracle.com>
	<EXNANE01tXsL1c00goZ00000067@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020904010703080406040605"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOeAa-0005L3-IA
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 11:46:09 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IOeAc-0007ha-Gt
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 11:46:13 -0700
In-Reply-To: <EXNANE01tXsL1c00goZ00000067@exnane01.hq.netapp.com>
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

This is a multi-part message in MIME format.
--------------020904010703080406040605
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> At 01:11 PM 7/13/2007, Chuck Lever wrote:
>> Talpey, Thomas wrote:
>>> The alternative is mentioned, and would involve marking pagelists
>>> built in xdr_inline_pages(), this of course would also require changes to
>>> the NFS-layer callers. I am prepared to do that, pending the outcome
>>> of these comments.
>> I would humbly prefer the clean alternative: I think several other 
>> operations can use this.  Seems like the distinction is the operations 
>> that read data (like readdir, readlink, read) and those that read 
>> metadata (getattr).
>>
>> The ULP should provide a hint on each of these.  Possibly you could hack 
>> the nfs_procedures tables (which is an RPC client data structure) to 
>> provide the hint.
> 
> So, to clean this up, I looked into hacking this flag into the rpc_procinfo
> as you suggested. It works, but I think it's too high up in the layering.
> The issue is that we want to stamp each buffer with its bulk-data disposition,
> not the entire procedure. For example, there might in the future be more than
> one READ in an NFSv4 COMPOUND.
> 
> What do you think of the following? There are some data movers in xdr.c
> that might peek at this flag for hints too, I haven't gone there yet.

I like this much better than what was there.  The NFS client tells the 
transport layer exactly which pages are bulk, instead of having the 
transport guess.

The name "page_is_bulk" however implies that you are marking the pages, 
where really, you are marking the buffer.  Marking the whole buffer is 
probably correct, but then you should probably rename the flag for clarity.

> Index: linux-2.6.22/fs/nfs/nfs2xdr.c
> ===================================================================
> --- linux-2.6.22.orig/fs/nfs/nfs2xdr.c
> +++ linux-2.6.22/fs/nfs/nfs2xdr.c
> @@ -251,6 +251,7 @@ nfs_xdr_readargs(struct rpc_rqst *req, _
>  	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS_readres_sz) << 2;
>  	xdr_inline_pages(&req->rq_rcv_buf, replen,
>  			 args->pages, args->pgbase, count);
> +	req->rq_rcv_buf.page_is_bulk = 1;
>  	return 0;
>  }
>  
> Index: linux-2.6.22/fs/nfs/nfs3xdr.c
> ===================================================================
> --- linux-2.6.22.orig/fs/nfs/nfs3xdr.c
> +++ linux-2.6.22/fs/nfs/nfs3xdr.c
> @@ -346,6 +346,7 @@ nfs3_xdr_readargs(struct rpc_rqst *req, 
>  	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS3_readres_sz) << 2;
>  	xdr_inline_pages(&req->rq_rcv_buf, replen,
>  			 args->pages, args->pgbase, count);
> +	req->rq_rcv_buf.page_is_bulk = 1;
>  	return 0;
>  }
>  
> Index: linux-2.6.22/fs/nfs/nfs4xdr.c
> ===================================================================
> --- linux-2.6.22.orig/fs/nfs/nfs4xdr.c
> +++ linux-2.6.22/fs/nfs/nfs4xdr.c
> @@ -1857,6 +1857,7 @@ static int nfs4_xdr_enc_read(struct rpc_
>  	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_read_sz) << 2;
>  	xdr_inline_pages(&req->rq_rcv_buf, replen,
>  			 args->pages, args->pgbase, args->count);
> +	req->rq_rcv_buf.page_is_bulk = 1;
>  out:
>  	return status;
>  }
> Index: linux-2.6.22/include/linux/sunrpc/xdr.h
> ===================================================================
> --- linux-2.6.22.orig/include/linux/sunrpc/xdr.h
> +++ linux-2.6.22/include/linux/sunrpc/xdr.h
> @@ -70,7 +70,8 @@ struct xdr_buf {
>  
>  	struct page **	pages;		/* Array of contiguous pages */
>  	unsigned int	page_base,	/* Start of page data */
> -			page_len;	/* Length of page data */
> +			page_len,	/* Length of page data */
> +			page_is_bulk;	/* Page(s) hold bulk data only */
>  
>  	unsigned int	buflen,		/* Total length of storage buffer */
>  			len;		/* Length of XDR encoded message */
> Index: linux-2.6.22/net/sunrpc/clnt.c
> ===================================================================
> --- linux-2.6.22.orig/net/sunrpc/clnt.c
> +++ linux-2.6.22/net/sunrpc/clnt.c
> @@ -871,6 +871,7 @@ rpc_xdr_buf_init(struct xdr_buf *buf, vo
>  	buf->head[0].iov_len = len;
>  	buf->tail[0].iov_len = 0;
>  	buf->page_len = 0;
> +	buf->page_is_bulk = 0;
>  	buf->len = 0;
>  	buf->buflen = len;
>  }
> Index: linux-2.6.22/net/sunrpc/xprtrdma/rpc_rdma.c
> ===================================================================
> --- linux-2.6.22.orig/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ linux-2.6.22/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -47,10 +47,6 @@
>  
>  #include "xprt_rdma.h"
>  
> -#include <linux/nfs2.h>
> -#include <linux/nfs3.h>
> -#include <linux/nfs4.h>
> -
>  #include <linux/highmem.h>
>  
>  #ifdef RPC_DEBUG
> @@ -351,37 +347,6 @@ rpcrdma_inline_pullup(struct rpc_rqst *r
>  }
>  
>  /*
> - * Totally imperfect, temporary attempt to detect nfs reads...
> - * e.g. establish a hint via xdr_inline_pages, etc.
> - */
> -static int
> -is_nfs_read(struct rpc_rqst *rqst)
> -{
> -	u32 *p;
> -
> -	if (rqst->rq_task->tk_client->cl_prog != NFS_PROGRAM)
> -		return 0;
> -	switch (rqst->rq_task->tk_client->cl_vers) {
> -	case 4:
> -		/* Must dig into the COMPOUND. */
> -		/* Back up from the end of what a read request would be */
> -		/* PUTFH, fh, OP_READ, stateid(16), offset(8), count(4) */
> -		p = (u32 *)(rqst->rq_snd_buf.head[0].iov_base +
> -			    rqst->rq_snd_buf.head[0].iov_len);
> -		/* test read and count */
> -		return (rqst->rq_snd_buf.head[0].iov_len > 40 &&
> -			p[-8] == __constant_htonl(OP_READ) &&
> -
> -			p[-1] == htonl(rqst->rq_rcv_buf.page_len));
> -	case 3:
> -		return rqst->rq_task->tk_msg.rpc_proc->p_proc == NFS3PROC_READ;
> -	case 2:
> -		return rqst->rq_task->tk_msg.rpc_proc->p_proc == NFSPROC_READ;
> -	}
> -	return 0;
> -}
> -
> -/*
>   * Marshal a request: the primary job of this routine is to choose
>   * the transfer modes. See comments below.
>   *
> @@ -443,7 +408,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqs
>  		wtype = rpcrdma_noch;
>  	else if (rqst->rq_rcv_buf.page_len == 0)
>  		wtype = rpcrdma_replych;
> -	else if (is_nfs_read(rqst))
> +	else if (rqst->rq_rcv_buf.page_is_bulk)
>  		wtype = rpcrdma_writech;
>  	else
>  		wtype = rpcrdma_replych;

--------------020904010703080406040605
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
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------020904010703080406040605
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------020904010703080406040605
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020904010703080406040605--
