From: Jeff Layton <jtlayton@poochiereds.net>
Subject: [PATCH] addr= hint for mount program
Date: Tue, 19 Jul 2005 17:53:02 -0400
Message-ID: <1121809982.6739.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-sBrbCW7Nkirhcx/+5K9g"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dv01i-0000it-Pd
	for nfs@lists.sourceforge.net; Tue, 19 Jul 2005 14:53:22 -0700
Received: from ms-smtp-04-lbl.southeast.rr.com ([24.25.9.103] helo=ms-smtp-04-eri0.southeast.rr.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Dv01h-0000Wi-1I
	for nfs@lists.sourceforge.net; Tue, 19 Jul 2005 14:53:23 -0700
To: autofs@linux.kernel.org, nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-sBrbCW7Nkirhcx/+5K9g
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Here's my first stab at a patch for mount to make it treat the addr=
option as a hint. I've done some very basic testing and it seems to do
the right thing, but I need to dredge up a multi-homed NFS server here
soon to verify that all is working. If anyone has one and wants to test
this out for me, I'd be appreciative :-)

The patch is a little larger than I had originally anticipated,
primarily because I had to move a chunk of code that happened before the
option parsing to after.

Since the util-linux mailing list seems to be inactive, should I just
submit this to the util-linux maintainer directly?

-- Jeff


--=-sBrbCW7Nkirhcx/+5K9g
Content-Disposition: attachment; filename=util-linux-2.12q-mount-preferred-address.patch
Content-Type: text/x-patch; name=util-linux-2.12q-mount-preferred-address.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

Index: util-linux/mount/nfsmount.c
===================================================================
--- util-linux/mount/nfsmount.c	(revision 170)
+++ util-linux/mount/nfsmount.c	(working copy)
@@ -195,7 +195,7 @@
 	static char *prev_bg_host;
 	char hostdir[1024];
 	CLIENT *mclient;
-	char *hostname, *dirname, *old_opts, *mounthost = NULL;
+	char *hostname, *dirname, *old_opts, *mounthost, *prefaddr_s = NULL;
 	char new_opts[1024];
 	struct timeval total_timeout;
 	enum clnt_stat clnt_stat;
@@ -207,6 +207,7 @@
 	struct sockaddr_in server_addr;
 	struct sockaddr_in mount_server_addr;
 	struct pmap *pm_mnt;
+	struct in_addr prefaddr;
 	int msock, fsock;
 	struct timeval retry_timeout;
 	union {
@@ -214,7 +215,7 @@
 		struct mountres3 nfsv3;
 	} status;
 	struct stat statbuf;
-	char *s;
+	char *s = NULL;
 	int port, mountport, proto, bg, soft, intr;
 	int posix, nocto, noac, nolock, broken_suid;
 	int retry, tcp;
@@ -258,43 +259,6 @@
 		goto fail;
 	}
 
-	server_addr.sin_family = AF_INET;
-#ifdef HAVE_inet_aton
-	if (!inet_aton(hostname, &server_addr.sin_addr))
-#endif
-	{
-		if ((hp = gethostbyname(hostname)) == NULL) {
-			fprintf(stderr, _("mount: can't get address for %s\n"),
-				hostname);
-			goto fail;
-		} else {
-			if (hp->h_length > sizeof(struct in_addr)) {
-				fprintf(stderr,
-					_("mount: got bad hp->h_length\n"));
-				hp->h_length = sizeof(struct in_addr);
-			}
-			memcpy(&server_addr.sin_addr,
-			       hp->h_addr, hp->h_length);
-		}
-	}
-
-	memcpy (&mount_server_addr, &server_addr, sizeof (mount_server_addr));
-
-	/* add IP address to mtab options for use when unmounting */
-
-	s = inet_ntoa(server_addr.sin_addr);
-	old_opts = *extra_opts;
-	if (!old_opts)
-		old_opts = "";
-	if (strlen(old_opts) + strlen(s) + 10 >= sizeof(new_opts)) {
-		fprintf(stderr, _("mount: "
-				  "excessively long option argument\n"));
-		goto fail;
-	}
-	sprintf(new_opts, "%s%saddr=%s",
-		old_opts, *old_opts ? "," : "", s);
-	*extra_opts = xstrdup(new_opts);
-
 	/* Set default options.
 	 * rsize/wsize (and bsize, for ver >= 3) are left 0 in order to
 	 * let the kernel decide.
@@ -328,6 +292,7 @@
 	nfsvers = 0;
 
 	/* parse options */
