From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 03/11] nfs-utils: mount:  mount -s (sloppy) option
Date: Mon, 26 Feb 2007 06:17:48 -0500
Message-ID: <45E2C1DC.5020507@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070206060702040608050600"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdp5-0000IR-Cg
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:15:16 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdp6-0006LT-21
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:15:17 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBFEQJ000745
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:14 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBFE8V005597
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:14 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBFCoB025556
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:15:13 -0500
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

This is a multi-part message in MIME format.
--------------070206060702040608050600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------070206060702040608050600
Content-Type: text/x-patch;
 name="patch-03.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-03.dif"

commit 72baf6d14f166da0531bfe02273861e1c394c3bd
Author: Karel Zak <kzak@redhat.com>
Date:   Sat Feb 24 15:07:17 2007 -0500

    Added support for the mount -s (sloppy) option
    
    Signed-off-by: Karel Zak <kzak@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 05ff90f..13bffbc 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -44,6 +44,7 @@ char *progname;
 int nomtab;
 int verbose;
 int mounttype;
+int sloppy;
 
 static struct option longopts[] = {
   { "fake", 0, 0, 'f' },
@@ -176,7 +177,6 @@ void copy_mntent(struct mntent *ment, nfs_mntent_t *nment)
 int add_mtab(char *fsname, char *mount_point, char *fstype, int flags, char *opts, int freq, int passno)
 {
 	struct mntent ment;
-	int fd;
 	FILE *mtab;
 
 	ment.mnt_fsname = fsname;
@@ -236,6 +236,7 @@ void mount_usage()
 	printf("\t-w\t\tMount file system read-write\n");
 	printf("\t-f\t\tFake mount, don't actually mount\n");
 	printf("\t-n\t\tDo not update /etc/mtab\n");
+	printf("\t-s\t\tTolerate sloppy mount options rather than failing.\n");
 	printf("\t-h\t\tPrint this help\n");
 	printf("\tversion\t\tnfs4 - NFS version 4, nfs - older NFS version supported\n");
 	printf("\tnfsoptions\tRefer mount.nfs(8) or nfs(5)\n\n");
@@ -370,7 +371,7 @@ int main(int argc, char *argv[])
 		return 0;
 	}
 
-	while ((c = getopt_long (argc - 2, argv + 2, "rt:vVwfno:h",
+	while ((c = getopt_long (argc - 2, argv + 2, "rt:vVwfno:hs",
 				longopts, NULL)) != -1) {
 		switch (c) {
 		case 'r':
@@ -400,6 +401,9 @@ int main(int argc, char *argv[])
 			else
 				mount_opts = xstrdup(optarg);
 			break;
+		case 's':
+			++sloppy;
+			break;
 		case 128: /* bind */
 			mounttype = MS_BIND;
 			break;
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 717ad56..4bc4ffc 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -50,6 +50,7 @@
 #endif
 
 extern int verbose;
+extern int sloppy;
 
 char *IDMAPLCK = DEFAULT_DIR "/rpcidmapd";
 #define idmapd_check() do { \
@@ -335,7 +336,7 @@ int nfs4mount(const char *spec, const char *node, int *flags,
 				nocto = !val;
 			else if (!strcmp(opt, "ac"))
 				noac = !val;
-			else {
+			else if (!sloppy) {
 				printf(_("unknown nfs mount option: "
 					 "%s%s\n"), val ? "" : "no", opt);
 				goto fail;
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 507ccdb..d437036 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -104,6 +104,7 @@ typedef union {
 static char errbuf[BUFSIZ];
 static char *erreob = &errbuf[BUFSIZ];
 extern int verbose;
+extern int sloppy;
 
 /* Convert RPC errors into strings */
 int rpc_strerror(int);
@@ -606,13 +607,13 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 			} else if (!strcmp(opt, "namlen")) {
 				if (nfs_mount_version >= 2)
 					data->namlen = val;
-				else
+				else if (!sloppy)
 					goto bad_parameter;
 #endif
 			} else if (!strcmp(opt, "addr")) {
 				/* ignore */;
 				continue;
- 			} else
+ 			} else if (!sloppy)
 				goto bad_parameter;
 			sprintf(cbuf, "%s=%s,", opt, opteq+1);
 		} else if (opteq) {
@@ -629,7 +630,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 					mnt_pmap->pm_prot = IPPROTO_TCP;
 					data->flags |= NFS_MOUNT_TCP;
 #endif
-				} else
+				} else if (!sloppy)
 					goto bad_parameter;
 #if NFS_MOUNT_VERSION >= 5
 			} else if (!strcmp(opt, "sec")) {
@@ -658,7 +659,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 					data->pseudoflavor = AUTH_GSS_SPKMI;
 				else if (!strcmp(secflavor, "spkm3p"))
 					data->pseudoflavor = AUTH_GSS_SPKMP;
-				else {
+				else if (!sloppy) {
 					printf(_("Warning: Unrecognized security flavor %s.\n"),
 						secflavor);
 					goto bad_parameter;
@@ -677,7 +678,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 					goto bad_parameter;
  				}
  				strncpy(data->context, context, NFS_MAX_CONTEXT_LEN);
- 			} else
+ 			} else if (!sloppy)
 				goto bad_parameter;
 			sprintf(cbuf, "%s=%s,", opt, opteq+1);
 		} else {
@@ -764,9 +765,11 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 #endif
 			} else {
 			bad_option:
-				printf(_("Unsupported nfs mount option: "
-					 "%s%s\n"), val ? "" : "no", opt);
-				goto out_bad;
+				if (!sloppy) {
+					printf(_("Unsupported nfs mount option: "
+						 "%s%s\n"), val ? "" : "no", opt);
+					goto out_bad;
+				}
 			}
 			sprintf(cbuf, val ? "%s,":"no%s,", opt);
 		}

--------------070206060702040608050600
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------070206060702040608050600
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070206060702040608050600--
