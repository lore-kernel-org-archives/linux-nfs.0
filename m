From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 9] knfsd: knfsd: Remove an unused variable from
	auth_unix_lookup()
Date: Tue, 25 Jul 2006 11:54:37 +1000
Message-ID: <1060725015437.21933@suse.de>
References: <20060725114207.21779.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5C8i-0004aZ-Hz
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:16 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5C8i-0003zV-Hj
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:17 -0700
To: Andrew Morton <akpm@osdl.org>
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


From: Greg Banks <gnb@melbourne.sgi.com>

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcauth_unix.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff .prev/net/sunrpc/svcauth_unix.c ./net/sunrpc/svcauth_unix.c
--- .prev/net/sunrpc/svcauth_unix.c	2006-07-24 14:33:40.000000000 +1000
+++ ./net/sunrpc/svcauth_unix.c	2006-07-24 14:33:40.000000000 +1000
@@ -348,12 +348,9 @@ int auth_unix_forget_old(struct auth_dom
 
 struct auth_domain *auth_unix_lookup(struct in_addr addr)
 {
-	struct ip_map key, *ipm;
+	struct ip_map *ipm;
 	struct auth_domain *rv;
 
-	strcpy(key.m_class, "nfsd");
-	key.m_addr = addr;
-
 	ipm = ip_map_lookup("nfsd", addr);
 
 	if (!ipm)

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
