Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552596;
	b=cZUSLehB3NxQf7pgk54AsmCoN6dKhaXA3WrK2aRQrvsL3z3IRSAmigfL+hlINZrzTl42
	 apiPxmw0AN2BcUILynsB1K5kpfX3PY8lDoN32TXygyfHM80dMlcA7F8onM4sM7vIb6l42
	 B4ZgtK5/ktPSbd+dp2lQOuw/j+cs4iD49pzk1t60CzYNGzgXv6pKNIHWPElUk81sNs1Qo
	 +1a+H9d6KCGCGydLcBQ66iM1LogLMAmdq3Yp5XGNKw8+ZI/d80BMP46+nFdR4duv2Xz6R
	 FnR65GH7LGzZ9bkTKaJUGXwaEMxI1u2dUPEXc7ZRX1w02OxDCUdhujbLtcIEEuQoVFg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552596;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=1Z5EYKR3zuCRsOgoCpct75zMOfdUFTXtn/PScOjLh3g=;
	b=2Mew+jhy6d1A+O6bzqvg+1PW7ausOEx/ikVHOBf5Hcddeqw7fEe4QV1dHJ7hshK1wNLU
	 twk72acEEY6CgT2zhvQ9Ite7VP3Z22GIFAc213N2Qgk9DLYP+lHTeoHKNj7nk+4jFECbQ
	 FfOHAfzLhN+7KbHsbc6OAbOPbVP7qNkoi55YesQEGy8Fr2s6DHjfEZeCGZBZnlPru07sA
	 CZWGjFeAgRY2ADlNSZvd4ljrQ6OF2+OiGgJwzND5CL5XfufAAPxJhGPVBxc6kPcLNv1/5
	 ipTmGSP85qIL+RJc7LDx2xY6bXM1E7hWre0bJ5pK9evxAV33AyzhuK0wOu3gtEV+hKQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=cuAbQ3om;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F64C606E847;
	Wed, 21 Oct 2026 03:16:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3F64C606E847
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=cuAbQ3om
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552593; bh=Rpwprzh2eYyYWotnA65KRqh2Jcb7fuYYdOguWAwVUjg=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=cuAbQ3omm3WMEFrviQQfeekK6DAsAAGK3N1HHZSrIcJGoHsiAk1KlRyltjBlWzyzx
	 7kfqDLrxSkFxe5pT4LFG1Eh8YazB3xDHmf8f8ZS3TRhwJBKJv2EgVOCCVtYXQxsEEB
	 r4FAAaBk6SIoNnj9BpU6LsdPt0H+JMDijjSzVw3vjgERC50vA36n7LUqbMa4+QdiOg
	 f+96hCZ7TN+oeya6qEx5lsXWrA+te6+3v7qzSdZCVtb+p5kFnuvgREfbDyMWxyxm9A
	 o0E8FmTH2fEqorOKc8uc4OXUyEJsGai6m54qgpmY0FjUrlMrlYYWkD8fwWGozmJfRy
	 y4orxDPPaCk5Q==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 536A88A0912;
	Wed, 21 Oct 2026 05:16:32 +0200 (CEST)
Message-ID: <54f57a7ac52b6b2b130b5a6e911e0998c9630da8.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 21/41] fs: add chown_r(), lchown_r(), fchown_r() and
 fchownat_r()
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Wed, 21 Oct 2026 05:15:41 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

The chown family with __kernel_uid_r_t owner and group, so files can be
given UUID and GUID owners on filesystems that support them
(SB_I_UID_R); others refuse with -EOVERFLOW. NULL pointers, UID_R_NONE
and the classic -1 leave the owner or group unchanged.

The classic calls and the new ones share the lookup and setattr code,
which now works on a struct chown_ids. The classic calls still report a
malformed id only once the file is found, as before.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/open.c                | 144 +++++++++++++++++++++++++++++++++++----
 include/linux/syscalls.h |  13 ++++
 2 files changed, 145 insertions(+), 12 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index 6b1c14e684..26175b5aa8 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -785,7 +785,46 @@ static inline bool setattr_vfsgid(struct iattr *attr, kgid_t kgid)
 	return true;
 }
 
