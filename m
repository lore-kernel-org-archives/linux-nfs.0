Received: from mail-oo2-f43.google.com (mail-oo2-f43.google.com [74.125.231.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51DC04A1DEC
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 15:29:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790263751; cv=none; b=azdFsOTlzEx41znMgfjVodOLr/oif8TxMMOiSLB+ZePbF5k+Dli5et8/cYJVWYn8AEFqGdT/U0XoOVL/wEfiieYqP191kglnujgx8HZLcCcJ/FAzl84zhJtu6A9NQ6PUQBYCWdU0F89jQCpLZh6oKwzmPS83gk3N0MfUGLgYm9c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790263751; c=relaxed/simple;
	bh=qLfFB474/65iE/AQ4j8y7aKK8cp+TO5c1Zseclrp7vs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Svu8t+ThrMc5cUoLpHQQpdmqHAFh+I8HQTgrXZKII41zScDH4EeiJDEBUlbYSFfRgPARQkEU+BZtO3mZJbWfiUbncC0mmBv1S2HfXikYkomVhWeHNHhIxA7ek1Lfuix7rEosRW0by/+QD9kulet90MhWAGtnZfizTM14AuI2Ssw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=nn/yHID+; arc=none smtp.client-ip=74.125.231.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="nn/yHID+"
Received: by mail-oo2-f43.google.com with SMTP id 006d021491bc7-6b1ae7166ebso1431212eaf.1
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 08:29:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790263747; x=1790868547; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=7g5mr8A2hrf4mPl1gXfjFn74KcPeh3R5nBGnQZhifcg=;
        b=nn/yHID+dNKNUfIe1V7YWP19wt61HiyN8kpDtrH2AKParitG1jVW+A/WGFNAGystus
         SWpff+CSthNC2o0OmDkKJFAqspLR720O0lm2d41+05hp3LH1f1csmnvVf7kod16zddQy
         bumPK/sI4rMAtl1R3cU9auRRHu6ebPOsRTqdPMmYMzU7ooQpnylHhAMzexbMz3amB7mP
         gwy/1ahHoM0eGv6nRy9I82oob7fDl65ufdbREmxtlq40TKDbNXYXoP/DV6N1lFUxeISC
         bmCjAwtM5HkNbrYJDTQ6qd9TV0rf9owpf3C74p1gPEMSkKI+HRn9pE5WtTx6/bgcIVq5
         v1hA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790263747; x=1790868547;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=7g5mr8A2hrf4mPl1gXfjFn74KcPeh3R5nBGnQZhifcg=;
        b=VRBGUFCEc3BS3Y+8uND5HrteilNMDDiiYfcxAKH8zOWUSANELN+V7aXw9dQvOe/3Pz
         x9yNDJFKGk8atmKGuwBCrlh8WByRtq51gUPCxo+flGFPdA3NyAIpwdFmOa2JkZwi+bE1
         +Yf7cQ7oGz/MCpy7jGpNEET90SCKom0eyLvoZKeZb/64Bp4AzblMnhZIz6uYbRFyjhpr
         66XStx/kutMmfuCDvdjtAHsrEcCHXljI/gZMi6CpCAXwLHHtDUWdp/+qQBtmYMv6U8Ju
         dxO3x9Zu3KbgdOdCiLpBQkg2WdmMGspxdUtu9RbM/7PwysQqJO7TjNTBe84i1kbsG3tj
         rkTA==
X-Gm-Message-State: AFuF++nSsLY+w3ihwDj/hyPZ1EH7h8utTW8lAEs0lnR1XIFV5WcZU+id
	wmQinpbMCvlCxg7p5nIyR5GDB8sYWMIcbL18YO8+lVEhxP0Rv6A5AMz93COULQ4BQ0oXSPu2jWD
	6Ip4y
X-Gm-Gg: AYBFou0hD8g6fylc7O08a3z0ZeIARF9SLJ0+E/e0Dn/xON3oLYVxAXmoC8bwmlUeVgR
	4w6krM0UBkVYYaQWbnqhdJHuTr3kZqUNXhe3wbQcE+CgRyEwcxGQqaT3mNSceuUDRLVS6Y7NwLe
	AET4jKDsPBjiuE/zf+XO+k2ky1QKgc5Ex51hnLZjn07hQZ1GpS61VyqIv2Rs/Ad8i9bvNgyOCNy
	ouTFBr6RW5Ggs5KEXQeJfrViyi2q/XrKErTiMJYBTpDczlh9WlAYMkrUIWxk6q2NM8pn4ynhl49
	fyXZqO4pnR5P+rFcM645dOLeCWlMWfXgwLApJL8POW9evgSowV7fd7sAlTVi46W6FpEJ2x3DQJI
	G2KRjqDpGemAp/I1DVl/qe5HDDb9elEzcUpQRlEaubQqwCtpXPEyiI4gks2m+EhM5dHQB3kSlmz
	OY+8ehsVFxF0aUsMc5LffUZDJZ4x0AQ/EwTBaWWoKdHX1RfAHB6bcr6K7GGq6yUQvqndMXSVb4e
	JVh3IKdmnBLOKPjcxBrNbDX7KKqRD/2OIVA5QcCub8w
X-Received: by 2002:a05:6820:1998:b0:6cd:3ffc:ad00 with SMTP id 006d021491bc7-6d441c7dfc8mr2762089eaf.80.1790263746747;
        Thu, 24 Sep 2026 08:29:06 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-81603ad2b19sm6551506a34.4.2026.09.24.08.29.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 24 Sep 2026 08:29:06 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] support/export: take SIGINT/SIGTERM/SIGHUP via signalfd
Date: Thu, 24 Sep 2026 11:29:01 -0400
Message-ID: <3dac2744458924f67e0890996bd73f4eb2ad2079.1790263469.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1790263469.git.bcodding@hammerspace.com>
References: <cover.1790263469.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

mountd and exportd exit from a signal handler that unregisters with
rpcbind, frees memory, logs and calls exit().  None of that is
async-signal-safe.  We have a core from a mountd that took SIGTERM while
pthread_create() was allocating TLS for the nfsd_path workqueue thread;
killer() went on to calloc() in clnt_vc_create() and glibc aborted with
"malloc(): unsorted double linked list corrupted".

Add cache_block_signals() for the daemons to call in place of installing
handlers.  It blocks the three signals and opens a signalfd that
cache_process() reads in its normal loop; cache_stop_signal() tells the
caller when to shut down.  SIGHUP is logged and ignored there as before.

Workers close the signalfd and unblock, so they still die of SIGTERM.
The parent of the workers keeps a handler, but all it does is send
SIGTERM to the process group once.  cache_wait_for_workers() now retries
on EINTR, and the caller's existing "no more workers" path cleans up.

ha_callout() clears the signal mask in its child before exec, since a
blocked mask survives exec.

Assisted-by: LLM
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 support/export/cache.c       | 122 ++++++++++++++++++++++++++++++++++-
 support/export/export.h      |   2 +
 support/include/ha-callout.h |   5 +-
 3 files changed, 127 insertions(+), 2 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index a5e95afd37ba..7f7f9ad17ef6 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -13,10 +13,12 @@
 #include <sys/sysmacros.h>
 #include <sys/types.h>
 #include <sys/select.h>
+#include <sys/signalfd.h>
 #include <sys/stat.h>
 #include <sys/vfs.h>
 #include <sys/wait.h>
 #include <time.h>
+#include <signal.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <unistd.h>
@@ -3880,6 +3882,76 @@ int cache_process_req(fd_set *readfds)
 	return cnt;
 }
 
