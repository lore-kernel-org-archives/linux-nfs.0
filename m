Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552592;
	b=r5cEifnjQUtYphgq9ivo80XBNKZ9naS+L4v8qc0KwssdbMtPHZbJmyjx5hHkCBghrpR6
	 Tq7EGmSnyKX7quV9O+Gqy7DWqbDvK/qk4CigI8B3d5lF86A0OtdFG8f+z8YD3EYVSLXUT
	 90YEr3YJ5AIG2MTc/fs2eX68pkvcjqAvL+dGO6VKFTvbXT+EL1/DO2X+2LO55dNqpA2W1
	 nbj5b4kj4otWNbILdUsWjPcBzFYmkMknBFRD7Cpn7R6ek4T8rxcXWz/FHx9OQ3DkfNud7
	 bGXC755RUkW6fIYR6xVMI+6szlGccfsFPQoPY4fDl+lHD/mGf4zrCzfV5mzNbaUmHsA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552592;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=d24OKph/dI3fMzhKO4dFLmk6VqPOISOSLJodM00CPtM=;
	b=wks0OtGJZ37RAJwuBdPZ7vbMMm+UYyoHetoGTfW+UciR3sY1zwed2IQ0uvmD8y+XL+tb
	 We1f9GSzQbiBfLN597tLjrwFrOVfB+s1RSCnvz0+Y97BTMeU3G1mEh8MouzSDSllVeZZr
	 jPEqnqyJ0226HgOYh14y5Tv/4pJVZd68ijiJqQ7iHad2QUj5rN0PA3QrZBq7XEOwgWiQQ
	 MSKsFzt9oWoLlH3TBarmJ3WDaBVzy+xffHKElD1Pn7ZBKVrvFltOt/LyDSS7wky5JAPOI
	 Bcs4Spgad2mmyi/LwMhBPYPCRM7Iv+3KRbsSe6BeBvX7vFTyHzTrHcjpEyCVyBTMZYw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=hUEK9wC8;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 890B3606DF4D;
	Wed, 21 Oct 2026 03:16:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 890B3606DF4D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=hUEK9wC8
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552589; bh=NMVDSDjOZGNY76Ujx4GCSRiB5GMdAmEKLefSrBeW47c=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=hUEK9wC8c82hmaxN7GvfHjVqWGzMBUAXR9E6XpyiOtyZrcL4m/ZkPkpTKM98bUt8/
	 hKmZeiz7ASHZjsZ24rEHvNw62WAJIiYExdUrg1ZkWb80RjyGYNZ0it3VZojohlLrCf
	 EkbtvP35+SyrEjI0hPw5TptUiOGClrsLKhS6ov3hbCYlipn9uocHRy1VRnNaEVLms1
	 ljCW4zBdndqEXuIIMmKnJLdgb2wvjjaPZY1212ZAwBJwC3b5fEgxLKLsFt2gNqGEdF
	 e2JdRS+sQ9Y23aumuWLMZ0frLnwYf+kniL+syh9yD4TJ1GVZ0C0q/MoNhw9VIbWglF
	 sSUYu3kf9JVFg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id C1CFD8A07DE;
	Wed, 21 Oct 2026 05:16:28 +0200 (CEST)
Message-ID: <f96af98f97ff569f2556381499da586646273c3d.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 20/41] groups: add getgroups_r() and setgroups_r()
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
Date: Wed, 21 Oct 2026 05:15:40 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Supplementary groups as arrays of __kernel_gid_r_t, so they can include
UUID and GUID groups. Unlike the set*id_r() calls, "no id" is not
accepted in the list. getgroups() reports such groups as the overflow
gid.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/linux/syscalls.h |  4 ++
 kernel/groups.c          | 79 +++++++++++++++++++++++++++++++++++++++-
 kernel/sys_ni.c          |  2 +
 3 files changed, 83 insertions(+), 2 deletions(-)

diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 09fa1093a9..b4b9d5d76f 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -994,6 +994,10 @@ asmlinkage long sys_setfsuid_r(const struct __kernel_uid_r __user *uid,
 			       struct __kernel_uid_r __user *old_uid);
 asmlinkage long sys_setfsgid_r(const struct __kernel_uid_r __user *gid,
 			       struct __kernel_uid_r __user *old_gid);
