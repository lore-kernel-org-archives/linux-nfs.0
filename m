From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] showmount: Eliminate compiler warnings
Date: Thu, 07 Jan 2010 11:26:21 -0500
Message-ID: <20100107162621.27102.7326.stgit@localhost.localdomain>
References: <20100107162421.27102.21422.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:36673 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933Ab0AGQ2c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2010 11:28:32 -0500
In-Reply-To: <20100107162421.27102.21422.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduced by "showmount: Try the highest mount version then fall back
to lower ones", seen with "-Wextra".

showmount.c: In function =E2=80=98main=E2=80=99:
showmount.c:210: warning: comparison between signed and unsigned intege=
r expressions
showmount.c:249: warning: comparison between signed and unsigned intege=
r expressions

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/showmount/showmount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/showmount/showmount.c b/utils/showmount/showmount.c
index 74cf116..652aa85 100644
--- a/utils/showmount/showmount.c
+++ b/utils/showmount/showmount.c
@@ -90,7 +90,7 @@ static const rpcvers_t mount_vers_tbl[] =3D {
 	MOUNTVERS_POSIX,
 	MOUNTVERS,
 };
-static const int max_vers_tblsz =3D=20
+static const unsigned int max_vers_tblsz =3D=20
 	(sizeof(mount_vers_tbl)/sizeof(mount_vers_tbl[0]));
=20
 /*

