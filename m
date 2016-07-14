Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57132 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbcGNC2N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2016 22:28:13 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 14 Jul 2016 12:26:43 +1000
Subject: [PATCH 7/8] mount: don't treat temporary name resolution failure as
 permanent.
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <20160714022643.5874.27102.stgit@noble>
In-Reply-To: <20160714021310.5874.22953.stgit@noble>
References: <20160714021310.5874.22953.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If getaddrinfo() returns EAI_AGAIN, we shouldn't just give up, but
should continue normal retries as the nameserver may be unavailable
for the same reason as the NFS server.

So move the getaddrinfo() call from nfs_validate_options() into
nfs_try_mounts() which is always called soon after, except in the
'remount' case when we don't want it anyway.

If EAI_AGAIN is returned, set errno to EAGAIN and allow this to be a
temporary failure.  Otherwise report error and set errno to EALREADY
so no further message is given.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/stropts.c |   54 ++++++++++++++++++++++++++++---------------------
 1 file changed, 31 insertions(+), 23 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d60b484ab960..522c7ae015f1 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -84,6 +84,7 @@ struct nfsmount_info {
 				*type;		/* "nfs" or "nfs4" */
 	char			*hostname;	/* server's hostname */
 	struct addrinfo		*address;	/* server's addresses */
+	sa_family_t		family;		/* Address family */
 
 	struct mount_options	*options;	/* parsed mount options */
 	char			**extra_opts;	/* string for /etc/mtab */
@@ -371,39 +372,19 @@ static int nfs_set_version(struct nfsmount_info *mi)
  */
 static int nfs_validate_options(struct nfsmount_info *mi)
 {
-	struct addrinfo hint = {
-		.ai_protocol	= (int)IPPROTO_UDP,
-	};
-	sa_family_t family;
-	int error;
-
 	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
 		return 0;
 
-	if (!nfs_nfs_proto_family(mi->options, &family))
+	if (!nfs_nfs_proto_family(mi->options, &mi->family))
 		return 0;
 
 	/*
 	 * A remount is not going to be able to change the server's address,
 	 * nor should we try to resolve another address for the server as we
 	 * may end up with a different address.
+	 * A non-remount will set 'addr' from ->hostname
 	 */
-	if (mi->flags & MS_REMOUNT) {
-		po_remove_all(mi->options, "addr");
-	} else {
-		hint.ai_family = (int)family;
-		error = getaddrinfo(mi->hostname, NULL, &hint, &mi->address);
-		if (error != 0) {
-			nfs_error(_("%s: Failed to resolve server %s: %s"),
-				progname, mi->hostname, gai_strerror(error));
-			mi->address = NULL;
-			return 0;
-		}
-
-		if (!nfs_append_addr_option(mi->address->ai_addr,
-						mi->address->ai_addrlen, mi->options))
-			return 0;
-	}
+	po_remove_all(mi->options, "addr");
 
 	if (!nfs_set_version(mi))
 		return 0;
@@ -903,6 +884,32 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 {
 	int result = 0;
 
+	if (mi->address == NULL) {
+		struct addrinfo hint = {
+			.ai_protocol	= (int)IPPROTO_UDP,
+		};
+		int error;
+		struct addrinfo *address;
+
+		hint.ai_family = (int)mi->family;
+		error = getaddrinfo(mi->hostname, NULL, &hint, &address);
+		if (error != 0) {
+			if (error == EAI_AGAIN)
+				errno = EAGAIN;
+			else {
+				nfs_error(_("%s: Failed to resolve server %s: %s"),
+					  progname, mi->hostname, gai_strerror(error));
+				errno = EALREADY;
+			}
+			return 0;
+		}
+
+		if (!nfs_append_addr_option(mi->address->ai_addr,
+					    mi->address->ai_addrlen, mi->options))
+			return 0;
+		mi->address = address;
+	}
+
 	switch (mi->version.major) {
 		case 2:
 		case 3:
@@ -941,6 +948,7 @@ static int nfs_is_permanent_error(int error)
 	case ETIMEDOUT:
 	case ECONNREFUSED:
 	case EHOSTUNREACH:
+	case EAGAIN:
 		return 0;	/* temporary */
 	default:
 		return 1;	/* permanent */