+asmlinkage long sys_getgroups_r(int gidsetsize,
+				struct __kernel_uid_r __user *grouplist);
+asmlinkage long sys_setgroups_r(int gidsetsize,
+				const struct __kernel_uid_r __user *grouplist);
 asmlinkage long sys_open_tree(int dfd, const char __user *path, unsigned flags);
 asmlinkage long sys_open_tree_attr(int dfd, const char __user *path,
 				   unsigned flags,
diff --git a/kernel/groups.c b/kernel/groups.c
index 3aa0651d7a..8eb8260fc7 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -8,6 +8,7 @@
 #include <linux/security.h>
 #include <linux/sort.h>
 #include <linux/syscalls.h>
+#include <linux/uidgid_r.h>
 #include <linux/user_namespace.h>
 #include <linux/vmalloc.h>
 #include <linux/uaccess.h>
@@ -194,7 +195,9 @@ bool may_setgroups(void)
  *	without another task interfering.
  */
 
-SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
+static long do_setgroups(int gidsetsize, const void __user *grouplist,
+			 int (*from_user)(struct group_info *,
+					  const void __user *))
 {
 	struct group_info *group_info;
 	int retval;
@@ -207,7 +210,7 @@ SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
 	group_info = groups_alloc(gidsetsize);
 	if (!group_info)
 		return -ENOMEM;
-	retval = groups_from_user(group_info, grouplist);
+	retval = from_user(group_info, grouplist);
 	if (retval) {
 		put_group_info(group_info);
 		return retval;
@@ -220,6 +223,78 @@ SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
 	return retval;
 }
 
+static int groups_from_user_classic(struct group_info *group_info,
+				    const void __user *grouplist)
+{
+	return groups_from_user(group_info, (gid_t __user *)grouplist);
+}
+
+SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
+{
+	return do_setgroups(gidsetsize, grouplist, groups_from_user_classic);
+}
+
+/* group_info to a user-space array of __kernel_gid_r_t */
+static int groups_to_user_r(struct __kernel_uid_r __user *grouplist,
+			    const struct group_info *group_info)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	unsigned int i;
+
+	for (i = 0; i < group_info->ngroups; i++) {
+		if (put_kgid_r(user_ns, group_info->gid[i], grouplist + i))
+			return -EFAULT;
+	}
+	return 0;
+}
+
+/* group_info from a user-space array of __kernel_gid_r_t; no "no id" here */
+static int groups_from_user_r(struct group_info *group_info,
+			      const void __user *grouplist)
+{
+	const struct __kernel_uid_r __user *list = grouplist;
+	struct user_namespace *user_ns = current_user_ns();
+	struct __kernel_uid_r id;
+	unsigned int i;
+
+	for (i = 0; i < group_info->ngroups; i++) {
+		kgid_t kgid;
+
+		if (copy_from_user(&id, list + i, sizeof(id)))
+			return -EFAULT;
+		kgid = make_kgid_r(user_ns, &id);
+		if (!gid_valid(kgid))
+			return -EINVAL;
+		group_info->gid[i] = kgid;
+	}
+	return 0;
+}
+
+SYSCALL_DEFINE2(getgroups_r, int, gidsetsize,
+		struct __kernel_uid_r __user *, grouplist)
+{
+	const struct cred *cred = current_cred();
+	int i;
+
+	if (gidsetsize < 0)
+		return -EINVAL;
+
+	i = cred->group_info->ngroups;
+	if (gidsetsize) {
+		if (i > gidsetsize)
+			return -EINVAL;
+		if (groups_to_user_r(grouplist, cred->group_info))
+			return -EFAULT;
+	}
+	return i;
+}
+
+SYSCALL_DEFINE2(setgroups_r, int, gidsetsize,
+		const struct __kernel_uid_r __user *, grouplist)
+{
+	return do_setgroups(gidsetsize, grouplist, groups_from_user_r);
+}
+
 /*
  * Check whether we're fsgid/egid or in the supplemental group..
  */
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 01f14d7a4d..aa0b867925 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -113,6 +113,8 @@ COND_SYSCALL(setresgid_r);
 COND_SYSCALL(getresgid_r);
 COND_SYSCALL(setfsuid_r);
 COND_SYSCALL(setfsgid_r);
+COND_SYSCALL(setgroups_r);
+COND_SYSCALL(getgroups_r);
 COND_SYSCALL(mq_open);
 COND_SYSCALL_COMPAT(mq_open);
 COND_SYSCALL(mq_unlink);
-- 
2.56.0

