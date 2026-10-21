Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552623;
	b=hWWXk6sdPyJay+TzzyrM9vLq7YNPMCQo//b99VHqZP7SbhlBdq4yAhZaaLcvso8Mw+AF
	 UgRxvc4zA0gaP8/KuEj5uu3frPttUYf/jjD8pRBYeXUSZKtxTiA7ASnuv+sPdRlsIJhor
	 Qap4VUCpQk8hjei4y7R6/rlTZ3tO07Nov2dcgqGeNVBNkHm8UAqHyjk3QDplcSir5A+Od
	 kXrtzSKWEXgKA5GM2599K7KRGYojP2DU5jfMHQ3j0BsNdB1xpWGrsUcMNrN9rdGwslo4j
	 R3xk0eL7DHKkS9blAoiDTEGoN2rRhsDcnjj5nWE8MIrunufO5KJS/3bPpFBYBNKnsVw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552623;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=vMKDB0NuuGoORFr/IB1kVTjvqvtcQDpz+g3SAxqtEZI=;
	b=xG9H5vRStBIOPB1jySAwjzkbKtFtzlV5sxrH19mjeWNsWl4dK6+mDB59kfkYNXWjfHxT
	 Yk1Q6Mo5qqtEZc22UuJZDqEwl5h6WnoQdV7gAYeKBCWCvGlz592clRfJjZHW75Uio59vw
	 fQQHo2KzlPQ4x/LSH2Y4rVp1Vu6EP3gNhAIpgetnIOLgr4/6f3dxZ5ZGIiHzx+LAM18gs
	 J8Z/ybVJD3n/mNBct5lRHuR7FhLlI/Pdv9MKXIYeDxpFdMyXNflC8P4dwFoPA4Zfl4WWk
	 oqFqqPds9+sICyblh/SAs472gIcLk5m/6JEpDf47eMV9QF50IkTtMV8ARpLW1hv07Jg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=AWm9pFDn;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16EAE6073A2C;
	Wed, 21 Oct 2026 03:17:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 16EAE6073A2C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=AWm9pFDn
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552620; bh=nbEHt/gzCOYzynoFgeDQGwy6kFuPGl0cHF7Ii/63+Uo=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=AWm9pFDnuKmhLmK65IyQB2eGFa89GleAtYQvUgxAJeE5v/y1WArqob9DqnWO6kgot
	 CJ+3O6nJ6oN5yvnjTVV7k36po4DpK5Bm7N8sHr0Ev9znQEw6Pn3ZFQ52cCbuWTi5qQ
	 dTqS+Z+GyJ9i140Z3CLMA8Aasol8NSd/DCCrnIRAVhYz6DT6kgO0RuRcu9eODDdUdH
	 3huLyoiB8P4YvR12ChHkoY+aRiG1rhhGn6/YXZPSIrzbVeR69a4V3EAqPJH0w7bGwF
	 tMD5/3AEVUq/jmPUY3rVoOwOEJNpHxCuJ7TNfi2p65d6tljsucwLx3EqU7smjI4xhW
	 DYI92z0v7JJ+g==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 70C078A09A4;
	Wed, 21 Oct 2026 05:16:59 +0200 (CEST)
Message-ID: <59988b6ac15fa727c7f5d14d5342ceba4d6e595f.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 29/41] signal: report the sender's UUID or GUID uid in
 si_uid_r
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
Date: Wed, 21 Oct 2026 05:15:49 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

si_uid is 32 bits, so a signal from a UUID or GUID user names the
overflow uid as its sender, and so do SIGCHLD and waitid() for such a
child.

Add si_uid_r, the sender's uid as __kernel_uid_r_t, to siginfo_t. union
__sifields has no room that all kinds of signals with si_uid share, so
it lives at a fixed offset (96) in the padding of siginfo_t, the same
in every layout and ABI, compat_siginfo included; kernel_siginfo grows
to cover it. The kernel sets it wherever it sets si_uid, through
siginfo_set_uid() and siginfo_set_kernel_uid(), maps it into the
receiver's user namespace like si_uid, and it is UID_R_NONE where
nobody set it. Signals queued from userspace carry what the sender put
there, exactly like si_uid.

