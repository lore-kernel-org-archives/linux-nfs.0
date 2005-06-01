From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 028 of 28] nfsd4-reboot-dirname
Date: Thu, 02 Jun 2005 08:50:58 +1000
Message-ID: <E1Ddc38-0006j7-19@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3R-0005xZ-MD
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:17 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3P-0005OI-9e
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:17 -0700
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


Set the recovery directory via /proc/fs/nfsd/nfs4recoverydir.

It may be changed any time, but is used only on startup.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4recover.c     |    1 -
 ./fs/nfsd/nfs4state.c       |   37 +++++++++++++++++++++++++++++++++++--
 ./fs/nfsd/nfsctl.c          |   23 +++++++++++++++++++++++
 ./include/linux/nfsd/nfsd.h |    2 ++
 4 files changed, 60 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4recover.c~current~ ./fs/nfsd/nfs4recover.c
--- ./fs/nfsd/nfs4recover.c~current~	2005-06-01 14:22:11.000000000 +1000
+++ ./fs/nfsd/nfs4recover.c	2005-06-01 14:27:47.000000000 +1000
@@ -50,7 +50,6 @@
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
 /* Globals */
-char recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
 static struct nameidata rec_dir;
 static int rec_dir_init = 0;
 

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-06-01 14:27:13.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-06-01 14:27:47.000000000 +1000
@@ -48,6 +48,7 @@
 #include <linux/nfs4.h>
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
+#include <linux/namei.h>
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -71,7 +72,8 @@ static stateid_t onestateid;            
 static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
 static void release_stateid_lockowners(struct nfs4_stateid *open_stp);
-extern char recovery_dirname[];
+static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
+static void nfs4_set_recdir(char *recdir);
 
 /* Locking:
  *
@@ -3224,8 +3226,10 @@ nfsd4_load_reboot_recovery_data(void)
 {
 	int status;
 
-	nfsd4_init_recdir(recovery_dirname);
+	nfs4_lock_state();
+	nfsd4_init_recdir(user_recovery_dirname);
 	status = nfsd4_recdir_load();
+	nfs4_unlock_state();
 	if (status)
 		printk("NFSD: Failure reading reboot recovery data\n");
 }
@@ -3329,6 +3333,35 @@ nfs4_state_shutdown(void)
 	nfs4_unlock_state();
 }
 
+static void
+nfs4_set_recdir(char *recdir)
+{
+	nfs4_lock_state();
+	strcpy(user_recovery_dirname, recdir);
+	nfs4_unlock_state();
+}
+
+/*
+ * Change the NFSv4 recovery directory to recdir.
+ */
+int
+nfs4_reset_recoverydir(char *recdir)
+{
+	int status;
+	struct nameidata nd;
+
+	status = path_lookup(recdir, LOOKUP_FOLLOW, &nd);
+	if (status)
+		return status;
+	status = -ENOTDIR;
+	if (S_ISDIR(nd.dentry->d_inode->i_mode)) {
+		nfs4_set_recdir(recdir);
+		status = 0;
+	}
+	path_release(&nd);
+	return status;
+}
+
 /*
  * Called when leasetime is changed.
  *

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2005-05-31 14:21:01.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2005-06-01 14:27:47.000000000 +1000
@@ -51,6 +51,7 @@ enum {
 	NFSD_Fh,
 	NFSD_Threads,
 	NFSD_Leasetime,
+	NFSD_RecoveryDir,
 };
 
 /*
@@ -66,6 +67,7 @@ static ssize_t write_getfs(struct file *
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
 static ssize_t write_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
+static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
@@ -78,6 +80,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Leasetime] = write_leasetime,
+	[NFSD_RecoveryDir] = write_recoverydir,
 };
 
 static ssize_t nfsctl_transaction_write(struct file *file, const char __user *buf, size_t size, loff_t *pos)
@@ -349,6 +352,25 @@ static ssize_t write_leasetime(struct fi
 	return strlen(buf);
 }
 
+static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
+{
+	char *mesg = buf;
+	char *recdir;
+	int len, status;
+
+	if (size > PATH_MAX || buf[size-1] != '\n')
+		return -EINVAL;
+	buf[size-1] = 0;
+
+	recdir = mesg;
+	len = qword_get(&mesg, recdir, size);
+	if (len <= 0)
+		return -EINVAL;
+
+	status = nfs4_reset_recoverydir(recdir);
+	return strlen(buf);
+}
+
 /*----------------------------------------------------------------------------*/
 /*
  *	populating the filesystem.
@@ -369,6 +391,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
 #endif
 		/* last one */ {""}
 	};

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2005-05-31 14:21:00.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2005-06-01 14:27:47.000000000 +1000
@@ -150,12 +150,14 @@ int nfs4_state_start(void);
 void nfs4_state_shutdown(void);
 time_t nfs4_lease_time(void);
 void nfs4_reset_lease(time_t leasetime);
+int nfs4_reset_recoverydir(char *recdir);
 #else
 static inline void nfs4_state_init(void){};
 static inline int nfs4_state_start(void){return 0;}
 static inline void nfs4_state_shutdown(void){}
 static inline time_t nfs4_lease_time(void){return 0;}
 static inline void nfs4_reset_lease(time_t leasetime){}
+static inline int nfs4_reset_recoverydir(char *recdir) {return 0;}
 #endif
 
 /*


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
