From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [BUG][PATCH] lockd won't work 248 days after booting.
Date: Thu, 07 Nov 2002 18:35:16 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021107.183516.95909668.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189jCQ-00060m-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Nov 2002 01:43:42 -0800
Received: from localhost (gw1.valinux.co.jp [202.221.173.98])
	by sv1.valinux.co.jp (Postfix) with ESMTP id C2C1670021
	for <nfs@lists.sourceforge.net>; Thu,  7 Nov 2002 18:43:35 +0900 (JST)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

I think lockd has jiffies wraparound problems.
It's wrong that lockd set some timers to zero in hope that
it'll exipre soon. But time_before() and time_after() won't
work 248 days after booting.

We should initialize them to jiffies instead of zero.

The following patch can be applied against 2.5.46 and 2.4.19.

Thank you,
Hirokazu Takahashi.


--- fs/lockd/host.c.JIF	Tue Nov  5 16:49:38 2030
+++ fs/lockd/host.c	Tue Nov  5 17:04:41 2030
@@ -128,7 +128,7 @@ nlm_lookup_host(int server, struct socka
 	nlm_hosts[hash]    = host;
 
 	if (++nrhosts > NLM_HOST_MAX)
-		next_gc = 0;
+		next_gc = jiffies;
 
 nohost:
 	up(&nlm_host_sema);
@@ -276,7 +276,7 @@ nlm_shutdown_hosts(void)
 	dprintk("lockd: nuking all hosts...\n");
 	for (i = 0; i < NLM_HOST_NRHASH; i++) {
 		for (host = nlm_hosts[i]; host; host = host->h_next)
-			host->h_expires = 0;
+			host->h_expires = jiffies;
 	}
 
 	/* Then, perform a garbage collection pass */
--- fs/lockd/svcsubs.c.JIF	Tue Nov  5 16:50:03 2030
+++ fs/lockd/svcsubs.c	Tue Nov  5 16:57:43 2030
@@ -302,7 +302,7 @@ nlmsvc_invalidate_all(void)
 	struct nlm_host *host;
 	while ((host = nlm_find_client()) != NULL) {
 		nlmsvc_free_host_resources(host);
-		host->h_expires = 0;
+		host->h_expires = jiffies;
 		host->h_killed = 1;
 		nlm_release_host(host);
 	}
--- fs/lockd/clntlock.c.JIF	Thu Nov  7 13:01:38 2030
+++ fs/lockd/clntlock.c	Thu Nov  7 13:02:07 2030
@@ -167,7 +167,7 @@ void nlmclnt_prepare_reclaim(struct nlm_
 	host->h_monitored = 0;
 	host->h_nsmstate = newstate;
 	host->h_state++;
-	host->h_nextrebind = 0;
+	host->h_nextrebind = jiffies;
 	nlm_rebind_host(host);
 	nlmclnt_mark_reclaim(host);
 	dprintk("NLM: reclaiming locks for host %s", host->h_name);


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
