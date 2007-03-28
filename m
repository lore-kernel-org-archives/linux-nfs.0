From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Odd log message associated with NFS
Date: Wed, 28 Mar 2007 19:23:48 -0400
Message-ID: <20070328232348.GJ21221@fieldses.org>
References: <2fe399760703271140l703c2791oa84e9e1832487dcb@mail.gmail.com>
	<20070327193909.GA585@ds20.borg.net>
	<20070328165925.GB21221@fieldses.org>
	<20070328190536.GB585@ds20.borg.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Thorsten Kranzkowski <dl8bcu@dl8bcu.de>,
	Phy Prabab <phyprabab@gmail.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWhUf-00028R-0D
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 16:23:53 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HWhUf-0006Vz-Ty
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 16:23:55 -0700
In-Reply-To: <20070328190536.GB585@ds20.borg.net>
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

On Wed, Mar 28, 2007 at 07:05:36PM +0000, Thorsten Kranzkowski wrote:
> I'll let a tcpdump run this evening and see if I can correlate the message
> with anything. 
> 
> If you have a printk or other patch for me to try, just let me know.

Well, just for fun, you could try something like this--should dump some
data the first time it hits the "bad direction" error.

--b.

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 9e340fa..c2349d2 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -35,6 +35,45 @@ struct xdr_netobj {
  */
 typedef int	(*kxdrproc_t)(void *rqstp, __be32 *data, void *obj);
 
+/* dump the buffer in `emacs-hexl' style */
+#define isprintable(c)      ((c > 0x1f) && (c < 0x7f))
+
+static inline void dump_hex(void *p, u_int length)
+{
+	u_int i, j, jm;
+	u8 c, *cp;
+
+	printk("RPC: print_hexl: length %d\n",length);
+	cp = p;
+
+	for (i = 0; i < length; i += 0x10) {
+		printk("  %04x: ", (u_int)i);
+		jm = length - i;
+		jm = jm > 16 ? 16 : jm;
+
+		for (j = 0; j < jm; j++) {
+			if ((j % 2) == 1)
+				printk("%02x ", (u_int)cp[i+j]);
+			else
+				printk("%02x", (u_int)cp[i+j]);
+		}
+		for (; j < 16; j++) {
+			if ((j % 2) == 1)
+				printk("   ");
+			else
+				printk("  ");
+		}
+		printk(" ");
+
+		for (j = 0; j < jm; j++) {
+			c = cp[i+j];
+			c = isprintable(c) ? c : '.';
+			printk("%c", c);
+		}
+		printk("\n");
+	}
+}
+
 /*
  * Basic structure for transmission/reception of a client XDR message.
  * Features a header (for a linear buffer containing RPC headers
@@ -61,6 +100,18 @@ struct xdr_buf {
 
 };
 
+static inline void dump_xdr_buf(struct xdr_buf *buf)
+{
+	printk("buf->head[0].iov_base = %p, buf->head[0].iov_len = %d\n",
+			buf->head[0].iov_base, buf->head[0].iov_len);
+	printk("buf->tail[0].iov_base = %p, buf->tail[0].iov_len = %d\n",
+			buf->tail[0].iov_base, buf->tail[0].iov_len);
+	printk("pages = %p, page_base = %d, page_len = %d\n",
+			buf->pages, buf->page_base, buf->page_len);
+	printk("buflen = %d, len = %d\n", buf->buflen, buf->len);
+	return;
+}
+
 /*
  * pre-xdr'ed macros.
  */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index b4db53f..977056e 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -776,6 +776,26 @@ svc_register(struct svc_serv *serv, int proto, unsigned short port)
 	return error;
 }
 
+static void
+dump_once(struct svc_rqst *rqstp, __be32 *orig_start)
+{
+	static int done = 0;
+	struct kvec *argv = &rqstp->rq_arg.head[0];
+	char buf[RPC_MAX_ADDRBUFLEN];
+
+	if (done)
+		return;
+	done++;
+
+	printk("dumping request; rq_addr = %s, rq_deferred = %p, rq_arg:\n",
+		svc_print_addr(rqstp, buf, sizeof(buf)), rqstp->rq_deferred);
+	dump_xdr_buf(&rqstp->rq_arg);
+
+	printk("head data (from %p):\n", orig_start);
+	dump_hex(orig_start, (argv->iov_base + argv->iov_len)
+						- (void *)orig_start);
+}
+
 /*
  * Process the RPC request.
  */
@@ -794,6 +814,7 @@ svc_process(struct svc_rqst *rqstp)
 	__be32			auth_stat, rpc_stat;
 	int			auth_res;
 	__be32			*reply_statp;
+	__be32			*start;
 
 	rpc_stat = rpc_success;
 
@@ -819,6 +840,7 @@ svc_process(struct svc_rqst *rqstp)
 	if (rqstp->rq_prot == IPPROTO_TCP)
 		svc_putnl(resv, 0);
 
+	start = argv->iov_base;
 	rqstp->rq_xid = svc_getu32(argv);
 	svc_putu32(resv, rqstp->rq_xid);
 
@@ -971,6 +993,7 @@ err_short_len:
 err_bad_dir:
 	if (net_ratelimit())
 		printk("svc: bad direction %d, dropping request\n", dir);
+	dump_once(rqstp, start);
 
 	serv->sv_stats->rpcbadfmt++;
 	goto dropit;			/* drop request */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