+/*
+ * SIGHUP, SIGINT and SIGTERM are held blocked from cache_block_signals()
+ * on, so no handler can run while the daemon is in the middle of malloc()
+ * or anything else that isn't async-signal-safe.  A single-process daemon
+ * reads them from cache_sigfd in cache_process().  Worker children get the
+ * default actions back, and the parent of the workers takes them with a
+ * handler that does nothing but pass SIGTERM on to the process group.
+ */
+static int cache_sigfd = -1;
+static volatile sig_atomic_t stop_signal;
+
+static void cache_signal_mask(sigset_t *mask)
+{
+	sigemptyset(mask);
+	sigaddset(mask, SIGHUP);
+	sigaddset(mask, SIGINT);
+	sigaddset(mask, SIGTERM);
+}
+
+/**
+ * cache_block_signals - start taking termination signals via signalfd
+ *
+ * Call this where a daemon would otherwise install its SIGTERM handler.
+ * Once cache_process() has picked up SIGINT or SIGTERM,
+ * cache_stop_signal() returns it and the caller should shut down.
+ */
+void cache_block_signals(void)
+{
+	struct sigaction sa;
+	sigset_t mask;
+
+	cache_signal_mask(&mask);
+	if (sigprocmask(SIG_BLOCK, &mask, NULL) < 0)
+		xlog(L_FATAL, "cannot block signals: %m");
+
+	/* An ignored signal is discarded, not left pending for signalfd */
+	sa.sa_handler = SIG_DFL;
+	sa.sa_flags = 0;
+	sigemptyset(&sa.sa_mask);
+	sigaction(SIGHUP, &sa, NULL);
+	sigaction(SIGINT, &sa, NULL);
+	sigaction(SIGTERM, &sa, NULL);
+
+	cache_sigfd = signalfd(-1, &mask, SFD_NONBLOCK | SFD_CLOEXEC);
+	if (cache_sigfd < 0)
+		xlog(L_FATAL, "cannot create signalfd: %m");
+}
+
+/**
+ * cache_stop_signal - the SIGINT or SIGTERM that asked us to exit, or 0
+ */
+int cache_stop_signal(void)
+{
+	return stop_signal;
+}
+
+static void cache_read_signals(void)
+{
+	struct signalfd_siginfo si;
+
+	while (read(cache_sigfd, &si, sizeof(si)) == sizeof(si)) {
+		if (si.ssi_signo == SIGHUP) {
+			/* don't exit on SIGHUP */
+			xlog(L_NOTICE, "Received SIGHUP... Ignoring.");
+			continue;
+		}
+		stop_signal = si.ssi_signo;
+	}
+}
+
 /**
  * cache_process - process incoming upcalls
  * Returns -ve on error, or number of fds in svc_fds
@@ -3897,6 +3969,8 @@ int cache_process(fd_set *readfds)
 	}
 	cache_set_fds(readfds);
 	v4clients_set_fds(readfds);
+	if (cache_sigfd >= 0)
+		FD_SET(cache_sigfd, readfds);
 
 	if (delayed || delayed_expkey || delayed_export) {
 		time_t now = time(NULL);
@@ -3938,6 +4012,11 @@ int cache_process(fd_set *readfds)
 		return -1;
 
 	default:
+		if (cache_sigfd >= 0 && FD_ISSET(cache_sigfd, readfds)) {
+			cache_read_signals();
+			FD_CLR(cache_sigfd, readfds);
+			selret--;
+		}
 		selret -= cache_process_req(readfds);
 		selret -= v4clients_process(readfds);
 		if (selret < 0)
@@ -4100,6 +4179,8 @@ cache_wait_for_workers(char *prog)
 		if (pid < 0) {
 			if (errno == ECHILD)
 				return; /* no more children */
