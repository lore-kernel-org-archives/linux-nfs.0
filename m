From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 6/22] Misc minor fixes, indentation changes
Date: Sat, 5 Aug 2006 15:06:48 +0200
Message-ID: <20060805130648.GA8044@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrh-00078y-CJ
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:53 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lrh-0000U0-AO
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:53 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 31FA41FFCC
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
Subject: Misc minor fixes, indentation changes

This cleans up some code in lockd/host.c, fixes an error printk
and makes it a fatal BUG if nlmsvc_free_host_resources fails.

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/lockd/host.c    |   15 ++++++---------
 fs/lockd/svcsubs.c |    8 +++++---
 2 files changed, 11 insertions(+), 12 deletions(-)

Index: build/fs/lockd/host.c
===================================================================
--- build.orig/fs/lockd/host.c
+++ build/fs/lockd/host.c
@@ -110,16 +110,13 @@ nlm_lookup_host(int server, const struct
 		if (host->h_server != server)
 			continue;
 
-		{
-			if (hp != nlm_hosts + hash) {
-				*hp = host->h_next;
-				host->h_next = nlm_hosts[hash];
-				nlm_hosts[hash] = host;
-			}
-			nlm_get_host(host);
-			mutex_unlock(&nlm_host_mutex);
-			return host;
+		if (hp != nlm_hosts + hash) {
+			*hp = host->h_next;
+			host->h_next = nlm_hosts[hash];
+			nlm_hosts[hash] = host;
 		}
+		nlm_get_host(host);
+		goto out;
 	}
 
 	/* Sadly, the host isn't in our hash table yet. See if
Index: build/fs/lockd/svcsubs.c
===================================================================
--- build.orig/fs/lockd/svcsubs.c
+++ build/fs/lockd/svcsubs.c
@@ -116,7 +116,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
 	 * the file.
 	 */
 	if ((nfserr = nlmsvc_ops->fopen(rqstp, f, &file->f_file)) != 0) {
-		dprintk("lockd: open failed (nfserr %d)\n", ntohl(nfserr));
+		dprintk("lockd: open failed (error %d)\n", nfserr);
 		goto out_free;
 	}
 
@@ -311,10 +311,12 @@ nlmsvc_free_host_resources(struct nlm_ho
 {
 	dprintk("lockd: nlmsvc_free_host_resources\n");
 
-	if (nlm_traverse_files(host, NLM_ACT_UNLOCK))
+	if (nlm_traverse_files(host, NLM_ACT_UNLOCK)) {
 		printk(KERN_WARNING
-			"lockd: couldn't remove all locks held by %s",
+			"lockd: couldn't remove all locks held by %s\n",
 			host->h_name);
+		BUG();
+	}
 }
 
 /*

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
