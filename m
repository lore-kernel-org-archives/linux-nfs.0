From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/17] mount.nfs: Eliminate some C macros that use
	implicit	arguments
Date: Sun, 15 Jul 2007 23:15:29 -0400
Message-ID: <20070716031529.11209.17612.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAH3b-0001nr-P7
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:31 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IAH3f-00060a-8U
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:15:35 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Get rid of nfs_probelist, mnt_probelist, and proto_probelist in order to
remove the use of HAVE_RELIABLE_TCP, MAX_NFSPROT, and MAX_MNTPROT.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsmount.c |  159 ++++++++++++++++++++++++------------------------
 1 files changed, 81 insertions(+), 78 deletions(-)

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 24dc6e6..8c261d9 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -72,10 +72,6 @@
 #define NFS_FHSIZE 32
 #endif
 
-#define MAX_NFSPROT ((nfs_mount_data_version >= 4) ? 3 : 2)
-#define MAX_MNTPROT ((nfs_mount_data_version >= 4) ? 3 : 2)
-#define HAVE_RELIABLE_TCP (nfs_mount_data_version >= 4)
-
 #ifndef HAVE_INET_ATON
 #define inet_aton(a,b) (0)
 #endif
@@ -97,53 +93,46 @@ extern int sloppy;
 
 extern int linux_version_code();
 
-/* Define the order in which to probe for UDP/TCP services */
-enum plist {
-	use_tcp = 0,
-	udp_tcp,
-	udp_only,
+static const unsigned int probe_udp_only[] = {
+	IPPROTO_UDP,
+	0,
 };
-static const u_int *
-proto_probelist(enum plist list)
-{
-	static const u_int probe_udp_tcp[] = { IPPROTO_UDP, IPPROTO_TCP, 0 };
-	static const u_int probe_both[] = { IPPROTO_TCP, IPPROTO_UDP, 0 };
-	static const u_int probe_udponly[] = { IPPROTO_UDP, 0 };
-
-	if (list == use_tcp)
-		return probe_both;
-	if (list == udp_tcp)
-		return probe_udp_tcp;
-	return probe_udponly;
-}
 
-/* Define the order in which NFS versions are probed on portmapper */
-static const u_long *
-nfs_probelist(const int vers)
-{
-	static const u_long nfs2_probe[] = { 2, 0};
-	static const u_long nfs3_probe[] = { 3, 2, 0};
-	switch (vers) {
-	case 3:
-		return nfs3_probe;
-	default:
-		return nfs2_probe;
-	}
-}
+static const unsigned int probe_udp_first[] = {
+	IPPROTO_UDP,
+	IPPROTO_TCP,
+	0,
+};
 
-/* Define the order in which Mountd versions are probed on portmapper */
-static const u_long *
-mnt_probelist(const int vers)
-{
-	static const u_long mnt1_probe[] = { 1, 2, 0 };
-	static const u_long mnt3_probe[] = { 3, 1, 2, 0 };
-	switch (vers) {
-	case 3:
-		return mnt3_probe;
-	default:
-		return mnt1_probe;
-	}
-}
+static const unsigned int probe_tcp_first[] = {
+	IPPROTO_TCP,
+	IPPROTO_UDP,
+	0,
+};
+
+static const unsigned long probe_nfs2_only[] = {
+	2,
+	0,
+};
+
+static const unsigned long probe_nfs3_first[] = {
+	3,
+	2,
+	0,
+};
+
+static const unsigned long probe_mnt1_first[] = {
+	1,
+	2,
+	0,
+};
+
+static const unsigned long probe_mnt3_first[] = {
+	3,
+	1,
+	2,
+	0,
+};
 
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
 int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
@@ -293,31 +282,30 @@ out_bad:
 	return 1;
 }
 
