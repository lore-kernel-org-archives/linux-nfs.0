From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/26] statd: Support IPv6 in sm_mon_1_svc()
Date: Tue, 13 Oct 2009 10:58:11 -0400
Message-ID: <20091013145811.2424.8971.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:53960 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760058AbZJMO64 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:58:56 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DExXPJ016830
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:59:35 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DDgcQS032065
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:58:18 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace deprecated gethostbyname(3) and gethostbyaddr(3) calls.

Handle IPv6 remotes and IDN labels properly.  At least with fairly
recent glibc's we are guaranteed that the returned hostnames will
contain only ASCII characters, allowing DNS labels to continue to be
used as file names as IDNs become commonplace.

Also address a couple of memory leaks.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/hostname.c |   30 ++++++++++++++++++++++++++++++
 utils/statd/monitor.c  |   31 ++++++++++++++++++-------------
 utils/statd/statd.h    |    2 ++
 3 files changed, 50 insertions(+), 13 deletions(-)

diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
index 0148b9d..7d9ed45 100644
--- a/utils/statd/hostname.c
+++ b/utils/statd/hostname.c
@@ -149,6 +149,36 @@ get_addrinfo(const char *hostname, const struct addrinfo* gai_hint)
 	return NULL;
 }
 
+/**
+ * nsm_forward_lookup - hostname or presentation address to sockaddr list
+ * @hostname: C string containing hostname or presentation address
+ *
+ * Returns addrinfo list, including the host's canonical DNS name,
+ * or NULL if an error occurs.  Caller must free addrinfo list via
+ * freeaddrinfo(3).
+ *
+ * AI_ADDRCONFIG should prevent us from monitoring a host that we can't
+ * reach.  If IPv6 is not enabled on this system, then we don't want to
+ * monitor remote hosts that have only IPv6 addresses.
+ */
+struct addrinfo *
+nsm_forward_lookup(const char *hostname)
+{
+	static const struct addrinfo gai_hint = {
+#ifdef IPV6_SUPPORTED
+		.ai_family	= AF_UNSPEC,
+		.ai_flags	= AI_CANONNAME | AI_ADDRCONFIG |
+				  AI_IDN | AI_IDN_USE_STD3_ASCII_RULES,
+#else	/* !IPV6_SUPPORTED */
+		.ai_family	= AF_INET,
+		.ai_flags	= AI_CANONNAME |
+				  AI_IDN | AI_IDN_USE_STD3_ASCII_RULES,
+#endif	/* !IPV6_SUPPORTED */
+	};
+
+	return get_addrinfo(hostname, &gai_hint);
+}
+
 #ifdef IPV6_SUPPORTED
 static int
 compare_sockaddrs(const struct sockaddr *sa1, const struct sockaddr *sa2)
diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index 3db7ce8..df3206a 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -72,8 +72,8 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 		.sin_family		= AF_INET,
 		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
 	};
-	char		*dnsname;
-	struct hostent	*hostinfo = NULL;
+	struct addrinfo *gai_results;
+	char *dnsname = NULL;
 
 	xlog(D_CALL, "Received SM_MON for %s from %s", mon_name, my_name);
 
@@ -115,9 +115,6 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 		     "or starting '.': %s", mon_name);
 		xlog(L_ERROR, "POSSIBLE SPOOF/ATTACK ATTEMPT!");
 		goto failure;
-	} else if ((hostinfo = gethostbyname(mon_name)) == NULL) {
-		xlog_warn("gethostbyname error for %s", mon_name);
-		goto failure;
 	}
 
 	/* my_name must not have white space */
@@ -130,15 +127,21 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	 * Now choose a hostname to use for matching.  We cannot
 	 * really trust much in the incoming NOTIFY, so to make
 	 * sure that multi-homed hosts work nicely, we get an
-	 * FQDN now, and use that for matching
+	 * FQDN now, and use that for matching.  If the kernel
+	 * handed us an IP presentation address, getaddrinfo(3)
+	 * copies that into ai_canonname.
 	 */
-	hostinfo = gethostbyaddr(hostinfo->h_addr,
-				 hostinfo->h_length,
-				 hostinfo->h_addrtype);
-	if (hostinfo)
-		dnsname = xstrdup(hostinfo->h_name);
-	else
-		dnsname = xstrdup(my_name);
+	gai_results = nsm_forward_lookup(mon_name);
+	if (gai_results == NULL) {
+		xlog(L_WARNING, "No canonical hostname found for %s", mon_name);
+		goto failure;
+	}
+	dnsname = strdup(gai_results->ai_canonname);
+	freeaddrinfo(gai_results);
+	if (dnsname == NULL) {
+		xlog(L_ERROR, "Failed to allocate memory");
+		goto failure;
+	}
 
 	/* Now check to see if this is a duplicate, and warn if so.
 	 * I will also return STAT_FAIL. (I *think* this is how I should
@@ -164,6 +167,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 				mon_name, my_name);
 
 			/* But we'll let you pass anyway. */
+			free(dnsname);
 			goto success;
 		}
 		clnt = NL_NEXT(clnt);
@@ -174,6 +178,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	 * doesn't fail.  (I should probably fix this assumption.)
 	 */
 	if (!(clnt = nlist_new(my_name, mon_name, 0))) {
+		free(dnsname);
 		xlog_warn("out of memory");
 		goto failure;
 	}
diff --git a/utils/statd/statd.h b/utils/statd/statd.h
index 71a77e2..5ee3ea6 100644
--- a/utils/statd/statd.h
+++ b/utils/statd/statd.h
@@ -25,6 +25,8 @@
 extern int	nsm_matchhostname(const char *hostname1, const char *hostname2);
 extern int	nsm_present_address(const struct sockaddr *sap, socklen_t salen,
 					char *buf, const size_t buflen);
+extern struct addrinfo *
+		nsm_forward_lookup(const char *hostname);
 extern void	my_svc_run(void);
 extern void	notify_hosts(void);
 extern void	shuffle_dirs(void);

