From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 28/29] statd: Use my_name when sending SM_NOTIFY requests
Date: Tue, 10 Nov 2009 17:01:05 -0500
Message-ID: <20091110220105.23822.28447.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:30457 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036AbZKJWBU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 17:01:20 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The mon_name argument of an SM_NOTIFY request is a string that
identifies the rebooting host.

sm-notify should send the my_name provided by the local lockd at the
time the remote was monitored, rather than cocking up a mon_name
argument based on the present return value of gethostname(3).  If the
local system's hostname happened to change after the last reboot, then
the string returned by gethostname(3) will not be recognized by the
remote.  Thus the remote will never initiate lock recovery for this
host.

The existing behavior of using the -v command line option as the
mon_name argument is preserved, but we now prevent sending an IP
presentation address, as some non-Linux implementations don't
recognize addresses as valid mon_names.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c   |   54 ++++++++++++++++++++++++++++++++++++---------
 utils/statd/sm-notify.man |   28 +++++++++++------------
 utils/statd/statd.man     |   14 ++----------
 3 files changed, 58 insertions(+), 38 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 9a46ec4..e883ae9 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -46,6 +46,7 @@
 struct nsm_host {
 	struct nsm_host *	next;
 	char *			name;
+	char *			my_name;
 	struct sockaddr_storage	addr;
 	socklen_t		addrlen;
 	struct addrinfo		*ai;
@@ -56,7 +57,7 @@ struct nsm_host {
 	unsigned int		xid;
 };
 
-static char		nsm_hostname[256];
+static char		nsm_hostname[SM_MAXSTRLEN + 1];
 static uint32_t		nsm_state;
 static int		nsm_family = AF_INET;
 static int		opt_debug = 0;
@@ -97,7 +98,7 @@ static struct addrinfo *smn_lookup(const char *name)
 }
 
 static struct nsm_host *
-smn_alloc_host(const char *hostname, const time_t timestamp)
+smn_alloc_host(const char *hostname, const char *my_name, const time_t timestamp)
 {
 	struct nsm_host	*host;
 
@@ -111,6 +112,13 @@ smn_alloc_host(const char *hostname, const time_t timestamp)
 		goto out_nomem;
 	}
 
+	host->my_name = strdup(my_name);
+	if (host->my_name == NULL) {
+		free(host->name);
+		free(host);
+		goto out_nomem;
+	}
+
 	host->last_used = timestamp;
 	host->timeout = NSM_TIMEOUT;
 	host->retries = 100;		/* force address retry */
@@ -128,6 +136,7 @@ static void smn_forget_host(struct nsm_host *host)
 
 	nsm_delete_notified_host(host->name);
 
+	free(host->my_name);
 	free(host->name);
 	if (host->ai)
 		freeaddrinfo(host->ai);
@@ -138,12 +147,17 @@ static void smn_forget_host(struct nsm_host *host)
 static unsigned int
 smn_get_host(const char *hostname,
 		__attribute__((unused)) const struct sockaddr *sap,
-		__attribute__((unused)) const struct mon *mon,
-		const time_t timestamp)
+		const struct mon *mon, const time_t timestamp)
 {
 	struct nsm_host	*host;
+	char *my_name;
+
+	if (opt_srcaddr)
+		my_name = nsm_hostname;
+	else
+		my_name = mon->mon_id.my_id.my_name;
 
-	host = smn_alloc_host(hostname, timestamp);
+	host = smn_alloc_host(hostname, my_name, timestamp);
 	if (host == NULL)
 		return 0;
 
@@ -336,6 +350,9 @@ out:
 int
 main(int argc, char **argv)
 {
+	struct addrinfo *results, hint = {
+		.ai_family	= AF_UNSPEC,
+	};
 	int	c, sock;
 	int	force = 0;
 	char *	progname;
@@ -403,11 +420,26 @@ usage:		fprintf(stderr,
 	}
 
 	if (opt_srcaddr) {
-		strncpy(nsm_hostname, opt_srcaddr, sizeof(nsm_hostname)-1);
-	} else
-	if (gethostname(nsm_hostname, sizeof(nsm_hostname)) < 0) {
-		xlog(L_ERROR, "Failed to obtain name of local host: %m");
-		exit(1);
+		hint.ai_flags = AI_NUMERICHOST;
+		if (getaddrinfo(opt_srcaddr, NULL, &hint, &results))
+			/* not a presentation address - use it */
+			strncpy(nsm_hostname, opt_srcaddr, sizeof(nsm_hostname));
+		else {
+			/* was a presentation address - look it up */
+			int error;
+
+			freeaddrinfo(results);
+			hint.ai_flags = AI_CANONNAME;
+			error = getaddrinfo(opt_srcaddr, NULL, &hint, &results);
+			if (error) {
+				xlog(L_ERROR, "Bind address %s is unusable: %s",
+						opt_srcaddr, gai_strerror(error));
+				exit(1);
+			}
+			strncpy(nsm_hostname, results->ai_canonname,
+							sizeof(nsm_hostname));
+			freeaddrinfo(results);
+		}
 	}
 
 	(void)nsm_retire_monitored_hosts();
@@ -576,7 +608,7 @@ notify_host(int sock, struct nsm_host *host)
 				NSM_PROGRAM, NSM_VERSION);
 	else
 		host->xid = nsm_xmit_notify(sock, dest, host->addrlen,
-				NSM_PROGRAM, nsm_hostname, nsm_state);
+				NSM_PROGRAM, host->my_name, nsm_state);
 	
 	return 0;
 }
