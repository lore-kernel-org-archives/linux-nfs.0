Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552619;
	b=yqb4sK5B/RsvXnltaUObQIiE6EQngNnpUnm/s057asAzjhp+wfqG8Bilfr7ddHp+cwnr
	 5PuGA1qYsAYlAz5io/ewX5AdAZmdiZ0BAPJPORsaNGVibo5Bknc7new0YC85WqOYUHytI
	 MPXC9YqDye/iTXNTD/T6WfdBzyHPB4UXhs5bFX5/MojrAdzidS19T/7icfgaG2hKzyzdZ
	 HE4c+e91LnmUfGLyBnjbI5nWQUxhz5EkG7ltJozm2pBU1BZtrUmF/UqvCbhosNSnYrMpm
	 ivheX08wS4h/hq4lSCGBbBXIB5otTWiGJaThItBWRwbrMS8t6Eu1yyOZ/FAWT9t3tNQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552619;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=DGpOL1alo4UJiM0Ho8CtIv0oQYcetUD0hsrP92D8HMc=;
	b=g4Q+BRkVtr/6f/K685XtHl2YR02ZjqlydfC5ro18BLrImIbDxnGTbRxk2sgqavQ55ydr
	 6xYgdDbPla7fh4aJnRryiAjYAYEtOsWRo1PlvHgpj1ZBf5TIJxcVo4vZIQj9GSq0+y9gy
	 IwzFtIdeY58MELZ8s5CzJSFQ1SzdnzYis4h6LVyPiaPB1biLCMAWgwipDl0Y+UW04FtzP
	 WtUFrdCGQqvcSFPbTEQXoYyCku9CbBJsWIiSHUD3q7E319gOB2mytpjDBEA1eUll9T5I6
	 r9hw1UZ+yZQuZD/kFI9nxixSTlJ1t3Arqy9Ou5U6W/BNlGOSVjTEso6+0d/5SYzwUTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=f4CKs3WW;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD928606A334;
	Wed, 21 Oct 2026 03:16:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CD928606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=f4CKs3WW
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552616; bh=VRBxDdnvXqALD2rzbv+EwPGrvd8Aj3j3z/QOZub3dbw=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=f4CKs3WWrWAUtUA2NGbEiD2VqCGTpmWPQALpTmfujgSfhuKpUZTBo5urvDI7oRumn
	 Mky25dJKdbumsGH/cp7T+CelOLAifIbww3yEbmrAAiI0K7Jf1AojXiWS2C2QLwDIYs
	 SxH6hvgRN9HhMSUrd25wHtrDnJ+9Fool/AkuT6ks/uDgdODqIarHFxad6I+dN1GZIc
	 NbBQWLvGeBUZtS0qc89wydGBQO5wRonEr8z9FtGBMLFkVlVEX85RXE7PUEbXNH6WpK
	 7VEPKSHUFDltm0Gjyk5J9RL0ebxmiZQM0aA/diF0sKnd0E3RJ2pkN9Kkb7MN4gRw4/
	 i9+KJtiNPHMwg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id D7BB48A098B;
	Wed, 21 Oct 2026 05:16:55 +0200 (CEST)
Message-ID: <ef85db692c151f13d4749f6c6f4fc7372a2ab0b4.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 28/41] net: add SO_PEERCRED_R, SO_PEERGROUPS_R and
 SCM_CREDENTIALS_R
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
Date: Wed, 21 Oct 2026 05:15:48 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Services authenticate AF_UNIX peers with SO_PEERCRED, SO_PEERGROUPS and
SCM_CREDENTIALS, which carry 32 bit ids: a UUID or GUID user shows up
as the overflow id there.

Add variants with __kernel_uid_r_t ids:

