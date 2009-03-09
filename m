From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 6/9] An example of an nfsmount.conf file
Date: Mon, 09 Mar 2009 17:04:54 -0400
Message-ID: <49B58476.7050104@RedHat.com>
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

commit f35a86f80c7e82d86403d0cf4e01b725e556b0a9
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 9 14:04:20 2009 -0400

    The example nfsmount.conf file
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 29e993d..de810a4 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -8,7 +8,7 @@ man8_MANS	= mount.nfs.man umount.nfs.man
 man5_MANS	= nfs.man
 
 sbin_PROGRAMS	= mount.nfs
-EXTRA_DIST = nfsmount.x $(man8_MANS) $(man5_MANS)
+EXTRA_DIST = nfsmount.x $(man8_MANS) $(man5_MANS) nfsmount.conf
 mount_nfs_SOURCES = mount.c error.c network.c fstab.c token.c \
 		    parse_opt.c parse_dev.c \
 		    nfsmount.c nfs4mount.c stropts.c\
diff --git a/utils/mount/nfsmount.conf b/utils/mount/nfsmount.conf
new file mode 100644
index 0000000..9272284
--- /dev/null
+++ b/utils/mount/nfsmount.conf
@@ -0,0 +1,120 @@
+#
+# /etc/nfsmount.conf - see nfsmount.conf(5) for details
+#
+# This is an NFS mount configuration file. This file can be broken
+# up into three different sections: Mount, Server and Global
+# 
+# [ <Mount_point> ] 
+# This section defines all the mount options that
+# should be used on a particular mount point. The '<Mount_Point>'
+# string need to be an exact match of the path in the mount 
+# command. Example:
+#     [/export/home]
+#       background=True
+# Would cause all mount to /export/home would be done in
+# the background
+#
+# [ <Server_Name> ]
+# This section defines all the mount options that
+# should be used on mounts to a particular NFS server. 
+# Example:
+#     [nfsserver.foo.com]
+#       rsize=32k
+#       wsize=32k
+# All reads and writes to the 'nfsserver.foo.com' server 
+# will be done with 32k (32768 bytes) block sizes.
+#
+#[ NFSMount_Global_Options ]
+# This statically named section defines global mount 
+# options that can be applied on all NFS mount.
+#
+# Protocol Version [2,3]
+# Nfsvers=3
+# Network Transport [Udp,Tcp,Rdma]
+# Proto=Tcp
+#
+# The number of times a request will be retired before 
+# generating a timeout 
+# Retrans=2
+#
+# The number of minutes that will retry mount
+# Retry=2
+#
+# The minimum time (in seconds) file attributes are cached
+# acregmin=30
+#
+# The Maximum time (in seconds) file attributes are cached
+# acregmin=60
+#
+# The minimum time (in seconds) directory attributes are cached
+# acregmin=30
+#
+# The Maximum time (in seconds) directory attributes are cached
+# acregmin=60
+#
+# Enable Access  Control  Lists
+# Acl=False
+#
+# Enable Attribute Caching
+# Ac=True
+#
+# Do mounts in background (i.e. asynchronously)
+# Background=False
+#
+# Close-To-Open cache coherence
+# Cto=True
+#
+# Do mounts in foreground (i.e. synchronously)
+# Foreground=True
+#
+# How to handle times out from servers (Hard is STRONGLY suggested)
+# Hard=True
+# Soft=False
+#
+# Enable File Locking
+# Lock=True
+#
+# Enable READDIRPLUS on NFS version 3 mounts
+# Rdirplus=True
+#
+# Maximum Read Size (in Bytes)
+# Rsize=8k
+#
+# Maximum Write Size (in Bytes)
+# Wsize=8k
+#
+# Maximum Server Block Size (in Bytes)
+# Bsize=8k
+#
+# Ignore unknown mount options
+# Sloppy=False
+#
+# Share Data and Attribute Caches
+# Sharecache=True
+#
+# The amount of time, in tenths of a seconds, the client
+# will wait for a response from the server before retransmitting
+# the request.
+# Timeo=600
+#
+# Sets all attributes times to the same time (in seconds)
+# actimeo=30
+#
+# Server Mountd port mountport
+# mountport=4001
+#
+# Server Mountd Protocol
+# mountproto=tcp
+#
+# Server Mountd Version
+# mounvers=3
+#
+# Server Mountd Host
+# mounthost=hostname
+#
+# Server Port
+# Port=2049
+#
+# RPCGSS security flavors 
+# [none, sys, krb5, krb5i, krb5p ]
+# Sec=sys
