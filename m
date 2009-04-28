From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] sm-notify: Failed DNS lookups should be retried
Date: Tue, 28 Apr 2009 17:36:58 -0400
Message-ID: <20090428213658.16098.19837.stgit@ingres.1015granger.net>
References: <20090428213453.16098.33168.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:41091 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551AbZD1Vif (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 17:38:35 -0400
In-Reply-To: <20090428213453.16098.33168.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, if getaddrinfo(3) fails when trying to resolve a hostname,
sm-notify gives up immediately on that host.  If sm-notify is started
before network service is available on a system, that means it quits
without notifying anyone.  Or, if DNS service isn't available due to
a network partition or because the DNS server crashed, sm-notify will
simply remove all of its callback files and exit.

Really, sm-notify should try harder.  We know that the hostnames
passed in to notify_host() have already been vetted by statd, which
won't monitor a hostname that it can't resolve.  So it's likely that
any DNS failure we meet here is a temporary condition.  If it isn't,
then sm-notify will stop trying to notify that host in 15 minutes
anyway.

[ The host's file is left in /var/lib/nfs/sm.bak in this case, but
  sm.bak is not read again until the next time sm-notify runs. ]

sm-notify already has retry logic for handling RPC timeouts.  We can
co-opt that to drive DNS resolution retries.

We also add AI_ADDRCONFIG because on systems whose network startup is
handled by NetworkManager, there appears to be a bug that causes
processes that started calling getaddinfo(3) before the network came
up to continue getting EAI_AGAIN even after the network is fully
operating.

As I understand it, legacy glibc (before AI_ADDRCONFIG was exposed in
headers) sets AI_ADDRCONFIG by default, although I haven't checked
this.  In any event, pre-glibc-2.2 systems probably won't run
NetworkManager anyway, so this may not be much of a problem for them.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   39 +++++++++++++++++++++++++++------------
 1 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 78d0a59..72dcff4 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -118,17 +118,33 @@ static void smn_set_port(struct sockaddr *sap, const unsigned short port)
 	}
 }
 
-static struct addrinfo *smn_lookup(const sa_family_t family, const char *name)
+static struct addrinfo *smn_lookup(const char *name)
 {
 	struct addrinfo	*ai, hint = {
-		.ai_family	= family,
+#if HAVE_DECL_AI_ADDRCONFIG
+		.ai_flags	= AI_ADDRCONFIG,
+#endif	/* HAVE_DECL_AI_ADDRCONFIG */
+		.ai_family	= AF_INET,
 		.ai_protocol	= IPPROTO_UDP,
 	};
+	int error;
+
+	error = getaddrinfo(name, NULL, &hint, &ai);
+	switch (error) {
+	case 0:
+		return ai;
+	case EAI_SYSTEM: 
+		if (opt_debug)
+			nsm_log(LOG_ERR, "getaddrinfo(3): %s",
+					strerror(errno));
+		break;
+	default:
+		if (opt_debug)
+			nsm_log(LOG_ERR, "getaddrinfo(3): %s",
+					gai_strerror(error));
+	}
 
-	if (getaddrinfo(name, NULL, &hint, &ai) != 0)
-		return NULL;
-
-	return ai;
+	return NULL;
 }
 
 static void smn_forget_host(struct nsm_host *host)
@@ -291,7 +307,7 @@ notify(void)
 
 	/* Bind source IP if provided on command line */
 	if (opt_srcaddr) {
-		struct addrinfo *ai = smn_lookup(AF_INET, opt_srcaddr);
+		struct addrinfo *ai = smn_lookup(opt_srcaddr);
 		if (!ai) {
 			nsm_log(LOG_ERR,
 				"Not a valid hostname or address: \"%s\"",
@@ -402,13 +418,12 @@ notify_host(int sock, struct nsm_host *host)
 		host->xid = xid++;
 
 	if (host->ai == NULL) {
-		host->ai = smn_lookup(AF_UNSPEC, host->name);
+		host->ai = smn_lookup(host->name);
 		if (host->ai == NULL) {
 			nsm_log(LOG_WARNING,
-				"%s doesn't seem to be a valid address,"
-				" skipped", host->name);
-			smn_forget_host(host);
-			return 1;
+				"DNS resolution of %s failed; "
+				"retrying later", host->name);
+			return 0;
 		}
 	}
 

