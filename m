From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [BUG] [PATCH] udp_data_ready may access wrong address.
Date: Mon, 18 Nov 2002 22:16:10 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021118.221610.58431303.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18DluP-0003pn-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 05:25:49 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	NFS maillist <nfs@lists.sourceforge.net>
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

Hello Trond,

I realized that udp_data_ready had a problem.

udp_data_ready may access wrong address to read xid of rpc.
The address of xid is not guaranteed to be placed next to the
UDP header as it is allowed to split its data to some fragments.

Actually kNFSd will send fragmented data via loopback device.

Could you apply it?


Thank you,
Hirokazu Takahashi.



--- net/sunrpc/xprt.c	Thu Oct 31 09:43:07 2002
+++ net/sunrpc/xprt.c.NEW	Mon Nov  4 10:50:34 2030
@@ -694,6 +694,7 @@ udp_data_ready(struct sock *sk, int len)
 	struct rpc_rqst *rovr;
 	struct sk_buff	*skb;
 	int		err, repsize, copied;
+	u32		xid;
 
 	dprintk("RPC:      udp_data_ready...\n");
 	if (!(xprt = xprt_from_sock(sk))) {
@@ -715,9 +716,11 @@ udp_data_ready(struct sock *sk, int len)
 		goto dropit;
 	}
 
+	if (skb_copy_bits(skb, sizeof(struct udphdr), &xid, sizeof(xid)))
+		goto dropit;
 	/* Look up and lock the request corresponding to the given XID */
 	spin_lock(&xprt->sock_lock);
-	rovr = xprt_lookup_rqst(xprt, *(u32 *) (skb->h.raw + sizeof(struct udphdr)));
+	rovr = xprt_lookup_rqst(xprt, xid);
 	if (!rovr)
 		goto out_unlock;
 	task = rovr->rq_task;


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
