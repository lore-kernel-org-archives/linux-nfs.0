From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] nfs(5): document new [no]resvport option
Date: Fri, 27 Feb 2009 15:05:24 -0500
Message-ID: <20090227200524.11301.8976.stgit@ingres.1015granger.net>
References: <20090227200511.11301.33720.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:21217 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755422AbZB0UGt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2009 15:06:49 -0500
In-Reply-To: <20090227200511.11301.33720.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kernel 2.6.25 deprecates intr/nointr.  Reflect this change in nfs(5).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index ad2a14d..13de524 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -612,6 +612,13 @@ Using the
 option is preferred to using the
 .B soft
 option because it is significantly less likely to result in data corruption.
+.IP
+The
+.BR intr " / " nointr
+mount option is deprecated after kernel 2.6.25.
+Only SIGKILL can interrupt a pending NFS operation on these kernels,
+and if specified, this mount option is ignored to provide backwards
+compatibility with older kernels.
 .TP 1.5i
 .BR cto " / " nocto
 Selects whether to use close-to-open cache coherence semantics.
@@ -706,6 +713,13 @@ Using the
 option is preferred to using the
 .B soft
 option because it is significantly less likely to result in data corruption.
+.IP
+The
+.BR intr " / " nointr
+mount option is deprecated after kernel 2.6.25.
+Only SIGKILL can interrupt a pending NFS operation on these kernels,
+and if specified, this mount option is ignored to provide backwards
+compatibility with older kernels.
 .TP 1.5i
 .BR cto " / " nocto
 Selects whether to use close-to-open cache coherence semantics