-static int
-probe_nfsport(clnt_addr_t *nfs_server)
+static int probe_nfsport(clnt_addr_t *nfs_server)
 {
-	const struct pmap *pmap = &nfs_server->pmap;
-	const u_long *probe_vers;
-	const u_int *probe_prot;
+	struct pmap *pmap = &nfs_server->pmap;
 
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
-	probe_vers = nfs_probelist(MAX_NFSPROT);
-	probe_prot = proto_probelist(HAVE_RELIABLE_TCP ? use_tcp : udp_only);
-	return probe_port(nfs_server, probe_vers, probe_prot);
+
+	if (nfs_mount_data_version >= 4)
+		return probe_port(nfs_server, probe_nfs3_first, probe_tcp_first);
+	else
+		return probe_port(nfs_server, probe_nfs2_only, probe_udp_only);
 }
 
 int probe_mntport(clnt_addr_t *mnt_server)
 {
-	const struct pmap *pmap = &mnt_server->pmap;
-	const u_long *probe_vers;
-	const u_int *probe_prot;
+	struct pmap *pmap = &mnt_server->pmap;
 
 	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
 		return 1;
-	probe_vers = mnt_probelist(MAX_MNTPROT);
-	probe_prot = proto_probelist(HAVE_RELIABLE_TCP ? udp_tcp : udp_only);
-	return probe_port(mnt_server, probe_vers, probe_prot);
+
+	if (nfs_mount_data_version >= 4)
+		return probe_port(mnt_server, probe_mnt3_first, probe_udp_first);
+	else
+		return probe_port(mnt_server, probe_mnt1_first, probe_udp_only);
 }
 
 static int
@@ -327,7 +315,7 @@ probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 	struct pmap *mnt_pmap = &mnt_server->pmap;
 	struct pmap save_nfs, save_mnt;
 	int res;
-	const u_long *probe_vers;
+	unsigned long *probe_vers;
 
 	if (mnt_pmap->pm_vers && !nfs_pmap->pm_vers)
 		nfs_pmap->pm_vers = mntvers_to_nfs(mnt_pmap->pm_vers);
@@ -335,9 +323,13 @@ probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 		mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
 	if (nfs_pmap->pm_vers)
 		goto version_fixed;
+
 	memcpy(&save_nfs, nfs_pmap, sizeof(save_nfs));
 	memcpy(&save_mnt, mnt_pmap, sizeof(save_mnt));
-	for (probe_vers = mnt_probelist(MAX_MNTPROT); *probe_vers; probe_vers++) {
+	probe_vers = (nfs_mount_data_version >= 4) ?
+			probe_mnt3_first : probe_mnt1_first;
+
+	for (; *probe_vers; probe_vers++) {
 		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
 		if ((res = probe_nfsport(nfs_server) != 0)) {
 			mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
@@ -354,9 +346,11 @@ probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 		}
 		memcpy(nfs_pmap, &save_nfs, sizeof(*nfs_pmap));
 	}
- out_bad:
+
+out_bad:
 	return 0;
- version_fixed:
+
+version_fixed:
 	if (!probe_nfsport(nfs_server))
 		goto out_bad;
 	return probe_mntport(mnt_server);
@@ -720,26 +714,35 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 	return 0;
 }
 
-static inline int
-nfsmnt_check_compat(const struct pmap *nfs_pmap, const struct pmap *mnt_pmap)
+static int nfsmnt_check_compat(const struct pmap *nfs_pmap,
+				const struct pmap *mnt_pmap)
 {
-	if (nfs_pmap->pm_vers && 
-		(nfs_pmap->pm_vers > MAX_NFSPROT || nfs_pmap->pm_vers < 2)) {
-		if (nfs_pmap->pm_vers == 4)
-			fprintf(stderr, _("'vers=4' is not supported.  "
-				"Use '-t nfs4' instead.\n"));
-		else
-			fprintf(stderr, _("NFS version %ld is not supported.\n"), 
-				nfs_pmap->pm_vers);
+	unsigned int max_nfs_vers = (nfs_mount_data_version >= 4) ? 3 : 2;
+	unsigned int max_mnt_vers = (nfs_mount_data_version >= 4) ? 3 : 2;
+
+	if (nfs_pmap->pm_vers == 4) {
+		fprintf(stderr, _("Please use '-t nfs4' "
+					"instead of '-o vers=4'.\n"));
 		goto out_bad;
 	}
-	if (mnt_pmap->pm_vers > MAX_MNTPROT) {
+
+	if (nfs_pmap->pm_vers) {
+		if (nfs_pmap->pm_vers > max_nfs_vers || nfs_pmap->pm_vers < 2) {
+			fprintf(stderr, _("NFS version %ld is not supported.\n"), 
+					nfs_pmap->pm_vers);
+			goto out_bad;
+		}
+	}
+
+	if (mnt_pmap->pm_vers > max_mnt_vers) {
 		fprintf(stderr, _("NFS mount version %ld s not supported.\n"), 
 			mnt_pmap->pm_vers);
 		goto out_bad;
 	}
+
 	return 1;
- out_bad:
+
+out_bad:
 	return 0;
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
