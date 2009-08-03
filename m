From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 7/8] NFS Mount Configuration File (Vers 2)
Date: Mon, 03 Aug 2009 10:59:07 -0400
Message-ID: <4A76FB3B.1070004@RedHat.com>
References: <4A76F8E6.2010607@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A76F8E6.2010607@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

commit 92e623c74908ffcc76da72e7927ce4e237062c76
Author: Steve Dickson <steved@redhat.com>
Date:   Sun Aug 2 12:41:03 2009 -0400

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
index 13de524..251b16f 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -752,6 +752,44 @@ In the presence of multiple client network interfaces,
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
+.B [<Mount_Point>]
+section  will
+be used only if they are not specified on the command line.
+.RE
+.B Server options
+.RS
+options set in the 
+.B [<Server_Name>] 
+section will be used
+if they are not specified on the command  line or  the
+mount point section.
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
index 0000000..1a3bb68
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
+branches; for example, 
+.BR [nfsserver.foo.com] . 
+Variables are assignment statements that assign values 
+to particular variables using the  
+.BR = 
+operator, as in 
+.BR Proto=Tcp .
+Sections are broken up into three basic categories:
+Global options, Server options and Mount Point options.
+.HP
+.BR [NFSMount_Global_Options]
+- This statically named section
+defines all of the global mount options that can be 
+applied to every NFS mount.
+.HP
+.BR [<Server_Name>]
+- This section defines all the mount options that should 
+be used on mounts to a particular NFS server. The 
+.BR <Server_Name>
+needs to be an exact match of the server
+name used in the 
+.B mount
+command. 
+.HP
+.BR [<Mount_Point>]
+- This section defines all the mount options that 
+should be used on a particular mount point.
+The 
+.BR <Mount_Point>
+string need to be an exact match of the
+path used in the 
+.BR mount 
+command.
+.SH EXAMPLES
+.PP
+These are some example lines of how sections and variables
+are defined in the configuration file.
+.PP
+.BR [NFSMount_Global_Options]
+.br
+.BR Proto=Tcp
+.RS
+.HP
+The TCP protocol will be used on every NFS mount.
+.HP
+.RE
+.BR [nfsserver.foo.com]
+.br
+.BR rsize=32k
+.br
+.BR wsize=32k
+.HP
+.RS
+A 33k (32768 bytes) block size will be used as the read and write
+size on all mounts to the 'nfsserver.foo.com' server.
+.HP
+.RE
+.BR [/export/home]
+.br
+.BR Background=True
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
