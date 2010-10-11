Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab0JKAGD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:06:03 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:06:03 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/15] mount.nfs: Eliminate compiler warnings in
	utils/mount/network.c
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:06:00 -0400
Message-ID: <20101011000600.6667.50880.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

network.c: In function ‘get_socket’:
network.c:431: warning: dereferencing type-punned pointer might break strict-aliasing rules

network.c: In function ‘probe_bothports’:
network.c:759: warning: dereferencing type-punned pointer might break strict-aliasing rules
network.c:762: warning: dereferencing type-punned pointer might break strict-aliasing rules

network.c: In function ‘nfs_probe_statd’:
network.c:775: warning: dereferencing type-punned pointer might break strict-aliasing rules

network.c: In function ‘nfs_call_umount’:
network.c:904: warning: dereferencing type-punned pointer might break strict-aliasing rules

network.c: In function ‘nfs_ca_sockname’:
network.c:1106: warning: dereferencing type-punned pointer might break strict-aliasing rules
network.c:1112: warning: dereferencing type-punned pointer might break strict-aliasing rules

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index d612427..62973cf 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -59,6 +59,8 @@
 #define CONNECT_TIMEOUT	(20)
 #define MOUNT_TIMEOUT	(30)
 
+#define SAFE_SOCKADDR(x)	(struct sockaddr *)(char *)(x)
+
 extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
@@ -428,12 +430,12 @@ static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
 		if (bindresvport(so, &laddr) < 0)
 			goto err_bindresvport;
 	} else {
-		cc = bind(so, (struct sockaddr *)&laddr, namelen);
+		cc = bind(so, SAFE_SOCKADDR(&laddr), namelen);
 		if (cc < 0)
 			goto err_bind;
 	}
 	if (type == SOCK_STREAM || (conn && type == SOCK_DGRAM)) {
-		cc = connect_to(so, (struct sockaddr *)saddr, namelen,
+		cc = connect_to(so, SAFE_SOCKADDR(saddr), namelen,
 				timeout);
 		if (cc < 0)
 			goto err_connect;
@@ -756,11 +758,12 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
  */
 int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 {
-	return nfs_probe_bothports((struct sockaddr *)&mnt_server->saddr,
-					sizeof(mnt_server->saddr),
+	struct sockaddr *mnt_addr = SAFE_SOCKADDR(&mnt_server->saddr);
+	struct sockaddr *nfs_addr = SAFE_SOCKADDR(&nfs_server->saddr);
+
+	return nfs_probe_bothports(mnt_addr, sizeof(mnt_server->saddr),
 					&mnt_server->pmap,
-					(struct sockaddr *)&nfs_server->saddr,
-					sizeof(nfs_server->saddr),
+					nfs_addr, sizeof(nfs_server->saddr),
 					&nfs_server->pmap);
 }
 
@@ -772,7 +775,7 @@ static int nfs_probe_statd(void)
 	};
 	rpcprog_t program = nfs_getrpcbyname(NSMPROG, nfs_ns_pgmtbl);
 
-	return nfs_getport_ping((struct sockaddr *)&addr, sizeof(addr),
+	return nfs_getport_ping(SAFE_SOCKADDR(&addr), sizeof(addr),
 				program, (rpcvers_t)1, IPPROTO_UDP);
 }
 
@@ -901,7 +904,7 @@ int nfs_advise_umount(const struct sockaddr *sap, const socklen_t salen,
  */
 int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 {
-	struct sockaddr *sap = (struct sockaddr *)&mnt_server->saddr;
+	struct sockaddr *sap = SAFE_SOCKADDR(&mnt_server->saddr);
 	socklen_t salen = sizeof(mnt_server->saddr);
 	struct pmap *pmap = &mnt_server->pmap;
 	CLIENT *clnt;
@@ -1103,13 +1106,13 @@ static int nfs_ca_sockname(const struct sockaddr *sap, const socklen_t salen,
 
 	switch (sap->sa_family) {
 	case AF_INET:
-		if (bind(sock, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
+		if (bind(sock, SAFE_SOCKADDR(&sin), sizeof(sin)) < 0) {
 			close(sock);
 			return 0;
 		}
 		break;
 	case AF_INET6:
-		if (bind(sock, (struct sockaddr *)&sin6, sizeof(sin6)) < 0) {
+		if (bind(sock, SAFE_SOCKADDR(&sin6), sizeof(sin6)) < 0) {
 			close(sock);
 			return 0;
 		}

