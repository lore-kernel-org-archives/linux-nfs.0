Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552616;
	b=r3KaUMOm9zmdo8evta9gm5kRlv0KQzImqJnm5hUuiOMZxNRAiCe5jV7/nJhy6YDsZ4Vv
	 GQfIIyvtbgBjJbaWHnIv+33TX+jg7EmXUck67Ll1DkEhM+3TK0TYcbH2q6MMinweIa8Zc
	 cpVoE//I+YbpL7tkoW1D2fQtNZREOAhf+a1vaJAd6/kf+wxJs5mDSLB6uQjCwafx4rVK8
	 vEdrJeDO46JU3RaD0eu+FX1V8Zm9XHQ1rm6E7O1Tw8fhv9kqMQNPv/iGn+LHgO083F/BJ
	 H/UVhnfaSul/gPGjvQ+o6mhQB4BvB4wuyFy+wjNbMbcpf4UDSLV71qASwePyLVx3YRA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552616;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=nt7cLHURNtluowmxthejngLoiwA2fJyKtvuq7clRERg=;
	b=i95E/nxy3t+mJN9u6KRYcr1aaquLD+E8jafHfGhIRI7yQk80y5UNl6KGu8mlrKdERqc2
	 Rkkm5J0wNrDB6pSTrXevCD6GHRaSknOICjpA16I8YuWXrxgbx9BPClugOlii2HZpSzhrJ
	 lqGHJuv9xj3OJjjwTg7YEy0VzDeZL81VcaFDlcaY3G4QVfRlYDeaYmKITNiPp7S2K5YLB
	 fPTQhPmALnfTxg154TWnXVHep+Sl/DEcP8KuQ75mCfLva9wo0BRniJNUKyOqCIOe/q2ie
	 5KP+OW93p45nP82ikD2YBWgTovkn4SVQuUPJsVRjkp22+A9ln7t2WzFW2fFWN4Y3h3w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b="GcJO0/JQ";
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C19260A3828;
	Wed, 21 Oct 2026 03:16:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1C19260A3828
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=GcJO0/JQ
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552613; bh=GH5CB0HbuaUqvadscjavGQud3VU7e+MvMkrRNnhpO6g=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=GcJO0/JQrcbzRRu5HNXnLUK64YbzdNVel1wJAZ5J9U9jhxmdjqaQOaQvFprktqegE
	 76FFEgyQbMj0CXvjhvA4SKm17w6vnIpwxx9u/aFrkQwUDUo/SR5j9FFWT4Ed7fbTQg
	 awEhLlIB9kXG6nZsFuNsOvaRpPfEJFgS7MD3GamXLtOWfUgSocCyYuS9ZO85xXeYpD
	 kqNYj1NQIujn4tRpYkih8sLXiYW9T8HdcesTot6B8gFzq2X//DSKXzx+3bZBhYwv8z
	 df0LWFHtR6/B9p8t36exn/n/vD2/EwmFKYaZ7x28jtLEej3mEF28SLxTUrREHPPaaH
	 5V9yONXAqEPEw==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id A0A128A090C;
	Wed, 21 Oct 2026 05:16:52 +0200 (CEST)
Message-ID: <875406238f051dbc4b95221b301b311dc0b75f67.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 27/41] audit: log UUID and GUID ids in full
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
Date: Wed, 21 Oct 2026 05:15:47 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Audit records print ids with from_kuid(&init_user_ns, ...), which gives
-1 for a UUID or GUID. 4294967295 is what audit uses for "unset", so a
UUID user's actions would be logged as if there were no login user.

Print all ids in audit records with KUID_STR()/KGID_STR(): classic ids
come out exactly as before (signed where the format was "%d"), UUIDs and
GUIDs in their text form. The binary AUDIT_SIGNAL_INFO reply keeps its
32 bit field.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 drivers/tty/tty_audit.c              |  7 ++--
 kernel/audit.c                       | 50 ++++++++++++-------------
 kernel/auditsc.c                     | 55 ++++++++++++++--------------
 net/core/dev.c                       |  8 ++--
 net/netlabel/netlabel_user.c         |  4 +-
 security/apparmor/file.c             |  8 ++--
 security/integrity/integrity_audit.c |  6 +--
 security/ipe/audit.c                 | 12 +++---
 security/selinux/selinuxfs.c         |  8 ++--
 security/selinux/ss/services.c       |  4 +-
 10 files changed, 78 insertions(+), 84 deletions(-)

