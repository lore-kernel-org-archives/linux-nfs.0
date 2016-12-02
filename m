Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36611 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753253AbcLBEAS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 23:00:18 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:30 +1100
Subject: [PATCH 15/15] Add nfs.systemd man page
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065111043.28046.3858869219236614683.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This discusses some of the behaviors of the various
unit files, and how best to work with them to achieve
various results.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/Makefile.am     |    4 +
 systemd/nfs.systemd.man |  167 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 169 insertions(+), 2 deletions(-)
 create mode 100644 systemd/nfs.systemd.man

diff --git a/systemd/Makefile.am b/systemd/Makefile.am
index b5ab157d728b..0d15b9f25ff8 100644
--- a/systemd/Makefile.am
+++ b/systemd/Makefile.am
@@ -36,8 +36,8 @@ endif
 endif
 
 man5_MANS	= nfs.conf.man
-
-EXTRA_DIST = $(unit_files) $(man5_MANS)
+man7_MANS	= nfs.systemd.man
+EXTRA_DIST = $(unit_files) $(man5_MANS) $(man7_MANS)
 
 unit_dir = /usr/lib/systemd/system
 generator_dir = /usr/lib/systemd/system-generators
diff --git a/systemd/nfs.systemd.man b/systemd/nfs.systemd.man
new file mode 100644
index 000000000000..01801ebb5f2c
--- /dev/null
+++ b/systemd/nfs.systemd.man
@@ -0,0 +1,167 @@
+.TH NFS.SYSTEMD 7
+.SH NAME
+nfs.systemd \- managing NFS services through systemd.
+.SH SYNOPSIS
+nfs-utils.service
+.br
+nfs-server.service
+.br
+nfs-client.target
+.br
+.I etc
+.SH DESCRIPTION
+The
+.I nfs-utils
+package provides a suite of
+.I systemd
+unit files which allow the various services to be started and
+managed.  These unit files ensure that the services are started in the
+correct order, and the prerequisites are active before dependant
+services start.  As there are quite  few unit files, it is not
+immediately obvious how best to achieve certain results.  The
+following subsections attempt to cover the issues that are most likely
+to come up.
+.SS Configuration
+The standard systemd unit files do not provide any easy way to pass
+any command line arguments to daemons so as to configure their
+behavior.  In many case such configuration can be performed by making
+changes to
+.I /etc/nfs.conf
+or other configuration files.  When that is not convenient, a
+distribution might provide systemd "drop-in" files which replace the
+.B ExecStart=
+setting to start the program with different arguments.  For example a
+drop-in file
+.B systemd/system/nfs-mountd.service.d/local.conf
+containing
+.RS
+.nf
+[Service]
+EnvironmentFile=/etc/sysconfig/nfs
+ExecStart=
+ExecStart= /usr/sbin/rpc.mountd $RPCMOUNTDOPTS
+.fi
+.RE
+would cause the
+.B nfs-mountd.service
+unit to run the
+.I rpc.mountd
+program using, for arguments, the value given for
+.B RPCMOUNTDOPTS
+in
+.IR /etc/sysconfig/nfs .
+This allows for seamless integration with existing configuration
+tools.
+.SS Enabling unit files
+There are three unit files which are designed to be manually enabled.
+All others are automatically run as required.  The three are:
+.TP
+.B nfs-client.target
+This should be enabled on any host which ever serves as an NFS client.
+There is little cost in transparently enabling it whenever NFS client
+software is installed.
+.TP
+.B nfs-server.service
+This must be enabled to provide NFS service to clients.  It starts and
+configures the required daemons in the required order.
+.TP
+.B nfs-blkmap.service
+The
+.B blkmapd
+daemon is only required on NFS clients which are using pNFS (parallel
+NFS), and particularly using the
+.B blocklayout
+layout protocol.  If you might use this particular extension to NFS,
+the
+.B nfs-blkmap.service
+unit should be enabled.
+.PP
+Several other units which might be considered to be optional, such as
+.I rpc-gssd.service
+are careful to only start if the required configuration file exists.
+.I rpc-gsdd.service
+will not start if the
+.I krb5.keytab
+file does not exist (typically in
+.IR /etc ).
+.SS Restarting NFS services
+Most NFS daemons can be restarted at any time.  They will reload any
+state that they need, and continue servicing requests.  This is rarely
+necessary though.
+.PP
+When configuration changesare make, it can be hard to know exactly
+which services need to be restarted to ensure that the configuration
+takes effect.  The simplest approach, which is often the best, is to
+restart everything.  To help with this, the
+.B nfs-utils.service
+unit is provided.  It declares appropriate dependencies with other
+unit files so that
+.RS
+.B systemctl restart nfs-utils
+.RE
+will restart all NFS daemons that are running.  This will cause all
+configuration changes to take effect
+.I except
+for changes to mount options lists in
+.I /etc/fstab
+or
+.IR /etc/nfsmount.conf .
+Mount options can only be changed by unmounting and remounting
+filesystem.  This can be a disruptive operation so it should only be
+done when the value justifies the cost.  The command
+.RS
+.B umount -a -t nfs; mount -a -t nfs
+.RE
+should unmount and remount all NFS filesystems.
+.SS Masking unwanted services
+Rarely there may be a desire to prohibit some services from running
+even though there are normally part of a working NFS system.  This may
+be needed to reduce system load to an absolute minimum, or to reduce
+attack surface by not running daemons that are not absolutely
+required.
+.PP
+Two particular services which this can apply to are
+.I rpcbind
+and
+.IR idmapd .
+.I rpcbind
+is not part of the
+.I nfs-utils
+package, but it used by several NFS services.  However it is
+.B not
+needed when only NFSv4 is in use.  If a site will never use NFSv3 (or
+NFSv2) and does not want
+.I rpcbind
+to be running, the correct approach is to run
+.RS
+.B systemctl mask rpcbind
+.RE
+This will disable
+.IR rpcbind ,
+and the various NFS services which depend on it (and are only needed
+for NFSv3) will refuse to start, without interfering with the
+operation of NFSv4 services.  In particular,
+.I rpc.statd
+will not run when
+.I rpcbind
+is masked.
+.PP
+.I idmapd
+is only needed for NFSv4, and even then is not needed when the client
+and server agree to use user-ids rather than user-names to identify the
+owners of files.  If
+.I idmapd
+is not needed and not wanted, it can be masked with
+.RS
+.B systemctl mask idmapd
+.RE
+.SH FILES
+/etc/nfs.conf
+.br
+/etc/nfsmount.conf
+.br
+/etc/idmapd.conf
+.SH SEE ALSO
+.BR systemd.unit (5),
+.BR nfs.conf (5),
+.BR nfsmount.conf (5).