diff --git a/utils/statd/sm-notify.man b/utils/statd/sm-notify.man
index 163713e..7a1cbfa 100644
--- a/utils/statd/sm-notify.man
+++ b/utils/statd/sm-notify.man
@@ -97,11 +97,9 @@ It uses the
 string as the destination.
 To identify which host has rebooted, the
 .B sm-notify
-command normally sends the results of
-.BR gethostname (3)
-as the
+command normally sends
 .I my_name
-string.
+string recorded when that remote was monitored.
 The remote
 .B rpc.statd
 matches incoming SM_NOTIFY requests using this string,
@@ -202,15 +200,22 @@ argument to use when sending SM_NOTIFY requests.
 If this option is not specified,
 .B sm-notify
 uses a wildcard address as the transport bind address,
-and uses the results of
-.BR gethostname (3)
-as the
+and uses the
+.I my_name
+recorded when the remote was monitored as the
 .I mon_name
-argument.
+argument when sending SM_NOTIFY requests.
 .IP
 The
 .I ipaddr
 form can be expressed as either an IPv4 or an IPv6 presentation address.
+If the
+.I ipaddr
+form is used, the
+.B sm-notify
+command converts this address to a hostname for use as the
+.I mon_name
+argument when sending SM_NOTIFY requests.
 .IP
 This option can be useful in multi-homed configurations where
 the remote requires notification from a specific network address.
@@ -252,13 +257,6 @@ consistent
 The hostname the client uses to mount the server should match the server's
 .I mon_name
 in SM_NOTIFY requests it sends
-.IP
-The use of network addresses as a
-.I mon_name
-or a
-.I my_name
-string should be avoided when
-interoperating with non-Linux NFS implementations.
 .PP
 Unmounting an NFS file system does not necessarily stop
 either the NFS client or server from monitoring each other.
diff --git a/utils/statd/statd.man b/utils/statd/statd.man
index d5ab081..ae7a4b7 100644
--- a/utils/statd/statd.man
+++ b/utils/statd/statd.man
@@ -100,11 +100,9 @@ It uses the
 string as the destination.
 To identify which host has rebooted, the
 .B sm-notify
-command normally sends the results of
-.BR gethostname (3)
-as the
+command sends the
 .I my_name
-string.
+string recorded when that remote was monitored.
 The remote
 .B rpc.statd
 matches incoming SM_NOTIFY requests using this string,
@@ -294,7 +292,6 @@ manual pages.
 .SH ADDITIONAL NOTES
 Lock recovery after a reboot is critical to maintaining data integrity
 and preventing unnecessary application hangs.
-.PP
 To help
 .B rpc.statd
 match SM_NOTIFY requests to NLM requests, a number of best practices
@@ -311,13 +308,6 @@ consistent
 The hostname the client uses to mount the server should match the server's
 .I mon_name
 in SM_NOTIFY requests it sends
-.IP
-The use of network addresses as a
-.I mon_name
-or a
-.I my_name
-string should be avoided when
-interoperating with non-Linux NFS implementations.
 .PP
 Unmounting an NFS file system does not necessarily stop
 either the NFS client or server from monitoring each other.

