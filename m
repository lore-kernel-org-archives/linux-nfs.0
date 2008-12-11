From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] sm-notify command: fix a use-after-free bug
Date: Thu, 11 Dec 2008 13:33:43 -0500
Message-ID: <20081211183343.6882.36272.stgit@ingres.1015granger.net>
References: <20081211182820.6882.20716.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:39829 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755834AbYLKSeZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 13:34:25 -0500
In-Reply-To: <20081211182820.6882.20716.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The recv_reply() function was referencing host->ai in a freeaddrinfo(3)
call after it had freed @host.

This is not likely to be harmful in a single-threaded user context,
but it's still bad form, and it will get called out if testing
sm-notify with poisoned free memory.  The less noise, the better we
are able to see real problems.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 9342bad..943caf8 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -133,6 +133,17 @@ static struct addrinfo *smn_lookup(const sa_family_t family, const char *name)
 	return ai;
 }
 
+static void smn_forget_host(struct nsm_host *host)
+{
+	unlink(host->path);
+	free(host->path);
+	free(host->name);
+	if (host->ai)
+		freeaddrinfo(host->ai);
+
+	free(host);
+}
+
 int
 main(int argc, char **argv)
 {
@@ -342,13 +353,8 @@ notify(void)
 			hp = hosts;
 			hosts = hp->next;
 
-			if (notify_host(sock, hp)){
-				unlink(hp->path);
-				free(hp->name);
-				free(hp->path);
-				free(hp);
+			if (notify_host(sock, hp))
 				continue;
-			}
 
 			/* Set the timeout for this call, using an
 			   exponential timeout strategy */
@@ -403,6 +409,7 @@ notify_host(int sock, struct nsm_host *host)
 			nsm_log(LOG_WARNING,
 				"%s doesn't seem to be a valid address,"
 				" skipped", host->name);
+			smn_forget_host(host);
 			return 1;
 		}
 	}
@@ -547,11 +554,7 @@ recv_reply(int sock)
 		if (p <= end) {
 			nsm_log(LOG_DEBUG, "Host %s notified successfully",
 					hp->name);
-			unlink(hp->path);
-			free(hp->name);
-			free(hp->path);
-			free(hp);
-			freeaddrinfo(hp->ai);
+			smn_forget_host(hp);
 			return;
 		}
 	}

