From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFSv2 won't work in case of error
Date: Tue, 5 Nov 2002 11:31:39 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15815.4459.667481.353188@notabene.cse.unsw.edu.au>
References: <20021101.170933.15272489.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 188tN7-00028R-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Nov 2002 18:23:18 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Tue, 5 Nov 2002 13:23:01 +1100
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Friday November 1
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

On Friday November 1, taka@valinux.co.jp wrote:
> Hello,
> 
> I've fixed a problem that NFSv2 won't work when NFSv2 procedure
> handler (proc->pc_func) returns error.
> 
> I guess there may be better way to fix it than this patch.

Thanks for noticing this.

I think this problem will affect lockd as well, so a more general
patch is needed.

I came up with the following.

NeilBrown


---------------------------------
Make sure final xdr_buf.len is correct on server reply

rq_res->len was not always updated properly.
It is only needed in the sendto routine, so we calculate
it just before that is called.


 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    7 +++++++
 1 files changed, 7 insertions(+)

--- ./net/sunrpc/svcsock.c	2002/11/03 22:12:12	1.2
+++ ./net/sunrpc/svcsock.c	2002/11/03 22:30:54	1.3
@@ -1195,6 +1195,7 @@ svc_send(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk;
 	int		len;
+	struct xdr_buf	*xb;
 
 	if ((svsk = rqstp->rq_sock) == NULL) {
 		printk(KERN_WARNING "NULL socket pointer in %s:%d\n",
@@ -1205,6 +1206,12 @@ svc_send(struct svc_rqst *rqstp)
 	/* release the receive skb before sending the reply */
 	svc_release_skb(rqstp);
 
+	/* calculate over-all length */
+	xb = & rqstp->rq_res;
+	xb->len = xb->head[0].iov_len +
+		xb->page_len +
+		xb->tail[0].iov_len;
+
 	len = svsk->sk_sendto(rqstp);
 	svc_sock_release(rqstp);
 


-------------------------------------------------------
This SF.net email is sponsored by: ApacheCon, November 18-21 in
Las Vegas (supported by COMDEX), the only Apache event to be
fully supported by the ASF. http://www.apachecon.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
