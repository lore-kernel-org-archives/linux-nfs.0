Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f179.google.com ([209.85.217.179]:56379 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884Ab3DZL77 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Apr 2013 07:59:59 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v6 3/7] CIFS: Add share_access parm to open request
Date: Fri, 26 Apr 2013 16:04:17 +0400
Message-Id: <1366977861-27678-4-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1366977861-27678-1-git-send-email-piastry@etersoft.ru>
References: <1366977861-27678-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

and simplify CIFSSMBOpen params.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/cifs/cifsacl.c   |  8 ++++----
 fs/cifs/cifsglob.h  |  2 +-
 fs/cifs/cifsproto.h |  8 ++++----
 fs/cifs/cifssmb.c   | 50 +++++++++++++++++++++++++++-----------------------
 fs/cifs/dir.c       | 12 ++++++------
 fs/cifs/file.c      | 10 ++++++----
 fs/cifs/inode.c     | 16 ++++++----------
 fs/cifs/link.c      | 25 ++++++++-----------------
 fs/cifs/readdir.c   |  5 ++---
 fs/cifs/smb1ops.c   | 16 +++++++---------
 fs/cifs/smb2file.c  | 10 +++++-----
 fs/cifs/smb2inode.c |  4 ++--
 fs/cifs/smb2ops.c   | 10 ++++++----
 fs/cifs/smb2pdu.c   |  6 +++---
 fs/cifs/smb2proto.h | 14 ++++++++------
 15 files changed, 95 insertions(+), 101 deletions(-)

