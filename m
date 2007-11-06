From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/15] nfs(5) man page: Add new EXAMPLES section
Date: Mon, 05 Nov 2007 20:03:28 -0500
Message-ID: <20071106010328.5037.32407.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCqm-0004fK-RP
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:28 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCqs-0004R7-ES
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:34 -0800
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

Add a section to nfs(5) that provides examples demonstrating how to specify
NFS mount options in /etc/fstab.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   54 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 9cb673a..10e5cd2 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -629,6 +629,60 @@ In the presence of multiple client network interfaces,
 special routing policies,
 or atypical network topologies,
 the exact address to use for callbacks may be nontrivial to determine. 
+.SH EXAMPLES
+To mount a remote share using NFS version 2,
+use the
+.B nfs
+file system type and specify the
+.B nfsvers=2
+mount option.
+To mount using NFS version 3,
+use the
+.B nfs
+file system type and specify the
+.B nfsvers=3
+mount option.
+To mount using NFS version 4,
+use the
+.B nfs4
+file system type.
+The
+.B nfsvers
+mount option is not supported for the
+.B nfs4
+file system type.
+.P
+The following example from an
+.I /etc/fstab
+file causes the mount command to negotiate
+reasonable defaults for NFS behavior.
+.P
+.NF
+.TA 2.5i +0.7i +0.7i +.7i
+	server:/export/share	/mnt	nfs	defaults	0 0
+.FI
+.P
+Here is an example from an /etc/fstab file for an NFS version 2 mount over UDP.
+.P
+.NF
+.TA 2.5i +0.7i +0.7i +.7i
+	server:/export/share	/mnt	nfs	nfsvers=2,proto=udp	0 0
+.FI
+.P
+Try this example to mount using NFS version 4 over TCP
+with Kerberos 5 mutual authentication.
+.P
+.NF
+.TA 2.5i +0.7i +0.7i +.7i
+	server:/export/share	/mnt	nfs4	sec=krb5	0 0
+.FI
+.P
+This example can be used to mount /usr over NFS.
+.P
+.NF
+.TA 2.5i +0.7i +0.7i +.7i
+	server:/export/share	/usr	nfs	ro,nolock,nocto,actimeo=3600	0 0
+.FI
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
