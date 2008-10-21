From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] rpcbind: Squelch a compiler warning
Date: Tue, 21 Oct 2008 18:04:33 -0400
Message-ID: <20081021220433.19488.79819.stgit@manray.1015granger.net>
References: <20081021220247.19488.82225.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:38510 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbYJUWFI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Oct 2008 18:05:08 -0400
In-Reply-To: <20081021220247.19488.82225.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove unused variable in read_struct().  This eliminates the compiler
warning:

warmstart.c: In function =E2=80=98read_struct=E2=80=99:
warmstart.c:106: warning: unused variable =E2=80=98sbuf=E2=80=99

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 src/warmstart.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/src/warmstart.c b/src/warmstart.c
index 91e482b..d52a835 100644
--- a/src/warmstart.c
+++ b/src/warmstart.c
@@ -103,7 +103,6 @@ read_struct(char *filename, xdrproc_t structproc, v=
oid *list)
 {
 	FILE *fp;
 	XDR xdrs;
-	struct stat sbuf;
 	=20
 	if (debugging)
 		fprintf(stderr, "rpcbind: using '%s' startup file\n", filename);

