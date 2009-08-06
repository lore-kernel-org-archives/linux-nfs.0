From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 5/10] NFS Mount Configuration File (Vers 3)
Date: Thu, 06 Aug 2009 14:44:35 -0400
Message-ID: <4A7B2493.4010701@RedHat.com>
References: <4A7B2324.9090406@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35360 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902AbZHFSrq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Aug 2009 14:47:46 -0400
In-Reply-To: <4A7B2324.9090406-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit a534e4fef0ee59a33548aa9a342dad588ae605df
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Aug 5 16:10:01 2009 -0400

    Adds '--enable-mountconfig' configuration flag that will
    enabled mount to read from a configuration file.
    The default value is disabled (or no)
    
    Adds '--with-mountfile' configuration flag that is used when
    mountconf is enabled to define the configuration file name.
    The default is /etc/nfsmount.conf.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/configure.ac b/configure.ac
index e0ca70e..1b653e4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -136,6 +136,31 @@ AC_ARG_ENABLE(ipv6,
 	AC_SUBST(enable_ipv6)
 	AM_CONDITIONAL(CONFIG_IPV6, [test "$enable_ipv6" = "yes"])
 
+if test "$enable_mount" = yes; then
+	AC_ARG_ENABLE(mountconfig,
+	[AC_HELP_STRING([--enable-mountconfig],
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
 

