From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/sunrpc/xdr.c: remove xdr_decode_string()
Date: Wed, 23 Nov 2005 02:24:18 +0100
Message-ID: <20051123012418.GI3963@stusta.de>
References: <044B81DE141D7443BCE91E8F44B3C1E288E4FC@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, neilb@cse.unsw.edu.au,
	trond.myklebust@fys.uio.no, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EejN4-0002ZS-Gw
	for nfs@lists.sourceforge.net; Tue, 22 Nov 2005 17:24:26 -0800
Received: from emailhub.stusta.mhn.de ([141.84.69.5] helo=mailout.stusta.mhn.de)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EejN2-0004BE-VY
	for nfs@lists.sourceforge.net; Tue, 22 Nov 2005 17:24:26 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E288E4FC@exsvl02.hq.netapp.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Oct 06, 2005 at 07:13:14AM -0700, Lever, Charles wrote:

> actually, can we hold off on this change?  the RPC transport switch will
> eventually need most of those EXPORT_SYMBOLs.

Am I right to assume this will happen in the foreseeable future?

> the only harmless change i see below is removing xdr_decode_string(). 

Patch below.

cu
Adrian


<--  snip  -->


This patch removes ths unused function xdr_decode_string().


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/linux/sunrpc/xdr.h |    1 -
 net/sunrpc/sunrpc_syms.c   |    1 -
 net/sunrpc/xdr.c           |   21 ---------------------
 3 files changed, 23 deletions(-)

--- linux-2.6.15-rc1-mm2-full/include/linux/sunrpc/xdr.h.old	2005-11-23 02:03:01.000000000 +0100
+++ linux-2.6.15-rc1-mm2-full/include/linux/sunrpc/xdr.h	2005-11-23 02:03:08.000000000 +0100
@@ -91,7 +91,6 @@
 u32 *	xdr_encode_opaque_fixed(u32 *p, const void *ptr, unsigned int len);
 u32 *	xdr_encode_opaque(u32 *p, const void *ptr, unsigned int len);
 u32 *	xdr_encode_string(u32 *p, const char *s);
-u32 *	xdr_decode_string(u32 *p, char **sp, int *lenp, int maxlen);
 u32 *	xdr_decode_string_inplace(u32 *p, char **sp, int *lenp, int maxlen);
 u32 *	xdr_encode_netobj(u32 *p, const struct xdr_netobj *);
 u32 *	xdr_decode_netobj(u32 *p, struct xdr_netobj *);
--- linux-2.6.15-rc1-mm2-full/net/sunrpc/xdr.c.old	2005-11-23 02:03:17.000000000 +0100
+++ linux-2.6.15-rc1-mm2-full/net/sunrpc/xdr.c	2005-11-23 02:03:27.000000000 +0100
@@ -93,27 +93,6 @@
 }
 
 u32 *
-xdr_decode_string(u32 *p, char **sp, int *lenp, int maxlen)
-{
-	unsigned int	len;
-	char		*string;
-
-	if ((len = ntohl(*p++)) > maxlen)
-		return NULL;
-	if (lenp)
-		*lenp = len;
-	if ((len % 4) != 0) {
-		string = (char *) p;
-	} else {
-		string = (char *) (p - 1);
-		memmove(string, p, len);
-	}
-	string[len] = '\0';
-	*sp = string;
-	return p + XDR_QUADLEN(len);
-}
-
-u32 *
 xdr_decode_string_inplace(u32 *p, char **sp, int *lenp, int maxlen)
 {
 	unsigned int	len;
--- linux-2.6.15-rc1-mm2-full/net/sunrpc/sunrpc_syms.c.old	2005-11-23 02:03:35.000000000 +0100
+++ linux-2.6.15-rc1-mm2-full/net/sunrpc/sunrpc_syms.c	2005-11-23 02:03:38.000000000 +0100
@@ -120,7 +120,6 @@
 
 /* Generic XDR */
 EXPORT_SYMBOL(xdr_encode_string);
-EXPORT_SYMBOL(xdr_decode_string);
 EXPORT_SYMBOL(xdr_decode_string_inplace);
 EXPORT_SYMBOL(xdr_decode_netobj);
 EXPORT_SYMBOL(xdr_encode_netobj);



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