+	old_opts = xstrdup(*extra_opts);
 
 	for (opt = strtok(old_opts, ","); opt; opt = strtok(NULL, ",")) {
 		if ((opteq = strchr(opt, '='))) {
@@ -388,10 +353,10 @@
 #endif
 					printf(_("Warning: Option namlen is not supported.\n"));
 			} else if (!strcmp(opt, "addr")) {
-				/* ignore */;
+				prefaddr_s = opteq + 1;
 			} else {
 				printf(_("unknown nfs mount parameter: "
-					 "%s=%d\n"), opt, val);
+					 "%s=%s\n"), opt, opteq+1);
 				goto fail;
 			}
 		} else {
@@ -477,8 +442,8 @@
 	       data.rsize, data.wsize, data.timeo, data.retrans);
 	printf("acreg (min, max) = (%d, %d), acdir (min, max) = (%d, %d)\n",
 	       data.acregmin, data.acregmax, data.acdirmin, data.acdirmax);
-	printf("port = %d, bg = %d, retry = %d, flags = %.8x\n",
-	       port, bg, retry, data.flags);
+	printf("port = %d, bg = %d, retry = %d, flags = %.8x, addr = %s\n",
+	       port, bg, retry, data.flags, prefaddr_s);
 	printf("mountprog = %d, mountvers = %d, nfsprog = %d, nfsvers = %d\n",
 	       mountprog, mountvers, nfsprog, nfsvers);
 	printf("soft = %d, intr = %d, posix = %d, nocto = %d, noac = %d\n",
@@ -511,6 +476,78 @@
 		return retval;
 	}
 
+	s = NULL;
+	server_addr.sin_family = AF_INET;
+#ifdef HAVE_inet_aton
+	if (!inet_aton(hostname, &server_addr.sin_addr))
+#endif
+	{
+		if ((hp = gethostbyname(hostname)) == NULL) {
+			fprintf(stderr, _("mount: can't get address for %s\n"),
+				hostname);
+			goto fail;
+		} else {
+			if (hp->h_length > sizeof(struct in_addr)) {
+				fprintf(stderr,
+					_("mount: got bad hp->h_length\n"));
+				hp->h_length = sizeof(struct in_addr);
+			}
+
+			val = 0;
+			s = NULL;
+
+#ifdef HAVE_inet_aton
+			/* if a preferred address is specified, then make sure
+			 * it matches one of the host's addresses before using
+			 * it. If it doesn't, just use first host in list.
+			 */
+			if (prefaddr_s) {
+				inet_aton(prefaddr_s,&prefaddr);
+				while(hp->h_addr_list[val]) {
+					if (prefaddr.s_addr == *(ulong *)
+						(hp->h_addr_list[val])) {
+						s = hp->h_addr_list[val];
+						break;
+					}
+					++val;
+				}
+
+				if (!s)
+					fprintf(stderr, _("mount: specified address doesn't match hostname. Ignoring it.\n"));
+			}
+#endif /* HAVE_inet_aton */
+
+			if (s) {
+				memcpy(&server_addr.sin_addr,
+			       		s, hp->h_length);
+			} else {
+				memcpy(&server_addr.sin_addr,
+			       		hp->h_addr, hp->h_length);
+			}
+		}
+	}
+
+	memcpy (&mount_server_addr, &server_addr, sizeof (mount_server_addr));
+
+	/* add IP address to mtab options for use when unmounting, if it
+	 * wasn't specified or was ignored */
+	if (!s) {
+		s = inet_ntoa(server_addr.sin_addr);
+		old_opts = *extra_opts;
+
+		if (!old_opts)
+			old_opts = "";
+
+		if (strlen(old_opts) + strlen(s) + 10 >= sizeof(new_opts)) {
+			fprintf(stderr, _("mount: "
+				  "excessively long option argument\n"));
+			goto fail;
+		}
+		sprintf(new_opts, "%s%saddr=%s",
+			old_opts, *old_opts ? "," : "", s);
+		*extra_opts = xstrdup(new_opts);
+	}
+
 	/* create mount deamon client */
 	/* See if the nfs host = mount host. */
 	if (mounthost) {

--=-sBrbCW7Nkirhcx/+5K9g--



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
