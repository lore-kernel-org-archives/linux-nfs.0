From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/15] nfs(5) man page: Replace the BUGS section
Date: Mon, 05 Nov 2007 20:03:54 -0500
Message-ID: <20071106010354.5037.4568.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCrE-0004gL-1K
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:56 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCrI-0004Xy-IU
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:04:01 -0800
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

Update the BUGS section of nfs(5).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   51 +++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 43 insertions(+), 8 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index b673cef..adc394e 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1052,15 +1052,50 @@ in an environment that mixes POSIX ACLs and NFS version 4.
 .TP 1.5i
 .I /etc/fstab
 file system table
+.SH BUGS
+The generic
+.B remount
+option is not fully supported.
+Generic options, such as
+.BR rw " and " ro
+can be modified using the
+.B remount
+option,
+but NFS-specific options are not all supported.
+The underlying transport or NFS version
+cannot be changed by a remount, for example.
+Performing a remount on an NFS file system mounted with the
+.B noac
+option may have unintended consequences.
+The
+.B noac
+option is a mixture of a generic option,
+.BR sync ,
+and an NFS-specific option
+.BR actimeo=0 .
+.P
+Before 2.4.7, the Linux NFS client did not support NFS over TCP.
+.P
+Before 2.4.20, the Linux NFS client used a heuristic
+to determine whether cached file data was still valid
+rather than using the standard close-to-open cache coherency method
+described above.
+.P
+Starting with 2.4.22, the Linux NFS client employs
+a Van Jacobsen-based RTT estimator to set RPC timeouts
+when using NFS over UDP.
+.P
+Before 2.6.0, the Linux NFS client did not support NFS version 4.
+.P
+Before 2.6.8, the Linux NFS client used only synchronous reads and writes
+when the
+.BR rsize " and " wsize
+settings were smaller than the system's page size.
+.P
+The Linux NFS client does not yet support
+certain optional features of the NFS version 4 protocol,
+such as security negotiation, server referrals, and named attributes.
 .SH "SEE ALSO"
 .BR fstab "(5), " mount "(8), " umount "(8), " exports (5)
 .SH AUTHOR
 "Rick Sladkey" <jrs@world.std.com>
-.SH BUGS
-.P
-Checking files on NFS filesystem referenced by file descriptors (i.e. the 
-.BR fcntl 
-and 
-.BR ioctl
-families of functions) may lead to inconsistent result due to the lack of
-consistency check in kernel even if noac is used.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