- SO_PEERCRED_R returns a struct __kernel_ucred_r of the peer,
- SO_PEERGROUPS_R its supplementary groups as __kernel_gid_r_t,
- SO_PASSCRED_R asks for SCM_CREDENTIALS_R messages, with a struct
  __kernel_ucred_r, next to or instead of SCM_CREDENTIALS (a separate
  option, so receivers sizing their control buffer for SCM_CREDENTIALS
  don't get truncated), and SCM_CREDENTIALS_R can be sent with the same
  privilege rules as SCM_CREDENTIALS.

The classic SCM_CREDENTIALS sending path now shares the checks and pid
handling with it. Netlink keeps classic ids in its skbs, so it hands out
the overflow id for UUID senders in SCM_CREDENTIALS_R too.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 arch/alpha/include/uapi/asm/socket.h  |  5 ++
 arch/mips/include/uapi/asm/socket.h   |  5 ++
 arch/parisc/include/uapi/asm/socket.h |  5 ++
 arch/sparc/include/uapi/asm/socket.h  |  5 ++
 include/linux/socket.h                |  1 +
 include/net/sock.h                    |  4 +-
 include/uapi/asm-generic/socket.h     |  5 ++
 include/uapi/linux/socket.h           |  9 +++
 net/core/scm.c                        | 94 ++++++++++++++++++---------
 net/core/sock.c                       | 84 ++++++++++++++++++++++++
 net/unix/af_unix.c                    |  3 +-
 11 files changed, 186 insertions(+), 34 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/socket.h b/arch/alpha/include/uapi/asm/socket.h
index 946a5fad26..3f1dd0e766 100644
--- a/arch/alpha/include/uapi/asm/socket.h
+++ b/arch/alpha/include/uapi/asm/socket.h
@@ -153,10 +153,15 @@
 #define SO_PASSRIGHTS		83
 
 #define SO_INQ			84
+
 #define SCM_INQ			SO_INQ
 
 #define SO_RIGHTS_NOTRUNC      85
 
+#define SO_PEERCRED_R		86
+#define SO_PEERGROUPS_R		87
+#define SO_PASSCRED_R		88
+
 #if !defined(__KERNEL__)
 
 #if __BITS_PER_LONG == 64
diff --git a/arch/mips/include/uapi/asm/socket.h b/arch/mips/include/uapi/asm/socket.h
index f1641dde13..a2bbd153a9 100644
--- a/arch/mips/include/uapi/asm/socket.h
+++ b/arch/mips/include/uapi/asm/socket.h
@@ -164,10 +164,15 @@
 #define SO_PASSRIGHTS		83
 
 #define SO_INQ			84
+
 #define SCM_INQ			SO_INQ
 
 #define SO_RIGHTS_NOTRUNC      85
 
+#define SO_PEERCRED_R		86
+#define SO_PEERGROUPS_R		87
+#define SO_PASSCRED_R		88
+
 #if !defined(__KERNEL__)
 
 #if __BITS_PER_LONG == 64
diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
index f3a3815c7d..72751399a8 100644
--- a/arch/parisc/include/uapi/asm/socket.h
+++ b/arch/parisc/include/uapi/asm/socket.h
@@ -145,10 +145,15 @@
 #define SO_PASSRIGHTS		0x4051
 
 #define SO_INQ			0x4052
+
 #define SCM_INQ			SO_INQ
 
 #define SO_RIGHTS_NOTRUNC	0x4053
 
+#define SO_PEERCRED_R		0x4054
+#define SO_PEERGROUPS_R		0x4055
+#define SO_PASSCRED_R		0x4056
+
 #if !defined(__KERNEL__)
 
 #if __BITS_PER_LONG == 64
diff --git a/arch/sparc/include/uapi/asm/socket.h b/arch/sparc/include/uapi/asm/socket.h
index 7907f3b1f0..39162ca456 100644
--- a/arch/sparc/include/uapi/asm/socket.h
+++ b/arch/sparc/include/uapi/asm/socket.h
@@ -146,10 +146,15 @@
 #define SO_PASSRIGHTS            0x005c
 
 #define SO_INQ                   0x005d
+
 #define SCM_INQ                  SO_INQ
 
 #define SO_RIGHTS_NOTRUNC        0x005e
 
+#define SO_PEERCRED_R            0x005f
+#define SO_PEERGROUPS_R          0x0060
+#define SO_PASSCRED_R            0x0061
+
 #if !defined(__KERNEL__)
 
 
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 5a5eb12501..b8e7ba6ffe 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -193,6 +193,7 @@ static inline size_t msg_data_left(const struct msghdr *msg)
 #define SCM_CREDENTIALS 0x02		/* rw: struct ucred		*/
 #define SCM_SECURITY	0x03		/* rw: security label		*/
 #define SCM_PIDFD	0x04		/* ro: pidfd (int)		*/
+#define SCM_CREDENTIALS_R 0x05		/* rw: struct __kernel_ucred_r	*/
 
 struct ucred {
 	__u32	pid;
diff --git a/include/net/sock.h b/include/net/sock.h
index 0986d94665..7055afcf0d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -358,6 +358,7 @@ struct sk_filter;
   *	@sk_scm_security: flagged by SO_PASSSEC to recv SCM_SECURITY
   *	@sk_scm_pidfd: flagged by SO_PASSPIDFD to recv SCM_PIDFD
   *	@sk_scm_rights: flagged by SO_PASSRIGHTS to recv SCM_RIGHTS
+  *	@sk_scm_credentials_r: flagged by SO_PASSCRED_R to recv SCM_CREDENTIALS_R
   *	@sk_scm_unused: unused flags for scm_recv()
   *	@ns_tracker: tracker for netns reference
   *	@sk_user_frags: xarray of pages the user is holding a reference on.
@@ -565,7 +566,8 @@ struct sock {
 				sk_scm_security : 1,
 				sk_scm_pidfd : 1,
 				sk_scm_rights : 1,
-				sk_scm_unused : 4;
+				sk_scm_credentials_r : 1,
+				sk_scm_unused : 3;
 		};
 	};
 	u8			sk_clockid;
diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index 84ea7b9293..f3445c32ca 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -148,10 +148,15 @@
 #define SO_PASSRIGHTS		83
 
 #define SO_INQ			84
+
 #define SCM_INQ			SO_INQ
 
 #define SO_RIGHTS_NOTRUNC	85
 
+#define SO_PEERCRED_R		86
+#define SO_PEERGROUPS_R		87
+#define SO_PASSCRED_R		88
+
 #if !defined(__KERNEL__)
 
 #if __BITS_PER_LONG == 64 || (defined(__x86_64__) && defined(__ILP32__))
diff --git a/include/uapi/linux/socket.h b/include/uapi/linux/socket.h
index d3fcd3b5ec..38d3cd814a 100644
--- a/include/uapi/linux/socket.h
+++ b/include/uapi/linux/socket.h
@@ -2,6 +2,8 @@
 #ifndef _UAPI_LINUX_SOCKET_H
 #define _UAPI_LINUX_SOCKET_H
 
+#include <linux/uidgid_r.h>
+
 /*
  * Desired design of maximum size and alignment (see RFC2553)
  */
@@ -35,4 +37,11 @@ struct __kernel_sockaddr_storage {
 #define SOCK_TXREHASH_DISABLED	0
 #define SOCK_TXREHASH_ENABLED	1
 
+/* SO_PEERCRED_R and SCM_CREDENTIALS_R: struct ucred with UUIDs and GUIDs */
+struct __kernel_ucred_r {
+	__u32			pid;
+	__kernel_uid_r_t	uid;
+	__kernel_gid_r_t	gid;
+};
+
 #endif /* _UAPI_LINUX_SOCKET_H */
diff --git a/net/core/scm.c b/net/core/scm.c
index f0d44ecdb1..7e40f7de12 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -40,22 +40,19 @@
 #include <net/cls_cgroup.h>
 #include <net/af_unix.h>
 
-
 /*
  *	Only allow a user to send credentials, that they could set with
  *	setu(g)id.
  */
 
-static __inline__ int scm_check_creds(struct ucred *creds)
+static int scm_check_kcreds(u32 pid, kuid_t uid, kgid_t gid)
 {
 	const struct cred *cred = current_cred();
-	kuid_t uid = make_kuid(cred->user_ns, creds->uid);
-	kgid_t gid = make_kgid(cred->user_ns, creds->gid);
 
 	if (!uid_valid(uid) || !gid_valid(gid))
 		return -EINVAL;
 
-	if ((creds->pid == task_tgid_vnr(current) ||
+	if ((pid == task_tgid_vnr(current) ||
 	     ns_capable(task_active_pid_ns(current)->user_ns, CAP_SYS_ADMIN)) &&
 	    ((uid_eq(uid, cred->uid)   || uid_eq(uid, cred->euid) ||
 	      uid_eq(uid, cred->suid)) || ns_capable(cred->user_ns, CAP_SETUID)) &&
@@ -163,6 +160,30 @@ static inline int scm_replace_pid(struct scm_cookie *scm, struct pid *pid)
 	return 0;
 }
 
+/* The sender's pid in @p is @pid, and the sender ids @uid and @gid */
+static int scm_set_creds(struct scm_cookie *p, u32 pid, kuid_t uid, kgid_t gid)
+{
+	int err;
+
+	if (!p->pid || pid_vnr(p->pid) != pid) {
+		struct pid *kpid = find_get_pid(pid);
+
+		if (!kpid)
+			return -ESRCH;
+		/* pass a struct pid reference from find_get_pid() to
+		 * scm_replace_pid().
+		 */
+		err = scm_replace_pid(p, kpid);
+		if (err) {
+			put_pid(kpid);
+			return err;
+		}
+	}
+	p->creds.uid = uid;
+	p->creds.gid = gid;
+	return 0;
+}
+
 int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 {
 	const struct proto_ops *ops = READ_ONCE(sock->ops);
@@ -203,35 +224,33 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 			if (cmsg->cmsg_len != CMSG_LEN(sizeof(struct ucred)))
 				goto error;
 			memcpy(&creds, CMSG_DATA(cmsg), sizeof(struct ucred));
-			err = scm_check_creds(&creds);
-			if (err)
-				goto error;
-
-			if (!p->pid || pid_vnr(p->pid) != creds.pid) {
-				struct pid *pid;
-				err = -ESRCH;
-				pid = find_get_pid(creds.pid);
-				if (!pid)
-					goto error;
-
-				/* pass a struct pid reference from
-				 * find_get_pid() to scm_replace_pid().
-				 */
-				err = scm_replace_pid(p, pid);
-				if (err) {
-					put_pid(pid);
-					goto error;
-				}
-			}
-
-			err = -EINVAL;
 			uid = make_kuid(current_user_ns(), creds.uid);
 			gid = make_kgid(current_user_ns(), creds.gid);
-			if (!uid_valid(uid) || !gid_valid(gid))
+			err = scm_check_kcreds(creds.pid, uid, gid);
+			if (!err)
+				err = scm_set_creds(p, creds.pid, uid, gid);
+			if (err)
 				goto error;
+			break;
+		}
+		/* SCM_CREDENTIALS with __kernel_uid_r_t ids */
+		case SCM_CREDENTIALS_R:
+		{
+			struct __kernel_ucred_r creds;
+			struct user_namespace *ns = current_user_ns();
+			kuid_t uid;
+			kgid_t gid;
 
-			p->creds.uid = uid;
-			p->creds.gid = gid;
+			if (cmsg->cmsg_len != CMSG_LEN(sizeof(creds)))
+				goto error;
+			memcpy(&creds, CMSG_DATA(cmsg), sizeof(creds));
+			uid = make_kuid_r(ns, &creds.uid);
+			gid = make_kgid_r(ns, &creds.gid);
+			err = scm_check_kcreds(creds.pid, uid, gid);
+			if (!err)
+				err = scm_set_creds(p, creds.pid, uid, gid);
+			if (err)
+				goto error;
 			break;
 		}
 		default:
@@ -526,8 +545,8 @@ static bool __scm_recv_common(struct sock *sk, struct msghdr *msg,
 			      struct scm_cookie *scm, int flags)
 {
 	if (!msg->msg_control) {
-		if (sk->sk_scm_credentials || sk->sk_scm_pidfd ||
-		    scm->fp || scm_has_secdata(sk))
+		if (sk->sk_scm_credentials || sk->sk_scm_credentials_r ||
+		    sk->sk_scm_pidfd || scm->fp || scm_has_secdata(sk))
 			msg->msg_flags |= MSG_CTRUNC;
 
 		scm_destroy(scm);
@@ -545,6 +564,17 @@ static bool __scm_recv_common(struct sock *sk, struct msghdr *msg,
 		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(ucreds), &ucreds);
 	}
 
+	if (sk->sk_scm_credentials_r) {
+		struct user_namespace *current_ns = current_user_ns();
+		struct __kernel_ucred_r ucreds;
+
+		memset(&ucreds, 0, sizeof(ucreds));
+		ucreds.pid = scm->creds.pid;
+		from_kuid_r_munged(current_ns, scm->creds.uid, &ucreds.uid);
+		from_kgid_r_munged(current_ns, scm->creds.gid, &ucreds.gid);
+		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS_R, sizeof(ucreds), &ucreds);
+	}
+
 	scm_passec(sk, msg, scm);
 
 	return true;
diff --git a/net/core/sock.c b/net/core/sock.c
index 300bc75ce1..d34da446b0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1585,6 +1585,13 @@ int sk_setsockopt(struct sock *sk, int level, int optname,
 			ret = -EOPNOTSUPP;
 		break;
 
+	case SO_PASSCRED_R:
+		if (sk_may_scm_recv(sk))
+			sk->sk_scm_credentials_r = valbool;
+		else
+			ret = -EOPNOTSUPP;
+		break;
+
 	case SO_INCOMING_CPU:
 		reuseport_update_incoming_cpu(sk, val);
 		break;
@@ -1714,6 +1721,34 @@ static void cred_to_ucred(struct pid *pid, const struct cred *cred,
 	}
 }
 
+static void cred_to_ucred_r(struct pid *pid, const struct cred *cred,
+			    struct __kernel_ucred_r *ucred)
+{
+	struct user_namespace *current_ns = current_user_ns();
+
+	memset(ucred, 0, sizeof(*ucred));
+	ucred->pid = pid_vnr(pid);
+	if (cred) {
+		from_kuid_r_munged(current_ns, cred->euid, &ucred->uid);
+		from_kgid_r_munged(current_ns, cred->egid, &ucred->gid);
+	}
+}
+
+static int groups_to_user_r(sockptr_t dst, const struct group_info *src)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	__kernel_gid_r_t gid;
+	int i;
+
+	for (i = 0; i < src->ngroups; i++) {
+		from_kgid_r_munged(user_ns, src->gid[i], &gid);
+		if (copy_to_sockptr_offset(dst, i * sizeof(gid), &gid, sizeof(gid)))
+			return -EFAULT;
+	}
+
+	return 0;
+}
+
 static int groups_to_user(sockptr_t dst, const struct group_info *src)
 {
 	struct user_namespace *user_ns = current_user_ns();
@@ -1900,6 +1935,13 @@ int sk_getsockopt(struct sock *sk, int level, int optname,
 		v.val = sk->sk_scm_rights;
 		break;
 
+	case SO_PASSCRED_R:
+		if (!sk_may_scm_recv(sk))
+			return -EOPNOTSUPP;
+
+		v.val = sk->sk_scm_credentials_r;
+		break;
+
 	case SO_PEERCRED:
 	{
 		struct ucred peercred;
@@ -1915,6 +1957,23 @@ int sk_getsockopt(struct sock *sk, int level, int optname,
 		goto lenout;
 	}
 
+	/* Like SO_PEERCRED, with uid and gid as __kernel_uid_r_t */
+	case SO_PEERCRED_R:
+	{
+		struct __kernel_ucred_r peercred;
+
+		if (len > sizeof(peercred))
+			len = sizeof(peercred);
+
+		spin_lock(&sk->sk_peer_lock);
+		cred_to_ucred_r(sk->sk_peer_pid, sk->sk_peer_cred, &peercred);
+		spin_unlock(&sk->sk_peer_lock);
+
+		if (copy_to_sockptr(optval, &peercred, len))
+			return -EFAULT;
+		goto lenout;
+	}
+
 	case SO_PEERPIDFD:
 	{
 		struct pid *peer_pid;
@@ -1980,6 +2039,31 @@ int sk_getsockopt(struct sock *sk, int level, int optname,
 		goto lenout;
 	}
 
+	/* Like SO_PEERGROUPS, with an array of __kernel_gid_r_t */
+	case SO_PEERGROUPS_R:
+	{
+		const struct cred *cred;
+		int ret, n;
+
+		cred = sk_get_peer_cred(sk);
+		if (!cred)
+			return -ENODATA;
+
+		n = cred->group_info->ngroups;
+		if (len < n * sizeof(__kernel_gid_r_t)) {
+			len = n * sizeof(__kernel_gid_r_t);
+			put_cred(cred);
+			return copy_to_sockptr(optlen, &len, sizeof(int)) ? -EFAULT : -ERANGE;
+		}
+		len = n * sizeof(__kernel_gid_r_t);
+
+		ret = groups_to_user_r(optval, cred->group_info);
+		put_cred(cred);
+		if (ret)
+			return ret;
+		goto lenout;
+	}
+
 	case SO_PEERNAME:
 	{
 		struct sockaddr_storage address;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 2b17310534..f2e1e88e83 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -803,7 +803,8 @@ static void copy_peercred(struct sock *sk, struct sock *peersk)
 
 static bool unix_may_passcred(const struct sock *sk)
 {
-	return sk->sk_scm_credentials || sk->sk_scm_pidfd;
+	return sk->sk_scm_credentials || sk->sk_scm_credentials_r ||
+	       sk->sk_scm_pidfd;
 }
 
 static int unix_listen(struct socket *sock, int backlog)
-- 
2.56.0