-int chown_common(const struct path *path, uid_t user, gid_t group)
+/*
+ * The new owner and group of a chown. Invalid ids stand for "unchanged";
+ * @err is an error of their conversion, reported once the path is found,
+ * which keeps the classic calls' order of errors.
+ */
+struct chown_ids {
+	kuid_t uid;
+	kgid_t gid;
+	int err;
+};
+
+static struct chown_ids chown_ids_classic(uid_t user, gid_t group)
+{
+	struct user_namespace *ns = current_user_ns();
+	struct chown_ids ids = {
+		.uid = make_kuid(ns, user),
+		.gid = make_kgid(ns, group),
+	};
+
+	if ((user != (uid_t)-1 && !uid_valid(ids.uid)) ||
+	    (group != (gid_t)-1 && !gid_valid(ids.gid)))
+		ids.err = -EINVAL;
+	return ids;
+}
+
+static int chown_ids_r(const struct __kernel_uid_r __user *user,
+		       const struct __kernel_uid_r __user *group,
+		       struct chown_ids *ids)
+{
+	struct user_namespace *ns = current_user_ns();
+	int err;
+
+	ids->err = 0;
+	err = get_kuid_r(ns, user, &ids->uid);
+	if (!err)
+		err = get_kgid_r(ns, group, &ids->gid);
+	return err;
+}
+
+static int chown_path(const struct path *path, const struct chown_ids *ids)
 {
 	struct mnt_idmap *idmap;
 	struct user_namespace *fs_userns;
@@ -793,11 +832,9 @@ int chown_common(const struct path *path, uid_t user, gid_t group)
 	struct delegated_inode delegated_inode = { };
 	int error;
 	struct iattr newattrs;
-	kuid_t uid;
-	kgid_t gid;
 
-	uid = make_kuid(current_user_ns(), user);
-	gid = make_kgid(current_user_ns(), group);
+	if (ids->err)
+		return ids->err;
 
 	idmap = mnt_idmap(path->mnt);
 	fs_userns = i_user_ns(inode);
@@ -806,9 +843,9 @@ int chown_common(const struct path *path, uid_t user, gid_t group)
 	newattrs.ia_vfsuid = INVALID_VFSUID;
 	newattrs.ia_vfsgid = INVALID_VFSGID;
 	newattrs.ia_valid =  ATTR_CTIME;
-	if ((user != (uid_t)-1) && !setattr_vfsuid(&newattrs, uid))
+	if (uid_valid(ids->uid) && !setattr_vfsuid(&newattrs, ids->uid))
 		return -EINVAL;
-	if ((group != (gid_t)-1) && !setattr_vfsgid(&newattrs, gid))
+	if (gid_valid(ids->gid) && !setattr_vfsgid(&newattrs, ids->gid))
 		return -EINVAL;
 	error = inode_lock_killable(inode);
 	if (error)
@@ -833,8 +870,15 @@ int chown_common(const struct path *path, uid_t user, gid_t group)
 	return error;
 }
 
