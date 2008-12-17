From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] configure: use "--disable-uuid" instead of
	"--without-uuid"
Date: Wed, 17 Dec 2008 15:37:40 -0500
Message-ID: <20081217203740.14933.18212.stgit@ingres.1015granger.net>
References: <20081217203301.14933.81853.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:26721 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbYLQUie (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2008 15:38:34 -0500
In-Reply-To: <20081217203301.14933.81853.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reported by Kevin Coffman and Jonathan Andrews.  Apparently --without-uuid
doesn't work with some older versions of autoconf, so correct the help text
to document the option that actually does the trick.

--- cut here ---

./configure --disable-nfsv4 --disable-gss --without-uuid
make clean;make

-MP -MF .deps/mountd-fsloc.Tpo -c -o mountd-fsloc.o `test -f 'fsloc.c' || echo
'./'`fsloc.c
mv -f .deps/mountd-fsloc.Tpo .deps/mountd-fsloc.Po
/bin/sh ../../libtool --tag=CC   --mode=link gcc -Wall -Wstrict-prototypes
-pipe -g -O2   -o mountd mountd-mountd.o mountd-mount_dispatch.o mountd-auth.o
mountd-rmtab.o mountd-cache.o mountd-svc_run.o mountd-fsloc.o
../../support/export/libexport.a ../../support/nfs/libnfs.a
../../support/misc/libmisc.a  -lwrap  -lblkid
mkdir .libs
gcc -Wall -Wstrict-prototypes -pipe -g -O2 -o mountd mountd-mountd.o
mountd-mount_dispatch.o mountd-auth.o mountd-rmtab.o mountd-cache.o
mountd-svc_run.o mountd-fsloc.o  ../../support/export/libexport.a
../../support/nfs/libnfs.a ../../support/misc/libmisc.a -lwrap -lblkid
/usr/lib/libblkid.a(probe.o)(.text+0x2b3): In function `set_uuid':
/root/src/GNU/unmodified_gnu/e2fsprogs-1.41.3/lib/blkid/probe.c:132: undefined
reference to `uuid_is_null'
/usr/lib/libblkid.a(probe.o)(.text+0x2d0):/root/src/GNU/unmodified_gnu/e2fsprogs-1.41.3/lib/blkid/probe.c:133:
undefined reference to `uuid_unparse'
/usr/lib/libblkid.a(probe.o)(.text+0x3af): In function `get_ext2_info':
/root/src/GNU/unmodified_gnu/e2fsprogs-1.41.3/lib/blkid/probe.c:162: undefined
reference to `uuid_is_null'
collect2: ld returned 1 exit status
make[2]: *** [mountd] Error 1
make[2]: Leaving directory
`/root/src/GNU/unmodified_gnu/nfs-utils-1.1.4-patched/utils/mountd'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory
`/root/src/GNU/unmodified_gnu/nfs-utils-1.1.4-patched/utils'
make: *** [all-recursive] Error 1

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure.ac b/configure.ac
index 48061e4..7140f48 100644
--- a/configure.ac
+++ b/configure.ac
@@ -109,7 +109,7 @@ AC_ARG_WITH(rpcgen,
 	AC_SUBST(RPCGEN_PATH)
 	AM_CONDITIONAL(CONFIG_RPCGEN, [test "$RPCGEN_PATH" == ""])
 AC_ARG_ENABLE(uuid,
-	[AC_HELP_STRING([--without-uuid], [Exclude uuid support and so avoid possibly buggy libblkid])],
+	[AC_HELP_STRING([--disable-uuid], [Exclude uuid support to avoid buggy libblkid])],
 	if test "$enableval" = "yes" ; then choose_blkid=yes; else choose_blkid=no; fi,
 	choose_blkid=default)
 AC_ARG_ENABLE(mount,

