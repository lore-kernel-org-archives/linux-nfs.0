Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f177.google.com ([209.85.217.177]:46880 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760697Ab3B1PWw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Feb 2013 10:22:52 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v3 3/7] CIFS: Add O_DENY* open flags support
Date: Thu, 28 Feb 2013 19:25:29 +0400
Message-Id: <1362065133-9490-4-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make CIFSSMBOpen take share_flags as a parm that allows us
to pass new O_DENY* flags to the server.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/cifs/cifsacl.c   |  6 ++++--
 fs/cifs/cifsglob.h  | 12 +++++++++++-
 fs/cifs/cifsproto.h |  9 +++++----
 fs/cifs/cifssmb.c   | 47 +++++++++++++++++++++++++----------------------
 fs/cifs/dir.c       | 13 ++++++++-----
 fs/cifs/file.c      | 12 ++++++++----
 fs/cifs/inode.c     | 11 ++++++-----
 fs/cifs/link.c      | 10 +++++-----
 fs/cifs/readdir.c   |  2 +-
 fs/cifs/smb1ops.c   | 15 ++++++++-------
 fs/cifs/smb2file.c  | 10 +++++-----
 fs/cifs/smb2inode.c |  4 ++--
 fs/cifs/smb2ops.c   | 10 ++++++----
 fs/cifs/smb2pdu.c   |  6 +++---
 fs/cifs/smb2proto.h | 14 ++++++++------
 15 files changed, 105 insertions(+), 76 deletions(-)

