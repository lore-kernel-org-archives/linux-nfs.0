From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] nfs(5): Replace the term "netid" in mount option descriptions
Date: Wed, 24 Sep 2008 14:24:54 -0400
Message-ID: <20080924182235.3000.71437.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: mike.eisler@netapp.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:32777 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbYIXS3D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2008 14:29:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

TI-RPC introduced the concept of "netid" which is a string that is
mapped to a set of transport capabilities via a netconfig database.
RPC services register a netid and bindaddr with their local rpcbind
daemon to advertise their ability to support particular transports.

Mike Eisler noted that the use of the term "netid" in nfs(5) is not
appropriate, since Linux does not treat the value of the proto= or
mountproto= options as a netid proper, but rather to select a
particular transport capability provided locally on the client.

The Linux NFS client currently uses a simple internal mapping between
these names and its own transport capabilities rather than using the
names as part of an rpcbind query, thus these strings are really not
netids.  They are more akin to what TI-RPC calls "protocol names".

Remove the term "netid" from nfs(5) for now.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Mike Eisler <mike.eisler@netapp.com>
---

Second take.  I hope I've addressed Trond's and Tom's concerns.

 utils/mount/nfs.man |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 0fc5079..c625ee2 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -411,15 +411,15 @@ for mounting the
 .B nfs
 file system type.
 .TP 1.5i
-.BI proto= netid
-The transport protocol used by the NFS client
+.BI proto= name
+The transport the NFS client uses
 to transmit requests to the NFS server for this mount point.
-.I netid
+.I name
 can be either
 .B udp
 or
 .BR tcp .
-Each transport protocol uses different default
+Each transport uses different default
 .B retrans
 and
 .B timeo
@@ -489,18 +489,18 @@ or the server's mountd service is not available on the advertised port.
 This option can be used when mounting an NFS server
 through a firewall that blocks the rpcbind protocol.
 .TP 1.5i
-.BI mountproto= netid
-The transport protocol used by the NFS client
+.BI mountproto= name
+The transport the NFS client uses
 to transmit requests to the NFS server's mountd service when performing
 this mount request, and when later unmounting this mount point.
-.I netid
+.I name
 can be either
 .B udp
 or
 .BR tcp .
 .IP
 This option can be used when mounting an NFS server
-through a firewall that blocks a particular transport protocol.
+through a firewall that blocks a particular transport.
 When used in combination with the
 .B proto
 option, different transports for mountd requests and NFS requests
@@ -638,10 +638,10 @@ for mounting the
 .B nfs4
 file system type.
 .TP 1.5i
-.BI proto= netid
-The transport protocol used by the NFS client
+.BI proto= name
+The transport the NFS client uses
 to transmit requests to the NFS server for this mount point.
-.I netid
+.I name
 can be either
 .B udp
 or

