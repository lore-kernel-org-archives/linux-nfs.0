From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 8/9] Another way to define the configuration file
Date: Mon, 09 Mar 2009 17:08:20 -0400
Message-ID: <49B58544.20308@RedHat.com>
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

commit e4a13e3b2f3d6c13b40425bcdbbf4689a3ceb6fa
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 9 15:11:04 2009 -0400

    Added '--with-mountconfig" configuration flag so the configuration
    file can be redefined during configuration.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/configure.ac b/configure.ac
index 5db4417..51645f2 100644
--- a/configure.ac
+++ b/configure.ac
@@ -278,8 +278,17 @@ if test "$enable_ipv6" = yes; then
   AC_CHECK_DECL([AI_ADDRCONFIG], ,
                AC_MSG_ERROR([full getaddrinfo(3) implementation needed for IPv6 support]),
                [ #include <netdb.h> ] )
+
 fi
 
+AC_ARG_WITH(mountconfig,
+	[AC_HELP_STRING([--with-mountconfig=filename],
+		[Using filename as the NFS mount options file [/etc/nfsmounts.conf]]
+	)],
+	mountconfig=$withval,
+	mountconfig=/etc/nfsmount.conf)
+	AC_SUBST(mountconfig)
+
 dnl *************************************************************
 dnl Check for headers
 dnl *************************************************************
@@ -344,6 +353,7 @@ dnl *************************************************************
 dnl Export some path names to config.h
 dnl *************************************************************
 AC_DEFINE_UNQUOTED(NFS_STATEDIR, "$statedir", [This defines the location of the NFS state files. Warning: this must match definitions in config.mk!])
+AC_DEFINE_UNQUOTED(MOUNTOPTS_CONFFILE, "$mountconfig", [This defines the location of the NFS mount configuration file])
 
 if test "x$cross_compiling" = "xno"; then
 	CFLAGS_FOR_BUILD=${CFLAGS_FOR_BUILD-"$CFLAGS"}
