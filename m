From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/23] mount.nfs: fix more nits with error messages
Date: Sat, 28 Jul 2007 17:49:23 -0400
Message-ID: <20070728214923.21871.11805.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuA9-0007P7-UB
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:25 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuAD-00031I-OD
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:49:30 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Catch-all.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/error.c    |    3 ++-
 utils/mount/network.c  |    7 ++++---
 utils/mount/nfsmount.c |   18 +++++++++++-------
 3 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index 74f8354..1fdc4e6 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -87,7 +87,8 @@ void mount_errors(char *server, int will_retry, int bg)
 			_("mount to NFS server '%s' failed: "), server);
 	else
 		pos = snprintf(tmp, (erreob - tmp),
-			_("mount: mount to NFS server '%s' failed: "), server);
+			_("%s: mount to NFS server '%s' failed: "),
+				progname, server);
 
 	tmp = &errbuf[pos];
 	if (rpc_createerr.cf_stat == RPC_TIMEDOUT) {
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 8da57d9..ab8cfb7 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -106,12 +106,13 @@ int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
 	saddr->sin_family = AF_INET;
 	if (!inet_aton(hostname, &saddr->sin_addr)) {
 		if ((hp = gethostbyname(hostname)) == NULL) {
-			nfs_error(_("mount: can't get address for %s\n"),
-				hostname);
+			nfs_error(_("%s: can't get address for %s\n"),
+					progname, hostname);
 			return 0;
 		} else {
 			if (hp->h_length > sizeof(*saddr)) {
-				nfs_error(_("mount: got bad hp->h_length\n"));
+				nfs_error(_("%s: got bad hp->h_length\n"),
+						progname);
 				hp->h_length = sizeof(*saddr);
 			}
 			memcpy(&saddr->sin_addr, hp->h_addr, hp->h_length);
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index a2b95ad..20509c7 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -272,7 +272,8 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 				char *secflavor = opteq+1;
 				/* see RFC 2623 */
 				if (nfs_mount_data_version < 5) {
-					printf(_("Warning: ignoring sec=%s option\n"), secflavor);
+					printf(_("Warning: ignoring sec=%s option\n"),
+							secflavor);
 					continue;
 				} else if (!strcmp(secflavor, "none"))
 					data->pseudoflavor = AUTH_NONE;
@@ -313,8 +314,9 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 				int ctxlen = strlen(context);
 
 				if (ctxlen > NFS_MAX_CONTEXT_LEN) {
-					printf(_("context parameter exceeds limit of %d\n"),
-						 NFS_MAX_CONTEXT_LEN);
+					nfs_error(_("context parameter exceeds"
+							" limit of %d"),
+							NFS_MAX_CONTEXT_LEN);
 					goto bad_parameter;
 				}
 				/* The context string is in the format of
@@ -426,15 +428,17 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 			bad_option:
 				if (sloppy)
 					continue;
-				printf(_("Unsupported nfs mount option: "
-					 "%s%s\n"), val ? "" : "no", opt);
+				nfs_error(_("%s: Unsupported nfs mount option:"
+						" %s%s"), progname,
+						val ? "" : "no", opt);
 				goto out_bad;
 			}
 			sprintf(cbuf, val ? _("%s,") : _("no%s,"), opt);
 		}
 		len += strlen(cbuf);
 		if (len >= opt_size) {
-			printf(_("mount: excessively long option argument\n"));
+			nfs_error(_("%s: excessively long option argument"),
+					progname);
 			goto out_bad;
 		}
 		strcat(new_opts, cbuf);
@@ -447,7 +451,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 	}
 	return 1;
  bad_parameter:
-	printf(_("Bad nfs mount parameter: %s\n"), opt);
+	nfs_error(_("%s: Bad nfs mount parameter: %s\n"), progname, opt);
  out_bad:
 	return 0;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
