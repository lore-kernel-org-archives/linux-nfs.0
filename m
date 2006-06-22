From: Amit Gud <agud@redhat.com>
Subject: [PATCH] Change mount configure option to --enable-mount
Date: Thu, 22 Jun 2006 12:51:04 -0400
Message-ID: <449ACA78.7050604@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080304090304060405090009"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FtSLD-00029g-G3
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 09:47:40 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FtSLD-0005wG-Eu
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 09:47:39 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------080304090304060405090009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


-- 
May the source be with you.
http://www.cis.ksu.edu/~gud


--------------080304090304060405090009
Content-Type: text/plain;
 name="mount-configure-option.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mount-configure-option.patch"

Change the configure option from --with-mount to --enable-mount.

Signed-off-by: Amit Gud <agud@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>

---
diff -uprN -X dontdiff nfs-utils/configure.in nfs-utils-ag/configure.in
--- nfs-utils/configure.in	2006-06-22 11:34:54.000000000 -0400
+++ nfs-utils-ag/configure.in	2006-06-22 10:55:31.000000000 -0400
@@ -107,12 +107,12 @@ AC_ARG_ENABLE(rquotad,
 	fi
 	AM_CONDITIONAL(CONFIG_RQUOTAD, [test "$enable_rquotad" = "yes"])
 
-AC_ARG_WITH(mount,
-	[AC_HELP_STRING([--without-mount],
-			[Create mount.nfs and do not use the util-linux mount(8) functionality. By default it doesn't.])],
-	use_mount=$withval,
-	use_mount=yes)
-	AM_CONDITIONAL(CONFIG_NOMOUNT, [test "$use_mount" = "no"])
+AC_ARG_ENABLE(mount,
+	[AC_HELP_STRING([--enable-mount],
+			[Create mount.nfs and don't use the util-linux mount(8) functionality. @<:@default=yes@:>@])],
+	enable_mount=$enableval,
+	enable_mount=yes)
+	AM_CONDITIONAL(CONFIG_MOUNT, [test "$enable_mount" = "yes"])
 
 # Check whether user wants TCP wrappers support
 AC_TCP_WRAPPERS
diff -uprN -X dontdiff nfs-utils/utils/Makefile.am nfs-utils-ag/utils/Makefile.am
--- nfs-utils/utils/Makefile.am	2006-06-22 11:34:54.000000000 -0400
+++ nfs-utils-ag/utils/Makefile.am	2006-06-22 10:55:31.000000000 -0400
@@ -14,7 +14,7 @@ if CONFIG_GSS
 OPTDIRS += gssd
 endif
 
-if CONFIG_NOMOUNT
+if CONFIG_MOUNT
 OPTDIRS += mount
 endif
 

--------------080304090304060405090009
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------080304090304060405090009
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080304090304060405090009--
