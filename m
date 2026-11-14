Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794653270;
	b=qyxKEwdZEPxkgLd79p3FQCnq8IaJXCuWbG0BHCA5OniaXNeT/9GWlhuhwxkkxbd1maYg
	 dAGbtml8aBLEval4E6dzGuO1aSYU27gpALKSjHXB5rYEZk/vJx4NVlR/iMUT5BEVTiiyJ
	 Nl5ivEAdivLpg8cB/qQQKJufyr2XlML/7Jt6bxLxkk1FMvyK0C4CH5RcwN3t7DXzU3b40
	 777/ZevX2G7hvZk5tEiPZMblxLmLQzrwtjJuWAjONBj2g1xuJeKUjAPSphKbdr8EnQyb3
	 KdRSjSE2gf/OZOUiVtOH0Fmh9hvqwwcqpA8Q48bPnJhhAXp6HSvYYWtWzyqfmly1tDA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794653270;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=aiYpXmGe/fYENsY2cEaqr+88QVJX1y5WFhqRFpjPy6A=;
	b=D9KQ7JGa42uuTSh6yT4B+q1jsGU8z60aV1VnsJxH9WBGDl1w3n4GrIDqDCGk88pbIDbe
	 dP6xZt8KoQETmhFwWOV5O7xL5SJT3i7M5NuO1kBTYtojB9EPm++obSL2sc/SbTI/3WTuD
	 2Ux+XLnR4LQwQxCgZ4nObxalpbiWnFeZfOrpa92Z7VWCEIVQAbmT38yLjDYQTaxHsUpyy
	 5YCqqpP6jJhF9+1S6oUHjbfGfv2s6KN/Ncph1uf8/QdET5E3Ks/2VqYM3ejm6+MDDrPe4
	 1igou341tMjgWTarRQZMmqPIkZIeCd1XDU4AoncGuQKgx2ZF3qa41UQK86A1JpOuH6Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=e0ClYM9e;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 239EA606A89D;
	Sat, 14 Nov 2026 10:47:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=e0ClYM9e
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2FAC81F000C5;
	Sat, 14 Nov 2026 10:47:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794653269;
	bh=aiYpXmGe/fYENsY2cEaqr+88QVJX1y5WFhqRFpjPy6A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=e0ClYM9eJkDr4OTfkRLUpfX0BDsHzQ87i+AOp/eGP+F7Yxp7J021askF1JW4AX7Js
	 RXvO1ca1Rj+y5e90w5eC6CQGZsRotFwhb9tRu9/T9tRCoxztB12Yb8S/ptTizsRUFx
	 Xn73LlQchFUSxVuqiFlZLcDHvwag2ljD2U1MEjggS6DtWuakCxOytLvpT+4cN3wk21
	 ioqWgu38F3yKc6w1SFvkx96RO5ZOy90zczZhWZQnJqR765mFcgCXPlpgxqVOjjDv6R
	 TYcgqLa5JKdtVt7iECf336A+ohy7e7U9f9YWa4MsOYginNEVnTa+S4FtU0bfXaVy5m
	 A9ZvM2132JE6w==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 11:47:08 +0100
Subject: [PATCH 01/12] fs: add kiocb_start_write_trylock()
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
Message-Id: <20261114-work-fs-frozen_writes-v1-1-f5ae61c898b1@kernel.org>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
In-Reply-To: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2642; i=brauner@kernel.org;
 h=from:subject:message-id; bh=2Po6bHdByqCno5Mh0RssbZ/s+w5+7TjOgXZhmuIK7vA=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9sLG1kJ3NbcfK+/mXpU7VzPwb67OOr83nu/nIuzJH5
 0XBurDejlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIm85GT4w/vjL5vgf+vmXYt/
 X7zCz3kiI4bL9ARDSMWn2bYGGwKvdjIyXJjue9YyU+3Yq9DfHyaZm6s8ai83Vr4QnnA6YvqVG0Y
 beQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

kiocb_start_write() waits until a frozen filesystem is thawed. A
nonblocking submission can't use it. io_uring open-codes the trylock
variant for its IOCB_NOWAIT writes.

Add kiocb_start_write_trylock() next to kiocb_start_write() and use it
in io_uring. The nvme target's file backend is going to need it as
well.

No functional changes.

Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 include/linux/fs.h | 22 ++++++++++++++++++++++
 io_uring/rw.c      |  9 +--------
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 99caef43ff3c4..eefc2c9d4af19 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2801,6 +2801,28 @@ static inline void kiocb_start_write(struct kiocb *iocb)
 	__sb_writers_release(inode->i_sb, SB_FREEZE_WRITE);
 }
 
+/**
+ * kiocb_start_write_trylock - try to get write access to a superblock for
+ *			       async file io
+ * @iocb: the io context we want to submit the write with
+ *
+ * This is kiocb_start_write() for a submission that must not wait until a
+ * frozen filesystem is thawed. Should be matched with a call to
+ * kiocb_end_write() if it succeeds.
+ *
+ * Return: true if write access was acquired, false if it wasn't.
+ */
+static inline bool kiocb_start_write_trylock(struct kiocb *iocb)
+{
+	struct inode *inode = file_inode(iocb->ki_filp);
+
+	if (!sb_start_write_trylock(inode->i_sb))
+		return false;
+	/* Fool lockdep just like kiocb_start_write() does. */
+	__sb_writers_release(inode->i_sb, SB_FREEZE_WRITE);
+	return true;
+}
+
 /**
  * kiocb_end_write - drop write access to a superblock after async file io
  * @iocb: the io context we sumbitted the write with
diff --git a/io_uring/rw.c b/io_uring/rw.c
index 3a8559ff4dc66..a0a16fc521455 100644
--- a/io_uring/rw.c
+++ b/io_uring/rw.c
@@ -1095,9 +1095,6 @@ int io_read_mshot(struct io_kiocb *req, unsigned int issue_flags)
 
 static bool io_kiocb_start_write(struct io_kiocb *req, struct kiocb *kiocb)
 {
-	struct inode *inode;
-	bool ret;
-
 	if (!(req->flags & REQ_F_ISREG))
 		return true;
 	if (!(kiocb->ki_flags & IOCB_NOWAIT)) {
@@ -1105,11 +1102,7 @@ static bool io_kiocb_start_write(struct io_kiocb *req, struct kiocb *kiocb)
 		return true;
 	}
 
-	inode = file_inode(kiocb->ki_filp);
-	ret = sb_start_write_trylock(inode->i_sb);
-	if (ret)
-		__sb_writers_release(inode->i_sb, SB_FREEZE_WRITE);
-	return ret;
+	return kiocb_start_write_trylock(kiocb);
 }
 
 int io_write(struct io_kiocb *req, unsigned int issue_flags)

-- 
2.53.0

