From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 19] knfsd: Misc minor fixes, indentation changes
Date: Fri, 1 Sep 2006 14:38:32 +1000
Message-ID: <1060901043832.27476@suse.de>
References: <20060901141639.27206.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ0nj-0005lx-70
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:38:43 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ0ni-0001Je-Cq
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:38:43 -0700
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


From: Olaf Kirch <okir@suse.de>

This cleans up some code in lockd/host.c, fixes an error printk
and makes it a fatal BUG if nlmsvc_free_host_resources fails.

Signed-off-by: Olaf Kirch <okir@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/host.c    |   15 ++++++---------
 ./fs/lockd/svcsubs.c |    8 +++++---
 2 files changed, 11 insertions(+), 12 deletions(-)

diff .prev/fs/lockd/host.c ./fs/lockd/host.c
--- .prev/fs/lockd/host.c	2006-08-31 17:00:03.000000000 +1000
+++ ./fs/lockd/host.c	2006-08-31 17:01:00.000000000 +1000
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

diff .prev/fs/lockd/svcsubs.c ./fs/lockd/svcsubs.c
--- .prev/fs/lockd/svcsubs.c	2006-08-31 17:01:00.000000000 +1000
+++ ./fs/lockd/svcsubs.c	2006-08-31 17:01:00.000000000 +1000
@@ -115,7 +115,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
 	 * the file.
 	 */
 	if ((nfserr = nlmsvc_ops->fopen(rqstp, f, &file->f_file)) != 0) {
-		dprintk("lockd: open failed (nfserr %d)\n", ntohl(nfserr));
+		dprintk("lockd: open failed (error %d)\n", nfserr);
 		goto out_free;
 	}
 
@@ -313,10 +313,12 @@ nlmsvc_free_host_resources(struct nlm_ho
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
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
