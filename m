From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/24] statd: Support IPv6 in sm_mon_1_svc()
Date: Thu, 14 Jan 2010 12:31:37 -0500
Message-ID: <20100114173137.26079.97265.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:37152 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757376Ab0ANRcK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:32:10 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace deprecated gethostbyname(3) and gethostbyaddr(3) calls in
monitor.c, and address a couple of memory leaks.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/monitor.c |   22 +++++++++-------------
 1 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index fb32196..11afe08 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -71,8 +71,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
 	};
-	char		*dnsname;
-	struct hostent	*hostinfo = NULL;
+	char *dnsname = NULL;
 
 	xlog(D_CALL, "Received SM_MON for %s from %s", mon_name, my_name);
 
@@ -114,9 +113,6 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 		     "or starting '.': %s", mon_name);
 		xlog(L_ERROR, "POSSIBLE SPOOF/ATTACK ATTEMPT!");
 		goto failure;
-	} else if ((hostinfo = gethostbyname(mon_name)) == NULL) {
-		xlog_warn("gethostbyname error for %s", mon_name);
-		goto failure;
 	}
 
 	/* my_name must not have white space */
@@ -129,15 +125,13 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	 * Now choose a hostname to use for matching.  We cannot
 	 * really trust much in the incoming NOTIFY, so to make
 	 * sure that multi-homed hosts work nicely, we get an
-	 * FQDN now, and use that for matching
+	 * FQDN now, and use that for matching.
 	 */
-	hostinfo = gethostbyaddr(hostinfo->h_addr,
-				 hostinfo->h_length,
-				 hostinfo->h_addrtype);
-	if (hostinfo)
-		dnsname = xstrdup(hostinfo->h_name);
-	else
-		dnsname = xstrdup(my_name);
+	dnsname = statd_canonical_name(mon_name);
+	if (dnsname == NULL) {
+		xlog(L_WARNING, "No canonical hostname found for %s", mon_name);
+		goto failure;
+	}
 
 	/* Now check to see if this is a duplicate, and warn if so.
 	 * I will also return STAT_FAIL. (I *think* this is how I should
@@ -163,6 +157,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 				mon_name, my_name);
 
 			/* But we'll let you pass anyway. */
+			free(dnsname);
 			goto success;
 		}
 		clnt = NL_NEXT(clnt);
@@ -173,6 +168,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	 * doesn't fail.  (I should probably fix this assumption.)
 	 */
 	if (!(clnt = nlist_new(my_name, mon_name, 0))) {
+		free(dnsname);
 		xlog_warn("out of memory");
 		goto failure;
 	}

