Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:35403 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755040Ab1ILWHJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 18:07:09 -0400
Received: by mail-gw0-f46.google.com with SMTP id 15so442001gwb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2011 15:07:09 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/8] sm-notify: sm-notify leaves monitor records in sm.bak
To: linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 18:07:07 -0400
Message-ID: <20110912220707.10854.51509.stgit@matisse.1015granger.net>
In-Reply-To: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
References: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

sm-notify fails to remove monitor records from sm.bak when it has
finally notified a host.  This is because of a recent change to send
two SM_NOTIFY requests for each monitored peer: one with the local
host's FQDN, and one with an unqualified version of same.  This was
commit baa41b2c: "sm-notify: Send fully-qualified and unqualified
mon_names" (March 19, 2010).

Because of the March 2010 commit, sm-notify modifies the "my_name"
string during notification, but then uses this modified string to try
to find the monitor record to remove.  Of course the search for the
record fails.  So a persistent monitor record is left in sm.bak.

Aside from leaving trash around, this causes the same hosts to be
notified after every reboot, even if they successfully responded to
the previous SM_NOTIFY and they had no contact with us during the last
boot.

I also noticed that the trick of truncating the argument of SM_NOTIFY
doesn't work at all if a substitute "my_name" was specified via the "-v"
command line option.  This patch attempts to address that as well.

sm-notify should preserve the original my_name string so that
nsm_delete_host() can find the correct monitor record to delete.  Also
add some degree of protection to the mon_name and my_name strings in
each nsm_host record to prevent a future change from breaking this
dependency.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   35 ++++++++++++++++++++++-------------
 1 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 690ec2a..a3290aa 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -45,8 +45,9 @@
 struct nsm_host {
 	struct nsm_host *	next;
 	char *			name;
-	char *			mon_name;
-	char *			my_name;
+	const char *		mon_name;
+	const char *		my_name;
+	char *			notify_arg;
 	struct addrinfo		*ai;
 	time_t			last_used;
 	time_t			send_next;
@@ -199,14 +200,23 @@ smn_alloc_host(const char *hostname, const char *mon_name,
 	if (host == NULL)
 		goto out_nomem;
 
+	/*
+	 * mon_name and my_name are preserved so sm-notify can
+	 * find the right monitor record to remove when it is
+	 * done processing this host.
+	 */
 	host->name = strdup(hostname);
-	host->mon_name = strdup(mon_name);
-	host->my_name = strdup(my_name);
+	host->mon_name = (const char *)strdup(mon_name);
+	host->my_name = (const char *)strdup(my_name);
+	host->notify_arg = strdup(opt_srcaddr != NULL ?
+					nsm_hostname : my_name);
 	if (host->name == NULL ||
 	    host->mon_name == NULL ||
-	    host->my_name == NULL) {
-		free(host->my_name);
-		free(host->mon_name);
+	    host->my_name == NULL ||
+	    host->notify_arg == NULL) {
+		free(host->notify_arg);
+		free((void *)host->my_name);
+		free((void *)host->mon_name);
 		free(host->name);
 		free(host);
 		goto out_nomem;
@@ -230,8 +240,9 @@ static void smn_forget_host(struct nsm_host *host)
 
 	nsm_delete_notified_host(host->name, host->mon_name, host->my_name);
 
-	free(host->my_name);
-	free(host->mon_name);
+	free(host->notify_arg);
+	free((void *)host->my_name);
+	free((void *)host->mon_name);
 	free(host->name);
 	if (host->ai)
 		freeaddrinfo(host->ai);
@@ -635,8 +646,6 @@ notify(const int sock)
 static int
 notify_host(int sock, struct nsm_host *host)
 {
-	const char *my_name = (opt_srcaddr != NULL ?
-					nsm_hostname : host->my_name);
 	struct sockaddr *sap;
 	socklen_t salen;
 
@@ -682,7 +691,7 @@ notify_host(int sock, struct nsm_host *host)
 		host->xid = nsm_xmit_rpcbind(sock, sap, SM_PROG, SM_VERS);
 	else
 		host->xid = nsm_xmit_notify(sock, sap, salen,
-					SM_PROG, my_name, nsm_state);
+					SM_PROG, host->notify_arg, nsm_state);
 
 	return 0;
 }
@@ -736,7 +745,7 @@ recv_rpcbind_reply(struct sockaddr *sap, struct nsm_host *host, XDR *xdr)
 static void
 recv_notify_reply(struct nsm_host *host)
 {
-	char *dot = strchr(host->my_name, '.');
+	char *dot = strchr(host->notify_arg, '.');
 
 	if (dot != NULL) {
 		*dot = '\0';

