From: Mike Frysinger <vapier@gentoo.org>
Subject: [patch] provide non-standard getgrouplist() in libnfsidmap
	when need be
Date: Sun, 25 Mar 2007 03:29:02 -0400
Message-ID: <200703250329.03353.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_/SiBGngsfvbB2q7"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVN9b-0003YJ-AX
	for nfs@lists.sourceforge.net; Sun, 25 Mar 2007 00:28:39 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HVN9c-00076A-DG
	for nfs@lists.sourceforge.net; Sun, 25 Mar 2007 00:28:41 -0700
Received: from home.wh0rd.org (pool-151-203-195-204.bos.east.verizon.net
	[151.203.195.204])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 91CA7649CA
	for <nfs@lists.sourceforge.net>; Sun, 25 Mar 2007 07:28:38 +0000 (UTC)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--Boundary-00=_/SiBGngsfvbB2q7
Content-Type: multipart/signed; boundary="nextPart1532523.mjUOOylcIY";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1532523.mjUOOylcIY
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

libnfsidmap uses the non-standard function getgrouplist() ... the attached=
=20
patch takes code from FreeBSD to implement the function based on POSIX=20
functions when the system libc is not sufficient
=2Dmike

--nextPart1532523.mjUOOylcIY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iQIVAwUARgYkv0FjO5/oN/WBAQLdSw//TtTsHVhAFiSm8etjMHaMOdLRl/nMh6W2
tIK4oxexp92GYNqhrP9M1uX/YbXf4ARdMmUwroMRcMlzak5C0kswNx8ATO/rFwrN
RAM97jmgDCBs2IjmzjPaO8nLmv6FeKJAFMNiGp5Z+MZ5FdiFlL+LZKUsfFn6f26o
oTqhfJ/ZjRH5e5oKiBKEuMaAVPgD3yTGQEnw1MD2+ldN/OCOww+1tBTepIVbyKRZ
PVHIhkf19nBKd6DueXdzvP0gDiFnGI4KnxF5p4xYp7DMTDluluHDfUeILZEe1s5I
d9FR45kteUheQBLQVvKOxXfxQll1lSnef9pj5B7/baQ2lbmmMyKQO/Uj+iprJrnZ
iynvPYHcJXS5vgw+jLF7WUD5K4DV6bcgB6/qdaB1TWv0t0SU/FZKXowOxLYkMu+D
TfCFnyTbcYq6McZ/vV+Z20tbpmqnHhwnZQDJEb1gbycP6jdWtE3fmJOdKVxgfA9z
bu/wPJD4fiXgvURnLs9/QSCwfx6YORYz+hFFela8ruMI5eMxaMLVBJ7PCsUIWZvx
g1dj6gX4S56UDdkABhRwz+WgmqNbiRYXptI2euFJeSdSxDG6D9UWxIIGo9QXC0uc
RLAJ2arR2pj6293f++zd2L60H8QKX/NqH/LDT8IOtBIZNC37+AEFimVZXl/6q15u
K706PCtga/s=
=m7uT
-----END PGP SIGNATURE-----

--nextPart1532523.mjUOOylcIY--

--Boundary-00=_/SiBGngsfvbB2q7
Content-Type: text/x-diff; charset="us-ascii";
	name="libnfsidmap-0.19-getgrouplist.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="libnfsidmap-0.19-getgrouplist.patch"

http://bugs.gentoo.org/169909

--- libnfsidmap-0.19/configure.in
+++ libnfsidmap-0.19/configure.in
@@ -38,7 +38,7 @@
 
 # Checks for library functions.
 AC_FUNC_MALLOC
-AC_CHECK_FUNCS([strchr strdup])
+AC_CHECK_FUNCS([strchr strdup getgrouplist])
 
 AC_CONFIG_FILES([Makefile])
 AC_OUTPUT(libnfsidmap.pc)
--- libnfsidmap-0.19/nss.c
+++ libnfsidmap-0.19/nss.c
@@ -49,6 +49,8 @@
 #include "cfg.h"
 #include <syslog.h>
 
+#include "getgrouplist.c"
+
 /*
  * NSS Translation Methods
  *
--- libnfsidmap-0.19/getgrouplist.c
+++ libnfsidmap-0.19/getgrouplist.c
@@ -0,0 +1,85 @@
+/*
+ *  getgrouplist.c
+ *
+ *  if system does not provide the non-standard getgrouplist, we will emulate
+ *  it via POSIX standard functions
+ *
+ * Copyright (c) 1991, 1993
+ *	The Regents of the University of California.  All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 4. Neither the name of the University nor the names of its contributors
+ *    may be used to endorse or promote products derived from this software
+ *    without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
+ * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
+ * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
+ * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
+ * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
+ * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
+ * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGE.
+ */
+
+#include <sys/types.h>
+#include <grp.h>
+#include <string.h>
+#include <unistd.h>
+
+#ifndef HAVE_GETGROUPLIST
+static
+int
+getgrouplist(const char *uname, gid_t agroup, gid_t *groups, int *grpcnt)
+{
+	const struct group *grp;
+	int i, maxgroups, ngroups, ret;
+
+	ret = 0;
+	ngroups = 0;
+	maxgroups = *grpcnt;
+	/*
+	 * When installing primary group, duplicate it;
+	 * the first element of groups is the effective gid
+	 * and will be overwritten when a setgid file is executed.
+	 */
+	groups[ngroups++] = agroup;
+	if (maxgroups > 1)
+		groups[ngroups++] = agroup;
+	/*
+	 * Scan the group file to find additional groups.
+	 */
+	setgrent();
+	while ((grp = getgrent()) != NULL) {
+		for (i = 0; i < ngroups; i++) {
+			if (grp->gr_gid == groups[i])
+				goto skip;
+		}
+		for (i = 0; grp->gr_mem[i]; i++) {
+			if (!strcmp(grp->gr_mem[i], uname)) {
+				if (ngroups >= maxgroups) {
+					ret = -1;
+					break;
+				}
+				groups[ngroups++] = grp->gr_gid;
+				break;
+			}
+		}
+skip:
+		;
+	}
+	endgrent();
+	*grpcnt = ngroups;
+	return (ret);
+}
+#endif

--Boundary-00=_/SiBGngsfvbB2q7
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--Boundary-00=_/SiBGngsfvbB2q7
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--Boundary-00=_/SiBGngsfvbB2q7--
