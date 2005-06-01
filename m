From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 011 of 28] nfsd4: idmap initialization
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006iE-JV@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3L-0005wa-DR
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:11 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3I-0002QA-4G
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:10 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Adopt standard kernel style by defining a no-op function instead of putting
ifdef's in the code where the function is called.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfsctl.c           |    4 ----
 ./include/linux/nfsd_idmap.h |    5 +++++
 2 files changed, 5 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2005-05-31 14:21:00.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2005-05-31 14:21:01.000000000 +1000
@@ -398,9 +398,7 @@ static int __init init_nfsd(void)
 	nfsd_export_init();	/* Exports table */
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
 	nfs4_state_init();	/* NFSv4 locking state */
-#ifdef CONFIG_NFSD_V4
 	nfsd_idmap_init();      /* Name to ID mapping */
-#endif /* CONFIG_NFSD_V4 */
 	if (proc_mkdir("fs/nfs", NULL)) {
 		struct proc_dir_entry *entry;
 		entry = create_proc_entry("fs/nfs/exports", 0, NULL);
@@ -427,9 +425,7 @@ static void __exit exit_nfsd(void)
 	remove_proc_entry("fs/nfs", NULL);
 	nfsd_stat_shutdown();
 	nfsd_lockd_shutdown();
-#ifdef CONFIG_NFSD_V4
 	nfsd_idmap_shutdown();
-#endif /* CONFIG_NFSD_V4 */
 	unregister_filesystem(&nfsd_fs_type);
 }
 

diff ./include/linux/nfsd_idmap.h~current~ ./include/linux/nfsd_idmap.h
--- ./include/linux/nfsd_idmap.h~current~	2005-05-31 14:21:01.000000000 +1000
+++ ./include/linux/nfsd_idmap.h	2005-05-31 14:21:01.000000000 +1000
@@ -43,8 +43,13 @@
 /* XXX from linux/nfs_idmap.h */
 #define IDMAP_NAMESZ 128
 
+#ifdef CONFIG_NFSD_V4
 void nfsd_idmap_init(void);
 void nfsd_idmap_shutdown(void);
+#else
+static inline void nfsd_idmap_init(void) {};
+static inline void nfsd_idmap_shutdown(void) {};
+#endif
 
 int nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, __u32 *);
 int nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, __u32 *);


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