diff --git a/fs/cifs/cifsacl.c b/fs/cifs/cifsacl.c
index 5cbd00e..222b989 100644
--- a/fs/cifs/cifsacl.c
+++ b/fs/cifs/cifsacl.c
@@ -891,7 +891,8 @@ static struct cifs_ntsd *get_cifs_acl_by_path(struct cifs_sb_info *cifs_sb,
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
 
 	rc = CIFSSMBOpen(xid, tcon, path, FILE_OPEN, READ_CONTROL,
-			create_options, &fid, &oplock, NULL, cifs_sb->local_nls,
+			FILE_SHARE_ALL, create_options, &fid, &oplock,
+			NULL, cifs_sb->local_nls,
 			cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
 	if (!rc) {
 		rc = CIFSSMBGetCIFSACL(xid, tcon, fid, &pntsd, pacllen);
@@ -952,7 +953,8 @@ int set_cifs_acl(struct cifs_ntsd *pnntsd, __u32 acllen,
 		access_flags = WRITE_DAC;
 
 	rc = CIFSSMBOpen(xid, tcon, path, FILE_OPEN, access_flags,
-			create_options, &fid, &oplock, NULL, cifs_sb->local_nls,
+			FILE_SHARE_ALL, create_options, &fid, &oplock,
+			NULL, cifs_sb->local_nls,
 			cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
 	if (rc) {
 		cERROR(1, "Unable to open file to set ACL");
diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index e6899ce..f1d62ed 100644
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
@@ -947,6 +947,16 @@ struct cifsFileInfo {
 	struct work_struct oplock_break; /* work for oplock breaks */
 };
 
+#define CIFS_DENY_RW_FLAGS_SHIFT	22
+#define CIFS_DENY_DEL_FLAG_SHIFT	23
+
+static inline int cifs_get_share_flags(unsigned int flags)
+{
+	return (flags & O_DENYMAND) ?
+		(((~(flags >> CIFS_DENY_RW_FLAGS_SHIFT)) & 3) |
+		 ((~(flags >> CIFS_DENY_DEL_FLAG_SHIFT)) & 4)) : FILE_SHARE_ALL;
+}
+
 struct cifs_io_parms {
 	__u16 netfid;
 #ifdef CONFIG_CIFS_SMB2
diff --git a/fs/cifs/cifsproto.h b/fs/cifs/cifsproto.h
index 1988c1b..9661607 100644
--- a/fs/cifs/cifsproto.h
+++ b/fs/cifs/cifsproto.h
@@ -361,10 +361,11 @@ extern int CIFSSMBQueryReparseLinkInfo(const unsigned int xid,
 			const struct nls_table *nls_codepage);
 #endif /* temporarily unused until cifs_symlink fixed */
 extern int CIFSSMBOpen(const unsigned int xid, struct cifs_tcon *tcon,
-			const char *fileName, const int disposition,
-			const int access_flags, const int omode,
-			__u16 *netfid, int *pOplock, FILE_ALL_INFO *,
-			const struct nls_table *nls_codepage, int remap);
+			const char *file_name, const int disposition,
+			const int access_flags, const int share_flags,
+			const int omode, __u16 *netfid, int *oplock,
+			FILE_ALL_INFO *, const struct nls_table *nls_codepage,
+			int remap);
 extern int SMBLegacyOpen(const unsigned int xid, struct cifs_tcon *tcon,
 			const char *fileName, const int disposition,
 			const int access_flags, const int omode,
diff --git a/fs/cifs/cifssmb.c b/fs/cifs/cifssmb.c
index 76d0d29..9c4632f 100644
--- a/fs/cifs/cifssmb.c
+++ b/fs/cifs/cifssmb.c
@@ -1289,10 +1289,11 @@ OldOpenRetry:
 
 int
 CIFSSMBOpen(const unsigned int xid, struct cifs_tcon *tcon,
-	    const char *fileName, const int openDisposition,
-	    const int access_flags, const int create_options, __u16 *netfid,
-	    int *pOplock, FILE_ALL_INFO *pfile_info,
-	    const struct nls_table *nls_codepage, int remap)
+	    const char *file_name, const int disposition,
+	    const int access_flags, const int share_flags,
+	    const int create_options, __u16 *netfid, int *oplock,
+	    FILE_ALL_INFO *file_info, const struct nls_table *nls_codepage,
+	    int remap)
 {
 	int rc = -EACCES;
 	OPEN_REQ *pSMB = NULL;
@@ -1313,26 +1314,28 @@ openRetry:
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
 	pSMB->DesiredAccess = cpu_to_le32(access_flags);
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
@@ -1347,8 +1350,8 @@ openRetry:
 	if (create_options & CREATE_OPTION_READONLY)
 		pSMB->FileAttributes |= cpu_to_le32(ATTR_READONLY);
 
-	pSMB->ShareAccess = cpu_to_le32(FILE_SHARE_ALL);
-	pSMB->CreateDisposition = cpu_to_le32(openDisposition);
+	pSMB->ShareAccess = cpu_to_le32(share_flags);
+	pSMB->CreateDisposition = cpu_to_le32(disposition);
 	pSMB->CreateOptions = cpu_to_le32(create_options & CREATE_OPTIONS_MASK);
 	/* BB Expirement with various impersonation levels and verify */
 	pSMB->ImpersonationLevel = cpu_to_le32(SECURITY_IMPERSONATION);
@@ -1366,20 +1369,20 @@ openRetry:
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
index 8719bbe..6975072 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -203,6 +203,7 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
 	FILE_ALL_INFO *buf = NULL;
 	struct inode *newinode = NULL;
 	int disposition;
+	int share_access;
 	struct TCP_Server_Info *server = tcon->ses->server;
 
 	*oplock = 0;
@@ -293,6 +294,8 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
 	else
 		cFYI(1, "Create flag not set in create function");
 
+	share_access = cifs_get_share_flags(oflags);
+
 	/*
 	 * BB add processing to set equivalent of mode - e.g. via CreateX with
 	 * ACLs
@@ -320,8 +323,8 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
 
 	rc = server->ops->open(xid, tcon, full_path, disposition,
-			       desired_access, create_options, fid, oplock,
-			       buf, cifs_sb);
+			       desired_access, share_access, create_options,
+			       fid, oplock, buf, cifs_sb);
 	if (rc) {
 		cFYI(1, "cifs_create returned 0x%x", rc);
 		goto out;
@@ -626,9 +629,9 @@ int cifs_mknod(struct inode *inode, struct dentry *direntry, umode_t mode,
 	if (backup_cred(cifs_sb))
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
 
-	rc = CIFSSMBOpen(xid, pTcon, full_path, FILE_CREATE,
-			 GENERIC_WRITE, create_options,
-			 &fileHandle, &oplock, buf, cifs_sb->local_nls,
+	rc = CIFSSMBOpen(xid, pTcon, full_path, FILE_CREATE, GENERIC_WRITE,
+			 FILE_SHARE_ALL, create_options, &fileHandle, &oplock,
+			 buf, cifs_sb->local_nls,
 			 cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
 	if (rc)
 		goto mknod_out;
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 8ea6ca5..3ad484c 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -174,6 +174,7 @@ cifs_nt_open(char *full_path, struct inode *inode, struct cifs_sb_info *cifs_sb,
 {
 	int rc;
 	int desired_access;
+	int share_access;
 	int disposition;
 	int create_options = CREATE_NOT_DIR;
 	FILE_ALL_INFO *buf;
@@ -209,6 +210,7 @@ cifs_nt_open(char *full_path, struct inode *inode, struct cifs_sb_info *cifs_sb,
  *********************************************************************/
 
 	disposition = cifs_get_disposition(f_flags);
+	share_access = cifs_get_share_flags(f_flags);
 
 	/* BB pass O_SYNC flag through on file attributes .. BB */
 
@@ -220,8 +222,8 @@ cifs_nt_open(char *full_path, struct inode *inode, struct cifs_sb_info *cifs_sb,
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
 
 	rc = server->ops->open(xid, tcon, full_path, disposition,
-			       desired_access, create_options, fid, oplock, buf,
-			       cifs_sb);
+			       desired_access, share_access, create_options,
+			       fid, oplock, buf, cifs_sb);
 
 	if (rc)
 		goto out;
@@ -579,6 +581,7 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
 	struct inode *inode;
 	char *full_path = NULL;
 	int desired_access;
+	int share_access;
 	int disposition = FILE_OPEN;
 	int create_options = CREATE_NOT_DIR;
 	struct cifs_fid fid;
@@ -643,6 +646,7 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
 	}
 
 	desired_access = cifs_convert_flags(cfile->f_flags);
+	share_access = cifs_get_share_flags(cfile->f_flags);
 
 	if (backup_cred(cifs_sb))
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
@@ -658,8 +662,8 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
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
index ed6208f..a497dfa 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -396,8 +396,8 @@ cifs_sfu_type(struct cifs_fattr *fattr, const unsigned char *path,
 	tcon = tlink_tcon(tlink);
 
 	rc = CIFSSMBOpen(xid, tcon, path, FILE_OPEN, GENERIC_READ,
-			 CREATE_NOT_DIR, &netfid, &oplock, NULL,
-			 cifs_sb->local_nls,
+			 FILE_SHARE_ALL, CREATE_NOT_DIR, &netfid, &oplock,
+			 NULL, cifs_sb->local_nls,
 			 cifs_sb->mnt_cifs_flags &
 				CIFS_MOUNT_MAP_SPECIAL_CHR);
 	if (rc == 0) {
@@ -987,8 +987,9 @@ cifs_rename_pending_delete(const char *full_path, struct dentry *dentry,
 	tcon = tlink_tcon(tlink);
 
 	rc = CIFSSMBOpen(xid, tcon, full_path, FILE_OPEN,
-			 DELETE|FILE_WRITE_ATTRIBUTES, CREATE_NOT_DIR,
-			 &netfid, &oplock, NULL, cifs_sb->local_nls,
+			 DELETE|FILE_WRITE_ATTRIBUTES, FILE_SHARE_ALL,
+			 CREATE_NOT_DIR, &netfid, &oplock, NULL,
+			 cifs_sb->local_nls,
 			 cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
 	if (rc != 0)
 		goto out;
@@ -1509,7 +1510,7 @@ cifs_do_rename(const unsigned int xid, struct dentry *from_dentry,
 
 	/* open the file to be renamed -- we need DELETE perms */
 	rc = CIFSSMBOpen(xid, tcon, from_path, FILE_OPEN, DELETE,
-			 CREATE_NOT_DIR, &srcfid, &oplock, NULL,
+			 FILE_SHARE_ALL, CREATE_NOT_DIR, &srcfid, &oplock, NULL,
 			 cifs_sb->local_nls, cifs_sb->mnt_cifs_flags &
 				CIFS_MOUNT_MAP_SPECIAL_CHR);
 	if (rc == 0) {
diff --git a/fs/cifs/link.c b/fs/cifs/link.c
index 51dc2fb..9b4f0db 100644
--- a/fs/cifs/link.c
+++ b/fs/cifs/link.c
@@ -212,7 +212,7 @@ CIFSCreateMFSymLink(const unsigned int xid, struct cifs_tcon *tcon,
 		create_options |= CREATE_OPEN_BACKUP_INTENT;
 
 	rc = CIFSSMBOpen(xid, tcon, fromName, FILE_CREATE, GENERIC_WRITE,
-			 create_options, &netfid, &oplock, NULL,
+			 FILE_SHARE_ALL, create_options, &netfid, &oplock, NULL,
 			 nls_codepage, remap);
 	if (rc != 0) {
 		kfree(buf);
@@ -254,8 +254,8 @@ CIFSQueryMFSymLink(const unsigned int xid, struct cifs_tcon *tcon,
 	FILE_ALL_INFO file_info;
 
 	rc = CIFSSMBOpen(xid, tcon, searchName, FILE_OPEN, GENERIC_READ,
-			 CREATE_NOT_DIR, &netfid, &oplock, &file_info,
-			 nls_codepage, remap);
+			 FILE_SHARE_ALL, CREATE_NOT_DIR, &netfid, &oplock,
+			 &file_info, nls_codepage, remap);
 	if (rc != 0)
 		return rc;
 
@@ -332,8 +332,8 @@ CIFSCheckMFSymlink(struct cifs_fattr *fattr,
 	pTcon = tlink_tcon(tlink);
 
 	rc = CIFSSMBOpen(xid, pTcon, path, FILE_OPEN, GENERIC_READ,
-			 CREATE_NOT_DIR, &netfid, &oplock, &file_info,
-			 cifs_sb->local_nls,
+			 FILE_SHARE_ALL, CREATE_NOT_DIR, &netfid, &oplock,
+			 &file_info, cifs_sb->local_nls,
 			 cifs_sb->mnt_cifs_flags &
 				CIFS_MOUNT_MAP_SPECIAL_CHR);
 	if (rc != 0)
diff --git a/fs/cifs/readdir.c b/fs/cifs/readdir.c
index cdd6ff4..726b52e 100644
--- a/fs/cifs/readdir.c
+++ b/fs/cifs/readdir.c
@@ -224,7 +224,7 @@ int get_symlink_reparse_path(char *full_path, struct cifs_sb_info *cifs_sb,
 	char *tmpbuffer;
 
 	rc = CIFSSMBOpen(xid, ptcon, full_path, FILE_OPEN, GENERIC_READ,
-			OPEN_REPARSE_POINT, &fid, &oplock, NULL,
+			FILE_SHARE_ALL, OPEN_REPARSE_POINT, &fid, &oplock, NULL,
 			cifs_sb->local_nls,
 			cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
 	if (!rc) {
diff --git a/fs/cifs/smb1ops.c b/fs/cifs/smb1ops.c
index 47bc5a8..d782209 100644
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
@@ -682,8 +682,8 @@ cifs_open_file(const unsigned int xid, struct cifs_tcon *tcon, const char *path,
 				     cifs_sb->local_nls, cifs_sb->mnt_cifs_flags
 						& CIFS_MOUNT_MAP_SPECIAL_CHR);
 	return CIFSSMBOpen(xid, tcon, path, disposition, desired_access,
-			   create_options, &fid->netfid, oplock, buf,
-			   cifs_sb->local_nls, cifs_sb->mnt_cifs_flags &
+			   share_access, create_options, &fid->netfid, oplock,
+			   buf, cifs_sb->local_nls, cifs_sb->mnt_cifs_flags &
 						CIFS_MOUNT_MAP_SPECIAL_CHR);
 }
 
@@ -779,8 +779,9 @@ smb_set_file_info(struct inode *inode, const char *full_path,
 	cFYI(1, "calling SetFileInfo since SetPathInfo for times not supported "
 		"by this server");
 	rc = CIFSSMBOpen(xid, tcon, full_path, FILE_OPEN,
-			 SYNCHRONIZE | FILE_WRITE_ATTRIBUTES, CREATE_NOT_DIR,
-			 &netfid, &oplock, NULL, cifs_sb->local_nls,
+			 SYNCHRONIZE | FILE_WRITE_ATTRIBUTES, FILE_SHARE_ALL,
+			 CREATE_NOT_DIR, &netfid, &oplock, NULL,
+			 cifs_sb->local_nls,
 			 cifs_sb->mnt_cifs_flags & CIFS_MOUNT_MAP_SPECIAL_CHR);
 
 	if (rc != 0) {
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
index c9c7aa7..dc38434 100644
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
1.8.1.2

