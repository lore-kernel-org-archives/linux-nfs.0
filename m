From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/24] sm-notify: Save mon_name and my_name strings
Date: Thu, 14 Jan 2010 12:31:02 -0500
Message-ID: <20100114173102.26079.84489.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:43560 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757392Ab0ANRbW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:22 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently sm-notify does not use the mon_name and my_name strings
passed to smn_get_host().  Very soon we're going to need the mon_name
and my_name strings, so add code to store those strings in struct
nsm_host, and free them when each host is forgotten.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 66a52eb..70d94a8 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -44,6 +44,8 @@
 struct nsm_host {
 	struct nsm_host *	next;
 	char *			name;
+	char *			mon_name;
+	char *			my_name;
 	struct addrinfo		*ai;
 	time_t			last_used;
 	time_t			send_next;
@@ -93,7 +95,8 @@ smn_lookup(const char *name)
 
 __attribute_malloc__
 static struct nsm_host *
-smn_alloc_host(const char *hostname, const time_t timestamp)
+smn_alloc_host(const char *hostname, const char *mon_name,
+		const char *my_name, const time_t timestamp)
 {
 	struct nsm_host	*host;
 
@@ -102,7 +105,14 @@ smn_alloc_host(const char *hostname, const time_t timestamp)
 		goto out_nomem;
 
 	host->name = strdup(hostname);
-	if (host->name == NULL) {
+	host->mon_name = strdup(mon_name);
+	host->my_name = strdup(my_name);
+	if (host->name == NULL ||
+	    host->mon_name == NULL ||
+	    host->my_name == NULL) {
+		free(host->my_name);
+		free(host->mon_name);
+		free(host->name);
 		free(host);
 		goto out_nomem;
 	}
@@ -124,6 +134,8 @@ static void smn_forget_host(struct nsm_host *host)
 
 	nsm_delete_notified_host(host->name);
 
+	free(host->my_name);
+	free(host->mon_name);
 	free(host->name);
 	if (host->ai)
 		freeaddrinfo(host->ai);
@@ -134,12 +146,12 @@ static void smn_forget_host(struct nsm_host *host)
 static unsigned int
 smn_get_host(const char *hostname,
 		__attribute__ ((unused)) const struct sockaddr *sap,
-		__attribute__ ((unused)) const struct mon *m,
-		const time_t timestamp)
+		const struct mon *m, const time_t timestamp)
 {
 	struct nsm_host	*host;
 
-	host = smn_alloc_host(hostname, timestamp);
+	host = smn_alloc_host(hostname,
+		m->mon_id.mon_name, m->mon_id.my_id.my_name, timestamp);
 	if (host == NULL)
 		return 0;
 

