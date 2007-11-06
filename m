From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/15] nfs(5) man page: Add new TRANSPORT METHODS
	section
Date: Mon, 05 Nov 2007 20:03:33 -0500
Message-ID: <20071106010333.5037.89264.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCqs-0004fR-3b
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:34 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCqx-00062S-Lv
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:39 -0800
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

Add a section to nfs(5) that discusses the trade-offs between the UDP and
TCP transports.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   56 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 10e5cd2..0debdb0 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -683,6 +683,62 @@ This example can be used to mount /usr over NFS.
 .TA 2.5i +0.7i +0.7i +.7i
 	server:/export/share	/usr	nfs	ro,nolock,nocto,actimeo=3600	0 0
 .FI
+.SH "TRANSPORT METHODS"
+NFS clients send requests to NFS servers via
+Remote Procedure Calls, or
+.IR RPCs .
+The RPC client discovers remote service endpoints automatically,
+handles per-request authentication,
+adjusts request parameters for different byte endianness on client and server,
+and retransmits requests that may have been lost by the network or server.
+RPC requests and replies flow over a network transport.
+.P
+The
+.BR mount (8)
+command, the NFS client, and the NFS server
+can usually automatically negotiate proper transport
+and data transfer size settings for a mount point.
+There are some cases, however, where it pays to specify
+these settings explicitly using mount options.
+.P
+TCP is the default transport for all modern NFS implementations.
+It performs well in almost every conceivable network environment
+and provides excellent guarantees against data corruption
+due to network unreliability.
+TCP is often a requirement for mounting a server through a network firewall.
+.P
+The UDP transport has many limitations
+that prevent smooth operation and good performance
+in some common deployment environments.
+However, UDP can be quite effective in specialized settings
+where the network's MTU is large relative to NFS's data transfer size.
+This includes the use of jumbo Ethernet frames
+or high bandwidth local area networks.
+Thus, with UDP, trimming the
+.B rsize
+and
+.B wsize
+settings
+so that each NFS read or write request fits in just a few network frames,
+or even in a single frame, is advised.
+This reduces the probability that the loss of a single MTU-sized network frame
+results in the loss of an entire NFS request.
+TCP itself manages the reliability of network transmissions,
+thus
+.B rsize
+and
+.B wsize
+can safely be allowed to default to the largest settings
+supported by both client and server.
+.P
+Reasonable timeout and retransmit settings for NFS over TCP
+are in the one to several minute range
+because the TCP transport already manages network-related packet loss.
+For UDP, even an insignificant packet loss rate results in the loss of
+whole NFS requests,
+thus retransmit timeouts are usually in the subsecond range.
+The Linux RPC client employs an RTT estimator that
+dynamically manages the timeout settings for requests sent via UDP. 
 .SH FILES
 .I /etc/fstab
 .SH "SEE ALSO"


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
