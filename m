From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 26/31] mount.nfs: Remove unused @salen parameter from
	nfs_ca_gai()
Date: Mon, 29 Jun 2009 13:39:03 -0400
Message-ID: <20090629173903.2076.36065.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:39836 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756811AbZF2RkN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:13 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Address compiler warning:

    network.c:1124: warning: unused parameter =E2=80=98salen=E2=80=99

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 6e0a72a..11c7162 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1103,7 +1103,7 @@ static int nfs_ca_sockname(const struct sockaddr =
*sap, const socklen_t salen,
  *
  * Returns 1 and fills in @buf if successful; otherwise, zero.
  */
-static int nfs_ca_gai(const struct sockaddr *sap, const socklen_t sale=
n,
+static int nfs_ca_gai(const struct sockaddr *sap,
 		      struct sockaddr *buf, socklen_t *buflen)
 {
 	struct addrinfo *gai_results;
@@ -1144,7 +1144,7 @@ int nfs_callback_address(const struct sockaddr *s=
ap, const socklen_t salen,
 	struct sockaddr_in6 *sin6 =3D (struct sockaddr_in6 *)buf;
=20
 	if (nfs_ca_sockname(sap, salen, buf, buflen) =3D=3D 0)
-		if (nfs_ca_gai(sap, salen, buf, buflen) =3D=3D 0)
+		if (nfs_ca_gai(sap, buf, buflen) =3D=3D 0)
 			goto out_failed;
=20
 	/*