signalfd_siginfo gets ssi_uid_r from its padding, and waitid() (also
through io_uring, which keeps its waitid_info in the async data now, as
it no longer fits into the command) fills in si_uid_r.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/signalfd.c                      |  3 ++
 include/linux/compat.h             |  6 ++++
 include/linux/ptrace.h             |  2 +-
 include/linux/signal.h             | 22 ++++++++++++++
 include/linux/signal_types.h       |  5 +++-
 include/uapi/asm-generic/siginfo.h | 17 +++++++++++
 include/uapi/linux/signalfd.h      |  4 ++-
 io_uring/waitid.c                  | 32 ++++++++++++--------
 io_uring/waitid.h                  |  1 +
 ipc/mqueue.c                       |  4 +--
 kernel/exit.c                      | 18 +++++++++--
 kernel/exit.h                      |  3 ++
 kernel/signal.c                    | 48 ++++++++++++++++++++----------
 13 files changed, 129 insertions(+), 36 deletions(-)

diff --git a/fs/signalfd.c b/fs/signalfd.c
index dff53745e3..8bca9d7f01 100644
--- a/fs/signalfd.c
+++ b/fs/signalfd.c
@@ -90,6 +90,7 @@ static int signalfd_copyinfo(struct iov_iter *to, kernel_siginfo_t const *kinfo)
 	case SIL_KILL:
 		new.ssi_pid = kinfo->si_pid;
 		new.ssi_uid = kinfo->si_uid;
+		new.ssi_uid_r = kinfo->si_uid_r;
 		break;
 	case SIL_TIMER:
 		new.ssi_tid = kinfo->si_tid;
@@ -125,6 +126,7 @@ static int signalfd_copyinfo(struct iov_iter *to, kernel_siginfo_t const *kinfo)
 	case SIL_CHLD:
 		new.ssi_pid    = kinfo->si_pid;
 		new.ssi_uid    = kinfo->si_uid;
+		new.ssi_uid_r  = kinfo->si_uid_r;
 		new.ssi_status = kinfo->si_status;
 		new.ssi_utime  = kinfo->si_utime;
 		new.ssi_stime  = kinfo->si_stime;
@@ -135,6 +137,7 @@ static int signalfd_copyinfo(struct iov_iter *to, kernel_siginfo_t const *kinfo)
 		 */
 		new.ssi_pid = kinfo->si_pid;
 		new.ssi_uid = kinfo->si_uid;
+		new.ssi_uid_r = kinfo->si_uid_r;
 		new.ssi_ptr = (long) kinfo->si_ptr;
 		new.ssi_int = kinfo->si_int;
 		break;
