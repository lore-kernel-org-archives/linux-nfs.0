Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794653301;
	b=BWmA5i4GQSy5AERzJ1qCgN6EOR+9Z4ImOJJyWoDNgTALh02HfKkiQtlDqW1C97ZLIfzx
	 CNMvg3ouM0M7Bf/YxGFcUlnVmDMx/4Nl0MpQWmtO/tYFDROM2R/Ek629gs/NMGeTliijc
	 +O3AzvBcWIfqpJEfE8fd+6oIWJ/HJLI75XfGU52tn4Ewzy7aaaU3hmNbkDoexva674TU0
	 Ua3MCkHuF6Iv740oU1pPyuDzQUMpYVc2FGurWqhDkwWC6j4oYS44R0OmFJPIi1I6UmUW6
	 COcxoAOWqIVSkxrjS96yr+1WUS0M0p++Qe1PPXHP+Nc0R5/SLAA59tHEXp10JXyEfBw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794653301;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=pjbhVx2fs5v7PEkUYOgJa+aS4bC1ZGO8oQVzHBWC01U=;
	b=QAjSL+4UMiEOLyG8B/fhsSnhVdU5qXgJTr8S8Sx3mahrsoe1E0PqtL9K32y3AoHyKceh
	 PvAhIPLNKhA/Cf4SZ2uvCiqqwGprsqajyU6YSISNbIVvmP8GCq4sNR//zNRvTBs+GXx4K
	 d2gwgjW40EqwT+5Uah4uDQX7eoyuKe3DDmponBaLoG7PG2whrjozJbSgcRqx+qlNX38+T
	 GPZKt6NnRk1GH5p5I+EzG3ngEZGd+jFw4qx4Spl+e4wvd48DCfRN1ganWQVvBlGSfAOyL
	 /Oq/8/RKupHU89KBnsl3DzdKGVbYN6ZzzIc8mo3MWIrVRynHrMDRhCgXRSwjGkXQ+tw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Af+KKCs4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D0BF060A6F71;
	Sat, 14 Nov 2026 10:48:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Af+KKCs4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DB7AC1F000C5;
	Sat, 14 Nov 2026 10:48:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794653301;
	bh=pjbhVx2fs5v7PEkUYOgJa+aS4bC1ZGO8oQVzHBWC01U=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Af+KKCs45CAl7fomaGE+uUOySiwEadp9iG1LotBHwhmhbghDQTIHCPSuh6eDy1e0P
	 Fnd1yVYV2Y5wDitIEf/NJcz++yTe0hJZbxOjRSoaQMibUYt4hRs15JM/1YKCmWuwHs
	 3hjcXUrJjY4kESZeln2Z+kqoXaLfu/Rin3xwffDJbUAG9liYRqNnu/4HZRUBCHGmil
	 ef8H4xARIwaAZM0JMbVOL2nhyeZWBNJj5g6BcBLFmyUsVhRxG5HpU9MplP3aYwCqXo
	 m2gm6RCzHr5UE46ZXE3xH8jPlFrd7uZBmAgT5xivoAioLXGpHADKB3F4ybToeszXwK
	 unVsVQJuFNETA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 11:47:16 +0100
Subject: [PATCH 09/12] coredump: take freeze protection for the truncate
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
Message-Id: <20261114-work-fs-frozen_writes-v1-9-f5ae61c898b1@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1200; i=brauner@kernel.org;
 h=from:subject:message-id; bh=34ncq8Kdq+MSTLVnNDtgt7r/DShig8xHabTi/tdVmLw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9sHE//KxCTm/yQQbrTLaAG2s4RYXWfBTX5mt5mD7ZT
 2gfb7NYRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwET+PWH4X+bDXclb0HDtNpeZ
 5PPGQxfuqW20XvRg28kO7XU7H+XMaGJk+NGZaeWr687tmjInzW3nouY5zUEmt8+0ccY1NunfOPW
 QCQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

coredump_file() truncates the core file after filp_open() returned.
The open took freeze protection for the create but dropped it again
before returning and coredump_write() only takes it for the dump
itself. So a freeze that lands in between lets the truncate modify a
frozen filesystem.

Take freeze protection around the truncate like do_ftruncate() does.

Fixes: 14da9200140f ("fs: Protect write paths by sb_start_write - sb_end_write")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/coredump.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index 82ef9d115999a..cc6a0c7e48ce2 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -1060,8 +1060,10 @@ static bool coredump_file(struct core_name *cn, struct coredump_params *cprm,
 	}
 	if (!(file->f_mode & FMODE_CAN_WRITE))
 		return false;
-	if (do_truncate(idmap, file->f_path.dentry, 0, 0, file))
-		return false;
+	scoped_guard(super_write, inode->i_sb) {
+		if (do_truncate(idmap, file->f_path.dentry, 0, 0, file))
+			return false;
+	}
 
 	cprm->file = no_free_ptr(file);
 	return true;

-- 
2.53.0

