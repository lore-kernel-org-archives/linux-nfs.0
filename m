From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] tcpwrapper: Eliminated shadowed declaration warnings
Date: Fri, 15 Jan 2010 12:50:15 -0500
Message-ID: <20100115175015.30104.75099.stgit@localhost.localdomain>
References: <20100115174426.30104.3492.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:53600 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950Ab0AORuk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 12:50:40 -0500
In-Reply-To: <20100115174426.30104.3492.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: the use of identifiers called "access" and "daemon" shadow
function declarations in unistd.h.  Seen with "-Wextra -pedantic".

tcpwrapper.c: In function =E2=80=98haccess_add=E2=80=99:
tcpwrapper.c:112: warning: declaration of =E2=80=98access=E2=80=99 shad=
ows a global
declaration
/usr/include/unistd.h:288: warning: shadowed declaration is here
tcpwrapper.c: In function =E2=80=98good_client=E2=80=99:
tcpwrapper.c:161: warning: declaration of =E2=80=98daemon=E2=80=99 shad=
ows a global
declaration
/usr/include/unistd.h:953: warning: shadowed declaration is here
tcpwrapper.c: In function =E2=80=98check_default=E2=80=99:
tcpwrapper.c:212: warning: declaration of =E2=80=98daemon=E2=80=99 shad=
ows a global
declaration
/usr/include/unistd.h:953: warning: shadowed declaration is here

Note that good_client() is used only in support/misc/tcpwrapper.c, so
make it static (and update its prototype to c99 standard form).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/tcpwrapper.h |    3 +--
 support/misc/tcpwrapper.c    |   32 +++++++++++++++-----------------
 2 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/support/include/tcpwrapper.h b/support/include/tcpwrapper.=
h
index 941394e..930ec6a 100644
--- a/support/include/tcpwrapper.h
+++ b/support/include/tcpwrapper.h
@@ -5,8 +5,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
=20
-extern int good_client(char *daemon, struct sockaddr_in *addr);
 extern int from_local(const struct sockaddr *sap);
-extern int check_default(char *daemon, struct sockaddr_in *addr, u_lon=
g prog);
+extern int check_default(char *name, struct sockaddr_in *addr, u_long =
prog);
=20
 #endif /* TCP_WRAPPER_H */
diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index 6f65c13..03f5dc4 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -62,9 +62,9 @@ static int check_files(void);
 #define DENY 0
=20
 typedef struct _haccess_t {
-	TAILQ_ENTRY(_haccess_t) list;
-	int access;
-    struct in_addr addr;
+	TAILQ_ENTRY(_haccess_t)	list;
+	int			allowed;
+	struct in_addr		addr;
 } haccess_t;
=20
 #define HASH_TABLE_SIZE 1021
@@ -73,7 +73,6 @@ typedef struct _hash_head {
 } hash_head;
 hash_head haccess_tbl[HASH_TABLE_SIZE];
 static haccess_t *haccess_lookup(struct sockaddr_in *addr, u_long);
-static void haccess_add(struct sockaddr_in *addr, u_long, int);
=20
 static unsigned long
 strtoint(const char *str)
@@ -99,7 +98,8 @@ HASH(const char *addr, const unsigned long program)
 	return hashint(strtoint(addr) + program);
 }
=20
-void haccess_add(struct sockaddr_in *addr, u_long prog, int access)
+static void
+haccess_add(struct sockaddr_in *addr, u_long prog, int allowed)
 {
 	hash_head *head;
 	haccess_t *hptr;
@@ -112,7 +112,7 @@ void haccess_add(struct sockaddr_in *addr, u_long p=
rog, int access)
 	hash =3D HASH(inet_ntoa(addr->sin_addr), prog);
 	head =3D &(haccess_tbl[hash]);
=20
-	hptr->access =3D access;
+	hptr->allowed =3D allowed;
 	hptr->addr.s_addr =3D addr->sin_addr.s_addr;
=20
 	if (TAILQ_EMPTY(&head->h_head))
@@ -146,14 +146,12 @@ logit(const struct sockaddr_in *sin)
 	=09
 }
=20
-int
-good_client(daemon, addr)
-char *daemon;
-struct sockaddr_in *addr;
+static int
+good_client(char *name, struct sockaddr_in *addr)
 {
 	struct request_info req;
=20
-	request_init(&req, RQ_DAEMON, daemon, RQ_CLIENT_SIN, addr, 0);
+	request_init(&req, RQ_DAEMON, name, RQ_CLIENT_SIN, addr, 0);
 	sock_methods(&req);
=20
 	if (hosts_access(&req))=20
@@ -191,7 +189,7 @@ static int check_files()
=20
 /**
  * check_default - additional checks for NULL, DUMP, GETPORT and unkno=
wn
- * @daemon: pointer to '\0'-terminated ASCII string containing name of=
 the
+ * @name: pointer to '\0'-terminated ASCII string containing name of t=
he
  *		daemon requesting the access check
  * @addr: pointer to socket address containing address of caller
  * @prog: RPC program number caller is attempting to access
@@ -199,26 +197,26 @@ static int check_files()
  * Returns TRUE if the caller is allowed access; otherwise FALSE is re=
turned.
  */
 int
-check_default(char *daemon, struct sockaddr_in *addr, u_long prog)
+check_default(char *name, struct sockaddr_in *addr, u_long prog)
 {
 	haccess_t *acc =3D NULL;
 	int changed =3D check_files();
=20
 	acc =3D haccess_lookup(addr, prog);
 	if (acc && changed =3D=3D 0)
-		return (acc->access);
+		return acc->allowed;
=20
-	if (!(from_local((struct sockaddr *)addr) || good_client(daemon, addr=
))) {
+	if (!(from_local((struct sockaddr *)addr) || good_client(name, addr))=
) {
 		logit(addr);
 		if (acc)
-			acc->access =3D FALSE;
+			acc->allowed =3D FALSE;
 		else=20
 			haccess_add(addr, prog, FALSE);
 		return (FALSE);
 	}
=20
 	if (acc)
-		acc->access =3D TRUE;
+		acc->allowed =3D TRUE;
 	else=20
 		haccess_add(addr, prog, TRUE);
=20

