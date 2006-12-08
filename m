From: NeilBrown <neilb@suse.de>
Subject: [PATCH 017 of 18] knfsd: Don't ignore kstrdup failure in rpc
	caches.
Date: Fri, 8 Dec 2006 12:14:51 +1100
Message-ID: <1061208011451.30761@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUJy-0003F8-Pj
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:38 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUJz-0001Kc-N7
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:40 -0800
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



Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcauth_unix.c |    4 ++++
 1 file changed, 4 insertions(+)

diff .prev/net/sunrpc/svcauth_unix.c ./net/sunrpc/svcauth_unix.c
--- .prev/net/sunrpc/svcauth_unix.c	2006-12-08 12:08:37.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2006-12-08 12:09:31.000000000 +1100
@@ -53,6 +53,10 @@ struct auth_domain *unix_domain_find(cha
 			return NULL;
 		kref_init(&new->h.ref);
 		new->h.name = kstrdup(name, GFP_KERNEL);
+		if (new->h.name == NULL) {
+			kfree(new);
+			return NULL;
+		}
 		new->h.flavour = &svcauth_unix;
 		new->addr_changes = 0;
 		rv = auth_domain_lookup(name, &new->h);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
