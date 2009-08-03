From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 4/8] NFS Mount Configuration File (Vers 2)
Date: Mon, 03 Aug 2009 10:54:32 -0400
Message-ID: <4A76FA28.2080109@RedHat.com>
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

commit 259bf96f9e2b6836529158ea1b7ee3a02e3266b7
Author: Steve Dickson <steved@redhat.com>
Date:   Sun Aug 2 12:28:19 2009 -0400

    Adds '--enable-mountconf' configuration flag that will
    enabled mount to read from a configuration file.
    The default value is disabled (or no)
    
    Adds '--with-mountfile' configuration flag that is used when
    mountconf is enabled to define the configuration file name.
    The default is /etc/nfsmount.conf.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/configure.ac b/configure.ac
index e0ca70e..5d26345 100644
--- a/configure.ac
+++ b/configure.ac
@@ -136,6 +136,31 @@ AC_ARG_ENABLE(ipv6,
 	AC_SUBST(enable_ipv6)
 	AM_CONDITIONAL(CONFIG_IPV6, [test "$enable_ipv6" = "yes"])
 
+if test "$enable_mount" = yes; then
+	AC_ARG_ENABLE(mountconfig,
+	[AC_HELP_STRING([--enable-mountconf],
+                        [enable mount to use a configuration file])],
+	mountconfig=$enableval,
+	mountconfig=no)
+	if test "$enable_mountconfig" = yes; then
+		AC_DEFINE(MOUNT_CONFIG, 1, 
+			[Define this if you want mount to read a configuration file])
+		AC_ARG_WITH(mountfile,
+			[AC_HELP_STRING([--with-mountfile=filename],
+			[Using filename as the NFS mount options file [/etc/nfsmounts.conf]]
+			)],
+		mountfile=$withval,
+		mountfile=/etc/nfsmount.conf)
+		AC_SUBST(mountfile)
+		AC_DEFINE_UNQUOTED(MOUNTOPTS_CONFFILE, "$mountfile", 
+			[This defines the location of the NFS mount configuration file])
+	else
+		enable_mountconfig=
+	fi
+	AC_SUBST(enable_mountconfig)
+	AM_CONDITIONAL(MOUNT_CONFIG, [test "$enable_mountconfig" = "yes"])
+fi
+
 dnl Check for TI-RPC library and headers
 AC_LIBTIRPC
