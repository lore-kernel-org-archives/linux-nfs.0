From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] only udp calls sock_sendmsg() to set destination.
Date: Mon, 18 Nov 2002 11:02:47 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15832.11815.395760.763047@notabene.cse.unsw.edu.au>
References: <20021115.132706.26959611.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18DZNU-0001YO-00
	for <nfs@lists.sourceforge.net>; Sun, 17 Nov 2002 16:03:00 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Mon, 18 Nov 2002 11:02:48 +1100
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Friday November 15
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

On Friday November 15, taka@valinux.co.jp wrote:
> Hello Neil,
> 
> I realized the first sock_sendmsg in svc_sendto() is meaningless
> in case of TCP as the connection is already established.
> I fixed it so that sock_sendmsg is called only if it's UDP.
> 

Fair enough.  I'm not sure that the optimisation is likely to be
noticable, but it is probably worth it.
You can make the whole 'msg' structure local to the "if udp" bit, and
do away with set_fs too as there is no data.

Thanks,
NeilBrown

--------------------------------------------------
Status: compiles

Only set dest addr in NFS/udp reply, not NFS/tcp.

We don't need to send an empty message to
set up remote address when sending tcp reply, so
we don't.  Also, as the data is empty, we don't
need to set_fs.


 ----------- Diffstat output ------------
 net/sunrpc/svcsock.c |   30 ++++++++++++++----------------
 1 files changed, 14 insertions(+), 16 deletions(-)

diff net/sunrpc/svcsock.c~current~ net/sunrpc/svcsock.c
--- net/sunrpc/svcsock.c~current~	2002-11-18 10:40:09.000000000 +1100
+++ net/sunrpc/svcsock.c	2002-11-18 10:58:16.000000000 +1100
@@ -324,10 +324,8 @@ svc_wake_up(struct svc_serv *serv)
 static int
 svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 {
-	mm_segment_t	oldfs;
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct socket	*sock = svsk->sk_sock;
-	struct msghdr	msg;
 	int		slen;
 	int		len = 0;
 	int		result;
@@ -339,23 +337,23 @@ svc_sendto(struct svc_rqst *rqstp, struc
 
 	slen = xdr->len;
 
-	msg.msg_name    = &rqstp->rq_addr;
-	msg.msg_namelen = sizeof(rqstp->rq_addr);
-	msg.msg_iov     = NULL;
-	msg.msg_iovlen  = 0;
-	msg.msg_control = NULL;
-	msg.msg_controllen = 0;
-	msg.msg_flags	= MSG_MORE;
-
 	/* Grab svsk->sk_sem to serialize outgoing data. */
 	down(&svsk->sk_sem);
 
-	/* set the destination */
-	oldfs = get_fs(); set_fs(KERNEL_DS);
-	len = sock_sendmsg(sock, &msg, 0);
-	set_fs(oldfs);
-	if (len < 0)
-		goto out;
+	if (rqstp->rq_prot == IPPROTO_UDP) {
+		/* set the destination */
+		struct msghdr	msg;
+		msg.msg_name    = &rqstp->rq_addr;
+		msg.msg_namelen = sizeof(rqstp->rq_addr);
+		msg.msg_iov     = NULL;
+		msg.msg_iovlen  = 0;
+		msg.msg_control = NULL;
+		msg.msg_controllen = 0;
+		msg.msg_flags	= MSG_MORE;
+
+		if (sock_sendmsg(sock, &msg, 0) < 0)
+			goto out;
+	}
 
 	/* send head */
 	if (slen == xdr->head[0].iov_len)


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
