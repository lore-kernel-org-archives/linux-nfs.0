Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552612;
	b=iryJg0SiY9ytDR/yLAGrgsAP6hVxo2L7bo1p67ZR5/yjuf7rmAp5iuGDhzDrtna1UX2Q
	 1i2OzO3DRCRSg1bKrrjTyCCe1UEQCaphiy2yzKa1J08vPUJVD5TDqHLGNGy+B0ZOdhw/P
	 wxjGnGtQsAqm6xpzTDqGJgaaGNdoXCdEmuonsh3CKtUpCJnZQZwEyao6fa2Tm26l9cY51
	 N22BpMv3xcr7HjjZyFyqO0nJXRaZ/cTXWK7jAfGWAU4y4vQ3mbT3buWeATHPrKY5uw5NE
	 SXUxc+HeexCMDBHEgo4o33ej2kHLl5dHG2AlB5RqyVJ2LYNxKqbq/8xcexlQOTVVj9A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552612;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=QG/YTu64g7cPU1MpTxxMQprkusMHZEfGMdzDXIiYMaI=;
	b=Fiz6qxbwmG1xCOfkyeMI6+flE/vZHh5K11vnRy0+KtQC9OYNH+jxaDehESMHfn4A2Osv
	 HbfWT6hFLtE4msxsMCaxiRo/bQpn5WZedm4em35nx8RtgWfYvNlaZaAcUCQ7/OjJaXwzF
	 5icqEz2jbRYQBjaz3VYhGyUFhvMZnWjKd6eoqj78uqwUUpGCvYmEG6Zz9HKd2nPHViBJm
	 Jl49JX3VlzSW+FL9umlAgo1iVwEwwrNEh/Ot1mS3iflVTAdmvFzLjnUoMY7waNfK2bKeq
	 +bGliKTD/O63NRrAbLwdYQk29knYK4fom6iXrLYTTK/txK6y89OXgrvd3Sh02rPxRZg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=HvLjUeDa;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3634607154C;
	Wed, 21 Oct 2026 03:16:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C3634607154C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=HvLjUeDa
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552609; bh=uKob3LFl90k+5dEZ++AozCC2j9UWbnbXt7mXPDXtlkA=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=HvLjUeDa9DC4BNLwQMhMTJob4I23X8g59hb2+YUzfv46ggABEeR1MYCXVM04+hLe9
	 4fzctKsQtYwvxl+kNsG62OyG4j6Ue65GqWYxUrSKy8c3g5QIVchJc5E0f49zDs336+
	 17NQOfsazOULvZzOBQxhYBkDWQEvKpjz/03T7KVfY66hJXZOZxUJgmE79x8ZNkPvav
	 N+69Np2MQV3n7ZN3De1imWOKUn6rtgmut5HrAR3Ha3+LjZQKPILBed8aacja5CuskI
	 kufiVhgB7Xq4zkoU+TmqIzt90I66mGtQmI8xxD3RT8RZgoX4hkOQuO6jmypzuia8bw
	 sGf4eptL931NQ==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 14F2B8A0988;
	Wed, 21 Oct 2026 05:16:49 +0200 (CEST)
Message-ID: <5e8def743ca1ecd53337d7c1ff543cab0ef9b313.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 26/41] proc: show UUID and GUID ids in status, accept
 them for loginuid
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
Date: Wed, 21 Oct 2026 05:15:46 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

/proc/<pid>/status shows ids without a 32 bit form as the overflow id.
Add Uid_r:, Gid_r: and Groups_r: lines with the same ids as text
(kuid_str()): a number, a UUID, or a GUID in braces, munged as usual
for ids the reader's user namespace can't see.

/proc/<pid>/loginuid accepts the text form of a UUID or GUID, so login
services can record such users, and shows such a loginuid as text.
Classic loginuids read and write as before, including 4294967295 for
"unset".

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/proc/array.c | 17 ++++++++++++++++-
 fs/proc/base.c  | 38 ++++++++++++++++++++++++--------------
 2 files changed, 40 insertions(+), 15 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index f6f75d2067..5b66ff32f7 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -156,6 +156,7 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 	const struct cred *cred;
 	pid_t ppid, tpid = 0, tgid, ngid;
 	unsigned int max_fds = 0;
+	char idbuf[KID_STR_LEN];
 
 	rcu_read_lock();
 	tracer = ptrace_parent(p);
@@ -200,10 +201,24 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 	for (g = 0; g < group_info->ngroups; g++)
 		seq_put_decimal_ull(m, g ? " " : "",
 				from_kgid_munged(user_ns, group_info->gid[g]));
