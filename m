Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552626;
	b=dUzqwv4EGp87HrBPFsc7x1SRge8BDwRLvNyskpKmmdm/ERd1qxVJuPbibxoYvbSn4GN9
	 m1WxLBcUNqE8viYlqfdVc6TG8b3lqY+tXmbPeD9tasVCMnAZSCrmXk8tAPSzvRXvZfOFU
	 IDSuutJnzaFSNjKyrrJtsfaesk6+A6Q9kkVFNDMgp/tKFRmxHlimgJZxFBV2m2+AOogvj
	 8eGxCTUwRnEaq8ZOMbJVjjdpl9i0qdoLaYdd0qBBE6z7pmNznJHukTHiUt6F5zdGllIgu
	 fuUS7Cls57wVo31+xGO6okGmAxiqleFC56v3YxLrPNINo4waNkk081zeNCnpHJu4FBg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552626;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=xPPuSjLhDbMViYqpEHpt4dnNVDTdoh5q6lqQYXei5pA=;
	b=CVfys4/AvH9+AelNGIOEupJoRwXW4NrB54AskXcZkiaYPTpdYaKpzyZ6sV8VgByR7fis
	 FyX5nZnybT4fwr8n8rV2v9L8/Ui4BYQ/uYT3bOk4RpJ8NKUYNxeH5qfYeg7mI2fUv7Jog
	 3/Qr1wQEWTuesearNXiuJ50Fm+PFg2+kFjZg1plYmgQTVjZY6UcUoPKz0iSoXSgdEn2PV
	 whqSdfZBeVCOLLNgmXISpmqk1cJX7Jh110mQj3l7uRz8OKohVO1Y/DNQFBiabRdaOtX4H
	 sKouaUM3E/wztBkLPrcmmNCocs2bvZKq0pAzaortdYLJ5QxXU6wNPHwlkz+9AJrBUAQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=l6sqAx24;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE3256074AF1;
	Wed, 21 Oct 2026 03:17:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DE3256074AF1
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=l6sqAx24
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552623; bh=7OhuYr1jzT08GfwqsT/yDIHMI0ebaXemXLD2jKJdeak=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=l6sqAx24f32iFDvNQPYmCz2mQIork2CZho4QaX7n4duiJm715lhI3Hl0W1nvJIYDv
	 AVQWyb0V6WKgAm3CYTdY1Z1aXftHAxnwKahEkibu627MXgGu7fG1F5yESuDetRxXWP
	 TpndRpd6PjP3HjXXz24bsk7FI83JMlw+lrUaUQj9+f1HAuNvcivO270Z1COlxj2Q70
	 TPFi2s4yHDpkEyEDkgaocDWQrbL/pyurE9jFfqNjU2zg6TqFNcRGyrMxveCwdx7v1t
	 KFn2xp0OIhZOarnx/1nxNeYc3c2hNrzKi7GCbEOV5FSzGZaW/BGgWLgrtIgsSo/yc+
	 zMbdRey63iHAg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 24F018A07DE;
	Wed, 21 Oct 2026 05:17:03 +0200 (CEST)
Message-ID: <b086aef70fd4516d33c535b4ea3d5d6f204c0af7.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 30/41] ipc: add IPC_STAT_R and IPC_SET_R
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
Date: Wed, 21 Oct 2026 05:15:50 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

The ids of SysV message queues, semaphore sets and shared memory
segments reach userspace in struct ipc64_perm, 32 bits each, so a UUID
or GUID owner shows up as the overflow id and can't be set at all.

Rather than doubling every *id64_ds, add two commands shared by
msgctl(), semctl() and shmctl() that work on a struct ipc_perm_r with
key, mode, and uid, gid, cuid and cgid as __kernel_uid_r_t:

- IPC_STAT_R reads it, with the permission checks of IPC_STAT,
- IPC_SET_R sets uid, gid and mode like IPC_SET does (a message queue
  keeps its size).

