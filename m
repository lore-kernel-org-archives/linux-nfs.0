From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Subject: lockd jiffies fixes
Date: Tue, 10 Jan 2006 14:45:53 +0900
Message-ID: <1136871953.120927.9448.nullmailer@yamt.dyndns.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed; boundary="NextPart-20060110144245-0654100"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EwCKp-0006lk-Du
	for nfs@lists.sourceforge.net; Mon, 09 Jan 2006 21:46:19 -0800
Received: from fla1adj210.kng.mesh.ad.jp ([60.236.232.210] helo=yamt.dyndns.org)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EwCKo-0005lI-0z
	for nfs@lists.sourceforge.net; Mon, 09 Jan 2006 21:46:19 -0800
To: neilb@suse.de
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

--NextPart-20060110144245-0654100
Content-Type: Text/Plain; charset=us-ascii

hi,

linux lockd has some code to initialize jiffies-relative variables with 0.
the attached patch fixes them.

YAMAMOTO Takashi

--NextPart-20060110144245-0654100
Content-Type: Text/Plain; charset=us-ascii
Content-Disposition: attachment;
 filename="vaj_2.6.12.6_lockd-jiffies-fix__0.patch"

--- linux/fs/lockd/host.c.BACKUP.LIST-2002.8	2005-11-25 10:36:35.000000000 +0900
+++ linux/fs/lockd/host.c	2005-11-25 10:36:58.000000000 +0900
@@ -125,7 +125,7 @@ nlm_lookup_host(int server, struct socka
 	spin_lock_init(&host->h_lock);
 
 	if (++nrhosts > NLM_HOST_MAX)
-		next_gc = 0;
+		next_gc = jiffies;
 
 nohost:
 	up(&nlm_host_sema);
--- linux/fs/lockd/svcsubs.c.BACKUP.LIST-2002.8	2005-11-25 10:36:35.000000000 +0900
+++ linux/fs/lockd/svcsubs.c	2005-11-25 10:36:58.000000000 +0900
@@ -302,7 +302,7 @@ nlmsvc_invalidate_all(void)
 	struct nlm_host *host;
 	while ((host = nlm_find_client()) != NULL) {
 		nlmsvc_free_host_resources(host);
-		host->h_expires = 0;
+		host->h_expires = jiffies;
 		host->h_killed = 1;
 		nlm_release_host(host);
 	}
--- linux/fs/lockd/clntlock.c.BACKUP.LIST-2002.8	2005-11-25 10:36:35.000000000 +0900
+++ linux/fs/lockd/clntlock.c	2005-11-25 10:36:59.000000000 +0900
@@ -164,7 +164,7 @@ void nlmclnt_prepare_reclaim(struct nlm_
 	host->h_monitored = 0;
 	host->h_nsmstate = newstate;
 	host->h_state++;
-	host->h_nextrebind = 0;
+	host->h_nextrebind = jiffies;
 	nlm_rebind_host(host);
 	nlmclnt_mark_reclaim(host);
 	dprintk("NLM: reclaiming locks for host %s", host->h_name);

--NextPart-20060110144245-0654100--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