-	put_cred(cred);
 	/* Trailing space shouldn't have been added in the first place. */
 	seq_putc(m, ' ');
 
+	/* The same ids including UUIDs and GUIDs, as kuid_str() writes them */
+	seq_printf(m, "\nUid_r:\t%s", kuid_str_munged(user_ns, cred->uid, idbuf));
+	seq_printf(m, "\t%s", kuid_str_munged(user_ns, cred->euid, idbuf));
+	seq_printf(m, "\t%s", kuid_str_munged(user_ns, cred->suid, idbuf));
+	seq_printf(m, "\t%s", kuid_str_munged(user_ns, cred->fsuid, idbuf));
+	seq_printf(m, "\nGid_r:\t%s", kgid_str_munged(user_ns, cred->gid, idbuf));
+	seq_printf(m, "\t%s", kgid_str_munged(user_ns, cred->egid, idbuf));
+	seq_printf(m, "\t%s", kgid_str_munged(user_ns, cred->sgid, idbuf));
+	seq_printf(m, "\t%s", kgid_str_munged(user_ns, cred->fsgid, idbuf));
+	seq_puts(m, "\nGroups_r:\t");
+	for (g = 0; g < group_info->ngroups; g++)
+		seq_printf(m, "%s%s", g ? " " : "",
+			   kgid_str_munged(user_ns, group_info->gid[g], idbuf));
+	put_cred(cred);
+
 #ifdef CONFIG_PID_NS
 	seq_puts(m, "\nNStgid:");
 	for (g = ns->level; g <= pid->level; g++)
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 6a39de424f..ec3147e7ab 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1290,20 +1290,26 @@ static const struct file_operations proc_oom_score_adj_operations = {
 };
 
 #ifdef CONFIG_AUDIT
-#define TMPBUFLEN 11
+#define TMPBUFLEN KID_STR_LEN
 static ssize_t proc_loginuid_read(struct file * file, char __user * buf,
 				  size_t count, loff_t *ppos)
 {
 	struct inode * inode = file_inode(file);
 	struct task_struct *task = get_proc_task(inode);
+	struct user_namespace *ns = file->f_cred->user_ns;
 	ssize_t length;
 	char tmpbuf[TMPBUFLEN];
+	kuid_t loginuid;
 
 	if (!task)
 		return -ESRCH;
-	length = scnprintf(tmpbuf, TMPBUFLEN, "%u",
-			   from_kuid(file->f_cred->user_ns,
-				     audit_get_loginuid(task)));
+	loginuid = audit_get_loginuid(task);
+	/* a UUID or GUID loginuid as text, if @ns can see it */
+	if (!uid_is_legacy(loginuid) && kuid_has_mapping(ns, loginuid))
+		length = strlen(kuid_str(loginuid, tmpbuf));
+	else
+		length = scnprintf(tmpbuf, TMPBUFLEN, "%u",
+				   from_kuid(ns, loginuid));
 	put_task_struct(task);
 	return simple_read_from_buffer(buf, count, ppos, tmpbuf, length);
 }
@@ -1312,7 +1318,7 @@ static ssize_t proc_loginuid_write(struct file * file, const char __user * buf,
 				   size_t count, loff_t *ppos)
 {
 	struct inode * inode = file_inode(file);
-	uid_t loginuid;
+	char tmpbuf[TMPBUFLEN];
 	kuid_t kloginuid;
 	int rv;
 
@@ -1332,16 +1338,20 @@ static ssize_t proc_loginuid_write(struct file * file, const char __user * buf,
 		return -EINVAL;
 	}
 
-	rv = kstrtou32_from_user(buf, count, 10, &loginuid);
-	if (rv < 0)
-		return rv;
+	/* a decimal uid, a UUID or a GUID in braces */
+	if (count >= sizeof(tmpbuf))
+		return -EINVAL;
+	if (copy_from_user(tmpbuf, buf, count))
+		return -EFAULT;
+	tmpbuf[count] = '\0';
 
-	/* is userspace tring to explicitly UNSET the loginuid? */
-	if (loginuid == AUDIT_UID_UNSET) {
-		kloginuid = INVALID_UID;
-	} else {
-		kloginuid = make_kuid(file->f_cred->user_ns, loginuid);
-		if (!uid_valid(kloginuid))
+	kloginuid = make_kuid_str(file->f_cred->user_ns, tmpbuf);
+	if (!uid_valid(kloginuid)) {
+		u32 loginuid;
+
+		/* is userspace tring to explicitly UNSET the loginuid? */
+		if (kstrtou32(tmpbuf, 10, &loginuid) ||
+		    loginuid != AUDIT_UID_UNSET)
 			return -EINVAL;
 	}
 
-- 
2.56.0

