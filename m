Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827069;
	b=1ZYoByZeJzkhR3tqI14ge3dGzZmdAxskdObPfdWFUUe9+EPlymVku7GFazAqHM2RrmHO
	 TTXZ9Dp1zxeFswv9ewzZ1a3RN4M+NTJQ6xwkfnxmEB8xXIOj8znB0rPbTf7WF7MbUS83w
	 EtvE+U67nWM5pX1ADt96c0N0mLWgtQW8HDzH61g90CJO9rzMZdPu7TiAkfCRB4ws7eCIH
	 0IHJamU/JvD3uRJy3UnKFmNDeXrMQeHBCj0HlzYmw21LhGPymnZDM8hntA65+Y6NoHPJk
	 EJ9AXNKu4T7voh7dPQhUILXsXNcxcQigoQilUntc8wRBzblBq8uWuqEU5iikTWEpFnw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827069;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=X0sCUEjvhiXaIlHtE/D1yfoet6A6Fo7cZoSOfG4Vvvk=;
	b=0I93yNL+mekFdJrEOG6bovGj8J3QmvItY2ncYrSelZgaJiQO4DOb5bx8angE+49QJ5Ng
	 Xg274DXtf2Y//vK7g4UF3g+GnRbgVhd2WxirtijWdN1u9vrv7TODmnd54jY9XXCbOCTuV
	 rZjQGkNaDYQC5SNJ4rd1Z6q3Yzx6fDpO2NT/1VEw5OMu8djSH9mzdWyy7oVaVyJJt5w6m
	 mNhdvZtjkzsNL4U4z5mWV/GBqRqWOHAOeLaWDQVlUcb65N1cGPiTf6nk0rsj+jRalHWX7
	 6qjpjbN24FOpd50mAhBNgvuP/AR7jzJupsXZ/qOeqANVxZP8jW1JNi2icV3VweAdz7g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=E7dE9sA0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7478A606A31C;
	Mon, 16 Nov 2026 11:04:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=E7dE9sA0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 53D271F000C5;
	Mon, 16 Nov 2026 11:04:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827069;
	bh=X0sCUEjvhiXaIlHtE/D1yfoet6A6Fo7cZoSOfG4Vvvk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=E7dE9sA0NFotPY1Hmpef+yX6EVKmyEZjdmuQiS8zkWmLEf6oVBg+P/y8u1iC2VsSf
	 KPFC2A4GL6EeWGTtHTjKLv6vVEn8sZOuxZf4rZDtykol7l3CrYlsW4T5mw0xu3qBEV
	 7LznvLrzKaJzA3n9bv7cM4XtzgxsAusUReLQh/BKFnpTJ7/UCaxlryrmTSIrwOcoqE
	 qvpgsPpdJ04xOOR5fvds3g+sn2Nwc1+6noHYyPsEea6wmsIvtnWKeLd/KXdZWSySQQ
	 7gMZBSnpJRRXACcnPvNdyZKeXOAu+0rozTj2AnvAhz8vKrDYBWHwpHEYvetpCpeRSi
	 YvGw33FnbFpFA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:41 +0100
Subject: [PATCH v2 01/17] fs: add kiocb_start_write_trylock()
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
Message-Id: <20261116-work-fs-frozen_writes-v2-1-ecc4a2aac40e@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2629; i=brauner@kernel.org;
 h=from:subject:message-id; bh=NKIuUXH/Pq/hGo26my0gWyXbRVtNRh9yNGadVxnLh0A=;
 b=kA0DAAoWkcYbwGV43KIByyZiAGr64x6jr5HzBoMm9JHxVLP/a5mgPg3IDGB3pF70rIslLrhdQ
 4h1BAAWCgAdFiEEQIc0Vx6nDHizMmkokcYbwGV43KIFAmr64x4ACgkQkcYbwGV43KLhWQEAqyQj
 7ka5/1GeFoOdt2YbWBYlOiN+vUkCDQMESc0F4i4BALZH1O+ebV3EQlAyMawIipKAH2lTL5MbwYU
 m5tZ0Xy8M
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

kiocb_start_write() waits until a frozen filesystem is thawed. A
nonblocking submission can't use it. io_uring open-codes the trylock
variant for its IOCB_NOWAIT writes.

Add kiocb_start_write_trylock() next to kiocb_start_write() and use it
in io_uring. kiocb_write_iter() is going to need it as well.

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

