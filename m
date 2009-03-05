From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] configure: Remove CPPFLAGS substitution
Date: Wed, 04 Mar 2009 19:02:44 -0500
Message-ID: <20090305000244.28749.64239.stgit@ingres.1015granger.net>
References: <20090304234711.28749.7018.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:16937 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816AbZCEADj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2009 19:03:39 -0500
In-Reply-To: <20090304234711.28749.7018.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At least on my systems, the AM_CPPFLAGS substitution at the end of
configure.ac is not needed.  It adds an extra copy of
"-I../../support/includes" to each compile step.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/configure.ac b/configure.ac
index 4fd111f..b2c8190 100644
--- a/configure.ac
+++ b/configure.ac
@@ -382,7 +382,6 @@ esac
 
 my_am_cflags="-Wall -Wstrict-prototypes $ARCHFLAGS -pipe"
 
-AC_SUBST([AM_CPPFLAGS], ["-I\${top_srcdir}/support/include"])
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
 
 # Make sure that $ACLOCAL_FLAGS are used during a rebuild