The IPC_SET path now works on the kernel ids of a struct ipc_set_ids,
which the classic command fills from its ipc64_perm. The audit record
of IPC_SET has the new owner as a kuid as well and logs it like the
other audit ids, in the initial user namespace.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/linux/audit.h    |   8 +--
 include/uapi/linux/ipc.h |  17 ++++++
 ipc/msg.c                |  40 ++++++++++----
 ipc/sem.c                |  31 ++++++++---
 ipc/shm.c                |  32 ++++++++---
 ipc/util.c               | 112 +++++++++++++++++++++++++++++++++++----
 ipc/util.h               |  23 +++++++-
 kernel/audit.h           |   4 +-
 kernel/auditsc.c         |   8 +--
 9 files changed, 226 insertions(+), 49 deletions(-)

diff --git a/include/linux/audit.h b/include/linux/audit.h
index 45abb3722d..a769f04e45 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -428,7 +428,7 @@ static inline void audit_ptrace(struct task_struct *t)
 
 				/* Private API (for audit.c only) */
 extern void __audit_ipc_obj(struct kern_ipc_perm *ipcp);
-extern void __audit_ipc_set_perm(unsigned long qbytes, uid_t uid, gid_t gid, umode_t mode);
+extern void __audit_ipc_set_perm(unsigned long qbytes, kuid_t uid, kgid_t gid, umode_t mode);
 extern void __audit_bprm(struct linux_binprm *bprm);
 extern int __audit_socketcall(int nargs, unsigned long *args);
 extern int __audit_sockaddr(int len, void *addr);
@@ -460,7 +460,7 @@ static inline void audit_fd_pair(int fd1, int fd2)
 	if (unlikely(!audit_dummy_context()))
 		__audit_fd_pair(fd1, fd2);
 }