+			if (errno == EINTR)
+				continue; /* cache_parent_signal() */
 			xlog(L_FATAL, "%s: can't wait: %s\n", prog,
 					strerror(errno));
 		}
@@ -4137,10 +4218,26 @@ static struct nl_sock *nl_cmd_sock_reopen(struct nl_sock *old)
 	return sock;
 }
 
+/*
+ * SIGINT/SIGTERM handler for the parent of the workers.  Only
+ * async-signal-safe calls here: the workers die of the SIGTERM,
+ * cache_wait_for_workers() returns, and the caller cleans up.
+ */
+static void cache_parent_signal(int sig)
+{
+	if (!stop_signal) {
+		stop_signal = sig;
+		/* play Kronos and eat our children */
+		kill(0, SIGTERM);
+	}
+}
+
 /* Fork num_threads worker children and wait for them */
 int
 cache_fork_workers(char *prog, int num_threads)
 {
+	struct sigaction sa;
+	sigset_t mask;
 	int i;
 	pid_t pid;
 
@@ -4184,7 +4281,6 @@ cache_fork_workers(char *prog, int num_threads)
 			 * so that workers die naturally when sent them.
 			 * Only the parent unregisters with pmap and
 			 * hence needs to do special SIGTERM handling. */
-			struct sigaction sa;
 			sa.sa_handler = SIG_DFL;
 			sa.sa_flags = 0;
 			sigemptyset(&sa.sa_mask);
@@ -4192,12 +4288,36 @@ cache_fork_workers(char *prog, int num_threads)
 			sigaction(SIGINT, &sa, NULL);
 			sigaction(SIGTERM, &sa, NULL);
 
+			if (cache_sigfd >= 0) {
+				close(cache_sigfd);
+				cache_sigfd = -1;
+			}
+			cache_signal_mask(&mask);
+			sigprocmask(SIG_UNBLOCK, &mask, NULL);
+
 			/* fall into my_svc_run in caller */
 			return 1;
 		}
 	}
 
 	/* in parent */
