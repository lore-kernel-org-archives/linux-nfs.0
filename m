From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] getport.c: fix non-standard C
Date: Mon, 06 Apr 2009 12:04:24 -0400
Message-ID: <20090406160411.7179.41228.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:17050 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbZDFQFj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Apr 2009 12:05:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Squelch a compiler warning in getport.c:

  getport.c:65: warning: =E2=80=98static=E2=80=99 is not at beginning o=
f declaration

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/getport.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 734d21a..cf1677e 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -60,9 +60,9 @@
 #endif	/* !HAVE_LIBTIRPC */
=20
 #ifdef HAVE_LIBTIRPC
-const static rpcvers_t default_rpcb_version =3D RPCBVERS_4;
+static const rpcvers_t default_rpcb_version =3D RPCBVERS_4;
 #else	/* !HAVE_LIBTIRPC */
-const static rpcvers_t default_rpcb_version =3D PMAPVERS;
+static const rpcvers_t default_rpcb_version =3D PMAPVERS;
 #endif	/* !HAVE_LIBTIRPC */
=20
 #ifdef HAVE_DECL_AI_ADDRCONFIG

