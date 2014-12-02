Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:49104 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754586AbaLBMrh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Dec 2014 07:47:37 -0500
Subject: [PATCH 3/3] [RFC] nfs-utils: include headers from srcdir
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Date: Tue, 02 Dec 2014 13:40:04 +0100
Message-ID: <20141202124004.13015.5604.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141202123805.13015.25151.stgit@zeus.muc.hardeman.nu>
References: <20141202123805.13015.25151.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some of the headers in ./support/include get generated as part of the
build process (and end up in the build dir hierarchy) and some are
not (so they stay in the srcdir hierarchy).

That means the build breaks when using a separate build dir. I'm not sure
what the best way to make sure that -I$(top_srcdir)/support/include is
defined everywhere is. Consider this a basis for discussion rather than
a real patch. Someone with more autoconf-fu can surely come up with a better
solution.
---
 configure.ac |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/configure.ac b/configure.ac
index e3af723..5d0ab2b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -479,6 +479,9 @@ my_am_cflags="-Wall -Wextra -Wstrict-prototypes $ARCHFLAGS -pipe"
 
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
 
+AM_CPPFLAGS="$AM_CPPFLAGS -I\$(top_srcdir)/support/include"
+AC_SUBST([AM_CPPFLAGS])
+
 # Make sure that $ACLOCAL_FLAGS are used during a rebuild
 AC_SUBST([ACLOCAL_AMFLAGS], ["-I $ac_macro_dir \$(ACLOCAL_FLAGS)"])
 

