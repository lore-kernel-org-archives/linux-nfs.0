From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/sunrpc/xdr.c: remove xdr_decode_string()
Date: Wed, 14 Dec 2005 22:10:41 +0100
Message-ID: <20051214211041.GD23349@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	Charles Lever <Charles.Lever@netapp.com>, netdev@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emdti-00016p-V7
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 13:10:50 -0800
Received: from mailout.stusta.mhn.de ([141.84.69.5])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Emdtf-0007GO-9i
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 13:10:50 -0800
To: neilb@cse.unsw.edu.au, trond.myklebust@fys.uio.no
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

This patch removes ths unused function xdr_decode_string().


Signed-off-by: Adrian Bunk <bunk@stusta.de>
Acked-by: Neil Brown <neilb@suse.de>
Acked-by: Charles Lever <Charles.Lever@netapp.com>

---

 include/linux/sunrpc/xdr.h |    1 -
 net/sunrpc/xdr.c           |   21 ---------------------
 2 files changed, 22 deletions(-)

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



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
