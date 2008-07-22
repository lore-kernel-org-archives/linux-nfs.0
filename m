From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] nfs(5) man page: Add documentation for the "mountproto="
	option
Date: Tue, 22 Jul 2008 15:47:16 -0400
Message-ID: <20080722194715.25475.67694.stgit@manray.1015granger.net>
References: <20080722194550.25475.37133.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:61237 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564AbYGVTsf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2008 15:48:35 -0400
In-Reply-To: <20080722194550.25475.37133.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks like mountproto= was never documented in nfs(5).  Add a paragraph
that describes it in the "nfs mount options" section.
---

 utils/mount/nfs.man |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 2c0b687..0fc5079 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -489,6 +489,25 @@ or the server's mountd service is not available on the advertised port.
 This option can be used when mounting an NFS server
 through a firewall that blocks the rpcbind protocol.
 .TP 1.5i
+.BI mountproto= netid
+The transport protocol used by the NFS client
+to transmit requests to the NFS server's mountd service when performing
+this mount request, and when later unmounting this mount point.
+.I netid
+can be either
+.B udp
+or
+.BR tcp .
+.IP
+This option can be used when mounting an NFS server
+through a firewall that blocks a particular transport protocol.
+When used in combination with the
+.B proto
+option, different transports for mountd requests and NFS requests
+can be specified.
+If the server's mountd service is not available via the specified
+transport, the mount request fails.
+.TP 1.5i
 .BI mounthost= name
 The hostname of the host running mountd.
 If this option is not specified, the

