From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: [PATCH] Make mountd complain on unsupported uid mapping
	schemes
Date: Sat, 23 Dec 2006 13:28:20 +0100
Message-ID: <20061223122820.GA1145@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gy5z7-000628-9j
	for nfs@lists.sourceforge.net; Sat, 23 Dec 2006 04:28:17 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gy5z7-0002tO-HE
	for nfs@lists.sourceforge.net; Sat, 23 Dec 2006 04:28:18 -0800
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1Gy5z0-0005gl-76
	for nfs@lists.sourceforge.net; Sat, 23 Dec 2006 13:28:10 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1Gy5zA-0000Io-00
	for <nfs@lists.sourceforge.net>; Sat, 23 Dec 2006 13:28:20 +0100
To: nfs@lists.sourceforge.net
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

[As usual, please Cc me on any replies]

I just put the following patch into Debian's nfs-utils; I thought it might be
useful for upstream as well:

  The NFS kernel server does not support uid mappings, activated with flags
  such as "map_daemon" in exports. There is already code that parses these
  flags, and gives an error at mount time if an unsupported flag (ie. any
  but the default) is given. However, at some point the kernel changed the
  export interface, and the new code forgot to include the relevant check.
  Thus, simply copy the check from the old to the new code, which makes
  sure mountd behaves the same in this aspect regardless of kernel version,
  and makes sure the admin does not inadvertently use map_daemon and expect
  it to work.

  Signed-off-by: Steinar H. Gunderson <sesse@debian.org>

--- nfs-utils-1.0.10.orig/utils/mountd/cache.c
+++ nfs-utils-1.0.10/utils/mountd/cache.c
@@ -381,6 +381,12 @@
 {
 	FILE *f;
 
+	if (exp->m_export.e_maptype != CLE_MAP_IDENT) {
+		xlog(L_ERROR, "%s: unsupported mapping; kernel supports only 'identity' (default)",
+		    exp->m_export.m_path);
+		return;
+	}
+
 	f = fopen("/proc/net/rpc/auth.unix.ip/channel", "w");
 	if (!f)
 		return;

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