+	if (cache_sigfd >= 0) {
+		close(cache_sigfd);
+		cache_sigfd = -1;
+	}
+	sa.sa_handler = cache_parent_signal;
+	sa.sa_flags = 0;
+	sigemptyset(&sa.sa_mask);
+	sigaction(SIGINT, &sa, NULL);
+	sigaction(SIGTERM, &sa, NULL);
+	sa.sa_handler = SIG_IGN;
+	sigaction(SIGHUP, &sa, NULL);
+	cache_signal_mask(&mask);
+	sigprocmask(SIG_UNBLOCK, &mask, NULL);
+
 	cache_wait_for_workers(prog);
+	if (stop_signal)
+		xlog(L_NOTICE, "%s: caught signal %d, workers stopped",
+		     prog, stop_signal);
 	return 0;
 }
diff --git a/support/export/export.h b/support/export/export.h
index e2009ccdc443..801fb01cbd89 100644
--- a/support/export/export.h
+++ b/support/export/export.h
@@ -32,6 +32,8 @@ int		cache_export(nfs_export *exp, char *path);
 int		cache_fork_workers(char *prog, int num_threads);
 void		cache_wait_for_workers(char *prog);
 int		cache_process(fd_set *readfds);
+void		cache_block_signals(void);
+int		cache_stop_signal(void);
 
 bool ipaddr_client_matches(nfs_export *exp, struct addrinfo *ai);
 bool namelist_client_matches(nfs_export *exp, char *dom);
diff --git a/support/include/ha-callout.h b/support/include/ha-callout.h
index a454bdbdb708..bb2ccfd93470 100644
--- a/support/include/ha-callout.h
+++ b/support/include/ha-callout.h
@@ -42,7 +42,10 @@ ha_callout(char *event, char *arg1, char *arg2, int arg3)
 	sigaction(SIGCHLD, &newact, &oldact);
 	pid = fork();
 	switch (pid) {
-		case 0: execl(ha_callout_prog, ha_callout_prog,
+		case 0: /* mountd keeps SIGTERM et al blocked for signalfd */
+			sigemptyset(&newact.sa_mask);
+			sigprocmask(SIG_SETMASK, &newact.sa_mask, NULL);
+			execl(ha_callout_prog, ha_callout_prog,
 				event, arg1, arg2, 
 			      arg3 < 0 ? NULL : buf,
 			      NULL);
-- 
2.53.0

