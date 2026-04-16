Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51783331A4C;
	Thu, 16 Apr 2026 17:35:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776360941; cv=none; b=eYe5I4mcR4auikM+Nnkh/zvvSW2WUEWrsvydJYpz6lPPHrepP0V1FIBBsHbtBI9RR0KMztDX5/ui2HzKNE0nDSFt5Y5PlSWD3aafMCoL+nP4Q8Wp+V6k/m8aD6P0cn/al6+RqmqxPu/K/ZUtNCZ88XR+KtW2cPalal7FuTWBrMA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776360941; c=relaxed/simple;
	bh=Z6rw+qotRNoi947YYJDbytbTTUU2Qh+ITj4J1EtYoTc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=IeSNGiHwHLuybOleqadd17s8FEIJeG6edauihoIrmWH4UkOAD+8jwNOyKTAgBT2IVOAgd9BWILvrYq3UFa3jpdnCErHG0mgfTTtpXPKCFOdSPAn/nNYb1dWuQh7zXmRFG8DSdS3PQZV2OJ9TqsmoF/PtvJSs5YsejADcUi/GpRk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nB+npK/5; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nB+npK/5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 58668C2BCB0;
	Thu, 16 Apr 2026 17:35:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776360941;
	bh=Z6rw+qotRNoi947YYJDbytbTTUU2Qh+ITj4J1EtYoTc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=nB+npK/5AUmlpcBlR3loUds30VYw1bcYmsytHjCvKBTjR5AyBqcJ9IKzavM/u9+l2
	 e1aMHd3mwMpRw/tdzfCuUMVevc6qMaj+5bWFqMEvhjP9EIiH10zhq7T9OzmVDm6Dgx
	 /BBaX30vaqYl6oldmLuesR/ldYEGmgtzpVa8d/4/BOo2MijpgAuIQ5eZpUaDzCu0yb
	 6EgGUEwsSI41Oo7Fp4PHC2bkPl8qolYlICnr9e24hjrOw3bTfYE7InbTWMtBK9hOXF
	 V9Xp4oiKtVf/n4omoM/pVc/MpbRkzzTH0mVjNGkzNoNk/RIUY28yaMhc84R5ChLePy
	 6BQ064XqqwZ9A==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 16 Apr 2026 10:35:05 -0700
Subject: [PATCH v2 04/28] filelock: add an inode_lease_ignore_mask helper
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260416-dir-deleg-v2-4-851426a550f6@kernel.org>
References: <20260416-dir-deleg-v2-0-851426a550f6@kernel.org>
In-Reply-To: <20260416-dir-deleg-v2-0-851426a550f6@kernel.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
 Chuck Lever <chuck.lever@oracle.com>, 
 Alexander Aring <alex.aring@gmail.com>, 
 Steven Rostedt <rostedt@goodmis.org>, 
 Masami Hiramatsu <mhiramat@kernel.org>, 
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Amir Goldstein <amir73il@gmail.com>
Cc: Calum Mackay <calum.mackay@oracle.com>, linux-fsdevel@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2251; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Z6rw+qotRNoi947YYJDbytbTTUU2Qh+ITj4J1EtYoTc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBp4R3izrjJLMf/CvpujB15OqjdOFBHFAlWZ9brn
 AoYQONh+9qJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaeEd4gAKCRAADmhBGVaC
 FWGUD/9a73g7s0beUr7v0CphMarQ+zT9kxBfuAD+wgsFT72A5SVYLKaH9i77EwTuTymcbxlx1SZ
 anomX1ig7VUkOP0FbOMEtYLtJGRSTJn+cSUBt2YfnScuMIoZYrTJMcpm8imMyBhlri61pSQcgV4
 9d+i2MOlqUGgM69uoYrV07eV87q0GWUPXSIufgpLQwAVaFPCVpbWVOcVQv88T+MSr7QJYWyqZgB
 NKXU7Zgr1IIvw2As0Gn6bjYdar1nGn0V8U5bue1VKqHdxtil6bxeeMhpr7Ltf7+/qvPDuXHW4oB
 pIYawKuaMtAloj/CTJGIFB2kOaXfZRCyNbqHZElOVNwyju9Uj+LJdWdyQOBji7Z5uLgxM1OY6wE
 exvvvGduXvOEAi/C7XFqY2kGqciCCTZ/zSk3v4uNNAluVxCo/x7JXuXnXnR7e+JsKMF4NVE0maY
 +DOJjAzTQo2bohoYOQ7dEuzJJymsTLceXHXhoIEwMFZmy+eNYuhMHyLe+0B3z+SxVifQmIP3O6N
 koB6hcOOqEZ7EILjxruQJGfnehjvYqJ9fRb8/nVvj87rnEVRS9fZdzR1KENfn76xay/bDi8rh70
 X/WHdXOjiXuXWA1sqk2GCRWdHkmNW9MCYVOiEJdkRm8cEEDHRLH6Iwdqsfp5vLh6kmC2xsNMyXC
 cCKwMSUicWpEdHQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Add a new routine that returns a mask of all dir change events that are
currently ignored by any leases. nfsd will use this to determine how to
configure the fsnotify_mark mask.

Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/locks.c               | 32 ++++++++++++++++++++++++++++++++
 include/linux/filelock.h |  1 +
 2 files changed, 33 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index 792c3920b33a..61f64b261282 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1582,6 +1582,38 @@ static bool leases_conflict(struct file_lock_core *lc, struct file_lock_core *bc
 	return rc;
 }
 
+#define IGNORE_MASK	(FL_IGN_DIR_CREATE | FL_IGN_DIR_DELETE | FL_IGN_DIR_RENAME)
+
+/**
+ * inode_lease_ignore_mask - return union of all ignored inode events for this inode
+ * @inode: inode of which to get ignore mask
+ *
+ * Walk the list of leases, and return the result of all of
+ * their FL_IGN_DIR_* bits or'ed together.
+ */
+u32
+inode_lease_ignore_mask(struct inode *inode)
+{
+	struct file_lock_context *ctx;
+	struct file_lock_core *flc;
+	u32 mask = 0;
+
+	ctx = locks_inode_context(inode);
+	if (!ctx)
+		return 0;
+
+	spin_lock(&ctx->flc_lock);
+	list_for_each_entry(flc, &ctx->flc_lease, flc_list) {
+		mask |= flc->flc_flags & IGNORE_MASK;
+		/* If we already have everything, we can stop */
+		if (mask == IGNORE_MASK)
+			break;
+	}
+	spin_unlock(&ctx->flc_lock);
+	return mask;
+}
+EXPORT_SYMBOL_GPL(inode_lease_ignore_mask);
+
 static bool
 ignore_dir_deleg_break(struct file_lease *fl, unsigned int flags)
 {
diff --git a/include/linux/filelock.h b/include/linux/filelock.h
index 9dd4e67a6f30..6e125902c58a 100644
--- a/include/linux/filelock.h
+++ b/include/linux/filelock.h
@@ -236,6 +236,7 @@ int generic_setlease(struct file *, int, struct file_lease **, void **priv);
 int kernel_setlease(struct file *, int, struct file_lease **, void **);
 int vfs_setlease(struct file *, int, struct file_lease **, void **);
 int lease_modify(struct file_lease *, int, struct list_head *);
+u32 inode_lease_ignore_mask(struct inode *inode);
 
 struct notifier_block;
 int lease_register_notifier(struct notifier_block *);

-- 
2.53.0

