From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/10] NFS man page: update nfs(5) with details about IPv6
	support
Date: Tue, 08 Dec 2009 13:00:52 -0500
Message-ID: <20091208180052.2544.37313.stgit@localhost.localdomain>
References: <20091208175128.2544.457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:62633 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965749AbZLHSBH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:01:07 -0500
In-Reply-To: <20091208175128.2544.457.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add details to nfs(5) about how to specify raw IPv6 addresses when mounting an
NFS server.  Mounting via an IPv6 NFS server via hostname should work as it
does with IPv4.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |  104 +++++++++++++++++++++++++++++++++++----------------
 1 files changed, 72 insertions(+), 32 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 2299637..93bd642 100644
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
@@ -470,32 +478,38 @@ for mounting the
 .B nfs
 file system type.
 .TP 1.5i
-.BI proto= transport
-The transport the NFS client uses
+.BI proto= netid
+The transport protocol name and protocol family the NFS client uses
 to transmit requests to the NFS server for this mount point.
-.I transport
-can be either
-.B udp
-or
-.BR tcp .
-Each transport uses different default
+If an NFS server has both an IPv4 and an IPv6 address, using a specific
+netid will force the use of IPv4 or IPv6 networking to communicate
+with that server.
+.IP
+If support for TI-RPC is built into the
+.B mount.nfs
+command,
+.I netid
+is a valid netid listed in
+.IR /etc/netconfig .
+Otherwise,
+.I netid
+is one of "tcp," "udp," or "rdma," and only IPv4 may be used.
+.IP
+Each transport protocol uses different default
 .B retrans
 and
 .B timeo
-settings; refer to the description of these two mount options for details.
+settings.
+Refer to the description of these two mount options for details.
 .IP
 In addition to controlling how the NFS client transmits requests to
 the server, this mount option also controls how the
 .BR mount (8)
 command communicates with the server's rpcbind and mountd services.
-Specifying
-.B proto=tcp
-forces all traffic from the
+Specifying a netid that uses TCP forces all traffic from the
 .BR mount (8)
 command and the NFS client to use TCP.
-Specifying
-.B proto=udp
-forces all traffic types to use UDP.
+Specifying a netid that uses UDP forces all traffic types to use UDP.
 .IP
 If the
 .B proto
@@ -548,15 +562,20 @@ or the server's mountd service is not available on the advertised port.
 This option can be used when mounting an NFS server
 through a firewall that blocks the rpcbind protocol.
 .TP 1.5i
-.BI mountproto= transport
-The transport the NFS client uses
+.BI mountproto= netid
+The transport protocol name and protocol family the NFS client uses
 to transmit requests to the NFS server's mountd service when performing
 this mount request, and when later unmounting this mount point.
-.I transport
-can be either
-.B udp
-or
-.BR tcp .
+.IP
+If support for TI-RPC is built into the
+.B mount.nfs
+command,
+.I netid
+is a valid netid listed in
+.IR /etc/netconfig .
+Otherwise,
+.I netid
+is one of "tcp" or "udp," and only IPv4 may be used.
 .IP
 This option can be used when mounting an NFS server
 through a firewall that blocks a particular transport.
@@ -566,6 +585,7 @@ option, different transports for mountd requests and NFS requests
 can be specified.
 If the server's mountd service is not available via the specified
 transport, the mount request fails.
+.IP
 Refer to the TRANSPORT METHODS section for more on how the
 .B mountproto
 mount option interacts with the
@@ -709,17 +729,26 @@ for mounting the
 .B nfs4
 file system type.
 .TP 1.5i
-.BI proto= transport
-The transport the NFS client uses
+.BI proto= netid
+The transport protocol name and protocol family the NFS client uses
 to transmit requests to the NFS server for this mount point.
-.I transport
-can be either
-.B udp
-or
-.BR tcp .
+If an NFS server has both an IPv4 and an IPv6 address, using a specific
+netid will force the use of IPv4 or IPv6 networking to communicate
+with that server.
+.IP
+If support for TI-RPC is built into the
+.B mount.nfs
+command,
+.I netid
+is a valid netid listed in
+.IR /etc/netconfig .
+Otherwise,
+.I netid
+is one of "tcp" or "udp," and only IPv4 may be used.
+.IP
 All NFS version 4 servers are required to support TCP,
 so if this mount option is not specified, the NFS version 4 client
-uses the TCP transport protocol.
+uses the TCP protocol.
 Refer to the TRANSPORT METHODS section for more details.
 .TP 1.5i
 .BI port= n
@@ -779,7 +808,8 @@ The DATA AND METADATA COHERENCE section discusses
 the behavior of this option in more detail.
 .TP 1.5i
 .BI clientaddr= n.n.n.n
-Specifies  a  single  IPv4  address  (in dotted-quad form)
+Specifies a single IPv4 address (in dotted-quad form),
+or a non-link-local IPv6 address,
 that the NFS client advertises to allow servers
 to perform NFS version 4 callback requests against
 files on this mount point. If  the  server is unable to
@@ -855,6 +885,14 @@ This example can be used to mount /usr over NFS.
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
@@ -1498,6 +1536,8 @@ such as security negotiation, server referrals, and named attributes.
 .BR mount.nfs (5),
 .BR umount.nfs (5),
 .BR exports (5),
+.BR netconfig (5),
+.BR ipv6 (7),
 .BR nfsd (8),
 .BR sm-notify (8),
 .BR rpc.statd (8),

