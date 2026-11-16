Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827077;
	b=ZC9Cz7U9hnEQTMdUtTD8I/BPz8e/U0KtZE9TBAmCmcnmq+xOSEENWIu8V2pb7MpZliQp
	 PJ7wzDlDvdl27QHQBG5XQfHpnBca1ftsam5h/BK2eNsHzoGD8wztppLGAaYgripe3ujZa
	 YjuEkdO4pGeBNbN7ooD5TYkvkF8zQb/4mwS/g4mOOo6HYJswmLqrYJYty7k8YKB1XUF9j
	 qugKAsj0q0Osqjc8kEtJOdYgtXb50F5dmtJLJqxi2Om3HP9Q7u1hMtbTQ4bXgp8mueSEy
	 DLHYOEnXgAs8ySXoSPTugcAJmPeQ9K3CE5IDqhelQo/WrwYS+QLfWm/3ydhJURpfFyQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827077;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=726hiCwS88TGvIdtuykXMk2SiBm2dzdYT7UT/Qe3T98=;
	b=av26YnZ70Vguq/EBFyg8JhkVGA4jdESkJwRuf7A7PkVX4v02TGyIzKUdnGWMAdyExYKd
	 v8ek3pg++tSJ5NqcpuqZAYokR4/5BZscd4WCkWDZdM95YtMZ4CUZe5krXRRMDunD0Nbmq
	 RtBJE7ztv13lwVlZv9uqp3GXj7yawKGWqma/UXMfIAsC0ep8UW924y3t+I+msiGylkeUJ
	 YLhsfb8M/Bh2YxGWsMGmGGh44BZwKPid9nBg0AAuT2h05NpQPUnBboLpZRpMwPQqR1ceh
	 +dC802J5qE5QThNBgVUZ4K7pkwHnn1u+0XHdtotE8HZecKssvAfKmgf50eaS+kcU67w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=H40xH7L5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A01C9606A33E;
	Mon, 16 Nov 2026 11:04:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=H40xH7L5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9212F1F000C4;
	Mon, 16 Nov 2026 11:04:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827077;
	bh=726hiCwS88TGvIdtuykXMk2SiBm2dzdYT7UT/Qe3T98=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=H40xH7L57ZEDZz7B+7LIQF2jQ/Xf2m6GTvcanzWxjnL8UjfgFbGG1wvTlstwfnipJ
	 ZYebSMKBzmZ4lwUKVPoyrje4WPuxGo8fOZdjd+15EgtH3bMNTghsrUXngiXAgFqzZ1
	 pZwJVWhcEcC98kYL8ck/smYBHqAxlI1bHYT9ln4mAiXwnlFbS59vZ1cSlr6ZyWyZs4
	 ox7gdEb7OhR1T31Ob0agig8q65ON49URlthX+/fmJ8vcVD4xmOaKi12A9/SABvO1f4
	 99quiZTKYHLD/hQUzWM8QBKgH7c33XxhL1hel5yYqVPAxQUW2opEv+dPb3VNq2Xdcb
	 oARYOOtu/aLQQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:43 +0100
Subject: [PATCH v2 03/17] fs: add file_write guard
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
Message-Id: <20261116-work-fs-frozen_writes-v2-3-ecc4a2aac40e@kernel.org>
References: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
In-Reply-To: <20261116-work-fs-frozen_writes-v2-0-ecc4a2aac40e@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeel.butt@linux.dev>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
 io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
 linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
 linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
 linux-nfs@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=768; i=brauner@kernel.org;
 h=from:subject:message-id; bh=+PyXE2DjqfV9gzlbEjY4C40DfRKNqWnhjaRkPLLRvfw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqx49Vsiy3qXgJnHLG4vF3+7/MXDMA73M86Pi61+p
 f4LTD26s6OUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAim34x/LOaP0mtdX066139
 16Y3Ocv/HbjhHpEcfKUprlagUVK87QwjQ/+foMaVL3U4n82qbtl0UpF/b5q3UtnZb1fCBDwzb31
 w4QYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Add a guard for file_start_write() and file_end_write().

Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 include/linux/fs.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 0b66a09fb686a..c156a326e8c89 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2782,6 +2782,11 @@ static inline void file_end_write(struct file *file)
 	sb_end_write(file_inode(file)->i_sb);
 }
 
+DEFINE_GUARD(file_write,
+	     struct file *,
+	     file_start_write(_T),
+	     file_end_write(_T))
+
 /**
  * kiocb_start_write - get write access to a superblock for async file io
  * @iocb: the io context we want to submit the write with

-- 
2.53.0

