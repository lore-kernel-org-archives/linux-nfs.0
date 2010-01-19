Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.122]:47629 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052Ab0ASN1o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jan 2010 08:27:44 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: chuck.lever@oracle.com, steved@redhat.com, trond.myklebust@fys.uio.no
Subject: [PATCH] mount.nfs: prefer IPv4 addresses over IPv6 (try #2)
Date: Tue, 19 Jan 2010 08:27:42 -0500
Message-Id: <1263907662-19107-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We're poised to enable IPv6 in nfs-utils in distros. There is a
potential problem however. mount.nfs will prefer IPv6 addrs.

If someone has a working IPv4 server today that has an IPv6 address,
then clients may start trying to mount over that address. If the server
doesn't support NFS serving over IPv6 (and virtually no linux servers
currently do), then the mount will start failing.

Avoid this problem by making the mount code prefer IPv4 addresses
when they are available and an address family isn't specified.

This is the second attempt at this patch. This moves the changes
into nfs_validate_options. Chuck also mentioned parameterizing this
behavior too. This patch doesn't include that, as I wasn't exactly
clear on what he had in mind.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/mount/stropts.c |   32 +++++++++++++++++++++++++-------
 1 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 57a4b32..f0937a2 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -326,6 +326,29 @@ static int nfs_set_version(struct nfsmount_info *mi)
 	return 1;
 }
 
+static int nfs_addr_option_lookup(struct nfsmount_info *mi)
+{
+	struct sockaddr *sap = &mi->address.sa;
+	sa_family_t family;
+
+	if (!nfs_nfs_proto_family(mi->options, &family))
+		return 0;
+
+	mi->salen = sizeof(mi->address);
+
+#ifdef IPV6_SUPPORTED
+	/*
+	 * A lot of servers don't support NFS over IPv6 yet. For now,
+	 * IPv4 addresses are preferred.
+	 */
+	if (family == AF_UNSPEC &&
+	    nfs_lookup(mi->hostname, AF_INET, sap, &mi->salen))
+		return 1;
+#endif /* IPV6_SUPPORTED */
+
+	return nfs_lookup(mi->hostname, family, sap, &mi->salen);
+}
+
 /*
  * Set up mandatory non-version specific NFS mount options.
  *
@@ -333,16 +356,11 @@ static int nfs_set_version(struct nfsmount_info *mi)
  */
 static int nfs_validate_options(struct nfsmount_info *mi)
 {
-	struct sockaddr *sap = &mi->address.sa;
-	sa_family_t family;
 
 	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
 		return 0;
 
-	if (!nfs_nfs_proto_family(mi->options, &family))
-		return 0;
-	mi->salen = sizeof(mi->address);
-	if (!nfs_lookup(mi->hostname, family, sap, &mi->salen))
+	if (!nfs_addr_option_lookup(mi))
 		return 0;
 
 	if (!nfs_set_version(mi))
@@ -351,7 +369,7 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_append_sloppy_option(mi->options))
 		return 0;
 
-	if (!nfs_append_addr_option(sap, mi->salen, mi->options))
+	if (!nfs_append_addr_option(&mi->address.sa, mi->salen, mi->options))
 		return 0;
 
 	return 1;
-- 
1.6.5.2