diff --git a/fs/cifs/cifsacl.c b/fs/cifs/cifsacl.c
index f1e3f25..56bdae2 100644
--- a/fs/cifs/cifsacl.c
+++ b/fs/cifs/cifsacl.c
@@ -908,8 +908,8 @@ static struct cifs_ntsd *get_cifs_acl_by_path(struct cifs_sb_info *cifs_sb,
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
 
 	rc = CIFSSMBOpen(xid, tcon, path, FILE_OPEN, READ_CONTROL,
-			create_options, &fid, &oplock, NULL, cifs_sb->local_nls,
-			cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
+			FILE_SHARE_ALL, create_options, &fid, &oplock,
+			NULL, cifs_sb);
 	if (!rc) {
 		rc = CIFSSMBGetCIFSACL(xid, tcon, fid, &pntsd, pacllen);
 		CIFSSMBClose(xid, tcon, fid);
@@ -969,8 +969,8 @@ int set_cifs_acl(struct cifs_ntsd *pnntsd, __u32 acllen,
 		access_flags = WRITE_DAC;
 
 	rc = CIFSSMBOpen(xid, tcon, path, FILE_OPEN, access_flags,
-			create_options, &fid, &oplock, NULL, cifs_sb->local_nls,
-			cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
+			FILE_SHARE_ALL, create_options, &fid, &oplock,
+			NULL, cifs_sb);
 	if (rc) {
 		cERROR(1, "Unable to open file to set ACL");
 		goto out;
diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index 4f07f6f..80af61d 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -310,7 +310,7 @@ struct smb_version_operations {
 			       struct cifs_sb_info *);
 	/* open a file for non-posix mounts */
 	int (*open)(const unsigned int, struct cifs_tcon *, const char *, int,
-		    int, int, struct cifs_fid *, __u32 *, FILE_ALL_INFO *,
+		    int, int, int, struct cifs_fid *, __u32 *, FILE_ALL_INFO *,
 		    struct cifs_sb_info *);
 	/* set fid protocol-specific info */
 	void (*set_fid)(struct cifsFileInfo *, struct cifs_fid *, __u32);
diff --git a/fs/cifs/cifsproto.h b/fs/cifs/cifsproto.h
index f450f06..d285b81 100644
--- a/fs/cifs/cifsproto.h
+++ b/fs/cifs/cifsproto.h
@@ -362,10 +362,10 @@ extern int CIFSSMBQueryReparseLinkInfo(const unsigned int xid,
 			const struct nls_table *nls_codepage);
 #endif /* temporarily unused until cifs_symlink fixed */
 extern int CIFSSMBOpen(const unsigned int xid, struct cifs_tcon *tcon,
-			const char *fileName, const int disposition,
-			const int access_flags, const int omode,
-			__u16 *netfid, int *pOplock, FILE_ALL_INFO *,
-			const struct nls_table *nls_codepage, int remap);
+			const char *file_name, const int disposition,
+			const int desired_access, const int share_access,
+			const int omode, __u16 *netfid, int *oplock,
+			FILE_ALL_INFO *, struct cifs_sb_info *);
 extern int SMBLegacyOpen(const unsigned int xid, struct cifs_tcon *tcon,
 			const char *fileName, const int disposition,
 			const int access_flags, const int omode,
diff --git a/fs/cifs/cifssmb.c b/fs/cifs/cifssmb.c
index 8e2e799..c857b02 100644
--- a/fs/cifs/cifssmb.c
+++ b/fs/cifs/cifssmb.c
@@ -1289,10 +1289,10 @@ OldOpenRetry:
 
 int
 CIFSSMBOpen(const unsigned int xid, struct cifs_tcon *tcon,
-	    const char *fileName, const int openDisposition,
-	    const int access_flags, const int create_options, __u16 *netfid,
-	    int *pOplock, FILE_ALL_INFO *pfile_info,
-	    const struct nls_table *nls_codepage, int remap)
+	    const char *file_name, const int disposition,
+	    const int desired_access, const int share_access,
+	    const int create_options, __u16 *netfid, int *oplock,
+	    FILE_ALL_INFO *file_info, struct cifs_sb_info *cifs_sb)
 {
 	int rc = -EACCES;
 	OPEN_REQ *pSMB = NULL;
@@ -1300,6 +1300,8 @@ CIFSSMBOpen(const unsigned int xid, struct cifs_tcon *tcon,
 	int bytes_returned;
 	int name_len;
 	__u16 count;
+	struct nls_table *nls_codepage = cifs_sb->local_nls;
+	int remap = cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR;
 
 openRetry:
 	rc = smb_init(SMB_COM_NT_CREATE_ANDX, 24, tcon, (void **) &pSMB,
@@ -1313,26 +1315,28 @@ openRetry:
 		count = 1;	/* account for one byte pad to word boundary */
 		name_len =
 		    cifsConvertToUTF16((__le16 *) (pSMB->fileName + 1),
-				       fileName, PATH_MAX, nls_codepage, remap);
+				       file_name, PATH_MAX, nls_codepage,
+				       remap);
 		name_len++;	/* trailing null */
 		name_len *= 2;
 		pSMB->NameLength = cpu_to_le16(name_len);
 	} else {		/* BB improve check for buffer overruns BB */
 		count = 0;	/* no pad */
-		name_len = strnlen(fileName, PATH_MAX);
+		name_len = strnlen(file_name, PATH_MAX);
 		name_len++;	/* trailing null */
 		pSMB->NameLength = cpu_to_le16(name_len);
-		strncpy(pSMB->fileName, fileName, name_len);
+		strncpy(pSMB->fileName, file_name, name_len);
 	}
-	if (*pOplock & REQ_OPLOCK)
+	if (*oplock & REQ_OPLOCK)
 		pSMB->OpenFlags = cpu_to_le32(REQ_OPLOCK);
-	else if (*pOplock & REQ_BATCHOPLOCK)
+	else if (*oplock & REQ_BATCHOPLOCK)
 		pSMB->OpenFlags = cpu_to_le32(REQ_BATCHOPLOCK);
-	pSMB->DesiredAccess = cpu_to_le32(access_flags);
+	pSMB->DesiredAccess = cpu_to_le32(desired_access);
 	pSMB->AllocationSize = 0;
-	/* set file as system file if special file such
-	   as fifo and server expecting SFU style and
-	   no Unix extensions */
+	/*
+	 * set file as system file if special file such as fifo and server
+	 * expecting SFU style and no Unix extensions
+	 */
 	if (create_options & CREATE_OPTION_SPECIAL)
 		pSMB->FileAttributes = cpu_to_le32(ATTR_SYSTEM);
 	else
@@ -1347,8 +1351,8 @@ openRetry:
 	if (create_options & CREATE_OPTION_READONLY)
 		pSMB->FileAttributes |= cpu_to_le32(ATTR_READONLY);
 
-	pSMB->ShareAccess = cpu_to_le32(FILE_SHARE_ALL);
-	pSMB->CreateDisposition = cpu_to_le32(openDisposition);
+	pSMB->ShareAccess = cpu_to_le32(share_access);
+	pSMB->CreateDisposition = cpu_to_le32(disposition);
 	pSMB->CreateOptions = cpu_to_le32(create_options & CREATE_OPTIONS_MASK);
 	/* BB Expirement with various impersonation levels and verify */
 	pSMB->ImpersonationLevel = cpu_to_le32(SECURITY_IMPERSONATION);
@@ -1366,20 +1370,20 @@ openRetry:
 	if (rc) {
 		cFYI(1, "Error in Open = %d", rc);
 	} else {
-		*pOplock = pSMBr->OplockLevel; /* 1 byte no need to le_to_cpu */
+		*oplock = pSMBr->OplockLevel; /* 1 byte no need to le_to_cpu */
 		*netfid = pSMBr->Fid;	/* cifs fid stays in le */
 		/* Let caller know file was created so we can set the mode. */
 		/* Do we care about the CreateAction in any other cases? */
 		if (cpu_to_le32(FILE_CREATE) == pSMBr->CreateAction)
-			*pOplock |= CIFS_CREATE_ACTION;
-		if (pfile_info) {
-			memcpy((char *)pfile_info, (char *)&pSMBr->CreationTime,
+			*oplock |= CIFS_CREATE_ACTION;
+		if (file_info) {
+			memcpy((char *)file_info, (char *)&pSMBr->CreationTime,
 				36 /* CreationTime to Attributes */);
 			/* the file_info buf is endian converted by caller */
-			pfile_info->AllocationSize = pSMBr->AllocationSize;
-			pfile_info->EndOfFile = pSMBr->EndOfFile;
-			pfile_info->NumberOfLinks = cpu_to_le32(1);
-			pfile_info->DeletePending = 0;
+			file_info->AllocationSize = pSMBr->AllocationSize;
+			file_info->EndOfFile = pSMBr->EndOfFile;
+			file_info->NumberOfLinks = cpu_to_le32(1);
+			file_info->DeletePending = 0;
 		}
 	}
 
diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
index 1cd0162..e5f6723 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -203,6 +203,7 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
 	FILE_ALL_INFO *buf = NULL;
 	struct inode *newinode = NULL;
 	int disposition;
+	int share_access = FILE_SHARE_ALL;
 	struct TCP_Server_Info *server = tcon->ses->server;
 
 	*oplock = 0;
@@ -320,8 +321,8 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
 
 	rc = server->ops->open(xid, tcon, full_path, disposition,
-			       desired_access, create_options, fid, oplock,
-			       buf, cifs_sb);
+			       desired_access, share_access, create_options,
+			       fid, oplock, buf, cifs_sb);
 	if (rc) {
 		cFYI(1, "cifs_create returned 0x%x", rc);
 		goto out;
@@ -626,10 +627,9 @@ int cifs_mknod(struct inode *inode, struct dentry *direntry, umode_t mode,
 	if (backup_cred(cifs_sb))
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
 
-	rc = CIFSSMBOpen(xid, pTcon, full_path, FILE_CREATE,
-			 GENERIC_WRITE, create_options,
-			 &fileHandle, &oplock, buf, cifs_sb->local_nls,
-			 cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
+	rc = CIFSSMBOpen(xid, pTcon, full_path, FILE_CREATE, GENERIC_WRITE,
+			 FILE_SHARE_ALL, create_options, &fileHandle, &oplock,
+			 buf, cifs_sb);
 	if (rc)
 		goto mknod_out;
 
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 7a0dd99..7631b0c 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -180,6 +180,7 @@ cifs_nt_open(char *full_path, struct inode *inode, struct cifs_sb_info *cifs_sb,
 {
 	int rc;
 	int desired_access;
+	int share_access = FILE_SHARE_ALL;
 	int disposition;
 	int create_options = CREATE_NOT_DIR;
 	FILE_ALL_INFO *buf;
@@ -226,8 +227,8 @@ cifs_nt_open(char *full_path, struct inode *inode, struct cifs_sb_info *cifs_sb,
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
 
 	rc = server->ops->open(xid, tcon, full_path, disposition,
-			       desired_access, create_options, fid, oplock, buf,
-			       cifs_sb);
+			       desired_access, share_access, create_options,
+			       fid, oplock, buf, cifs_sb);
 
 	if (rc)
 		goto out;
@@ -589,6 +590,7 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
 	struct inode *inode;
 	char *full_path = NULL;
 	int desired_access;
+	int share_access = FILE_SHARE_ALL;
 	int disposition = FILE_OPEN;
 	int create_options = CREATE_NOT_DIR;
 	struct cifs_fid fid;
@@ -668,8 +670,8 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
 	 * not dirty locally we could do this.
 	 */
 	rc = server->ops->open(xid, tcon, full_path, disposition,
-			       desired_access, create_options, &fid, &oplock,
-			       NULL, cifs_sb);
+			       desired_access, share_access, create_options,
+			       &fid, &oplock, NULL, cifs_sb);
 	if (rc) {
 		mutex_unlock(&cfile->fh_mutex);
 		cFYI(1, "cifs_reopen returned 0x%x", rc);
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 20887bf..ecb951f 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -406,10 +406,8 @@ cifs_sfu_type(struct cifs_fattr *fattr, const unsigned char *path,
 	tcon = tlink_tcon(tlink);
 
 	rc = CIFSSMBOpen(xid, tcon, path, FILE_OPEN, GENERIC_READ,
-			 CREATE_NOT_DIR, &netfid, &oplock, NULL,
-			 cifs_sb->local_nls,
-			 cifs_sb->mnt_cifs_flags &
-				CIFS_MOUNT_MAP_SPECIAL_CHR);
+			 FILE_SHARE_ALL, CREATE_NOT_DIR, &netfid, &oplock,
+			 NULL, cifs_sb);
 	if (rc == 0) {
 		int buf_type = CIFS_NO_BUFFER;
 			/* Read header */
@@ -1005,9 +1003,8 @@ cifs_rename_pending_delete(const char *full_path, struct dentry *dentry,
 	}
 
 	rc = CIFSSMBOpen(xid, tcon, full_path, FILE_OPEN,
-			 DELETE|FILE_WRITE_ATTRIBUTES, CREATE_NOT_DIR,
-			 &netfid, &oplock, NULL, cifs_sb->local_nls,
-			 cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
+			 DELETE|FILE_WRITE_ATTRIBUTES, FILE_SHARE_ALL,
+			 CREATE_NOT_DIR, &netfid, &oplock, NULL, cifs_sb);
 	if (rc != 0)
 		goto out;
 
@@ -1525,9 +1522,8 @@ cifs_do_rename(const unsigned int xid, struct dentry *from_dentry,
 
 	/* open the file to be renamed -- we need DELETE perms */
 	rc = CIFSSMBOpen(xid, tcon, from_path, FILE_OPEN, DELETE,
-			 CREATE_NOT_DIR, &srcfid, &oplock, NULL,
-			 cifs_sb->local_nls, cifs_sb->mnt_cifs_flags &
-				CIFS_MOUNT_MAP_SPECIAL_CHR);
+			 FILE_SHARE_ALL, CREATE_NOT_DIR, &srcfid, &oplock, NULL,
+			 cifs_sb);
 	if (rc == 0) {
 		rc = CIFSSMBRenameOpenFile(xid, tcon, srcfid,
 				(const char *) to_dentry->d_name.name,
diff --git a/fs/cifs/link.c b/fs/cifs/link.c
index 9f6c4c4..886f61d 100644
--- a/fs/cifs/link.c
+++ b/fs/cifs/link.c
@@ -187,16 +187,11 @@ CIFSCreateMFSymLink(const unsigned int xid, struct cifs_tcon *tcon,
 {
 	int rc;
 	int oplock = 0;
-	int remap;
 	int create_options = CREATE_NOT_DIR;
 	__u16 netfid = 0;
 	u8 *buf;
 	unsigned int bytes_written = 0;
 	struct cifs_io_parms io_parms;
-	struct nls_table *nls_codepage;
-
-	nls_codepage = cifs_sb->local_nls;
-	remap = cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR;
 
 	buf = kmalloc(CIFS_MF_SYMLINK_FILE_SIZE, GFP_KERNEL);
 	if (!buf)
@@ -212,8 +207,8 @@ CIFSCreateMFSymLink(const unsigned int xid, struct cifs_tcon *tcon,
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
 
 	rc = CIFSSMBOpen(xid, tcon, fromName, FILE_CREATE, GENERIC_WRITE,
-			 create_options, &netfid, &oplock, NULL,
-			 nls_codepage, remap);
+			 FILE_SHARE_ALL, create_options, &netfid, &oplock, NULL,
+			 cifs_sb);
 	if (rc != 0) {
 		kfree(buf);
 		return rc;
@@ -240,7 +235,7 @@ CIFSCreateMFSymLink(const unsigned int xid, struct cifs_tcon *tcon,
 static int
 CIFSQueryMFSymLink(const unsigned int xid, struct cifs_tcon *tcon,
 		   const unsigned char *searchName, char **symlinkinfo,
-		   const struct nls_table *nls_codepage, int remap)
+		   struct cifs_sb_info *cifs_sb)
 {
 	int rc;
 	int oplock = 0;
@@ -254,8 +249,8 @@ CIFSQueryMFSymLink(const unsigned int xid, struct cifs_tcon *tcon,
 	FILE_ALL_INFO file_info;
 
 	rc = CIFSSMBOpen(xid, tcon, searchName, FILE_OPEN, GENERIC_READ,
-			 CREATE_NOT_DIR, &netfid, &oplock, &file_info,
-			 nls_codepage, remap);
+			 FILE_SHARE_ALL, CREATE_NOT_DIR, &netfid, &oplock,
+			 &file_info, cifs_sb);
 	if (rc != 0)
 		return rc;
 
@@ -332,10 +327,8 @@ CIFSCheckMFSymlink(struct cifs_fattr *fattr,
 	pTcon = tlink_tcon(tlink);
 
 	rc = CIFSSMBOpen(xid, pTcon, path, FILE_OPEN, GENERIC_READ,
-			 CREATE_NOT_DIR, &netfid, &oplock, &file_info,
-			 cifs_sb->local_nls,
-			 cifs_sb->mnt_cifs_flags &
-				CIFS_MOUNT_MAP_SPECIAL_CHR);
+			 FILE_SHARE_ALL, CREATE_NOT_DIR, &netfid, &oplock,
+			 &file_info, cifs_sb);
 	if (rc != 0)
 		goto out;
 
@@ -530,9 +523,7 @@ cifs_follow_link(struct dentry *direntry, struct nameidata *nd)
 	 */
 	if (cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MF_SYMLINKS)
 		rc = CIFSQueryMFSymLink(xid, tcon, full_path, &target_path,
-					cifs_sb->local_nls,
-					cifs_sb->mnt_cifs_flags &
-						CIFS_MOUNT_MAP_SPECIAL_CHR);
+					cifs_sb);
 
 	if ((rc != 0) && cap_unix(tcon->ses))
 		rc = CIFSSMBUnixQuerySymLink(xid, tcon, full_path, &target_path,
diff --git a/fs/cifs/readdir.c b/fs/cifs/readdir.c
index df40cc5..3d6717d 100644
--- a/fs/cifs/readdir.c
+++ b/fs/cifs/readdir.c
@@ -222,9 +222,8 @@ int get_symlink_reparse_path(char *full_path, struct cifs_sb_info *cifs_sb,
 	char *tmpbuffer;
 
 	rc = CIFSSMBOpen(xid, ptcon, full_path, FILE_OPEN, GENERIC_READ,
-			OPEN_REPARSE_POINT, &fid, &oplock, NULL,
-			cifs_sb->local_nls,
-			cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
+			FILE_SHARE_ALL, OPEN_REPARSE_POINT, &fid, &oplock, NULL,
+			cifs_sb);
 	if (!rc) {
 		tmpbuffer = kmalloc(maxpath);
 		rc = CIFSSMBQueryReparseLinkInfo(xid, ptcon, full_path,
diff --git a/fs/cifs/smb1ops.c b/fs/cifs/smb1ops.c
index 47bc5a8..a76950a 100644
--- a/fs/cifs/smb1ops.c
+++ b/fs/cifs/smb1ops.c
@@ -671,9 +671,9 @@ cifs_mkdir_setinfo(struct inode *inode, const char *full_path,
 
 static int
 cifs_open_file(const unsigned int xid, struct cifs_tcon *tcon, const char *path,
-	       int disposition, int desired_access, int create_options,
-	       struct cifs_fid *fid, __u32 *oplock, FILE_ALL_INFO *buf,
-	       struct cifs_sb_info *cifs_sb)
+	       int disposition, int desired_access, int share_access,
+	       int create_options, struct cifs_fid *fid, __u32 *oplock,
+	       FILE_ALL_INFO *buf, struct cifs_sb_info *cifs_sb)
 {
 	if (!(tcon->ses->capabilities & CAP_NT_SMBS))
 		return SMBLegacyOpen(xid, tcon, path, disposition,
@@ -682,9 +682,8 @@ cifs_open_file(const unsigned int xid, struct cifs_tcon *tcon, const char *path,
 				     cifs_sb->local_nls, cifs_sb->mnt_cifs_flags
 						& CIFS_MOUNT_MAP_SPECIAL_CHR);
 	return CIFSSMBOpen(xid, tcon, path, disposition, desired_access,
-			   create_options, &fid->netfid, oplock, buf,
-			   cifs_sb->local_nls, cifs_sb->mnt_cifs_flags &
-						CIFS_MOUNT_MAP_SPECIAL_CHR);
+			   share_access, create_options, &fid->netfid, oplock,
+			   buf, cifs_sb);
 }
 
 static void
@@ -779,9 +778,8 @@ smb_set_file_info(struct inode *inode, const char *full_path,
 	cFYI(1, "calling SetFileInfo since SetPathInfo for times not supported "
 		"by this server");
 	rc = CIFSSMBOpen(xid, tcon, full_path, FILE_OPEN,
-			 SYNCHRONIZE | FILE_WRITE_ATTRIBUTES, CREATE_NOT_DIR,
-			 &netfid, &oplock, NULL, cifs_sb->local_nls,
-			 cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
+			 SYNCHRONIZE | FILE_WRITE_ATTRIBUTES, FILE_SHARE_ALL,
+			 CREATE_NOT_DIR, &netfid, &oplock, NULL, cifs_sb);
 
 	if (rc != 0) {
 		if (rc == -EIO)
diff --git a/fs/cifs/smb2file.c b/fs/cifs/smb2file.c
index 71e6aed..7dfb50c 100644
--- a/fs/cifs/smb2file.c
+++ b/fs/cifs/smb2file.c
@@ -58,9 +58,9 @@ smb2_set_oplock_level(struct cifsInodeInfo *cinode, __u32 oplock)
 
 int
 smb2_open_file(const unsigned int xid, struct cifs_tcon *tcon, const char *path,
-	       int disposition, int desired_access, int create_options,
-	       struct cifs_fid *fid, __u32 *oplock, FILE_ALL_INFO *buf,
-	       struct cifs_sb_info *cifs_sb)
+	       int disposition, int desired_access, int share_access,
+	       int create_options, struct cifs_fid *fid, __u32 *oplock,
+	       FILE_ALL_INFO *buf, struct cifs_sb_info *cifs_sb)
 {
 	int rc;
 	__le16 *smb2_path;
@@ -87,8 +87,8 @@ smb2_open_file(const unsigned int xid, struct cifs_tcon *tcon, const char *path,
 		memcpy(smb2_oplock + 1, fid->lease_key, SMB2_LEASE_KEY_SIZE);
 
 	rc = SMB2_open(xid, tcon, smb2_path, &fid->persistent_fid,
-		       &fid->volatile_fid, desired_access, disposition,
-		       0, 0, smb2_oplock, smb2_data);
+		       &fid->volatile_fid, desired_access, share_access,
+		       disposition, 0, 0, smb2_oplock, smb2_data);
 	if (rc)
 		goto out;
 
diff --git a/fs/cifs/smb2inode.c b/fs/cifs/smb2inode.c
index 7064824..6af174a 100644
--- a/fs/cifs/smb2inode.c
+++ b/fs/cifs/smb2inode.c
@@ -54,8 +54,8 @@ smb2_open_op_close(const unsigned int xid, struct cifs_tcon *tcon,
 		return -ENOMEM;
 
 	rc = SMB2_open(xid, tcon, utf16_path, &persistent_fid, &volatile_fid,
-		       desired_access, create_disposition, file_attributes,
-		       create_options, &oplock, NULL);
+		       desired_access, FILE_SHARE_ALL, create_disposition,
+		       file_attributes, create_options, &oplock, NULL);
 	if (rc) {
 		kfree(utf16_path);
 		return rc;
diff --git a/fs/cifs/smb2ops.c b/fs/cifs/smb2ops.c
index bceffe7..22aef1d 100644
--- a/fs/cifs/smb2ops.c
+++ b/fs/cifs/smb2ops.c
@@ -222,7 +222,8 @@ smb2_is_path_accessible(const unsigned int xid, struct cifs_tcon *tcon,
 		return -ENOMEM;
 
 	rc = SMB2_open(xid, tcon, utf16_path, &persistent_fid, &volatile_fid,
-		       FILE_READ_ATTRIBUTES, FILE_OPEN, 0, 0, &oplock, NULL);
+		       FILE_READ_ATTRIBUTES, FILE_SHARE_ALL, FILE_OPEN, 0, 0,
+		       &oplock, NULL);
 	if (rc) {
 		kfree(utf16_path);
 		return rc;
@@ -432,8 +433,8 @@ smb2_query_dir_first(const unsigned int xid, struct cifs_tcon *tcon,
 		return -ENOMEM;
 
 	rc = SMB2_open(xid, tcon, utf16_path, &persistent_fid, &volatile_fid,
-		       FILE_READ_ATTRIBUTES | FILE_READ_DATA, FILE_OPEN, 0, 0,
-		       &oplock, NULL);
+		       FILE_READ_ATTRIBUTES | FILE_READ_DATA, FILE_SHARE_ALL,
+		       FILE_OPEN, 0, 0, &oplock, NULL);
 	kfree(utf16_path);
 	if (rc) {
 		cERROR(1, "open dir failed");
@@ -515,7 +516,8 @@ smb2_queryfs(const unsigned int xid, struct cifs_tcon *tcon,
 	u8 oplock = SMB2_OPLOCK_LEVEL_NONE;
 
 	rc = SMB2_open(xid, tcon, &srch_path, &persistent_fid, &volatile_fid,
-		       FILE_READ_ATTRIBUTES, FILE_OPEN, 0, 0, &oplock, NULL);
+		       FILE_READ_ATTRIBUTES, FILE_SHARE_ALL, FILE_OPEN, 0, 0,
+		       &oplock, NULL);
 	if (rc)
 		return rc;
 	buf->f_type = SMB2_MAGIC_NUMBER;
diff --git a/fs/cifs/smb2pdu.c b/fs/cifs/smb2pdu.c
index 41d9d07..45fa2dc 100644
--- a/fs/cifs/smb2pdu.c
+++ b/fs/cifs/smb2pdu.c
@@ -910,8 +910,8 @@ parse_lease_state(struct smb2_create_rsp *rsp)
 int
 SMB2_open(const unsigned int xid, struct cifs_tcon *tcon, __le16 *path,
 	  u64 *persistent_fid, u64 *volatile_fid, __u32 desired_access,
-	  __u32 create_disposition, __u32 file_attributes, __u32 create_options,
-	  __u8 *oplock, struct smb2_file_all_info *buf)
+	  __u32 share_access, __u32 create_disposition, __u32 file_attributes,
+	  __u32 create_options,  __u8 *oplock, struct smb2_file_all_info *buf)
 {
 	struct smb2_create_req *req;
 	struct smb2_create_rsp *rsp;
@@ -940,7 +940,7 @@ SMB2_open(const unsigned int xid, struct cifs_tcon *tcon, __le16 *path,
 	req->DesiredAccess = cpu_to_le32(desired_access);
 	/* File attributes ignored on open (used in create though) */
 	req->FileAttributes = cpu_to_le32(file_attributes);
-	req->ShareAccess = FILE_SHARE_ALL_LE;
+	req->ShareAccess = cpu_to_le32(share_access);
 	req->CreateDisposition = cpu_to_le32(create_disposition);
 	req->CreateOptions = cpu_to_le32(create_options);
 	uni_path_len = (2 * UniStrnlen((wchar_t *)path, PATH_MAX)) + 2;
diff --git a/fs/cifs/smb2proto.h b/fs/cifs/smb2proto.h
index 2aa3535..edff8f6 100644
--- a/fs/cifs/smb2proto.h
+++ b/fs/cifs/smb2proto.h
@@ -86,9 +86,10 @@ extern int smb2_create_hardlink(const unsigned int xid, struct cifs_tcon *tcon,
 
 extern int smb2_open_file(const unsigned int xid, struct cifs_tcon *tcon,
 			  const char *full_path, int disposition,
-			  int desired_access, int create_options,
-			  struct cifs_fid *fid, __u32 *oplock,
-			  FILE_ALL_INFO *buf, struct cifs_sb_info *cifs_sb);
+			  int desired_access, int share_access,
+			  int create_options,  struct cifs_fid *fid,
+			  __u32 *oplock, FILE_ALL_INFO *buf,
+			  struct cifs_sb_info *cifs_sb);
 extern void smb2_set_oplock_level(struct cifsInodeInfo *cinode, __u32 oplock);
 extern int smb2_unlock_range(struct cifsFileInfo *cfile,
 			     struct file_lock *flock, const unsigned int xid);
@@ -108,9 +109,10 @@ extern int SMB2_tcon(const unsigned int xid, struct cifs_ses *ses,
 extern int SMB2_tdis(const unsigned int xid, struct cifs_tcon *tcon);
 extern int SMB2_open(const unsigned int xid, struct cifs_tcon *tcon,
 		     __le16 *path, u64 *persistent_fid, u64 *volatile_fid,
-		     __u32 desired_access, __u32 create_disposition,
-		     __u32 file_attributes, __u32 create_options,
-		     __u8 *oplock, struct smb2_file_all_info *buf);
+		     __u32 desired_access, __u32 share_access,
+		     __u32 create_disposition, __u32 file_attributes,
+		     __u32 create_options, __u8 *oplock,
+		     struct smb2_file_all_info *buf);
 extern int SMB2_close(const unsigned int xid, struct cifs_tcon *tcon,
 		      u64 persistent_file_id, u64 volatile_file_id);
 extern int SMB2_flush(const unsigned int xid, struct cifs_tcon *tcon,
-- 
1.8.1.5

