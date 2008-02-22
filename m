From: Peng Haitao <penght@cn.fujitsu.com>
Subject: [NFS]  [PATCH] Fix nfsstat --mounted
Date: Fri, 22 Feb 2008 10:07:21 +0800
Message-ID: <47BE2E59.8050309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050104020500060608050100"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: "neilb@suse.de" <neilb@suse.de>, gam3-9QXkWSUAZhY@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54187 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758423AbYBVCGG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 21:06:06 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JSNIY-0002dc-TI
	for linux-nfs@vger.kernel.org; Fri, 22 Feb 2008 13:06:03 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050104020500060608050100
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit

Execute command "nfsstat --mounted" will print the error message
"nfsstat: unrecognized option `--mounted'".

Package: nfs-utils
Version: 1.1.1

Signed-off-by: Peng Haitao <penght@cn.fujitsu.com>

Index: nfs-utils-1.1.1/utils/nfsstat/nfsstat.c
===================================================================
diff -Nurp nfs-utils-1.1.1.orig/utils/nfsstat/nfsstat.c
nfs-utils-1.1.1/utils/nfsstat/nfsstat.c
--- nfs-utils-1.1.1.orig/utils/nfsstat/nfsstat.c	2008-02-19
17:34:14.000000000 +0800
+++ nfs-utils-1.1.1/utils/nfsstat/nfsstat.c	2008-02-19
17:48:52.000000000 +0800
@@ -237,7 +237,7 @@ static struct option longopts[] =
 	{ "all", 0, 0, 'v' },
 	{ "auto", 0, 0, '\3' },
 	{ "client", 0, 0, 'c' },
-	{ "mounts", 0, 0, 'm' },
+	{ "mounted", 0, 0, 'm' },
 	{ "nfs", 0, 0, 'n' },
 	{ "rpc", 0, 0, 'r' },
 	{ "server", 0, 0, 's' },


-- 
Regards
Peng Haitao
--------------------------------------------------
Peng Haitao
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL: +86+25-86630566-837
COINS: 79955-837
FAX: +86+25-83317685
MAIL: penght@cn.fujitsu.com
--------------------------------------------------

--------------050104020500060608050100
Content-Type: text/plain;
 name="nfsstat_mounted.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="nfsstat_mounted.patch"

ZGlmZiAtTnVycCBuZnMtdXRpbHMtMS4xLjEub3JpZy91dGlscy9uZnNzdGF0L25mc3N0YXQu
YyBuZnMtdXRpbHMtMS4xLjEvdXRpbHMvbmZzc3RhdC9uZnNzdGF0LmMKLS0tIG5mcy11dGls
cy0xLjEuMS5vcmlnL3V0aWxzL25mc3N0YXQvbmZzc3RhdC5jCTIwMDgtMDItMTkgMTc6MzQ6
MTQuMDAwMDAwMDAwICswODAwCisrKyBuZnMtdXRpbHMtMS4xLjEvdXRpbHMvbmZzc3RhdC9u
ZnNzdGF0LmMJMjAwOC0wMi0xOSAxNzo0ODo1Mi4wMDAwMDAwMDAgKzA4MDAKQEAgLTIzNyw3
ICsyMzcsNyBAQCBzdGF0aWMgc3RydWN0IG9wdGlvbiBsb25nb3B0c1tdID0KIAl7ICJhbGwi
LCAwLCAwLCAndicgfSwKIAl7ICJhdXRvIiwgMCwgMCwgJ1wzJyB9LAogCXsgImNsaWVudCIs
IDAsIDAsICdjJyB9LAotCXsgIm1vdW50cyIsIDAsIDAsICdtJyB9LAorCXsgIm1vdW50ZWQi
LCAwLCAwLCAnbScgfSwKIAl7ICJuZnMiLCAwLCAwLCAnbicgfSwKIAl7ICJycGMiLCAwLCAw
LCAncicgfSwKIAl7ICJzZXJ2ZXIiLCAwLCAwLCAncycgfSwK
--------------050104020500060608050100
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------050104020500060608050100
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--------------050104020500060608050100--



