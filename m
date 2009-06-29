From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 28/31] umount.nfs: Use correct data type in nfsumount()
Date: Mon, 29 Jun 2009 13:39:22 -0400
Message-ID: <20090629173921.2076.20628.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:39707 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056AbZF2RkJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:09 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Address compiler warning:

    nfsumount.c: In function =E2=80=98nfsumount=E2=80=99:
    nfsumount.c:347: warning: comparison between signed and unsigned

The result type of pointer arithmetic and the return type of strlen(3)
are both size_t.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index ba27900..f81db14 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -336,7 +336,7 @@ int nfsumount(int argc, char *argv[])
 			char *opt =3D hasmntopt(&mc->m, "user");
 			struct passwd *pw;
 			char *comma;
-			int len;
+			size_t len;
 			if (!opt)
 				goto only_root;
 			if (opt[4] !=3D '=3D')

