From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] tcpwrapper: Fix signage problems in the tcp_wrappers hash
	function
Date: Fri, 15 Jan 2010 16:31:46 -0500
Message-ID: <20100115213145.18214.65113.stgit@localhost.localdomain>
References: <20100115212102.18214.19398.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:29169 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758304Ab0AOVdn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 16:33:43 -0500
In-Reply-To: <20100115212102.18214.19398.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eliminate the following compiler warnings:

tcpwrapper.c:78: warning: no previous prototype for =E2=80=98strtoint=E2=
=80=99
tcpwrapper.c: In function =E2=80=98strtoint=E2=80=99:
tcpwrapper.c:81: warning: conversion to =E2=80=98int=E2=80=99 from =E2=80=
=98size_t=E2=80=99 may change the sign of the result
tcpwrapper.c:85: warning: conversion to =E2=80=98unsigned int=E2=80=99 =
from =E2=80=98int=E2=80=99 may change the sign of the result
tcpwrapper.c: In function =E2=80=98hashint=E2=80=99:
tcpwrapper.c:91: warning: conversion to =E2=80=98int=E2=80=99 from =E2=80=
=98unsigned int=E2=80=99 may change the sign of the result

The hash value is probably computed consistently even with unexpected
sign inversions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/misc/tcpwrapper.c |   34 ++++++++++++++++++++--------------
 1 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index b981d58..6f65c13 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -75,29 +75,35 @@ hash_head haccess_tbl[HASH_TABLE_SIZE];
 static haccess_t *haccess_lookup(struct sockaddr_in *addr, u_long);
 static void haccess_add(struct sockaddr_in *addr, u_long, int);
=20
-inline unsigned int strtoint(char *str)
+static unsigned long
+strtoint(const char *str)
 {
-	unsigned int n =3D 0;
-	int len =3D strlen(str);
-	int i;
+	unsigned long i, n =3D 0;
+	size_t len =3D strlen(str);
=20
-	for (i=3D0; i < len; i++)
-		n+=3D((int)str[i])*i;
+	for (i =3D 0; i < len; i++)
+		n +=3D (unsigned char)str[i] * i;
=20
 	return n;
 }
-static inline int hashint(unsigned int num)
+
+static unsigned int
+hashint(const unsigned long num)
+{
+	return (unsigned int)(num % HASH_TABLE_SIZE);
+}
+
+static unsigned int
+HASH(const char *addr, const unsigned long program)
 {
-	return num % HASH_TABLE_SIZE;
+	return hashint(strtoint(addr) + program);
 }
-#define HASH(_addr, _prog) \
-	hashint((strtoint((_addr))+(_prog)))
=20
 void haccess_add(struct sockaddr_in *addr, u_long prog, int access)
 {
 	hash_head *head;
- 	haccess_t *hptr;
-	int hash;
+	haccess_t *hptr;
+	unsigned int hash;
=20
 	hptr =3D (haccess_t *)malloc(sizeof(haccess_t));
 	if (hptr =3D=3D NULL)
@@ -117,8 +123,8 @@ void haccess_add(struct sockaddr_in *addr, u_long p=
rog, int access)
 haccess_t *haccess_lookup(struct sockaddr_in *addr, u_long prog)
 {
 	hash_head *head;
- 	haccess_t *hptr;
-	int hash;
+	haccess_t *hptr;
+	unsigned int hash;
=20
 	hash =3D HASH(inet_ntoa(addr->sin_addr), prog);
 	head =3D &(haccess_tbl[hash]);

