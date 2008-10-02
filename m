From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] nfs(5): Clarify behavior of the mountproto= and proto= options
Date: Thu, 02 Oct 2008 11:56:37 -0400
Message-ID: <20081002155516.25702.69105.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Thomas.Talpey@netapp.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:16537 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169AbYJBP6O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Oct 2008 11:58:14 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Document the interaction between the mountproto= and the proto= mount
options in a new subsection of nfs(5).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Here's the latest version of this patch.  Comments?

 utils/mount/nfs.man |   85 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 85 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 433e73a..0c86559 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -507,6 +507,11 @@ option, different transports for mountd requests and NFS requests
 can be specified.
 If the server's mountd service is not available via the specified
 transport, the mount request fails.
+Refer to the TRANSPORT METHODS section for more on how the
+.B mountproto
+mount option interacts with the
+.B proto
+mount option.
 .TP 1.5i
 .BI mounthost= name
 The hostname of the host running mountd.
@@ -831,6 +836,84 @@ and
 .B wsize
 can safely be allowed to default to the largest values supported by  
 both client and server, independent of the network's MTU size.
+.SS "Using the mountproto mount option"
+This section applies only to NFS version 2 and version 3 mounts
+since NFS version 4 does not use a separate protocol for mount
+requests.
+.P
+The Linux NFS client can use a different transport for
+contacting an NFS server's rpcbind service, its mountd service,
+its Network Lock Manager (NLM) service, and its NFS service.
+The exact transports employed by the Linux NFS client for
+each mount point depends on the settings of the transport
+mount options, which include
+.BR proto ,
+.BR mountproto ,
+.BR udp ", and " tcp .
+.P
+The client sends Network Status Manager (NSM) notifications
+via UDP no matter what transport options are specified, but
+listens for server NSM notifications on both UDP and TCP.
+The NFS Access Control List (NFSACL) protocol shares the same
+transport as the main NFS service.
+.P
+If no transport options are specified, the Linux NFS client
+uses UDP to contact the server's mountd service, and TCP to
+contact its NLM and NFS services by default.
+.P
+If the server does not support these transports for these services, the
+.BR mount (8)
+command attempts to discover what the server supports, and then retries
+the mount request once using the discovered transports.
+If the server does not advertise any transport supported by the client
+or is misconfigured, the mount request fails.
+If the
+.B bg
+option is in effect, the mount command backgrounds itself and continues
+to attempt the specified mount request.
+.P
+When the
+.B proto
+option, the
+.B udp
+option, or the
+.B tcp
+option is specified but the
+.B mountproto
+option is not, the specified transport is used to contact
+both the server's mountd service and for the NLM and NFS services.
+.P
+If the
+.B mountproto
+option is specified but none of the
+.BR proto ", " udp " or " tcp
+options are specified, then the specified transport is used for the
+initial mountd request, but the mount command attempts to discover
+what the server supports for the NFS protocol, preferring TCP if
+both transports are supported.
+.P
+If both the
+.BR mountproto " and " proto
+(or
+.BR udp " or " tcp )
+options are specified, then the transport specified by the
+.B mountproto
+option is used for the initial mountd request, and the transport
+specified by the
+.B proto
+option (or the
+.BR udp " or " tcp " options)"
+is used for NFS, no matter what order these options appear.
+No automatic service discovery is performed if these options are
+specified.
+.P
+If any of the
+.BR proto ", " udp ", " tcp ", "
+or
+.B mountproto
+options are specified more than once on the same mount command line,
+then the value of the rightmost instance of each of these options
+takes effect.
 .SH "DATA AND METADATA COHERENCE"
 Some modern cluster file systems provide
 perfect cache coherence among their clients.
@@ -1234,6 +1317,8 @@ such as security negotiation, server referrals, and named attributes.
 .BR umount.nfs (5),
 .BR exports (5),
 .BR nfsd (8),
+.BR sm-notify (8),
+.BR rpc.statd (8),
 .BR rpc.idmapd (8),
 .BR rpc.gssd (8),
 .BR rpc.svcgssd (8),

