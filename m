From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] sm-notify: Use my_name when sending SM_NOTIFY requests
Date: Mon, 15 Mar 2010 13:51:37 -0400
Message-ID: <20100315175137.2586.71894.stgit@localhost.localdomain>
References: <20100315174453.2586.40876.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:37534 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab0CORvj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 13:51:39 -0400
Received: by qw-out-2122.google.com with SMTP id 9so784198qwb.37
        for <linux-nfs@vger.kernel.org>; Mon, 15 Mar 2010 10:51:38 -0700 (PDT)
In-Reply-To: <20100315174453.2586.40876.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The mon_name argument of an SM_NOTIFY request is a string that
identifies the rebooting host.

sm-notify should send the my_name provided by the local lockd at the
time the remote was monitored, rather than cocking up a mon_name
argument based on the present return value of gethostname(3).  If the
local system's hostname happened to change after the last reboot, then
the string returned by gethostname(3) will not be recognized by the
remote.  Thus the remote will never initiate lock recovery for the
original named host, possibly leaving stale locks.

The existing behavior of using the -v command line option as the
mon_name argument is preserved, but we now prevent sending an IP
presentation address, as some non-Linux implementations don't
recognize addresses as valid mon_names.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c   |   41 ++++++++++++++++++++++++++++++++---------
 utils/statd/sm-notify.man |   28 +++++++++++++---------------
 utils/statd/statd.man     |   14 ++------------
 3 files changed, 47 insertions(+), 36 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 3259a3e..2d14668 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -54,7 +54,7 @@ struct nsm_host {
 	uint32_t		xid;
 };
 
-static char		nsm_hostname[256];
+static char		nsm_hostname[SM_MAXSTRLEN + 1];
 static int		nsm_state;
 static int		nsm_family = AF_INET;
 static int		opt_debug = 0;
@@ -412,12 +412,33 @@ usage:		fprintf(stderr,
 		}
 	}
 
-	if (opt_srcaddr) {
-		strncpy(nsm_hostname, opt_srcaddr, sizeof(nsm_hostname)-1);
-	} else
-	if (gethostname(nsm_hostname, sizeof(nsm_hostname)) < 0) {
-		xlog(L_ERROR, "Failed to obtain name of local host: %m");
-		exit(1);
+	if (opt_srcaddr != NULL) {
+		struct addrinfo *ai = NULL;
+		struct addrinfo hint = {
+			.ai_family	= AF_UNSPEC,
+			.ai_flags	= AI_NUMERICHOST,
+		};
+
+		if (getaddrinfo(opt_srcaddr, NULL, &hint, &ai))
+			/* not a presentation address - use it */
+			strncpy(nsm_hostname, opt_srcaddr, sizeof(nsm_hostname));
+		else {
+			/* was a presentation address - look it up in
+			 * /etc/hosts, so it can be used for my_name */
+			int error;
+
+			freeaddrinfo(ai);
+			hint.ai_flags = AI_CANONNAME;
+			error = getaddrinfo(opt_srcaddr, NULL, &hint, &ai);
+			if (error != 0) {
+				xlog(L_ERROR, "Bind address %s is unusable: %s",
+						opt_srcaddr, gai_strerror(error));
+				exit(1);
+			}
+			strncpy(nsm_hostname, ai->ai_canonname,
+							sizeof(nsm_hostname));
+			freeaddrinfo(ai);
+		}
 	}
 
 	(void)nsm_retire_monitored_hosts();
@@ -535,6 +556,8 @@ notify(const int sock)
 static int
 notify_host(int sock, struct nsm_host *host)
 {
+	const char *my_name = (opt_srcaddr != NULL ?
+					nsm_hostname : host->my_name);
 	struct sockaddr *sap;
 	socklen_t salen;
 
@@ -580,8 +603,8 @@ notify_host(int sock, struct nsm_host *host)
 		host->xid = nsm_xmit_rpcbind(sock, sap, SM_PROG, SM_VERS);
 	else
 		host->xid = nsm_xmit_notify(sock, sap, salen,
-				SM_PROG, nsm_hostname, nsm_state);
-	
+					SM_PROG, my_name, nsm_state);
+
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
index ffc5e95..ca00e24 100644
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
@@ -292,7 +290,6 @@ man pages.
 .SH ADDITIONAL NOTES
 Lock recovery after a reboot is critical to maintaining data integrity
 and preventing unnecessary application hangs.
-.PP
 To help
 .B rpc.statd
 match SM_NOTIFY requests to NLM requests, a number of best practices
@@ -309,13 +306,6 @@ consistent
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

