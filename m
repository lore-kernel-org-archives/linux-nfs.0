From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 8/10] NFS Mount Configuration File (Vers 3)
Date: Thu, 06 Aug 2009 14:47:55 -0400
Message-ID: <4A7B255B.1010608@RedHat.com>
References: <4A7B2324.9090406@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35067 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbZHFSvH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Aug 2009 14:51:07 -0400
In-Reply-To: <4A7B2324.9090406-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit eba88370ed83a3bbfe5f4b1ef85b64da702b5e84
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Aug 5 17:04:00 2009 -0400

    The new nfsmount.conf(5) man page and the update to
    the nfs(5) man page
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index a1b56ca..5c1e5ad 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -19,6 +19,7 @@ mount_nfs_SOURCES = mount.c error.c network.c fstab.c token.c \
 
 if MOUNT_CONFIG
 mount_nfs_SOURCES += configfile.c
+man5_MANS += nfsmount.conf.man
 endif
 
 mount_nfs_LDADD = ../../support/nfs/libnfs.a \
diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 13de524..72538d1 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -752,6 +752,51 @@ In the presence of multiple client network interfaces,
 special routing policies,
 or atypical network topologies,
 the exact address to use for callbacks may be nontrivial to determine. 
+.SH MOUNT CONFIGURATION FILE
+All of the mount options described in the previous section can also be configured in
+the 
+.I /etc/nfsmount.conf 
+file. This configuration file is made up of three
+different sections: Global, Server and MountPoint. See 
+.BR nfsmount.conf(5)
+for details.
+.PP
+The mount command parses section in a particular order, and will not use
+options that were set in previous sections.  The order of precedence is as follows:
+
+.B Command line option 
+.RS
+options set on the command line will always be used.
+.RE
+.B Mount Point options
+.RS
+options set in the 
+.B [MountPoint \(lqMount_Point\(rq]
+section will be used only if they are not specified 
+on the command line. 
+.I \(lqMount_Point\(rq 
+must be surrounded by \(lq and must be the exact same 
+character string given on the mount command line as
+the mount point.
+.RE
+.B Server options
+.RS
+options set in the 
+.B [Server \(lqServer_Name\(rq] 
+section will be used if they are not specified on the 
+command  line or in the mount point section.
+.I \(lqServer_Name\(rq 
+must be surrounded by \(lq and must be the exact same 
+character string given on the mount command line as 
+the server name.
+.RE
+.B Global options 
+.RS
+options set in the 
+.B [NFSMount_Global_Options] 
+will be used if they are not specified on the command line, mount point 
+section, or the server section.
+.RE
 .SH EXAMPLES
 To mount an export using NFS version 2,
 use the
diff --git a/utils/mount/nfsmount.conf.man b/utils/mount/nfsmount.conf.man
new file mode 100644
index 0000000..12a3fe7
--- /dev/null
+++ b/utils/mount/nfsmount.conf.man
@@ -0,0 +1,87 @@
+.\"@(#)nfsmount.conf.5"
+.TH NFSMOUNT.CONF 5 "9 Mar 2008"
+.SH NAME
+nfsmount.conf - Configuration file for NFS mounts
+.SH SYNOPSIS
+Configuration file for NFS mounts that allows options
+to be set globally, per server or per mount point.
+.SH DESCRIPTION
+The configuration file is made up of multiple sections 
+followed by variables associated with that section.
+A section is defined by a string enclosed by 
+.BR [
+and 
+.BR ]
+branches.
+Variables are assignment statements that assign values 
+to particular variables using the  
+.BR = 
+operator, as in 
+.BR Proto=Tcp .
+Sections are broken up into three basic categories:
+Global options, Server options and Mount Point options.
+.HP
+.B [ NFSMount_Global_Options ]
+- This statically named section
+defines all of the global mount options that can be 
+applied to every NFS mount.
+.HP
+.B [ Server \(lqServer_Name\(rq ] 
+- This section defines all the mount options that should 
+be used on mounts to a particular NFS server. The 
+.I \(lqServer_Name\(rq
+strings needs to be surrounded by '\(lq' and 
+be an exact match of the server name used in the 
+.B mount
+command. 
+.HP
+.B [ MountPoint \(lqMount_Point\(rq ]
+- This section defines all the mount options that 
+should be used on a particular mount point.
+The 
+.I \(lqMount_Point\(rq
+string needs to be surrounded by '\(lq' and be an 
+exact match of the mount point used in the 
+.BR mount 
+command.
+.SH EXAMPLES
+.PP
+These are some example lines of how sections and variables
+are defined in the configuration file.
+.PP
+[ NFSMount_Global_Options ]
+.br
+    Proto=Tcp
+.RS
+.HP
+The TCP protocol will be used on every NFS mount.
+.HP
+.RE
+[ Server \(lqnfsserver.foo.com\(rq ]
+.br
+    rsize=32k
+.br
+    wsize=32k
+.HP
+.RS
+A 33k (32768 bytes) block size will be used as the read and write
+size on all mounts to the 'nfsserver.foo.com' server.
+.HP
+.RE
+.BR 
+[ MountPoint \(lq/export/home\(rq ]
+.br
+    Background=True
+.RS
+.HP
+All mounts to the '/export/home' export will be performed in
+the background (i.e. done asynchronously).
+.HP
+.SH FILES
+.TP 10n
+.I /etc/nfsmount.conf
+Default NFS mount configuration file
+.PD
+.SH SEE ALSO
+.BR nfs (5),
+.BR mount (8),

