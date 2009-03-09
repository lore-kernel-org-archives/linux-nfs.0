From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 7/9] New nfsmount.conf(5) man page
Date: Mon, 09 Mar 2009 17:06:42 -0400
Message-ID: <49B584E2.9000608@RedHat.com>
References: <49B57FB2.9020000@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49B57FB2.9020000@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

commit 5232a0cbb7d7b1eb64dfb3f282b42d1ff5fd586a
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 9 14:08:57 2009 -0400

    The new nfsmount.conf(5) man page and the update to
    the nfs(5) man page
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index de810a4..a586edc 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -5,7 +5,7 @@
 sbindir = /sbin
 
 man8_MANS	= mount.nfs.man umount.nfs.man
-man5_MANS	= nfs.man
+man5_MANS	= nfs.man nfsmount.conf.man
 
 sbin_PROGRAMS	= mount.nfs
 EXTRA_DIST = nfsmount.x $(man8_MANS) $(man5_MANS) nfsmount.conf
diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 13de524..1700c5b 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -752,6 +752,36 @@ In the presence of multiple client network interfaces,
 special routing policies,
 or atypical network topologies,
 the exact address to use for callbacks may be nontrivial to determine. 
+.SH "MOUNT CONFIGURATION FILE"
+All of the mount options described the above section can also be set 
+in the 
+.B /etc/nfsmount.conf
+file. The configuration file is made up of three different 
+sections: Global, Server and MountPoint. See 
+.B nfsmount.conf(5) 
+for details.
+.PP
+The mount command parses section in a particular order and
+will not use options that have been set in previous sections.
+The order of precedence is as follows:
+is:
+.HP
+.B Command line option
+- options set on the command will always be used.
+.HP
+.B Mount Point options
+- options set in the '<Mount_Point>' section will be 
+used only if they are not specified on the command line.
+.HP
+.B Sever options
+- options set in the '<Server_Name>' section will be used if 
+they are not specified on the command line section or 
+the mount point section.
+.HP
+.B Global options
+- options set in the '[NFSMount_Global_Options]' will be used 
+if they are not specified on the command or in the mount 
+point section or the server section.
 .SH EXAMPLES
 To mount an export using NFS version 2,
 use the
diff --git a/utils/mount/nfsmount.conf.man b/utils/mount/nfsmount.conf.man
new file mode 100644
index 0000000..fddd018
--- /dev/null
+++ b/utils/mount/nfsmount.conf.man
@@ -0,0 +1,68 @@
+.\"@(#)nfsmount.conf.5"
+.TH NFSMOUNT.CONF 5 "9 Mar 2008"
+.SH NAME
+nfsmount.conf - Configuration file for NFS mounts
+.SH SYNOPSIS
+Configuration file for NFS mounts that allow mount options
+to be set globally, per server or per mount point.
+.SH DESCRIPTION
+The configuration file is made up of multiple sections 
+followed by variables associated with that section.
+A section is define by a string enclosed by '[' and ']'
+branches, similar to '[nfs.server.com]'. 
+Variables are assignment statements that assign values 
+to particular variables using a '=' sign,
+similar to 'Proto=Tcp'.
+Sections are broken up into three basic categories:
+Global options, Server options and Mount Point options.
+.HP
+.BR [NFSMount_Global_Options]
+- This statically named section
+defines all of the global mount options that can be 
+applied on every NFS mount.
+.HP
+.BR [<Server_Name>]
+- This section defines all the mount options that should 
+be used on mounts to a particular NFS server. The '<Sever_Name>'
+needs to be an exact match of server name in the 
+mount command. 
+.HP
+.BR [<Mount_Point>]
+- This section defines all the mount options that 
+should be used on a particular mount point.
+The '<Mount_Point>' string need to be an exact match of the
+path in the mount command.
+.SH EXAMPLES
+.PP
+These are some example lines of how sections and variables
+are define in the configuration file.
+.PP
+[NFSMount_Global_Options]
+.br
+Proto=Tcp
+.PP
+The TCP protocol will be used on every NFS mount.
+.PP
+[nfsserver.foo.com]
+.br
+rsize=32k
+.br
+wsize=32k
+.PP
+A 33k (32768 bytes) block size will be used as the read and write
+size on all mounts to the 'nfsserver.foo.com' server.
+.PP
+[/export/home]
+.br
+Background=True
+.PP
+All mounts to the '/export/home' export will put in
+background (i.e. done asynchronously).
+.SH FILES
+.TP 10n
+.I /etc/nfsmount.conf
+Default NFS mount configuration file
+.PD
+.SH SEE ALSO
+.BR nfs (5),
+.BR mount (8),
