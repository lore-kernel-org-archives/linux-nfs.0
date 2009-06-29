From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 27/31] mount.nfs: remove unused @addrlen argument from
	nfs_string_to_sockaddr()
Date: Mon, 29 Jun 2009 13:39:12 -0400
Message-ID: <20090629173912.2076.38606.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:39611 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756742AbZF2RkF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:40:05 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Address compiler warning:

    network.c: In function =E2=80=98nfs_string_to_sockaddr=E2=80=99:
    network.c:272: warning: unused parameter =E2=80=98addrlen=E2=80=99

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    5 ++---
 utils/mount/network.h |    3 +--
 utils/mount/stropts.c |    6 ++----
 3 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 11c7162..4ec7c7b 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -255,7 +255,6 @@ int nfs_gethostbyname(const char *hostname, struct =
sockaddr_in *sin)
 /**
  * nfs_string_to_sockaddr - convert string address to sockaddr
  * @address:	pointer to presentation format address to convert
- * @addrlen:	length of presentation address
  * @sap:	pointer to socket address buffer to fill in
  * @salen:	IN: length of address buffer
  *		OUT: length of converted socket address
@@ -269,8 +268,8 @@ int nfs_gethostbyname(const char *hostname, struct =
sockaddr_in *sin)
  * See RFC 4038 section 5.1 or RFC 3513 section 2.2 for more details
  * on presenting IPv6 addresses as text strings.
  */
-int nfs_string_to_sockaddr(const char *address, const size_t addrlen,
-			   struct sockaddr *sap, socklen_t *salen)
+int nfs_string_to_sockaddr(const char *address, struct sockaddr *sap,
+			   socklen_t *salen)
 {
 	struct addrinfo *gai_results;
 	struct addrinfo gai_hint =3D {
diff --git a/utils/mount/network.h b/utils/mount/network.h
index ca5fa3b..db5134c 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -45,8 +45,7 @@ int nfs_probe_bothports(const struct sockaddr *, cons=
t socklen_t,
 			const socklen_t, struct pmap *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
 int nfs_name_to_address(const char *, struct sockaddr *, socklen_t *);
-int nfs_string_to_sockaddr(const char *, const size_t,
-			   struct sockaddr *, socklen_t *);
+int nfs_string_to_sockaddr(const char *, struct sockaddr *, socklen_t =
*);
 int nfs_present_sockaddr(const struct sockaddr *,
 			 const socklen_t, char *, const size_t);
 int nfs_callback_address(const struct sockaddr *, const socklen_t,
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 8d168db..e277b3d 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -312,16 +312,14 @@ static int nfs_extract_server_addresses(struct mo=
unt_options *options,
 	option =3D po_get(options, "addr");
 	if (option =3D=3D NULL)
 		return 0;
-	if (!nfs_string_to_sockaddr(option, strlen(option),
-						nfs_saddr, nfs_salen))
+	if (!nfs_string_to_sockaddr(option, nfs_saddr, nfs_salen))
 		return 0;
=20
 	option =3D po_get(options, "mountaddr");
 	if (option =3D=3D NULL) {
 		memcpy(mnt_saddr, nfs_saddr, *nfs_salen);
 		*mnt_salen =3D *nfs_salen;
-	} else if (!nfs_string_to_sockaddr(option, strlen(option),
-						mnt_saddr, mnt_salen))
+	} else if (!nfs_string_to_sockaddr(option, mnt_saddr, mnt_salen))
 		return 0;
=20
 	return 1;

