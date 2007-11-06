From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/15] nfs(5) man page: Update DESCRIPTION section
Date: Mon, 05 Nov 2007 20:03:02 -0500
Message-ID: <20071106010302.5037.68416.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCqI-0004ZB-9X
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:02:58 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCqN-0004Kb-MZ
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:04 -0800
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |  106 +++++++++++++++++++++++++++------------------------
 1 files changed, 57 insertions(+), 49 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 6af39bd..06bd3be 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -11,60 +11,68 @@ file systems
 .SH SYNOPSIS
 .I /etc/fstab
 .SH DESCRIPTION
-The
-.I fstab
-file contains information about which filesystems
-to mount where and with what options.
-For NFS mounts, it contains the server name and
-exported server directory to mount from,
-the local directory that is the mount point,
-and the NFS specific options that control
-the way the filesystem is mounted.
+NFS is an Internet Standard protocol
+invented by Sun Microsystems in the 1980s
+to share files between systems residing
+on a local area network.
+The Linux NFS client supports three versions
+of the NFS protocol:
+NFS version 2 [RFC1094],
+NFS version 3 [RFC1813],
+and NFS version 4 [RFC3530].
 .P
-Three different versions of the NFS protocol are
-supported by the Linux NFS client:
-NFS version 2, NFS version 3, and NFS version 4.
-To mount via NFS version 2, use the
-.BR nfs
-file system type and specify
-.BR nfsvers=2 .
-To mount via NFS version 3, use the
-.BR nfs
-file system type and specify
-.BR nfsvers=3 .
-Version 3 is the default protocol version for the
-.BR nfs
-file system type when
-.BR nfsvers=
-is not specified on the mount command and both client and server
-support it.
-To mount via NFS version 4, use the
-.BR nfs4
-file system type.
 The
-.BR nfsvers=
-keyword is not supported for the
-.BR nfs4
-file system type.
+.BR mount (8)
+command attaches a file system to the system's
+name space hierarchy at a given mount point.
+The
+.I /etc/fstab
+file describes how
+.BR mount (8)
+should assemble a system's file name hierarchy
+from various independent file systems,
+including remote NFS shares.
+Each line in the
+.I /etc/fstab
+file describes a single file system, its mount point,
+and a set of default mount options for that mount point.
 .P
-These file system types share similar mount options;
-the differences are listed below.
+For NFS file system mounts, a line in the
+.I /etc/fstab
+file specifies the server name,
+the path name of the exported server directory to mount,
+the local directory that is the mount point,
+the type of file system that is being mounted,
+and a list of mount options that control
+the way the filesystem is mounted and
+how the NFS client behaves when accessing
+files on this mount point.
+The fifth and sixth fields on each line are not used
+by NFS, thus conventionally each contain the digit zero.
 .P
-Here is an example from an \fI/etc/fstab\fP file for an NFSv3 mount
-over TCP.
-.sp
-.nf
-.ta 2.5i +0.75i +0.75i +1.0i
-server:/usr/local/pub	/pub	nfs	rsize=32768,wsize=32768,timeo=14,intr
-.fi
+.SP
+.NF
+.TA 2.5i +0.75i +0.75i +1.0i
+server:path	/mountpoint	fstype	option,option,...	0 0
+.FI
 .P
-Here is an example for an NFSv4 mount over TCP using Kerberos
-5 mutual authentication.
-.sp
-.nf
-.ta 2.5i +0.75i +0.75i +1.0i
-server:/usr/local/pub	/pub	nfs4	proto=tcp,sec=krb5,hard,intr
-.fi
+The server's hostname and the export pathname
+are separated by a colon,
+the mount options are separated by commas,
+and the remaining fields are separated by blanks or tabs.
+The server's hostname can be an unqualified hostname,
+a fully qualified domain name,
+or a dotted quad IPv4 address.
+The
+.I fstype
+field contains either "nfs" for version 2 or version 3 NFS mounts,
+or "nfs4" for NFS version 4 mounts.
+The
+.B nfs
+and
+.B nfs4
+file system types share similar mount options,
+which are described below. 
 .DT
 .SS Options for the nfs file system type
 .TP 1.5i


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
