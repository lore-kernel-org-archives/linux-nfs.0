From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] rpcbind: Squelch a compiler warning
Date: Tue, 21 Oct 2008 18:04:48 -0400
Message-ID: <20081021220448.19488.77889.stgit@manray.1015granger.net>
References: <20081021220247.19488.82225.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:38520 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbYJUWFJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Oct 2008 18:05:09 -0400
In-Reply-To: <20081021220247.19488.82225.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove a needless pointer-to-integer conversion.  getnameinfo(3) wants
a size value greater than or equal to offsetof(struct sockaddr_un,
sun_path).  Since pointers can be different sizes depending on the
hardware platform, let's make this a simple constant instead.

This eliminates the compiler warning:

rpcinfo.c: In function =E2=80=98sa_len=E2=80=99:
rpcinfo.c:666: warning: cast from pointer to integer of different size

when building on x86-64.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 src/rpcinfo.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/src/rpcinfo.c b/src/rpcinfo.c
index afd949b..0170f65 100644
--- a/src/rpcinfo.c
+++ b/src/rpcinfo.c
@@ -663,7 +663,7 @@ sa_len(struct sockaddr *sa)
     switch (sa->sa_family)
     {
         case AF_LOCAL:
-            salen =3D (socklen_t) (((struct sockaddr_un *) NULL)->sun_=
path);
+            salen =3D sizeof (struct sockaddr_un);
             break;
         case AF_INET:
             salen =3D sizeof (struct sockaddr_in);