-int do_fchownat(int dfd, const char __user *filename, uid_t user, gid_t group,
-		int flag)
+int chown_common(const struct path *path, uid_t user, gid_t group)
+{
+	struct chown_ids ids = chown_ids_classic(user, group);
+
+	return chown_path(path, &ids);
+}
+
+static int fchownat_ids(int dfd, const char __user *filename,
+			const struct chown_ids *ids, int flag)
 {
 	struct path path;
 	int error;
@@ -850,7 +894,7 @@ int do_fchownat(int dfd, const char __user *filename, uid_t user, gid_t group,
 	if (!error) {
 		error = mnt_want_write(path.mnt);
 		if (!error) {
-			error = chown_common(&path, user, group);
+			error = chown_path(&path, ids);
 			mnt_drop_write(path.mnt);
 		}
 		path_put(&path);
@@ -862,6 +906,14 @@ int do_fchownat(int dfd, const char __user *filename, uid_t user, gid_t group,
 	return error;
 }
 
+int do_fchownat(int dfd, const char __user *filename, uid_t user, gid_t group,
+		int flag)
+{
+	struct chown_ids ids = chown_ids_classic(user, group);
+
+	return fchownat_ids(dfd, filename, &ids, flag);
+}
+
 SYSCALL_DEFINE5(fchownat, int, dfd, const char __user *, filename, uid_t, user,
 		gid_t, group, int, flag)
 {
@@ -879,7 +931,7 @@ SYSCALL_DEFINE3(lchown, const char __user *, filename, uid_t, user, gid_t, group
 			   AT_SYMLINK_NOFOLLOW);
 }
 
-int vfs_fchown(struct file *file, uid_t user, gid_t group)
+static int fchown_ids(struct file *file, const struct chown_ids *ids)
 {
 	int error;
 
@@ -887,11 +939,18 @@ int vfs_fchown(struct file *file, uid_t user, gid_t group)
 	if (error)
 		return error;
 	audit_file(file);
-	error = chown_common(&file->f_path, user, group);
+	error = chown_path(&file->f_path, ids);
 	mnt_drop_write_file(file);
 	return error;
 }
 
+int vfs_fchown(struct file *file, uid_t user, gid_t group)
+{
+	struct chown_ids ids = chown_ids_classic(user, group);
+
+	return fchown_ids(file, &ids);
+}
+
 int ksys_fchown(unsigned int fd, uid_t user, gid_t group)
 {
 	CLASS(fd, f)(fd);
@@ -907,6 +966,67 @@ SYSCALL_DEFINE3(fchown, unsigned int, fd, uid_t, user, gid_t, group)
 	return ksys_fchown(fd, user, group);
 }
 
+/*
+ * The *_r variants take __kernel_uid_r_t ids, which can also be UUIDs or
+ * GUIDs. A NULL pointer, UID_R_NONE or a classic -1 leave the owner or
+ * group unchanged.
+ */
+SYSCALL_DEFINE5(fchownat_r, int, dfd, const char __user *, filename,
+		const struct __kernel_uid_r __user *, user,
+		const struct __kernel_uid_r __user *, group, int, flag)
+{
+	struct chown_ids ids;
+	int error;
+
+	error = chown_ids_r(user, group, &ids);
+	if (error)
+		return error;
+	return fchownat_ids(dfd, filename, &ids, flag);
+}
+
+SYSCALL_DEFINE3(chown_r, const char __user *, filename,
+		const struct __kernel_uid_r __user *, user,
+		const struct __kernel_uid_r __user *, group)
+{
+	struct chown_ids ids;
+	int error;
+
+	error = chown_ids_r(user, group, &ids);
+	if (error)
+		return error;
+	return fchownat_ids(AT_FDCWD, filename, &ids, 0);
+}
+
+SYSCALL_DEFINE3(lchown_r, const char __user *, filename,
+		const struct __kernel_uid_r __user *, user,
+		const struct __kernel_uid_r __user *, group)
+{
+	struct chown_ids ids;
+	int error;
+
+	error = chown_ids_r(user, group, &ids);
+	if (error)
+		return error;
+	return fchownat_ids(AT_FDCWD, filename, &ids, AT_SYMLINK_NOFOLLOW);
+}
+
+SYSCALL_DEFINE3(fchown_r, unsigned int, fd,
+		const struct __kernel_uid_r __user *, user,
+		const struct __kernel_uid_r __user *, group)
+{
+	struct chown_ids ids;
+	int error;
+
+	error = chown_ids_r(user, group, &ids);
+	if (error)
+		return error;
+
+	CLASS(fd, f)(fd);
+	if (fd_empty(f))
+		return -EBADF;
+	return fchown_ids(fd_file(f), &ids);
+}
+
 static inline int file_get_write_access(struct file *f)
 {
 	int error;
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index b4b9d5d76f..4a18b59631 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -998,6 +998,19 @@ asmlinkage long sys_getgroups_r(int gidsetsize,
 				struct __kernel_uid_r __user *grouplist);
 asmlinkage long sys_setgroups_r(int gidsetsize,
 				const struct __kernel_uid_r __user *grouplist);
+asmlinkage long sys_chown_r(const char __user *filename,
+			    const struct __kernel_uid_r __user *user,
+			    const struct __kernel_uid_r __user *group);
+asmlinkage long sys_lchown_r(const char __user *filename,
+			     const struct __kernel_uid_r __user *user,
+			     const struct __kernel_uid_r __user *group);
+asmlinkage long sys_fchown_r(unsigned int fd,
+			     const struct __kernel_uid_r __user *user,
+			     const struct __kernel_uid_r __user *group);
+asmlinkage long sys_fchownat_r(int dfd, const char __user *filename,
+			       const struct __kernel_uid_r __user *user,
+			       const struct __kernel_uid_r __user *group,
+			       int flag);
 asmlinkage long sys_open_tree(int dfd, const char __user *path, unsigned flags);
 asmlinkage long sys_open_tree_attr(int dfd, const char __user *path,
 				   unsigned flags,
-- 
2.56.0

