From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 16/22] [lockd] make nlmclnt_next_cookie SMP safe
Date: Sat, 5 Aug 2006 15:06:48 +0200
Message-ID: <20060805130648.GA8097@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrm-00079s-Rd
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:58 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lrm-0003MY-DG
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:59 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id E30D11FFDD
	for <nfs@lists.sourceforge.net>; Sat,  5 Aug 2006 15:06:48 +0200 (CEST)
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

From: Olaf Kirch <okir@suse.de>
Subject: [lockd] make nlmclnt_next_cookie SMP safe

  The way we incremented the NLM cookie in nlmclnt_next_cookie
  was not thread safe. This patch changes the counter to an
  atomic_t

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/lockd/clntproc.c         |   10 +++++-----
 include/linux/lockd/lockd.h |    3 ++-
 2 files changed, 7 insertions(+), 6 deletions(-)

Index: build/fs/lockd/clntproc.c
===================================================================
--- build.orig/fs/lockd/clntproc.c
+++ build/fs/lockd/clntproc.c
@@ -36,14 +36,14 @@ static const struct rpc_call_ops nlmclnt
 /*
  * Cookie counter for NLM requests
  */
-static u32	nlm_cookie = 0x1234;
+static atomic_t	nlm_cookie = ATOMIC_INIT(0x1234);
 
-static inline void nlmclnt_next_cookie(struct nlm_cookie *c)
+void nlmclnt_next_cookie(struct nlm_cookie *c)
 {
-	memcpy(c->data, &nlm_cookie, 4);
-	memset(c->data+4, 0, 4);
+	u32	cookie = atomic_inc_return(&nlm_cookie);
+
+	memcpy(c->data, &cookie, 4);
 	c->len=4;
-	nlm_cookie++;
 }
 
 static struct nlm_lockowner *nlm_get_lockowner(struct nlm_lockowner *lockowner)
Index: build/include/linux/lockd/lockd.h
===================================================================
--- build.orig/include/linux/lockd/lockd.h
+++ build/include/linux/lockd/lockd.h
@@ -159,6 +159,7 @@ int		  nlmclnt_block(struct nlm_wait *bl
 u32		  nlmclnt_grant(const struct sockaddr_in *addr, const struct nlm_lock *);
 void		  nlmclnt_recovery(struct nlm_host *);
 int		  nlmclnt_reclaim(struct nlm_host *, struct file_lock *);
+void		  nlmclnt_next_cookie(struct nlm_cookie *);
 
 /*
  * Host cache

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
