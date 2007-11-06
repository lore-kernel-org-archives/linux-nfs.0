From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/15] nfs(5) man page: Refresh the "SEE ALSO" section
Date: Mon, 05 Nov 2007 20:03:59 -0500
Message-ID: <20071106010359.5037.46575.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCrI-0004gX-60
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:04:02 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCrN-0006AR-Pi
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:04:05 -0800
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

Add appropriate references to nfs(5).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   28 +++++++++++++++++++++++++++-
 1 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index adc394e..67ecc94 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1096,6 +1096,32 @@ The Linux NFS client does not yet support
 certain optional features of the NFS version 4 protocol,
 such as security negotiation, server referrals, and named attributes.
 .SH "SEE ALSO"
-.BR fstab "(5), " mount "(8), " umount "(8), " exports (5)
+.BR fstab (5),
+.BR mount (8),
+.BR umount (8),
+.BR mount.nfs (5),
+.BR umount.nfs (5),
+.BR exports (5),
+.BR nfsd (8),
+.BR rpc.idmapd (8),
+.BR rpc.gssd (8),
+.BR rpc.svcgssd (8),
+.BR kerberos (1)
+.sp
+RFC 768 for the UDP specification.
+.br
+RFC 793 for the TCP specification.
+.br
+RFC 1094 for the NFS version 2 specification.
+.br
+RFC 1813 for the NFS version 3 specification.
+.br
+RFC 1832 for the XDR specification.
+.br
+RFC 1833 for the RPC bind specification.
+.br
+RFC 2203 for the RPCSEC GSS API protocol specification.
+.br
+RFC 3530 for the NFS version 4 specification. 
 .SH AUTHOR
 "Rick Sladkey" <jrs@world.std.com>


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
