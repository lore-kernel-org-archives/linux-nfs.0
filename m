Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827111;
	b=J47bYENmhMuh3Y246mOw8HVf8yULetcPiIveMCR26fZXVHHpAL56yf1OUaDqP8ATjHLh
	 y1/PrBaEFKozXsMNNJe8FDQCipBA1pHAD9LoFiogmc3d0wv2wl8rFACz8ydPAgAxuCyjK
	 UTnX9HNaY0Kj4EwjRM+ruGU/txzTUJWWX4whfadj0P9gORwBm94kq5qBBeWFKZc9ehMQc
	 hkWELrGcsxEqlDPPeLwPukFem1iaWRbxXX1TM+QizGRGbse7aOJfuBIQpinjKru9GMs/q
	 YrIxKtgWsoMXfzZl4icsdGpFfetRQiPY9ohZDXdSdmTJin9H/8EGuB3i8mM+eHMTRQw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827111;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=pjbhVx2fs5v7PEkUYOgJa+aS4bC1ZGO8oQVzHBWC01U=;
	b=HjnOYxMWvKrAP+GBdPfdRjMrpyqgKFShGS7BS/HVCynSNw//XvrIx8xllR6+654Q1MnR
	 dd7YYqvjc5IdvXYvAgU6DTc4bfQkgzBuA6EpZoCSAxt6loh8LcohnAVaxg8V1pGwMCsqj
	 H9/YJAGb9t47qwgl0MOKWU85QWeQwVWTahaLBDygsV/t22KjS/vrCLUzPyY2HBqKqGGLR
	 tFBh7wrVSAuhRLbjxInyiEZiR1kP0xVEyp75tW21XSLDrMBJgg+6beSCKZDJJzYki+G3p
	 vtRDFb4JTFKuztBn9vXEUcjFitLIcWnfu9seaqODkBg5kUTrNqWM2W9ek1/y3VbTtcA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nYXu1uiQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE0CD60A260A;
	Mon, 16 Nov 2026 11:05:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nYXu1uiQ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D04171F0093E;
	Mon, 16 Nov 2026 11:05:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827110;
	bh=pjbhVx2fs5v7PEkUYOgJa+aS4bC1ZGO8oQVzHBWC01U=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nYXu1uiQb94rPtCHLvJxnWX/TUDUZcHdjNN+JiXznWofO/Ao94RfItRka5GVt69Nd
	 56ZQzYNlXAl+s8vv/MrU8u9kvtGLL2+icBZWnMXmeoBkwje9K4MgBxwaU3dvYOUcB7
	 kGGgVDP3KnDjLMW+vvytpomBwqRACF5eYPYpd8kBMJoayxEvV3Y0RvdYx98QkT5CaK
	 maRZwaZ2Ay9bITJIM5uB6jEAX8BVeOoFxX+MwqN967mZuxjhRgAsGX7zHbZiJfy9vD
	 iUa59+RNlZIUWgraD/XFuuXksPNfW154MGZ8J/zg/hvkES9dSpVeywguSGp39q2+9g
	 97P9YY9aJ2raA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:03:51 +0100
Subject: [PATCH v2 11/17] coredump: take freeze protection for the truncate
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
Message-Id: <20261116-work-fs-frozen_writes-v2-11-ecc4a2aac40e@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1200; i=brauner@kernel.org;
 h=from:subject:message-id; bh=34ncq8Kdq+MSTLVnNDtgt7r/DShig8xHabTi/tdVmLw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9eqzVKTV/xdpjUtYvDKKMtkfu+/pAYoskz9s09sIX2
 zharnlHdpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEykZSHDf7cN0mGeKyubxTpC
 60IvHJxm/OTpFmOeMo4pz+f+73sweQbDP1vh6dcLH1+ZrugULr/z0EeeCduWNHB9dro4297B6vW
 GRwwA
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

