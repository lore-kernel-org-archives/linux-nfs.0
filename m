From: Neil Brown <neilb@suse.de>
Subject: [PATCH] sm-notify: perform DNS lookup in the background.
Date: Tue, 15 Jul 2008 16:21:46 +1000
Message-ID: <18556.16890.235207.711721@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:56096 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753761AbYGOGVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 02:21:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi Steve,
 if you agree with the following patch, it can be pulled from

  git://neil.brown.name/nfs-utils for-steved


Thanks,
NeilBrown


From: Neil Brown <neilb@suse.de>
Date: Tue, 15 Jul 2008 06:11:55 +1000
Subject: [PATCH] sm-notify: perform DNS lookup in the background.

If an NFS server has no network connectivity when it reboots,
it will block in sm-notify waiting for DNS lookup for a potentially
large number of hosts.  This is not helpful and just annoys the
sysadmin.

So do the DNS lookup in the backgrounded phase of sm-notify,
before sending off the NOTIFY requests.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 utils/statd/sm-notify.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index bb67c37..8e00aac 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -286,6 +286,20 @@ notify(void)
 			hp = hosts;
 			hosts = hp->next;
 
+			if (hp->ai == NULL)
+				hp->ai = host_lookup(AF_UNSPEC, hp->name);
+			if (hp->ai == NULL) {
+				nsm_log(LOG_WARNING,
+					"%s doesn't seem to be a valid address,"
+					" skipped",
+					hp->name);
+				unlink(hp->path);
+				free(hp->name);
+				free(hp->path);
+				free(hp);
+				continue;
+			}
+
 			notify_host(sock, hp);
 
 			/* Set the timeout for this call, using an
@@ -532,15 +546,6 @@ get_hosts(const char *dirname)
 		if (stat(path, &stb) < 0)
 			continue;
 
-		host->ai = host_lookup(AF_UNSPEC, de->d_name);
-		if (! host->ai) {
-			nsm_log(LOG_WARNING,
-				"%s doesn't seem to be a valid address, skipped",
-				de->d_name);
-			unlink(path);
-			continue;
-		}
-
 		host->last_used = stb.st_mtime;
 		host->timeout = NSM_TIMEOUT;
 		host->path = strdup(path);
-- 
1.5.6.2

