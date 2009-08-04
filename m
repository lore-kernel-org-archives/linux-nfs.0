From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] NFS man page: update nfs(5) with details about IPv6
	support
Date: Tue, 04 Aug 2009 14:07:26 -0400
Message-ID: <20090804180726.21944.88977.stgit@matisse.1015granger.net>
References: <20090804180334.21944.64404.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:47493 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933026AbZHDSHu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2009 14:07:50 -0400
In-Reply-To: <20090804180334.21944.64404.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add details to nfs(5) about how to specify raw IPv6 addresses when mounting an
NFS server.  Mounting via an IPv6 NFS server via hostname should work as it
does with IPv4.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 280ddcb..e543fe4 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -58,9 +58,17 @@ The server's hostname and export pathname
 are separated by a colon, while
 the mount options are separated by commas. The remaining fields
 are separated by blanks or tabs.
+.P
 The server's hostname can be an unqualified hostname,
 a fully qualified domain name,
-or a dotted quad IPv4 address.
+a dotted quad IPv4 address, or
+an IPv6 address enclosed in square brackets.
+Link-local and site-local IPv6 addresses must be accompanied by an
+interface identifier.
+See
+.BR ipv6 (7)
+for details on specifying raw IPv6 addresses.
+.P
 The
 .I fstype
 field contains either "nfs" (for version 2 or version 3 NFS mounts)
@@ -779,7 +787,8 @@ The DATA AND METADATA COHERENCE section discusses
 the behavior of this option in more detail.
 .TP 1.5i
 .BI clientaddr= n.n.n.n
-Specifies  a  single  IPv4  address  (in dotted-quad form)
+Specifies a single IPv4 address (in dotted-quad form),
+or a non-link-local IPv6 address,
 that the NFS client advertises to allow servers
 to perform NFS version 4 callback requests against
 files on this mount point. If  the  server is unable to
@@ -848,6 +857,14 @@ This example can be used to mount /usr over NFS.
 .TA 2.5i +0.7i +0.7i +.7i
 	server:/export	/usr	nfs	ro,nolock,nocto,actimeo=3600	0 0
 .FI
+.P
+This example shows how to mount an NFS server
+using a raw IPv6 link-local address.
+.P
+.NF
+.TA 2.5i +0.7i +0.7i +.7i
+	[fe80::215:c5ff:fb3e:e2b1%eth0]:/export	/mnt	nfs	defaults	0 0
+.FI
 .SH "TRANSPORT METHODS"
 NFS clients send requests to NFS servers via
 Remote Procedure Calls, or
@@ -1491,6 +1508,7 @@ such as security negotiation, server referrals, and named attributes.
 .BR mount.nfs (5),
 .BR umount.nfs (5),
 .BR exports (5),
+.BR ipv6 (7),
 .BR nfsd (8),
 .BR sm-notify (8),
 .BR rpc.statd (8),

