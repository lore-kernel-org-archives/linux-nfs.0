From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: NFSv2 won't work in case of error
Date: Tue, 05 Nov 2002 12:11:11 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021105.121111.68165074.taka@valinux.co.jp>
References: <20021101.170933.15272489.taka@valinux.co.jp>
	<15815.4459.667481.353188@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 188uFM-0005SO-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Nov 2002 19:19:20 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <15815.4459.667481.353188@notabene.cse.unsw.edu.au>
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

Hello,

> > I've fixed a problem that NFSv2 won't work when NFSv2 procedure
> > handler (proc->pc_func) returns error.
> > 
> > I guess there may be better way to fix it than this patch.
> 
> Thanks for noticing this.
> 
> I think this problem will affect lockd as well, so a more general
> patch is needed.

Yes, you're right.

> I came up with the following.

And we can also remove redundant code.

> ---------------------------------
> Make sure final xdr_buf.len is correct on server reply
> 
> rq_res->len was not always updated properly.
> It is only needed in the sendto routine, so we calculate
> it just before that is called.
> 
> 
>  ----------- Diffstat output ------------
>  ./net/sunrpc/svcsock.c |    7 +++++++
>  1 files changed, 7 insertions(+)
> 
> --- ./net/sunrpc/svcsock.c	2002/11/03 22:12:12	1.2
> +++ ./net/sunrpc/svcsock.c	2002/11/03 22:30:54	1.3
> @@ -1195,6 +1195,7 @@ svc_send(struct svc_rqst *rqstp)
>  {
>  	struct svc_sock	*svsk;
>  	int		len;
> +	struct xdr_buf	*xb;
>  
>  	if ((svsk = rqstp->rq_sock) == NULL) {
>  		printk(KERN_WARNING "NULL socket pointer in %s:%d\n",
> @@ -1205,6 +1206,12 @@ svc_send(struct svc_rqst *rqstp)
>  	/* release the receive skb before sending the reply */
>  	svc_release_skb(rqstp);
>  
> +	/* calculate over-all length */
> +	xb = & rqstp->rq_res;
> +	xb->len = xb->head[0].iov_len +
> +		xb->page_len +
> +		xb->tail[0].iov_len;
> +
>  	len = svsk->sk_sendto(rqstp);
>  	svc_sock_release(rqstp);



--- include/linux/sunrpc/svc.h.ORGlen	Tue Nov  5 11:53:06 2030
+++ include/linux/sunrpc/svc.h	Tue Nov  5 11:53:28 2030
@@ -167,7 +167,6 @@ xdr_ressize_check(struct svc_rqst *rqstp
 	char *cp = (char*)p;
 
 	vec->iov_len = cp - (char*)vec->iov_base;
-	rqstp->rq_res.len = vec->iov_len;
 
 	return vec->iov_len <= PAGE_SIZE;
 }
--- fs/nfsd/nfs3xdr.c.ORGlen	Tue Nov  5 11:52:23 2030
+++ fs/nfsd/nfs3xdr.c	Tue Nov  5 11:54:22 2030
@@ -615,10 +615,6 @@ nfs3svc_encode_readres(struct svc_rqst *
 			rqstp->rq_res.tail[0].iov_base = NULL;
 			rqstp->rq_res.tail[0].iov_len = 4 - (resp->count & 3);
 		}
-		rqstp->rq_res.len =
-			rqstp->rq_res.head[0].iov_len+
-			rqstp->rq_res.page_len+
-			rqstp->rq_res.tail[0].iov_len;
 		return 1;
 	} else
 		return xdr_ressize_check(rqstp, p);
@@ -688,9 +684,6 @@ nfs3svc_encode_readdirres(struct svc_rqs
 		*p++ = 0;		/* no more entries */
 		*p++ = htonl(resp->common.err == nfserr_eof);
 		rqstp->rq_res.page_len = ((unsigned long)p & ~PAGE_MASK);
-		rqstp->rq_res.len =
-			rqstp->rq_res.head[0].iov_len+
-			rqstp->rq_res.page_len;
 		return 1;
 	} else
 		return xdr_ressize_check(rqstp, p);
--- fs/nfsd/nfsxdr.c.ORGlen	Tue Nov  5 11:52:18 2030
+++ fs/nfsd/nfsxdr.c	Tue Nov  5 11:54:35 2030
@@ -396,10 +396,6 @@ nfssvc_encode_readres(struct svc_rqst *r
 		rqstp->rq_res.tail[0].iov_base = NULL;
 		rqstp->rq_res.tail[0].iov_len = 4 - (resp->count&3);
 	}
-	rqstp->rq_res.len = 
-		rqstp->rq_res.head[0].iov_len+
-		rqstp->rq_res.page_len+
-		rqstp->rq_res.tail[0].iov_len;
 	return 1;
 }
 
@@ -412,9 +408,6 @@ nfssvc_encode_readdirres(struct svc_rqst
 	*p++ = 0;			/* no more entries */
 	*p++ = htonl((resp->common.err == nfserr_eof));
 	rqstp->rq_res.page_len = ((unsigned long)p & ~PAGE_MASK);
-	rqstp->rq_res.len =
-			rqstp->rq_res.head[0].iov_len+
-			rqstp->rq_res.page_len;
 
 	return 1;
 }


-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