diff --git a/include/linux/compat.h b/include/linux/compat.h
index 8da0a15c95..4b85059008 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -169,6 +169,12 @@ typedef struct compat_siginfo {
 	union {
 		int _pad[128/sizeof(int) - 3];
 
+		/* si_uid_r, at __SI_UID_R_OFFSET like in siginfo_t */
+		struct {
+			int _uid_r_pad[__SI_UID_R_OFFSET / sizeof(int) - 3];
+			__kernel_uid_r_t _uid_r;
+		} _sir;
+
 		/* kill() */
 		struct {
 			compat_pid_t _pid;	/* sender's pid */
diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
index 2839d5c8ea..1d6d41c67f 100644
--- a/include/linux/ptrace.h
+++ b/include/linux/ptrace.h
@@ -347,7 +347,7 @@ static inline void user_single_step_report(struct pt_regs *regs)
 	info.si_errno = 0;
 	info.si_code = SI_USER;
 	info.si_pid = 0;
-	info.si_uid = 0;
+	siginfo_set_kernel_uid(&info);
 	force_sig_info(&info);
 }
 #endif
diff --git a/include/linux/signal.h b/include/linux/signal.h
index f19816832f..928e67e283 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -6,6 +6,7 @@
 #include <linux/list.h>
 #include <linux/signal_types.h>
 #include <linux/string.h>
+#include <linux/uidgid.h>
 
 struct task_struct;
 
@@ -23,6 +24,27 @@ static inline void clear_siginfo(kernel_siginfo_t *info)
 	memset(info, 0, sizeof(*info));
 }
 
+struct user_namespace;
+
+/*
+ * Sets si_uid and si_uid_r to @uid as seen from @ns (the receiver's user
+ * namespace), the overflow id if it has no mapping there.
+ */
+static inline void siginfo_set_uid(kernel_siginfo_t *info,
+				   struct user_namespace *ns, kuid_t uid)
+{
+	info->si_uid = from_kuid_munged(ns, uid);
+	from_kuid_r_munged(ns, uid, &info->si_uid_r);
+}
+
+/* si_uid and si_uid_r of a signal from the kernel: 0 */
+static inline void siginfo_set_kernel_uid(kernel_siginfo_t *info)
+{
+	info->si_uid = 0;
+	memset(&info->si_uid_r, 0, sizeof(info->si_uid_r));
+	info->si_uid_r.type = UID_R_LEGACY;
+}
+
 #define SI_EXPANSION_SIZE (sizeof(struct siginfo) - sizeof(struct kernel_siginfo))
 
 static inline void copy_siginfo_to_external(siginfo_t *to,
diff --git a/include/linux/signal_types.h b/include/linux/signal_types.h
index caf4f7a59a..eaf922e443 100644
--- a/include/linux/signal_types.h
+++ b/include/linux/signal_types.h
@@ -10,7 +10,10 @@
 #include <uapi/linux/signal.h>
 
 typedef struct kernel_siginfo {
-	__SIGINFO;
+	union {
+		__SIGINFO;
+		__SIGINFO_UID_R;
+	};
 } kernel_siginfo_t;
 
 struct ucounts;
diff --git a/include/uapi/asm-generic/siginfo.h b/include/uapi/asm-generic/siginfo.h
index 5a1ca43b5f..e8f32c942b 100644
--- a/include/uapi/asm-generic/siginfo.h
+++ b/include/uapi/asm-generic/siginfo.h
@@ -4,6 +4,7 @@
 
 #include <linux/compiler.h>
 #include <linux/types.h>
+#include <linux/uidgid_r.h>
 
 typedef union sigval {
 	int sival_int;
@@ -131,9 +132,24 @@ struct {				\
 }
 #endif /* __ARCH_HAS_SWAPPED_SIGINFO */
 
+/*
+ * The sender's uid as __kernel_uid_r_t (a UUID or GUID too), for the
+ * signals with si_pid and si_uid. It lives at the same offset in every
+ * layout and ABI, past the end of union __sifields; UID_R_NONE where the
+ * kernel doesn't set it.
+ */
+#define __SI_UID_R_OFFSET	96
+
+#define __SIGINFO_UID_R						\
+struct {							\
+	int _uid_r_pad[__SI_UID_R_OFFSET / sizeof(int)];	\
+	__kernel_uid_r_t _uid_r;				\
+} _sir
+
 typedef struct siginfo {
 	union {
 		__SIGINFO;
+		__SIGINFO_UID_R;
 		int _si_pad[SI_MAX_SIZE/sizeof(int)];
 	};
 } __ARCH_SI_ATTRIBUTES siginfo_t;
@@ -143,6 +159,7 @@ typedef struct siginfo {
  */
 #define si_pid		_sifields._kill._pid
 #define si_uid		_sifields._kill._uid
+#define si_uid_r	_sir._uid_r
 #define si_tid		_sifields._timer._tid
 #define si_overrun	_sifields._timer._overrun
 #define si_sys_private  _sifields._timer._sys_private
diff --git a/include/uapi/linux/signalfd.h b/include/uapi/linux/signalfd.h
index 83429a05b6..471bafc539 100644
--- a/include/uapi/linux/signalfd.h
+++ b/include/uapi/linux/signalfd.h
@@ -10,6 +10,7 @@
 #define _UAPI_LINUX_SIGNALFD_H
 
 #include <linux/types.h>
+#include <linux/uidgid_r.h>
 /* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/fcntl.h>
 
@@ -39,6 +40,7 @@ struct signalfd_siginfo {
 	__s32 ssi_syscall;
 	__u64 ssi_call_addr;
 	__u32 ssi_arch;
+	__kernel_uid_r_t ssi_uid_r;	/* sender's uid, also a UUID or GUID */
 
 	/*
 	 * Pad strcture to 128 bytes. Remember to update the
@@ -49,7 +51,7 @@ struct signalfd_siginfo {
 	 * comes out of a read(2) and we really don't want to have
 	 * a compat on read(2).
 	 */
-	__u8 __pad[28];
+	__u8 __pad[8];
 };
 
 
diff --git a/io_uring/waitid.c b/io_uring/waitid.c
index 2b75601742..24f27b67d3 100644
--- a/io_uring/waitid.c
+++ b/io_uring/waitid.c
@@ -29,7 +29,6 @@ struct io_waitid {
 	atomic_t refs;
 	struct wait_queue_head *head;
 	struct siginfo __user *infop;
-	struct waitid_info info;
 };
 
 static void io_waitid_free(struct io_kiocb *req)
@@ -40,8 +39,10 @@ static void io_waitid_free(struct io_kiocb *req)
 	io_req_async_data_free(req);
 }
 
-static bool io_waitid_compat_copy_si(struct io_waitid *iw, int signo)
+static bool io_waitid_compat_copy_si(struct io_kiocb *req, int signo)
 {
+	struct io_waitid *iw = io_kiocb_to_cmd(req, struct io_waitid);
+	struct io_waitid_async *iwa = req->async_data;
 	struct compat_siginfo __user *infop;
 	bool ret;
 
@@ -52,10 +53,12 @@ static bool io_waitid_compat_copy_si(struct io_waitid *iw, int signo)
 
 	unsafe_put_user(signo, &infop->si_signo, Efault);
 	unsafe_put_user(0, &infop->si_errno, Efault);
-	unsafe_put_user(iw->info.cause, &infop->si_code, Efault);
-	unsafe_put_user(iw->info.pid, &infop->si_pid, Efault);
-	unsafe_put_user(iw->info.uid, &infop->si_uid, Efault);
-	unsafe_put_user(iw->info.status, &infop->si_status, Efault);
+	unsafe_put_user(iwa->info.cause, &infop->si_code, Efault);
+	unsafe_put_user(iwa->info.pid, &infop->si_pid, Efault);
+	unsafe_put_user(iwa->info.uid, &infop->si_uid, Efault);
+	unsafe_copy_to_user((char __user *)&infop->_sifields._sir._uid_r,
+			    (const char *)&iwa->info.uid_r, sizeof(iwa->info.uid_r), Efault);
+	unsafe_put_user(iwa->info.status, &infop->si_status, Efault);
 	ret = true;
 done:
 	user_write_access_end();
@@ -68,23 +71,26 @@ static bool io_waitid_compat_copy_si(struct io_waitid *iw, int signo)
 static bool io_waitid_copy_si(struct io_kiocb *req, int signo)
 {
 	struct io_waitid *iw = io_kiocb_to_cmd(req, struct io_waitid);
+	struct io_waitid_async *iwa = req->async_data;
 	bool ret;
 
 	if (!iw->infop)
 		return true;
 
 	if (io_is_compat(req->ctx))
-		return io_waitid_compat_copy_si(iw, signo);
+		return io_waitid_compat_copy_si(req, signo);
 
 	if (!user_write_access_begin(iw->infop, sizeof(*iw->infop)))
 		return false;
 
 	unsafe_put_user(signo, &iw->infop->si_signo, Efault);
 	unsafe_put_user(0, &iw->infop->si_errno, Efault);
-	unsafe_put_user(iw->info.cause, &iw->infop->si_code, Efault);
-	unsafe_put_user(iw->info.pid, &iw->infop->si_pid, Efault);
-	unsafe_put_user(iw->info.uid, &iw->infop->si_uid, Efault);
-	unsafe_put_user(iw->info.status, &iw->infop->si_status, Efault);
+	unsafe_put_user(iwa->info.cause, &iw->infop->si_code, Efault);
+	unsafe_put_user(iwa->info.pid, &iw->infop->si_pid, Efault);
+	unsafe_put_user(iwa->info.uid, &iw->infop->si_uid, Efault);
+	unsafe_copy_to_user((char __user *)&iw->infop->si_uid_r,
+			    (const char *)&iwa->info.uid_r, sizeof(iwa->info.uid_r), Efault);
+	unsafe_put_user(iwa->info.status, &iw->infop->si_status, Efault);
 	ret = true;
 done:
 	user_write_access_end();
@@ -294,7 +300,7 @@ int io_waitid_prep(struct io_kiocb *req, const struct io_uring_sqe *sqe)
 	iw->options = READ_ONCE(sqe->file_index);
 	iw->head = NULL;
 	iw->infop = u64_to_user_ptr(READ_ONCE(sqe->addr2));
-	memset(&iw->info, 0, sizeof(iw->info));
+	memset(&iwa->info, 0, sizeof(iwa->info));
 	return 0;
 }
 
@@ -305,7 +311,7 @@ int io_waitid(struct io_kiocb *req, unsigned int issue_flags)
 	struct io_ring_ctx *ctx = req->ctx;
 	int ret;
 
-	ret = kernel_waitid_prepare(&iwa->wo, iw->which, iw->upid, &iw->info,
+	ret = kernel_waitid_prepare(&iwa->wo, iw->which, iw->upid, &iwa->info,
 					iw->options, NULL);
 	if (ret)
 		goto done;
diff --git a/io_uring/waitid.h b/io_uring/waitid.h
index d5544aaf30..60b744a0e8 100644
--- a/io_uring/waitid.h
+++ b/io_uring/waitid.h
@@ -5,6 +5,7 @@
 struct io_waitid_async {
 	struct io_kiocb *req;
 	struct wait_opts wo;
+	struct waitid_info info;
 };
 
 int io_waitid_prep(struct io_kiocb *req, const struct io_uring_sqe *sqe);
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index d1dd36a651..f0a319ed97 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -802,8 +802,8 @@ static void __do_notify(struct mqueue_inode_info *info)
 			/* map current pid/uid into info->owner's namespaces */
 			sig_i.si_pid = task_tgid_nr_ns(current,
 						ns_of_pid(info->notify_owner));
-			sig_i.si_uid = from_kuid_munged(info->notify_user_ns,
-						current_uid());
+			siginfo_set_uid(&sig_i, info->notify_user_ns,
+					current_uid());
 			/*
 			 * We can't use kill_pid_info(), this signal should
 			 * bypass check_kill_permission(). It is from kernel
diff --git a/kernel/exit.c b/kernel/exit.c
index 282328d2b4..130234f702 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1185,7 +1185,8 @@ static int wait_task_zombie(struct wait_opts *wo, struct task_struct *p)
 {
 	int state, status;
 	pid_t pid = task_pid_vnr(p);
-	uid_t uid = from_kuid_munged(current_user_ns(), task_uid(p));
+	kuid_t kuid = task_uid(p);
+	uid_t uid = from_kuid_munged(current_user_ns(), kuid);
 	struct waitid_info *infop;
 
 	if (!likely(wo->wo_flags & WEXITED))
@@ -1302,6 +1303,7 @@ static int wait_task_zombie(struct wait_opts *wo, struct task_struct *p)
 		}
 		infop->pid = pid;
 		infop->uid = uid;
+		from_kuid_r_munged(current_user_ns(), kuid, &infop->uid_r);
 	}
 
 	return pid;
@@ -1343,6 +1345,7 @@ static int wait_task_stopped(struct wait_opts *wo,
 	struct waitid_info *infop;
 	int exit_code, *p_code, why;
 	uid_t uid = 0; /* unneeded, required by compiler */
+	kuid_t kuid = INVALID_UID;
 	pid_t pid;
 
 	/*
@@ -1368,7 +1371,8 @@ static int wait_task_stopped(struct wait_opts *wo,
 	if (!unlikely(wo->wo_flags & WNOWAIT))
 		*p_code = 0;
 
-	uid = from_kuid_munged(current_user_ns(), task_uid(p));
+	kuid = task_uid(p);
+	uid = from_kuid_munged(current_user_ns(), kuid);
 unlock_sig:
 	spin_unlock_irq(&p->sighand->siglock);
 	if (!exit_code)
@@ -1399,6 +1403,7 @@ static int wait_task_stopped(struct wait_opts *wo,
 		infop->status = exit_code;
 		infop->pid = pid;
 		infop->uid = uid;
+		from_kuid_r_munged(current_user_ns(), kuid, &infop->uid_r);
 	}
 	return pid;
 }
@@ -1414,6 +1419,7 @@ static int wait_task_continued(struct wait_opts *wo, struct task_struct *p)
 	struct waitid_info *infop;
 	pid_t pid;
 	uid_t uid;
+	kuid_t kuid;
 
 	if (!unlikely(wo->wo_flags & WCONTINUED))
 		return 0;
@@ -1429,7 +1435,8 @@ static int wait_task_continued(struct wait_opts *wo, struct task_struct *p)
 	}
 	if (!unlikely(wo->wo_flags & WNOWAIT))
 		p->signal->flags &= ~SIGNAL_STOP_CONTINUED;
-	uid = from_kuid_munged(current_user_ns(), task_uid(p));
+	kuid = task_uid(p);
+	uid = from_kuid_munged(current_user_ns(), kuid);
 	spin_unlock_irq(&p->sighand->siglock);
 
 	pid = task_pid_vnr(p);
@@ -1447,6 +1454,7 @@ static int wait_task_continued(struct wait_opts *wo, struct task_struct *p)
 		infop->cause = CLD_CONTINUED;
 		infop->pid = pid;
 		infop->uid = uid;
+		from_kuid_r_munged(current_user_ns(), kuid, &infop->uid_r);
 		infop->status = SIGCONT;
 	}
 	return pid;
@@ -1846,6 +1854,8 @@ SYSCALL_DEFINE5(waitid, int, which, pid_t, upid, struct siginfo __user *,
 	unsafe_put_user(info.cause, &infop->si_code, Efault);
 	unsafe_put_user(info.pid, &infop->si_pid, Efault);
 	unsafe_put_user(info.uid, &infop->si_uid, Efault);
+	unsafe_copy_to_user((char __user *)&infop->si_uid_r,
+			    (const char *)&info.uid_r, sizeof(info.uid_r), Efault);
 	unsafe_put_user(info.status, &infop->si_status, Efault);
 	user_write_access_end();
 	return err;
@@ -1989,6 +1999,8 @@ COMPAT_SYSCALL_DEFINE5(waitid,
 	unsafe_put_user(info.cause, &infop->si_code, Efault);
 	unsafe_put_user(info.pid, &infop->si_pid, Efault);
 	unsafe_put_user(info.uid, &infop->si_uid, Efault);
+	unsafe_copy_to_user((char __user *)&infop->_sifields._sir._uid_r,
+			    (const char *)&info.uid_r, sizeof(info.uid_r), Efault);
 	unsafe_put_user(info.status, &infop->si_status, Efault);
 	user_write_access_end();
 	return err;
diff --git a/kernel/exit.h b/kernel/exit.h
index 278faa26a6..f24a6d6917 100644
--- a/kernel/exit.h
+++ b/kernel/exit.h
@@ -2,9 +2,12 @@
 #ifndef LINUX_WAITID_H
 #define LINUX_WAITID_H
 
+#include <linux/uidgid_r.h>
+
 struct waitid_info {
 	pid_t pid;
 	uid_t uid;
+	__kernel_uid_r_t uid_r;		/* uid as __kernel_uid_r_t */
 	int status;
 	int cause;
 };
diff --git a/kernel/signal.c b/kernel/signal.c
index d31ebcb6ed..af0793d04b 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -602,7 +602,7 @@ static void collect_signal(int sig, struct sigpending *list, kernel_siginfo_t *i
 		info->si_errno = 0;
 		info->si_code = SI_USER;
 		info->si_pid = 0;
-		info->si_uid = 0;
+		siginfo_set_kernel_uid(info);
 	}
 }
 
@@ -1120,9 +1120,8 @@ static int __send_signal_locked(int sig, struct kernel_siginfo *info,
 			q->info.si_pid = task_tgid_nr_ns(current,
 							task_active_pid_ns(t));
 			rcu_read_lock();
-			q->info.si_uid =
-				from_kuid_munged(task_cred_xxx(t, user_ns),
-						 current_uid());
+			siginfo_set_uid(&q->info, task_cred_xxx(t, user_ns),
+					current_uid());
 			rcu_read_unlock();
 			break;
 		case (unsigned long) SEND_SIG_PRIV:
@@ -1131,7 +1130,7 @@ static int __send_signal_locked(int sig, struct kernel_siginfo *info,
 			q->info.si_errno = 0;
 			q->info.si_code = SI_KERNEL;
 			q->info.si_pid = 0;
-			q->info.si_uid = 0;
+			siginfo_set_kernel_uid(&q->info);
 			break;
 		default:
 			copy_siginfo(&q->info, info);
@@ -1229,6 +1228,13 @@ int send_signal_locked(int sig, struct kernel_siginfo *info,
 			info = &rewritten;
 			uid = make_kuid(current_user_ns(), info->si_uid);
 			rewritten.si_uid = from_kuid_munged(t_user_ns, uid);
+			if (rewritten.si_uid_r.type != UID_R_NONE) {
+				kuid_t uid_r = make_kuid_r(current_user_ns(),
+							   &rewritten.si_uid_r);
+
+				from_kuid_r_munged(t_user_ns, uid_r,
+						   &rewritten.si_uid_r);
+			}
 		}
 		rcu_read_unlock();
 #endif
@@ -1684,7 +1690,7 @@ void force_sig(int sig)
 	info.si_errno = 0;
 	info.si_code = SI_KERNEL;
 	info.si_pid = 0;
-	info.si_uid = 0;
+	siginfo_set_kernel_uid(&info);
 	force_sig_info(&info);
 }
 EXPORT_SYMBOL(force_sig);
@@ -1698,7 +1704,7 @@ void force_fatal_sig(int sig)
 	info.si_errno = 0;
 	info.si_code = SI_KERNEL;
 	info.si_pid = 0;
-	info.si_uid = 0;
+	siginfo_set_kernel_uid(&info);
 	force_sig_info_to_task(&info, current, HANDLER_SIG_DFL);
 }
 
@@ -1711,7 +1717,7 @@ void force_exit_sig(int sig)
 	info.si_errno = 0;
 	info.si_code = SI_KERNEL;
 	info.si_pid = 0;
-	info.si_uid = 0;
+	siginfo_set_kernel_uid(&info);
 	force_sig_info_to_task(&info, current, HANDLER_EXIT);
 }
 
@@ -2282,8 +2288,8 @@ bool do_notify_parent(struct task_struct *tsk, int sig)
 	 */
 	rcu_read_lock();
 	info.si_pid = task_pid_nr_ns(tsk, task_active_pid_ns(tsk->parent));
-	info.si_uid = from_kuid_munged(task_cred_xxx(tsk->parent, user_ns),
-				       task_uid(tsk));
+	siginfo_set_uid(&info, task_cred_xxx(tsk->parent, user_ns),
+			task_uid(tsk));
 	rcu_read_unlock();
 
 	task_cputime(tsk, &utime, &stime);
@@ -2377,7 +2383,7 @@ static void do_notify_parent_cldstop(struct task_struct *tsk,
 	 */
 	rcu_read_lock();
 	info.si_pid = task_pid_nr_ns(tsk, task_active_pid_ns(parent));
-	info.si_uid = from_kuid_munged(task_cred_xxx(parent, user_ns), task_uid(tsk));
+	siginfo_set_uid(&info, task_cred_xxx(parent, user_ns), task_uid(tsk));
 	rcu_read_unlock();
 
 	task_cputime(tsk, &utime, &stime);
@@ -2582,7 +2588,7 @@ static int ptrace_do_notify(int signr, int exit_code, int why, unsigned long mes
 	info.si_signo = signr;
 	info.si_code = exit_code;
 	info.si_pid = task_pid_vnr(current);
-	info.si_uid = from_kuid_munged(current_user_ns(), current_uid());
+	siginfo_set_uid(&info, current_user_ns(), current_uid());
 
 	/* Let the debugger run.  */
 	return ptrace_stop(exit_code, why, message, &info);
@@ -2836,8 +2842,8 @@ static int ptrace_signal(int signr, kernel_siginfo_t *info, enum pid_type type)
 		info->si_code = SI_USER;
 		rcu_read_lock();
 		info->si_pid = task_pid_vnr(current->parent);
-		info->si_uid = from_kuid_munged(current_user_ns(),
-						task_uid(current->parent));
+		siginfo_set_uid(info, current_user_ns(),
+				task_uid(current->parent));
 		rcu_read_unlock();
 	}
 
@@ -3639,6 +3645,7 @@ void copy_siginfo_to_external32(struct compat_siginfo *to,
 	case SIL_KILL:
 		to->si_pid = from->si_pid;
 		to->si_uid = from->si_uid;
+		to->_sifields._sir._uid_r = from->si_uid_r;
 		break;
 	case SIL_TIMER:
 		to->si_tid     = from->si_tid;
@@ -3678,6 +3685,7 @@ void copy_siginfo_to_external32(struct compat_siginfo *to,
 	case SIL_CHLD:
 		to->si_pid = from->si_pid;
 		to->si_uid = from->si_uid;
+		to->_sifields._sir._uid_r = from->si_uid_r;
 		to->si_status = from->si_status;
 		to->si_utime = from->si_utime;
 		to->si_stime = from->si_stime;
@@ -3685,6 +3693,7 @@ void copy_siginfo_to_external32(struct compat_siginfo *to,
 	case SIL_RT:
 		to->si_pid = from->si_pid;
 		to->si_uid = from->si_uid;
+		to->_sifields._sir._uid_r = from->si_uid_r;
 		to->si_int = from->si_int;
 		break;
 	case SIL_SYS:
@@ -3717,6 +3726,7 @@ static int post_copy_siginfo_from_user32(kernel_siginfo_t *to,
 	case SIL_KILL:
 		to->si_pid = from->si_pid;
 		to->si_uid = from->si_uid;
+		to->si_uid_r = from->_sifields._sir._uid_r;
 		break;
 	case SIL_TIMER:
 		to->si_tid     = from->si_tid;
@@ -3756,6 +3766,7 @@ static int post_copy_siginfo_from_user32(kernel_siginfo_t *to,
 	case SIL_CHLD:
 		to->si_pid    = from->si_pid;
 		to->si_uid    = from->si_uid;
+		to->si_uid_r  = from->_sifields._sir._uid_r;
 		to->si_status = from->si_status;
 #ifdef CONFIG_X86_X32_ABI
 		if (in_x32_syscall()) {
@@ -3771,6 +3782,7 @@ static int post_copy_siginfo_from_user32(kernel_siginfo_t *to,
 	case SIL_RT:
 		to->si_pid = from->si_pid;
 		to->si_uid = from->si_uid;
+		to->si_uid_r = from->_sifields._sir._uid_r;
 		to->si_int = from->si_int;
 		break;
 	case SIL_SYS:
@@ -4008,7 +4020,7 @@ static void prepare_kill_siginfo(int sig, struct kernel_siginfo *info,
 	info->si_errno = 0;
 	info->si_code = (type == PIDTYPE_PID) ? SI_TKILL : SI_USER;
 	info->si_pid = task_tgid_vnr(current);
-	info->si_uid = from_kuid_munged(current_user_ns(), current_uid());
+	siginfo_set_uid(info, current_user_ns(), current_uid());
 }
 
 /*
@@ -4979,6 +4991,12 @@ static inline void siginfo_buildtime_checks(void)
 	/* kill */
 	CHECK_OFFSET(si_pid);
 	CHECK_OFFSET(si_uid);
+	CHECK_OFFSET(si_uid_r);
+	BUILD_BUG_ON(offsetof(siginfo_t, si_uid_r) != __SI_UID_R_OFFSET);
+#ifdef CONFIG_COMPAT
+	BUILD_BUG_ON(offsetof(struct compat_siginfo, _sifields._sir._uid_r) !=
+		     __SI_UID_R_OFFSET);
+#endif
 
 	/* timer */
 	CHECK_OFFSET(si_tid);
-- 
2.56.0