diff --git a/drivers/tty/tty_audit.c b/drivers/tty/tty_audit.c
index d014af6ab0..03ad4961b8 100644
--- a/drivers/tty/tty_audit.c
+++ b/drivers/tty/tty_audit.c
@@ -65,8 +65,6 @@ static void tty_audit_log(const char *description, dev_t dev,
 {
 	struct audit_buffer *ab;
 	pid_t pid = task_pid_nr(current);
-	uid_t uid = from_kuid(&init_user_ns, task_uid(current));
-	uid_t loginuid = from_kuid(&init_user_ns, audit_get_loginuid(current));
 	unsigned int sessionid = audit_get_sessionid(current);
 	char name[TASK_COMM_LEN];
 
@@ -74,8 +72,9 @@ static void tty_audit_log(const char *description, dev_t dev,
 	if (!ab)
 		return;
 
-	audit_log_format(ab, "%s pid=%u uid=%u auid=%u ses=%u major=%d minor=%d comm=",
-			 description, pid, uid, loginuid, sessionid,
+	audit_log_format(ab, "%s pid=%u uid=%s auid=%s ses=%u major=%d minor=%d comm=",
+			 description, pid, KUID_STR(task_uid(current)),
+			 KUID_STR(audit_get_loginuid(current)), sessionid,
 			 MAJOR(dev), MINOR(dev));
 	get_task_comm(name, current);
 	audit_log_untrustedstring(ab, name);
diff --git a/kernel/audit.c b/kernel/audit.c
index 9412af9144..ed4ac5c88d 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1128,7 +1128,6 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 static void audit_log_common_recv_msg(struct audit_context *context,
 					struct audit_buffer **ab, u16 msg_type)
 {
-	uid_t uid = from_kuid(&init_user_ns, current_uid());
 	pid_t pid = task_tgid_nr(current);
 
 	if (!audit_enabled && msg_type != AUDIT_USER_AVC) {
@@ -1139,7 +1138,7 @@ static void audit_log_common_recv_msg(struct audit_context *context,
 	*ab = audit_log_start(context, GFP_KERNEL, msg_type);
 	if (unlikely(!*ab))
 		return;
-	audit_log_format(*ab, "pid=%d uid=%u ", pid, uid);
+	audit_log_format(*ab, "pid=%d uid=%s ", pid, KUID_STR(current_uid()));
 	audit_log_session_info(*ab);
 	audit_log_task_context(*ab);
 }
@@ -1658,10 +1657,10 @@ static void audit_log_multicast(int group, const char *op, int err)
 
 	cred = current_cred();
 	tty = audit_get_tty();
-	audit_log_format(ab, "pid=%u uid=%u auid=%u tty=%s ses=%u",
+	audit_log_format(ab, "pid=%u uid=%s auid=%s tty=%s ses=%u",
 			 task_tgid_nr(current),
-			 from_kuid(&init_user_ns, cred->uid),
-			 from_kuid(&init_user_ns, audit_get_loginuid(current)),
+			 KUID_STR(cred->uid),
+			 KUID_STR(audit_get_loginuid(current)),
 			 tty ? tty_name(tty) : "(none)",
 			 audit_get_sessionid(current));
 	audit_put_tty(tty);
@@ -2230,9 +2229,8 @@ void audit_log_d_path(struct audit_buffer *ab, const char *prefix,
 void audit_log_session_info(struct audit_buffer *ab)
 {
 	unsigned int sessionid = audit_get_sessionid(current);
-	uid_t auid = from_kuid(&init_user_ns, audit_get_loginuid(current));
-
-	audit_log_format(ab, "auid=%u ses=%u", auid, sessionid);
+	audit_log_format(ab, "auid=%s ses=%u",
+			 KUID_STR(audit_get_loginuid(current)), sessionid);
 }
 
 void audit_log_key(struct audit_buffer *ab, char *key)
@@ -2465,20 +2463,20 @@ void audit_log_task_info(struct audit_buffer *ab)
 	cred = current_cred();
 	tty = audit_get_tty();
 	audit_log_format(ab,
-			 " ppid=%d pid=%d auid=%u uid=%u gid=%u"
-			 " euid=%u suid=%u fsuid=%u"
-			 " egid=%u sgid=%u fsgid=%u tty=%s ses=%u",
+			 " ppid=%d pid=%d auid=%s uid=%s gid=%s"
+			 " euid=%s suid=%s fsuid=%s"
+			 " egid=%s sgid=%s fsgid=%s tty=%s ses=%u",
 			 task_ppid_nr(current),
 			 task_tgid_nr(current),
-			 from_kuid(&init_user_ns, audit_get_loginuid(current)),
-			 from_kuid(&init_user_ns, cred->uid),
-			 from_kgid(&init_user_ns, cred->gid),
-			 from_kuid(&init_user_ns, cred->euid),
-			 from_kuid(&init_user_ns, cred->suid),
-			 from_kuid(&init_user_ns, cred->fsuid),
-			 from_kgid(&init_user_ns, cred->egid),
-			 from_kgid(&init_user_ns, cred->sgid),
-			 from_kgid(&init_user_ns, cred->fsgid),
+			 KUID_STR(audit_get_loginuid(current)),
+			 KUID_STR(cred->uid),
+			 KGID_STR(cred->gid),
+			 KUID_STR(cred->euid),
+			 KUID_STR(cred->suid),
+			 KUID_STR(cred->fsuid),
+			 KGID_STR(cred->egid),
+			 KGID_STR(cred->sgid),
+			 KGID_STR(cred->fsgid),
 			 tty ? tty_name(tty) : "(none)",
 			 audit_get_sessionid(current));
 	audit_put_tty(tty);
@@ -2693,7 +2691,6 @@ static void audit_log_set_loginuid(kuid_t koldloginuid, kuid_t kloginuid,
 				   unsigned int sessionid, int rc)
 {
 	struct audit_buffer *ab;
-	uid_t uid, oldloginuid, loginuid;
 	struct tty_struct *tty;
 
 	if (!audit_enabled)
@@ -2703,15 +2700,14 @@ static void audit_log_set_loginuid(kuid_t koldloginuid, kuid_t kloginuid,
 	if (!ab)
 		return;
 
-	uid = from_kuid(&init_user_ns, task_uid(current));
-	oldloginuid = from_kuid(&init_user_ns, koldloginuid);
-	loginuid = from_kuid(&init_user_ns, kloginuid);
 	tty = audit_get_tty();
 
-	audit_log_format(ab, "pid=%d uid=%u", task_tgid_nr(current), uid);
+	audit_log_format(ab, "pid=%d uid=%s", task_tgid_nr(current),
+			 KUID_STR(task_uid(current)));
 	audit_log_task_context(ab);
-	audit_log_format(ab, " old-auid=%u auid=%u tty=%s old-ses=%u ses=%u res=%d",
-			 oldloginuid, loginuid, tty ? tty_name(tty) : "(none)",
+	audit_log_format(ab, " old-auid=%s auid=%s tty=%s old-ses=%u ses=%u res=%d",
+			 KUID_STR(koldloginuid), KUID_STR(kloginuid),
+			 tty ? tty_name(tty) : "(none)",
 			 oldsessionid, sessionid, !rc);
 	audit_put_tty(tty);
 	audit_log_end(ab);
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 2b9ce0b525..08d8f5af46 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1104,9 +1104,9 @@ static int audit_log_pid_context(struct audit_context *context, pid_t pid,
 	if (!ab)
 		return rc;
 
-	audit_log_format(ab, "opid=%d oauid=%d ouid=%d oses=%d", pid,
-			 from_kuid(&init_user_ns, auid),
-			 from_kuid(&init_user_ns, uid), sessionid);
+	audit_log_format(ab, "opid=%d oauid=%s ouid=%s oses=%d", pid,
+			 KUID_STR_D(auid),
+			 KUID_STR_D(uid), sessionid);
 	if (lsmprop_is_set(prop) && audit_log_obj_ctx(ab, prop))
 		rc = 1;
 
@@ -1309,9 +1309,9 @@ static void audit_log_fcaps(struct audit_buffer *ab, struct audit_names *name)
 	}
 	audit_log_cap(ab, "cap_fp", &name->fcap.permitted);
 	audit_log_cap(ab, "cap_fi", &name->fcap.inheritable);
-	audit_log_format(ab, " cap_fe=%d cap_fver=%x cap_frootid=%d",
+	audit_log_format(ab, " cap_fe=%d cap_fver=%x cap_frootid=%s",
 			 name->fcap.fE, name->fcap_ver,
-			 from_kuid(&init_user_ns, name->fcap.rootid));
+			 KUID_STR_D(name->fcap.rootid));
 }
 
 static void audit_log_time(struct audit_context *context, struct audit_buffer **ab)
@@ -1380,9 +1380,9 @@ static void show_special(struct audit_context *context, int *call_panic)
 				context->socketcall.args[i]);
 		break; }
 	case AUDIT_IPC:
-		audit_log_format(ab, "ouid=%u ogid=%u mode=%#ho",
-				 from_kuid(&init_user_ns, context->ipc.uid),
-				 from_kgid(&init_user_ns, context->ipc.gid),
+		audit_log_format(ab, "ouid=%s ogid=%s mode=%#ho",
+				 KUID_STR(context->ipc.uid),
+				 KGID_STR(context->ipc.gid),
 				 context->ipc.mode);
 		if (lsmprop_is_set(&context->ipc.oprop)) {
 			if (audit_log_obj_ctx(ab, &context->ipc.oprop))
@@ -1534,13 +1534,13 @@ static void audit_log_name(struct audit_context *context, struct audit_names *n,
 		audit_log_format(ab, " name=(null)");
 
 	if (n->ino != AUDIT_INO_UNSET)
-		audit_log_format(ab, " inode=%llu dev=%02x:%02x mode=%#ho ouid=%u ogid=%u rdev=%02x:%02x",
+		audit_log_format(ab, " inode=%llu dev=%02x:%02x mode=%#ho ouid=%s ogid=%s rdev=%02x:%02x",
 				 n->ino,
 				 MAJOR(n->dev),
 				 MINOR(n->dev),
 				 n->mode,
-				 from_kuid(&init_user_ns, n->uid),
-				 from_kgid(&init_user_ns, n->gid),
+				 KUID_STR(n->uid),
+				 KGID_STR(n->gid),
 				 MAJOR(n->rdev),
 				 MINOR(n->rdev));
 	if (lsmprop_is_set(&n->oprop) &&
@@ -1632,18 +1632,18 @@ static void audit_log_uring(struct audit_context *ctx)
 				 ctx->return_code);
 	audit_log_format(ab,
 			 " items=%d"
-			 " ppid=%d pid=%d uid=%u gid=%u euid=%u suid=%u"
-			 " fsuid=%u egid=%u sgid=%u fsgid=%u",
+			 " ppid=%d pid=%d uid=%s gid=%s euid=%s suid=%s"
+			 " fsuid=%s egid=%s sgid=%s fsgid=%s",
 			 ctx->name_count,
 			 task_ppid_nr(current), task_tgid_nr(current),
-			 from_kuid(&init_user_ns, cred->uid),
-			 from_kgid(&init_user_ns, cred->gid),
-			 from_kuid(&init_user_ns, cred->euid),
-			 from_kuid(&init_user_ns, cred->suid),
-			 from_kuid(&init_user_ns, cred->fsuid),
-			 from_kgid(&init_user_ns, cred->egid),
-			 from_kgid(&init_user_ns, cred->sgid),
-			 from_kgid(&init_user_ns, cred->fsgid));
+			 KUID_STR(cred->uid),
+			 KGID_STR(cred->gid),
+			 KUID_STR(cred->euid),
+			 KUID_STR(cred->suid),
+			 KUID_STR(cred->fsuid),
+			 KGID_STR(cred->egid),
+			 KGID_STR(cred->sgid),
+			 KGID_STR(cred->fsgid));
 	audit_log_task_context(ab);
 	audit_log_key(ab, ctx->filterkey);
 	audit_log_end(ab);
@@ -1715,9 +1715,8 @@ static void audit_log_exit(void)
 			audit_log_cap(ab, "pi", &axs->new_pcap.inheritable);
 			audit_log_cap(ab, "pe", &axs->new_pcap.effective);
 			audit_log_cap(ab, "pa", &axs->new_pcap.ambient);
-			audit_log_format(ab, " frootid=%d",
-					 from_kuid(&init_user_ns,
-						   axs->fcap.rootid));
+			audit_log_format(ab, " frootid=%s",
+					 KUID_STR_D(axs->fcap.rootid));
 			break; }
 
 		}
@@ -2894,10 +2893,10 @@ static void audit_log_task(struct audit_buffer *ab)
 	sessionid = audit_get_sessionid(current);
 	current_uid_gid(&uid, &gid);
 
-	audit_log_format(ab, "auid=%u uid=%u gid=%u ses=%u",
-			 from_kuid(&init_user_ns, auid),
-			 from_kuid(&init_user_ns, uid),
-			 from_kgid(&init_user_ns, gid),
+	audit_log_format(ab, "auid=%s uid=%s gid=%s ses=%u",
+			 KUID_STR(auid),
+			 KUID_STR(uid),
+			 KGID_STR(gid),
 			 sessionid);
 	audit_log_task_context(ab);
 	audit_log_format(ab, " pid=%d comm=", task_tgid_nr(current));
diff --git a/net/core/dev.c b/net/core/dev.c
index e76762e293..a726352114 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -9718,12 +9718,12 @@ int __dev_set_promiscuity(struct net_device *dev, int inc, bool notify)
 			current_uid_gid(&uid, &gid);
 			audit_log(audit_context(), GFP_ATOMIC,
 				  AUDIT_ANOM_PROMISCUOUS,
-				  "dev=%s prom=%d old_prom=%d auid=%u uid=%u gid=%u ses=%u",
+				  "dev=%s prom=%d old_prom=%d auid=%s uid=%s gid=%s ses=%u",
 				  dev->name, (dev->flags & IFF_PROMISC),
 				  (old_flags & IFF_PROMISC),
-				  from_kuid(&init_user_ns, audit_get_loginuid(current)),
-				  from_kuid(&init_user_ns, uid),
-				  from_kgid(&init_user_ns, gid),
+				  KUID_STR(audit_get_loginuid(current)),
+				  KUID_STR(uid),
+				  KGID_STR(gid),
 				  audit_get_sessionid(current));
 		}
 
diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index 0da652844d..31ac4a0fcb 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -92,8 +92,8 @@ struct audit_buffer *netlbl_audit_start_common(int type,
 	if (audit_buf == NULL)
 		return NULL;
 
-	audit_log_format(audit_buf, "netlabel: auid=%u ses=%u",
-			 from_kuid(&init_user_ns, audit_info->loginuid),
+	audit_log_format(audit_buf, "netlabel: auid=%s ses=%u",
+			 KUID_STR(audit_info->loginuid),
 			 audit_info->sessionid);
 	audit_log_subj_ctx(audit_buf, &audit_info->prop);
 
diff --git a/security/apparmor/file.c b/security/apparmor/file.c
index 3e74b613db..74a168edae 100644
--- a/security/apparmor/file.c
+++ b/security/apparmor/file.c
@@ -60,10 +60,10 @@ static void file_audit_cb(struct audit_buffer *ab, void *va)
 		audit_log_format(ab, " denied_mask=\"%s\"", str);
 	}
 	if (ad->request & AA_AUDIT_FILE_MASK) {
-		audit_log_format(ab, " fsuid=%d",
-				 from_kuid(&init_user_ns, fsuid));
-		audit_log_format(ab, " ouid=%d",
-				 from_kuid(&init_user_ns, ad->fs.ouid));
+		audit_log_format(ab, " fsuid=%s",
+				 KUID_STR_D(fsuid));
+		audit_log_format(ab, " ouid=%s",
+				 KUID_STR_D(ad->fs.ouid));
 	}
 
 	if (ad->peer) {
diff --git a/security/integrity/integrity_audit.c b/security/integrity/integrity_audit.c
index d8d9e5ff1c..cc4959182a 100644
--- a/security/integrity/integrity_audit.c
+++ b/security/integrity/integrity_audit.c
@@ -47,10 +47,10 @@ void integrity_audit_message(int audit_msgno, struct inode *inode,
 	ab = audit_log_start(audit_context(), GFP_KERNEL, audit_msgno);
 	if (!ab)
 		return;
-	audit_log_format(ab, "pid=%d uid=%u auid=%u ses=%u",
+	audit_log_format(ab, "pid=%d uid=%s auid=%s ses=%u",
 			 task_pid_nr(current),
-			 from_kuid(&init_user_ns, current_uid()),
-			 from_kuid(&init_user_ns, audit_get_loginuid(current)),
+			 KUID_STR(current_uid()),
+			 KUID_STR(audit_get_loginuid(current)),
 			 audit_get_sessionid(current));
 	audit_log_task_context(ab);
 	audit_log_format(ab, " op=%s cause=%s comm=", op, cause);
diff --git a/security/ipe/audit.c b/security/ipe/audit.c
index 93fb59fbdd..ace64cf218 100644
--- a/security/ipe/audit.c
+++ b/security/ipe/audit.c
@@ -220,8 +220,8 @@ void ipe_audit_policy_activation(const struct ipe_policy *const op,
 		audit_log_format(ab, " ");
 	}
 	audit_policy(ab, AUDIT_NEW_ACTIVE_POLICY_FMT, np);
-	audit_log_format(ab, " auid=%u ses=%u lsm=ipe res=1",
-			 from_kuid(&init_user_ns, audit_get_loginuid(current)),
+	audit_log_format(ab, " auid=%s ses=%u lsm=ipe res=1",
+			 KUID_STR(audit_get_loginuid(current)),
 			 audit_get_sessionid(current));
 
 	audit_log_end(ab);
@@ -248,8 +248,8 @@ void ipe_audit_policy_load(const struct ipe_policy *const p)
 		err = PTR_ERR(p);
 	}
 
-	audit_log_format(ab, " auid=%u ses=%u lsm=ipe res=%d errno=%d",
-			 from_kuid(&init_user_ns, audit_get_loginuid(current)),
+	audit_log_format(ab, " auid=%s ses=%u lsm=ipe res=%d errno=%d",
+			 KUID_STR(audit_get_loginuid(current)),
 			 audit_get_sessionid(current), !err, err);
 
 	audit_log_end(ab);
@@ -269,10 +269,10 @@ void ipe_audit_enforce(bool new_enforce, bool old_enforce)
 		return;
 
 	audit_log(audit_context(), GFP_KERNEL, AUDIT_MAC_STATUS,
-		  "enforcing=%d old_enforcing=%d auid=%u ses=%u"
+		  "enforcing=%d old_enforcing=%d auid=%s ses=%u"
 		  " enabled=1 old-enabled=1 lsm=ipe res=1",
 		  new_enforce, old_enforce,
-		  from_kuid(&init_user_ns, audit_get_loginuid(current)),
+		  KUID_STR(audit_get_loginuid(current)),
 		  audit_get_sessionid(current));
 
 	audit_log_end(ab);
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index c7d9147697..7db30ead97 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -163,10 +163,10 @@ static ssize_t sel_write_enforce(struct file *file, const char __user *buf,
 		if (length)
 			goto out;
 		audit_log(audit_context(), GFP_KERNEL, AUDIT_MAC_STATUS,
-			"enforcing=%d old_enforcing=%d auid=%u ses=%u"
+			"enforcing=%d old_enforcing=%d auid=%s ses=%u"
 			" enabled=1 old-enabled=1 lsm=selinux res=1",
 			new_value, old_value,
-			from_kuid(&init_user_ns, audit_get_loginuid(current)),
+			KUID_STR(audit_get_loginuid(current)),
 			audit_get_sessionid(current));
 		enforcing_set(new_value);
 		if (new_value)
@@ -581,8 +581,8 @@ static ssize_t sel_write_load(struct file *file, const char __user *buf,
 	selinux_policy_commit(&load_state);
 	length = count;
 	audit_log(audit_context(), GFP_KERNEL, AUDIT_MAC_POLICY_LOAD,
-		"auid=%u ses=%u lsm=selinux res=1",
-		from_kuid(&init_user_ns, audit_get_loginuid(current)),
+		"auid=%s ses=%u lsm=selinux res=1",
+		KUID_STR(audit_get_loginuid(current)),
 		audit_get_sessionid(current));
 
 out_unlock:
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index da77ad769c..dd42142e20 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -3012,11 +3012,11 @@ int security_set_bools(u32 len, const int *values)
 		if (new_state != old_state) {
 			audit_log(audit_context(), GFP_ATOMIC,
 				AUDIT_MAC_CONFIG_CHANGE,
-				"bool=%s val=%d old_val=%d auid=%u ses=%u",
+				"bool=%s val=%d old_val=%d auid=%s ses=%u",
 				sym_name(&newpolicy->policydb, SYM_BOOLS, i),
 				new_state,
 				old_state,
-				from_kuid(&init_user_ns, audit_get_loginuid(current)),
+				KUID_STR(audit_get_loginuid(current)),
 				audit_get_sessionid(current));
 			newpolicy->policydb.bool_val_to_struct[i]->state = new_state;
 		}
-- 
2.56.0

