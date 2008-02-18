From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/17] mount command: Add headers needed for IPv6 support
Date: Mon, 18 Feb 2008 13:35:46 -0500
Message-ID: <20080218183546.19060.86460.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:55363 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424AbYBRSfs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:35:48 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIZkop017324
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:35:47 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIZkvk019324
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:35:46 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add #include directives for additional header files needed to support IPv6
networking in util/mount/network.c.  We do this as a separate patch so we
can reorder the subsequent patches without collision.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index ab7f6d0..92ccc3d 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -33,10 +33,13 @@
 #include <errno.h>
 #include <netdb.h>
 #include <time.h>
+
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>
 #include <rpc/pmap_clnt.h>
-#include <sys/socket.h>
 
 #include "xcommon.h"
 #include "mount.h"

