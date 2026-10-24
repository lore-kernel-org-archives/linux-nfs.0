Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792838337;
	b=hJJ07Rei9hbngkgU19SRz23qD8BPBHOPSoPqUPUpPwT8im4wH+BhX/3OY6cn5KRjKdsG
	 WuREuEpyU3ttMg2r+54UTwQb62vOkN6OON3jg+Aa9JFlSssUUl82PA+NfR7pceflJLNzp
	 P1zxYcl1niZ+XrgjVeBkgNIT8zmSzJBWZerAhwMRU+XIXxp3Lzl7J+tNfAtZ8U4W/HUqY
	 KamyztkYPvZew11kLIa75MXCSsEr4/ZrPsjpkPh3vj8+dG9LSffH7KW521CGuVdyg1pUg
	 aIkWxlN4QqbW+G0DS9BSZ+nDPks4tdZXM4g9vipyWNZ5LrTEE1djaHaSm/L5HQiR0lw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792838337;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=0lHnkOuzW8Rnw6mcuodZiLq72KKIiWbgdE/75Babj4M=;
	b=zZKAcUyOlCBTr9+0fvz7oqV1qikf/GQSWjaWDgEE/kObeGsBu0pYr7uctNKGvKXlTXfY
	 OeFee3RV5AP6ZizzA0zCPA+CAeJ9t1d5tUPfRkAT5GkfJRNSOdIQZZ+IXu1JmqYmZ3Z/Q
	 VYDs/naIjMbcWXGzpoxXLPHziykoCV/6JptIJkfbNKJk23oXSSldEuyel9Q9l+C70fxNz
	 X6OspfD/uC8oIbe8c1JOUYyaZjepvklu7AI3aGJfjuZjMeogK1+cmrrDIlgSmrXIGq3Oh
	 gIRrRqSZcEp3mA7k/Pa4ezGO1LE9owAvL1ernhgrj9srhnH7+wYYYpZWA3ivxnuScsw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XEU4BCR2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D3E28606A320;
	Sat, 24 Oct 2026 10:38:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XEU4BCR2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CB0B81F01828;
	Sat, 24 Oct 2026 10:38:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792838336;
	bh=0lHnkOuzW8Rnw6mcuodZiLq72KKIiWbgdE/75Babj4M=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XEU4BCR2VKMoONlmngrAj6jeUF223g+qZVlK39zJzhzTo0OkxQ7qemjY3/QSP34wM
	 mNZKf3f8Bl7cnZT+v9/AdDjIgWIKVXoRdW+Bl4arhOOQ8T7MJtpg4hj2Zk2V4wraTl
	 hVjPqawQBXyu32Qn8y2vU/QMYkUu9i8fGOTcVvm92i/JFFsWi93Ee97uZnyhsme/os
	 k5zmUWFT8sXv7Ws2xPb4ZdXyagpjL2jeJvx14TgFckz47CnqXAeZKrbDD1PLHd7NOu
	 6sPqDcZOHa6goeQnvB0yUK2SykJsUebeXmmgBB32OtQ8TzeFaoX1T8vARMObqIGWO4
	 lkTmvecJaCV9Q==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 24 Oct 2026 12:38:32 +0200
Subject: [PATCH 6/7] proc: explain which entries can't be mountpoints
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261024-work-procfs-fixes-v1-6-46b03c3a8fac@kernel.org>
References: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
In-Reply-To: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, 
 Aleksa Sarai <cyphar@cyphar.com>, Chris Mason <mason@kernel.org>, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1895; i=brauner@kernel.org;
 h=from:subject:message-id; bh=tsPQHLOVHinXpqTGb6E7fVo2+z3dPrBK0/xR9fIU6DU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWTd6Vq/0pTX58RLWcOJZ0+ZNH+sXziR/am6Nr9pzfHe4
 8bZInn3OkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYiLMzI0H3E3Epdca2sisu1
 rDUafy8HFm2vEF7rVdT29pxJ6YlDMYwMP3W5vq3Zlzap8J2LzIX3Z+qLeH8/mZM6jflDB3Njkjw
 XHwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Document how a failing ->d_revalidate() takes the mounts off a procfs
entry, which entries can't be mountpoints because of that and why the
other entries of a process are fine.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/internal.h | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index b9aaac41c283..296ea13bbd49 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -425,9 +425,21 @@ static inline void pde_force_lookup(struct proc_dir_entry *pde)
 }
 
 /*
- * Add a new procfs dentry that can't serve as a mountpoint. That should
- * encompass anything that is ephemeral and can just disappear while the
- * process is still around.
+ * Add a new procfs dentry that can't serve as a mountpoint.
+ *
+ * If ->d_revalidate() fails the VFS calls d_invalidate() on the dentry. That
+ * detaches every mount on it and below it, in every mount namespace, locked
+ * mounts included, and the next lookup creates a new dentry without them. So
+ * nothing whose ->d_revalidate() can fail while the process is still around
+ * may be a mountpoint: the entries below fd/ and fdinfo/ once the fd is
+ * closed, the entries below map_files/ once the mapping is gone and
+ * everything below net/ where proc_net_d_revalidate() fails on every lookup.
+ * The links into /proc/self can't be mountpoints either. A mount on one of
+ * them would redirect every process that walks through it.
+ *
+ * The other entries of a process fail pid_revalidate() only once the task
+ * is gone and proc_flush_pid() invalidates them when it is reaped. Mounts
+ * on them go away together with the task.
  */
 static inline struct dentry *proc_splice_unmountable(struct inode *inode,
 		struct dentry *dentry, const struct dentry_operations *d_ops)

-- 
2.53.0

