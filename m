From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 20] knfsd: nfsd4: build rpcsec_gss whenever
	nfsd4 is built
Date: Tue, 10 Jul 2007 12:23:04 +1000
Message-ID: <1070710022304.12950@suse.de>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J . Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I85No-0004ls-Q7
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:23:21 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85Nq-000391-U8
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:23:24 -0700
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


From: J. Bruce Fields <bfields@citi.umich.edu>

Select rpcsec_gss support whenever asked for NFSv4 support.  The rfc
actually requires gss, and gss is also the main reason to migrate to v4.
We already do this on the client side.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff .prev/fs/Kconfig ./fs/Kconfig
--- .prev/fs/Kconfig	2007-07-10 11:19:59.000000000 +1000
+++ ./fs/Kconfig	2007-07-10 11:26:04.000000000 +1000
@@ -1725,6 +1725,7 @@ config NFSD_V3_ACL
 config NFSD_V4
 	bool "Provide NFSv4 server support (EXPERIMENTAL)"
 	depends on NFSD_V3 && EXPERIMENTAL
+	select RPCSEC_GSS_KRB5
 	help
 	  If you would like to include the NFSv4 server as well as the NFSv2
 	  and NFSv3 servers, say Y here.  This feature is experimental, and

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
