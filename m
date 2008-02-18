From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/17] text-based mount.nfs: support AF_INET6 addresses for
	NFSv4 mounting
Date: Mon, 18 Feb 2008 13:36:43 -0500
Message-ID: <20080218183643.19060.97270.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:57123 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbYBRSgo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:36:44 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIahhV019749
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:36:43 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIahj4019390
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:36:43 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel now supports client-side IPv6 for the main NFS protocols,
but not yet for auxiliary protocols such as NLM.

Enable the text-based mount.nfs logic to resolve hostnames to IPv6
addresses.  This should be enough to begin testing the in-kernel NFSv4 
support for IPv6.

Since NFSv4 unmounting is only a local process (no communication with the
server) we don't need to do anything to support unmounting an
IPv6-addressed NFSv4 server.

Note that the mount command may now also pass in an IPv6 address via
the "clientaddr=" mount option, though the kernel NFS client doesn't
yet support an IPv6 callback service.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index ef6365d..caf13b1 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -725,13 +725,14 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 		    int flags, char **extra_opts, int fake, int child)
 {
 	struct mount_options *options = NULL;
-	struct sockaddr_in saddr;
+	struct sockaddr_storage dummy;
+	struct sockaddr *saddr = (struct sockaddr *)&dummy;
 	char *hostname;
 	int retval = EX_FAIL;
 
 	if (!parse_devname(spec, &hostname))
 		return retval;
-	if (!fill_ipv4_sockaddr(hostname, &saddr))
+	if (nfs_name_to_address(hostname, AF_UNSPEC, saddr))
 		goto fail;
 
 	options = po_split(*extra_opts);
@@ -740,7 +741,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 		goto fail;
 	}
 
-	if (!set_mandatory_options(type, (struct sockaddr *)&saddr, options))
+	if (!set_mandatory_options(type, saddr, options))
 		goto out;
 
 	if (po_rightmost(options, "bg", "fg") == PO_KEY1_RIGHTMOST)