-static inline void audit_ipc_set_perm(unsigned long qbytes, uid_t uid, gid_t gid, umode_t mode)
+static inline void audit_ipc_set_perm(unsigned long qbytes, kuid_t uid, kgid_t gid, umode_t mode)
 {
 	if (unlikely(!audit_dummy_context()))
 		__audit_ipc_set_perm(qbytes, uid, gid, mode);
@@ -652,8 +652,8 @@ static inline void audit_seccomp_actions_logged(const char *names,
 { }
 static inline void audit_ipc_obj(struct kern_ipc_perm *ipcp)
 { }
-static inline void audit_ipc_set_perm(unsigned long qbytes, uid_t uid,
-					gid_t gid, umode_t mode)
+static inline void audit_ipc_set_perm(unsigned long qbytes, kuid_t uid,
+					kgid_t gid, umode_t mode)
 { }
 static inline void audit_bprm(struct linux_binprm *bprm)
 { }
diff --git a/include/uapi/linux/ipc.h b/include/uapi/linux/ipc.h
index 5995fc9d67..e927564fbb 100644
--- a/include/uapi/linux/ipc.h
+++ b/include/uapi/linux/ipc.h
@@ -3,6 +3,7 @@
 #define _UAPI_LINUX_IPC_H
 
 #include <linux/types.h>
+#include <linux/uidgid_r.h>
 
 #define IPC_PRIVATE ((__kernel_key_t) 0)  
 
@@ -40,6 +41,22 @@ struct ipc_perm
 #define IPC_SET  1     /* set ipc_perm options */
 #define IPC_STAT 2     /* get ipc_perm options */
 #define IPC_INFO 3     /* see ipcs */
+#define IPC_SET_R  21  /* set uid, gid and mode from struct ipc_perm_r */
+#define IPC_STAT_R 22  /* get struct ipc_perm_r */
+
+/*
+ * The ids and mode of an ipc object for IPC_STAT_R and IPC_SET_R, which
+ * also hold UUIDs and GUIDs; IPC_SET_R uses uid, gid and mode. The other
+ * attributes of the object come from IPC_STAT.
+ */
+struct ipc_perm_r {
+	__kernel_key_t		key;
+	__u32			mode;
+	__kernel_uid_r_t	uid;
+	__kernel_gid_r_t	gid;
+	__kernel_uid_r_t	cuid;
+	__kernel_gid_r_t	cgid;
+};
 
 /*
  * Version flags for semctl, msgctl, and shmctl commands
diff --git a/ipc/msg.c b/ipc/msg.c
index 62996b97f0..a3f5287e54 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -398,8 +398,10 @@ copy_msqid_from_user(struct msqid64_ds *out, void __user *buf, int version)
  * to be held in write mode.
  * NOTE: no locks must be held, the rwsem is taken inside this function.
  */
+/* IPC_SET_R is IPC_SET without a new queue size */
 static int msgctl_down(struct ipc_namespace *ns, int msqid, int cmd,
-			struct ipc64_perm *perm, int msg_qbytes)
+			const struct ipc_set_ids *set, int msg_qbytes,
+			bool set_qbytes)
 {
 	struct kern_ipc_perm *ipcp;
 	struct msg_queue *msq;
@@ -409,7 +411,7 @@ static int msgctl_down(struct ipc_namespace *ns, int msqid, int cmd,
 	rcu_read_lock();
 
 	ipcp = ipcctl_obtain_check(ns, &msg_ids(ns), msqid, cmd,
-				      perm, msg_qbytes);
+				      set, msg_qbytes);
 	if (IS_ERR(ipcp)) {
 		err = PTR_ERR(ipcp);
 		goto out_unlock1;
@@ -431,18 +433,19 @@ static int msgctl_down(struct ipc_namespace *ns, int msqid, int cmd,
 	{
 		DEFINE_WAKE_Q(wake_q);
 
-		if (msg_qbytes > ns->msg_ctlmnb &&
+		if (set_qbytes && msg_qbytes > ns->msg_ctlmnb &&
 		    !capable(CAP_SYS_RESOURCE)) {
 			err = -EPERM;
 			goto out_unlock1;
 		}
 
 		ipc_lock_object(&msq->q_perm);
-		err = ipc_update_perm(perm, ipcp);
+		err = ipc_update_perm(set, ipcp);
 		if (err)
 			goto out_unlock0;
 
-		msq->q_qbytes = msg_qbytes;
+		if (set_qbytes)
+			msq->q_qbytes = msg_qbytes;
 
 		msq->q_ctime = ktime_get_real_seconds();
 		/*
@@ -598,6 +601,7 @@ static long ksys_msgctl(int msqid, int cmd, struct msqid_ds __user *buf, int ver
 {
 	struct ipc_namespace *ns;
 	struct msqid64_ds msqid64;
+	struct ipc_set_ids set;
 	int err;
 
 	if (msqid < 0 || cmd < 0)
@@ -628,10 +632,17 @@ static long ksys_msgctl(int msqid, int cmd, struct msqid_ds __user *buf, int ver
 	case IPC_SET:
 		if (copy_msqid_from_user(&msqid64, buf, version))
 			return -EFAULT;
-		return msgctl_down(ns, msqid, cmd, &msqid64.msg_perm,
-				   msqid64.msg_qbytes);
+		ipc64_perm_to_set_ids(&msqid64.msg_perm, &set);
+		return msgctl_down(ns, msqid, cmd, &set, msqid64.msg_qbytes, true);
+	case IPC_SET_R:
+		if (ipc_perm_r_to_set_ids((void __user *)buf, &set))
+			return -EFAULT;
+		return msgctl_down(ns, msqid, IPC_SET, &set, 0, false);
+	case IPC_STAT_R:
+		return ipc_stat_r(ns, &msg_ids(ns), msqid,
+				  security_msg_queue_msgctl, (void __user *)buf);
 	case IPC_RMID:
-		return msgctl_down(ns, msqid, cmd, NULL, 0);
+		return msgctl_down(ns, msqid, cmd, NULL, 0, false);
 	default:
 		return  -EINVAL;
 	}
@@ -734,6 +745,7 @@ static long compat_ksys_msgctl(int msqid, int cmd, void __user *uptr, int versio
 	struct ipc_namespace *ns;
 	int err;
 	struct msqid64_ds msqid64;
+	struct ipc_set_ids set;
 
 	ns = current->nsproxy->ipc_ns;
 
@@ -763,9 +775,17 @@ static long compat_ksys_msgctl(int msqid, int cmd, void __user *uptr, int versio
 	case IPC_SET:
 		if (copy_compat_msqid_from_user(&msqid64, uptr, version))
 			return -EFAULT;
-		return msgctl_down(ns, msqid, cmd, &msqid64.msg_perm, msqid64.msg_qbytes);
+		ipc64_perm_to_set_ids(&msqid64.msg_perm, &set);
+		return msgctl_down(ns, msqid, cmd, &set, msqid64.msg_qbytes, true);
+	case IPC_SET_R:
+		if (ipc_perm_r_to_set_ids(uptr, &set))
+			return -EFAULT;
+		return msgctl_down(ns, msqid, IPC_SET, &set, 0, false);
+	case IPC_STAT_R:
+		return ipc_stat_r(ns, &msg_ids(ns), msqid,
+				  security_msg_queue_msgctl, uptr);
 	case IPC_RMID:
-		return msgctl_down(ns, msqid, cmd, NULL, 0);
+		return msgctl_down(ns, msqid, cmd, NULL, 0, false);
 	default:
 		return -EINVAL;
 	}
diff --git a/ipc/sem.c b/ipc/sem.c
index 5ec41de7e8..ab456991e4 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -1599,7 +1599,7 @@ copy_semid_from_user(struct semid64_ds *out, void __user *buf, int version)
  * NOTE: no locks must be held, the rwsem is taken inside this function.
  */
 static int semctl_down(struct ipc_namespace *ns, int semid,
-		       int cmd, struct semid64_ds *semid64)
+		       int cmd, const struct ipc_set_ids *set)
 {
 	struct sem_array *sma;
 	int err;
@@ -1608,8 +1608,7 @@ static int semctl_down(struct ipc_namespace *ns, int semid,
 	down_write(&sem_ids(ns).rwsem);
 	rcu_read_lock();
 
-	ipcp = ipcctl_obtain_check(ns, &sem_ids(ns), semid, cmd,
-				      &semid64->sem_perm, 0);
+	ipcp = ipcctl_obtain_check(ns, &sem_ids(ns), semid, cmd, set, 0);
 	if (IS_ERR(ipcp)) {
 		err = PTR_ERR(ipcp);
 		goto out_unlock1;
@@ -1629,7 +1628,7 @@ static int semctl_down(struct ipc_namespace *ns, int semid,
 		goto out_up;
 	case IPC_SET:
 		sem_lock(sma, NULL, -1);
-		err = ipc_update_perm(&semid64->sem_perm, ipcp);
+		err = ipc_update_perm(set, ipcp);
 		if (err)
 			goto out_unlock0;
 		sma->sem_ctime = ktime_get_real_seconds();
@@ -1653,6 +1652,7 @@ static long ksys_semctl(int semid, int semnum, int cmd, unsigned long arg, int v
 	struct ipc_namespace *ns;
 	void __user *p = (void __user *)arg;
 	struct semid64_ds semid64;
+	struct ipc_set_ids set;
 	int err;
 
 	if (semid < 0)
@@ -1694,9 +1694,16 @@ static long ksys_semctl(int semid, int semnum, int cmd, unsigned long arg, int v
 	case IPC_SET:
 		if (copy_semid_from_user(&semid64, p, version))
 			return -EFAULT;
-		fallthrough;
+		ipc64_perm_to_set_ids(&semid64.sem_perm, &set);
+		return semctl_down(ns, semid, cmd, &set);
+	case IPC_SET_R:
+		if (ipc_perm_r_to_set_ids(p, &set))
+			return -EFAULT;
+		return semctl_down(ns, semid, IPC_SET, &set);
+	case IPC_STAT_R:
+		return ipc_stat_r(ns, &sem_ids(ns), semid, security_sem_semctl, p);
 	case IPC_RMID:
-		return semctl_down(ns, semid, cmd, &semid64);
+		return semctl_down(ns, semid, cmd, NULL);
 	default:
 		return -EINVAL;
 	}
@@ -1776,6 +1783,7 @@ static long compat_ksys_semctl(int semid, int semnum, int cmd, int arg, int vers
 	void __user *p = compat_ptr(arg);
 	struct ipc_namespace *ns;
 	struct semid64_ds semid64;
+	struct ipc_set_ids set;
 	int err;
 
 	ns = current->nsproxy->ipc_ns;
@@ -1808,9 +1816,16 @@ static long compat_ksys_semctl(int semid, int semnum, int cmd, int arg, int vers
 	case IPC_SET:
 		if (copy_compat_semid_from_user(&semid64, p, version))
 			return -EFAULT;
-		fallthrough;
+		ipc64_perm_to_set_ids(&semid64.sem_perm, &set);
+		return semctl_down(ns, semid, cmd, &set);
+	case IPC_SET_R:
+		if (ipc_perm_r_to_set_ids(p, &set))
+			return -EFAULT;
+		return semctl_down(ns, semid, IPC_SET, &set);
+	case IPC_STAT_R:
+		return ipc_stat_r(ns, &sem_ids(ns), semid, security_sem_semctl, p);
 	case IPC_RMID:
-		return semctl_down(ns, semid, cmd, &semid64);
+		return semctl_down(ns, semid, cmd, NULL);
 	default:
 		return -EINVAL;
 	}
diff --git a/ipc/shm.c b/ipc/shm.c
index bb1a721a3e..33f30941c2 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -993,7 +993,7 @@ static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
  * NOTE: no locks must be held, the rwsem is taken inside this function.
  */
 static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
-		       struct shmid64_ds *shmid64)
+		       const struct ipc_set_ids *set)
 {
 	struct kern_ipc_perm *ipcp;
 	struct shmid_kernel *shp;
@@ -1002,8 +1002,7 @@ static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 	down_write(&shm_ids(ns).rwsem);
 	rcu_read_lock();
 
-	ipcp = ipcctl_obtain_check(ns, &shm_ids(ns), shmid, cmd,
-				      &shmid64->shm_perm, 0);
+	ipcp = ipcctl_obtain_check(ns, &shm_ids(ns), shmid, cmd, set, 0);
 	if (IS_ERR(ipcp)) {
 		err = PTR_ERR(ipcp);
 		goto out_unlock1;
@@ -1023,7 +1022,7 @@ static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 		goto out_up;
 	case IPC_SET:
 		ipc_lock_object(&shp->shm_perm);
-		err = ipc_update_perm(&shmid64->shm_perm, ipcp);
+		err = ipc_update_perm(set, ipcp);
 		if (err)
 			goto out_unlock0;
 		shp->shm_ctim = ktime_get_real_seconds();
@@ -1246,6 +1245,7 @@ static long ksys_shmctl(int shmid, int cmd, struct shmid_ds __user *buf, int ver
 	int err;
 	struct ipc_namespace *ns;
 	struct shmid64_ds sem64;
+	struct ipc_set_ids set;
 
 	if (cmd < 0 || shmid < 0)
 		return -EINVAL;
@@ -1284,9 +1284,17 @@ static long ksys_shmctl(int shmid, int cmd, struct shmid_ds __user *buf, int ver
 	case IPC_SET:
 		if (copy_shmid_from_user(&sem64, buf, version))
 			return -EFAULT;
-		fallthrough;
+		ipc64_perm_to_set_ids(&sem64.shm_perm, &set);
+		return shmctl_down(ns, shmid, cmd, &set);
+	case IPC_SET_R:
+		if (ipc_perm_r_to_set_ids((void __user *)buf, &set))
+			return -EFAULT;
+		return shmctl_down(ns, shmid, IPC_SET, &set);
+	case IPC_STAT_R:
+		return ipc_stat_r(ns, &shm_ids(ns), shmid, security_shm_shmctl,
+				  (void __user *)buf);
 	case IPC_RMID:
-		return shmctl_down(ns, shmid, cmd, &sem64);
+		return shmctl_down(ns, shmid, cmd, NULL);
 	case SHM_LOCK:
 	case SHM_UNLOCK:
 		return shmctl_do_lock(ns, shmid, cmd);
@@ -1440,6 +1448,7 @@ static long compat_ksys_shmctl(int shmid, int cmd, void __user *uptr, int versio
 {
 	struct ipc_namespace *ns;
 	struct shmid64_ds sem64;
+	struct ipc_set_ids set;
 	int err;
 
 	ns = current->nsproxy->ipc_ns;
@@ -1479,9 +1488,16 @@ static long compat_ksys_shmctl(int shmid, int cmd, void __user *uptr, int versio
 	case IPC_SET:
 		if (copy_compat_shmid_from_user(&sem64, uptr, version))
 			return -EFAULT;
-		fallthrough;
+		ipc64_perm_to_set_ids(&sem64.shm_perm, &set);
+		return shmctl_down(ns, shmid, cmd, &set);
+	case IPC_SET_R:
+		if (ipc_perm_r_to_set_ids(uptr, &set))
+			return -EFAULT;
+		return shmctl_down(ns, shmid, IPC_SET, &set);
+	case IPC_STAT_R:
+		return ipc_stat_r(ns, &shm_ids(ns), shmid, security_shm_shmctl, uptr);
 	case IPC_RMID:
-		return shmctl_down(ns, shmid, cmd, &sem64);
+		return shmctl_down(ns, shmid, cmd, NULL);
 	case SHM_LOCK:
 	case SHM_UNLOCK:
 		return shmctl_do_lock(ns, shmid, cmd);
diff --git a/ipc/util.c b/ipc/util.c
index 1737d776bc..bc4df56193 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -681,28 +681,117 @@ int ipcget(struct ipc_namespace *ns, struct ipc_ids *ids,
  * @in:  the permission given as input.
  * @out: the permission of the ipc to set.
  */
-int ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out)
+int ipc_update_perm(const struct ipc_set_ids *in, struct kern_ipc_perm *out)
 {
-	kuid_t uid = make_kuid(current_user_ns(), in->uid);
-	kgid_t gid = make_kgid(current_user_ns(), in->gid);
-	if (!uid_valid(uid) || !gid_valid(gid))
-		return -EINVAL;
+	if (in->err)
+		return in->err;
 
-	out->uid = uid;
-	out->gid = gid;
+	out->uid = in->uid;
+	out->gid = in->gid;
 	out->mode = (out->mode & ~S_IRWXUGO)
 		| (in->mode & S_IRWXUGO);
 
 	return 0;
 }
 
+/**
+ * ipc64_perm_to_set_ids - the IPC_SET ids and mode of a classic ipc64_perm
+ * @in: user permissions
+ * @out: kernel ids and mode, -EINVAL in @out->err if an id is invalid
+ */
+void ipc64_perm_to_set_ids(const struct ipc64_perm *in, struct ipc_set_ids *out)
+{
+	out->uid = make_kuid(current_user_ns(), in->uid);
+	out->gid = make_kgid(current_user_ns(), in->gid);
+	out->mode = in->mode;
+	out->err = uid_valid(out->uid) && gid_valid(out->gid) ? 0 : -EINVAL;
+}
+
+/**
+ * ipc_perm_r_to_set_ids - the IPC_SET_R ids and mode of a struct ipc_perm_r
+ * @in: user permissions
+ * @out: kernel ids and mode, -EINVAL in @out->err if an id is invalid
+ *
+ * Return: 0 or -EFAULT.
+ */
+int ipc_perm_r_to_set_ids(const struct ipc_perm_r __user *in,
+			  struct ipc_set_ids *out)
+{
+	struct ipc_perm_r perm;
+
+	if (copy_from_user(&perm, in, sizeof(perm)))
+		return -EFAULT;
+	out->uid = make_kuid_r(current_user_ns(), &perm.uid);
+	out->gid = make_kgid_r(current_user_ns(), &perm.gid);
+	out->mode = perm.mode;
+	out->err = uid_valid(out->uid) && gid_valid(out->gid) ? 0 : -EINVAL;
+	return 0;
+}
+
+/**
+ * ipc_stat_r - IPC_STAT_R of an ipc object
+ * @ns: ipc namespace
+ * @ids: the table of ids where to look for the object
+ * @id: the id of the object
+ * @security: the security hook of the object's kind, asked for IPC_STAT
+ * @buf: where to put the struct ipc_perm_r
+ *
+ * Return: 0 or a negative error code.
+ */
+int ipc_stat_r(struct ipc_namespace *ns, struct ipc_ids *ids, int id,
+	       int (*security)(struct kern_ipc_perm *, int),
+	       struct ipc_perm_r __user *buf)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	struct kern_ipc_perm *ipcp;
+	struct ipc_perm_r perm;
+	int err;
+
+	memset(&perm, 0, sizeof(perm));
+	rcu_read_lock();
+	ipcp = ipc_obtain_object_check(ids, id);
+	if (IS_ERR(ipcp)) {
+		err = PTR_ERR(ipcp);
+		goto out_unlock;
+	}
+
+	err = -EACCES;
+	if (ipcperms(ns, ipcp, S_IRUGO))
+		goto out_unlock;
+
+	err = security(ipcp, IPC_STAT);
+	if (err)
+		goto out_unlock;
+
+	ipc_lock_object(ipcp);
+	if (!ipc_valid_object(ipcp)) {
+		ipc_unlock_object(ipcp);
+		err = -EIDRM;
+		goto out_unlock;
+	}
+	perm.key = ipcp->key;
+	perm.mode = ipcp->mode;
+	from_kuid_r_munged(user_ns, ipcp->uid, &perm.uid);
+	from_kgid_r_munged(user_ns, ipcp->gid, &perm.gid);
+	from_kuid_r_munged(user_ns, ipcp->cuid, &perm.cuid);
+	from_kgid_r_munged(user_ns, ipcp->cgid, &perm.cgid);
+	ipc_unlock_object(ipcp);
+	rcu_read_unlock();
+
+	return copy_to_user(buf, &perm, sizeof(perm)) ? -EFAULT : 0;
+
+out_unlock:
+	rcu_read_unlock();
+	return err;
+}
+
 /**
  * ipcctl_obtain_check - retrieve an ipc object and check permissions
  * @ns:  ipc namespace
  * @ids:  the table of ids where to look for the ipc
  * @id:   the id of the ipc to retrieve
  * @cmd:  the cmd to check
- * @perm: the permission to set
+ * @set: the ids and mode to set
  * @extra_perm: one extra permission parameter used by msq
  *
  * This function does some common audit and permissions check for some IPC_XXX
@@ -718,7 +807,8 @@ int ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out)
  */
 struct kern_ipc_perm *ipcctl_obtain_check(struct ipc_namespace *ns,
 					struct ipc_ids *ids, int id, int cmd,
-					struct ipc64_perm *perm, int extra_perm)
+					const struct ipc_set_ids *set,
+					int extra_perm)
 {
 	kuid_t euid;
 	int err = -EPERM;
@@ -732,8 +822,8 @@ struct kern_ipc_perm *ipcctl_obtain_check(struct ipc_namespace *ns,
 
 	audit_ipc_obj(ipcp);
 	if (cmd == IPC_SET)
-		audit_ipc_set_perm(extra_perm, perm->uid,
-				   perm->gid, perm->mode);
+		audit_ipc_set_perm(extra_perm, set->uid,
+				   set->gid, set->mode);
 
 	euid = current_euid();
 	if (uid_eq(euid, ipcp->cuid) || uid_eq(euid, ipcp->uid)  ||
diff --git a/ipc/util.h b/ipc/util.h
index a55d6cebe6..b0d57f4e64 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -177,10 +177,29 @@ struct kern_ipc_perm *ipc_obtain_object_idr(struct ipc_ids *ids, int id);
 
 void kernel_to_ipc64_perm(struct kern_ipc_perm *in, struct ipc64_perm *out);
 void ipc64_perm_to_ipc_perm(struct ipc64_perm *in, struct ipc_perm *out);
-int ipc_update_perm(struct ipc64_perm *in, struct kern_ipc_perm *out);
+
+/*
+ * The new owner, group and mode of IPC_SET/IPC_SET_R. @err is an error of
+ * their conversion, reported once the object has been found.
+ */
+struct ipc_set_ids {
+	kuid_t uid;
+	kgid_t gid;
+	umode_t mode;
+	int err;
+};
+
+void ipc64_perm_to_set_ids(const struct ipc64_perm *in, struct ipc_set_ids *out);
+int ipc_perm_r_to_set_ids(const struct ipc_perm_r __user *in,
+			  struct ipc_set_ids *out);
+int ipc_update_perm(const struct ipc_set_ids *in, struct kern_ipc_perm *out);
 struct kern_ipc_perm *ipcctl_obtain_check(struct ipc_namespace *ns,
 					     struct ipc_ids *ids, int id, int cmd,
-					     struct ipc64_perm *perm, int extra_perm);
+					     const struct ipc_set_ids *set,
+					     int extra_perm);
+int ipc_stat_r(struct ipc_namespace *ns, struct ipc_ids *ids, int id,
+	       int (*security)(struct kern_ipc_perm *, int),
+	       struct ipc_perm_r __user *buf);
 
 static inline void ipc_update_pid(struct pid **pos, struct pid *pid)
 {
diff --git a/kernel/audit.h b/kernel/audit.h
index 92d5e723d5..6195f13882 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -168,8 +168,8 @@ struct audit_context {
 			umode_t			mode;
 			struct lsm_prop		oprop;
 			int			has_perm;
-			uid_t			perm_uid;
-			gid_t			perm_gid;
+			kuid_t			perm_uid;
+			kgid_t			perm_gid;
 			umode_t			perm_mode;
 			unsigned long		qbytes;
 		} ipc;
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 08d8f5af46..9abe0615a1 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1395,10 +1395,10 @@ static void show_special(struct audit_context *context, int *call_panic)
 			if (unlikely(!ab))
 				return;
 			audit_log_format(ab,
-				"qbytes=%lx ouid=%u ogid=%u mode=%#ho",
+				"qbytes=%lx ouid=%s ogid=%s mode=%#ho",
 				context->ipc.qbytes,
-				context->ipc.perm_uid,
-				context->ipc.perm_gid,
+				KUID_STR(context->ipc.perm_uid),
+				KGID_STR(context->ipc.perm_gid),
 				context->ipc.perm_mode);
 		}
 		break;
@@ -2585,7 +2585,7 @@ void __audit_ipc_obj(struct kern_ipc_perm *ipcp)
  *
  * Called only after audit_ipc_obj().
  */
-void __audit_ipc_set_perm(unsigned long qbytes, uid_t uid, gid_t gid, umode_t mode)
+void __audit_ipc_set_perm(unsigned long qbytes, kuid_t uid, kgid_t gid, umode_t mode)
 {
 	struct audit_context *context = audit_context();
 
-- 
2.56.0

