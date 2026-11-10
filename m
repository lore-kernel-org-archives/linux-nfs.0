Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302397;
	b=UuCmnP1qjKwpPs+oV46MMbBbBFaojimi2zt3qX2+5V4KLen2M9rD6z6b0XbueOw1A8zT
	 9/LutZ5J59UnqQNMTyZrwXQCO/y18f3zR6XiQ9mjE+M3Bp/gY4Zclg6qsxRY+5jND0Psa
	 UWoSLytVmpSmqMudrFEkn5+wE+0ntjoRrAtaPjD7pHmX9k1Zk52FGLSWswLBvmp0NNSK6
	 2CQC5yCNZMXcX/xKvhBdW2hU73KSX5eC/0FwTK04Vwj8i9Aa4fIiNXcV7tzYNwaIndSY4
	 WSNBF7b0jXriarJ6/mz9+DE1gtQgf9oMD1BqzwQww/4d/rQb7bPE9U5fZ1pONezoZTQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302397;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=qJiFf9w4hToXcclP9ppmON8B46ZerQobJ1F8sM9X2a8=;
	b=Un35AGctUTmNLtwz27i+LwRjeQIprcH0Qnm4/FSiZ/smd3gySMZY9ucAZCgoWaY/b59Q
	 ue5zqdtsVaMEVeCmTgfzU5Ql4Ppj21qtAlfcHxSOATWJhENkToBAByfyREJd4gR5tHKjs
	 nhwVOVtsQOxViupPUsDdA79ih/yNSwy9RapJjikmM+t4SRNmVj1ll/iPIm/JkDh5vcYMN
	 GYct2xyHvo67qB4ynduSa/2/IvARcLoYPBgItu5rugLMWHAhplyeKUnrCfhsuWmYq1iJs
	 a1982/0/nqkOB0Lr4iZofuUSfLgJ5eKtgwcUUVgZoOw/LPUvhhS7n6VCk/jgxLf/RAQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YSj0RR1a;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0E6DB607B02E;
	Tue, 10 Nov 2026 09:19:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YSj0RR1a
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7F39D1F008A1;
	Tue, 10 Nov 2026 09:19:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302396;
	bh=qJiFf9w4hToXcclP9ppmON8B46ZerQobJ1F8sM9X2a8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=YSj0RR1aG6qNPyxHpaLvknjLVj91ILD+92zWFulNcS/9GzuRoaQHatZawU0nYbR8y
	 wus7ohgAGQBai1txsuKrJnXmIbOHGPu8ofJJf/FVDtHI8ClyJKzU7qfsjBbW0aZ+ce
	 zWv3AeSLtwvY+Mjd5A9NqJjMByywMDui/mH5eL6dgY9srHxtjNOSh4WuAXPTmUK3oc
	 rj74FmSQAg97IU/fPvixOSTy1hGHbrW8yJHlHbDd2o5Lngy9Nmbmsk6Ah2dyvn2OaD
	 xaVAA8ELW3uvaLp+l18HV1m2/38wuA8CuBANF9a3ezWOwggIRGtvqG3gki5e2MoaKT
	 vZL834m+QNo/A==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:51 +0100
Subject: [PATCH RFC 35/41] zloop: refuse zone files on pseudo filesystems
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
Message-Id: <20261110-work-loop-pseudo-v1-35-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
In-Reply-To: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
 target-devel@vger.kernel.org, driver-core@lists.linux.dev, 
 linux-mm@kvack.org, bpf@vger.kernel.org, 
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, 
 linux-kselftest@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=822; i=brauner@kernel.org;
 h=from:subject:message-id; bh=li+gC8cc0Mt1bD1j4gMcmL8SOHESlN2++n5Uf9tP8Fo=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erDHcu21pTOZuhx19nwxdyrrCmUMb3503015p6SPw
 76FMcqxHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABN5bMvwv9AwrjaFoTvl5SXZ
 U7d+5SbufCNqdW372nkxojHPVJnq7Rn+R03u+RT9ITNnZY8fx/JF32OmNseuuiD0fVMyz/+nq9X
 nMAAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

zloop opens its zone files by name below the base directory but a bind
mount can put any file there, including a procfs or sysfs file. Refuse
files on pseudo filesystems as zone files just like loop does.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/zloop.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/block/zloop.c b/drivers/block/zloop.c
index 65634a39b0bf..dcc06dd47b04 100644
--- a/drivers/block/zloop.c
+++ b/drivers/block/zloop.c
@@ -1137,6 +1137,11 @@ static int zloop_init_zone(struct zloop_device *zlo, struct zloop_options *opts,
 		goto out_fput;
 	}
 
+	if (file_is_pseudo(zone->file)) {
+		ret = -EINVAL;
+		goto out_fput;
+	}
+
 	if (zlo->block_size) {
 		ret = zloop_get_block_size(zlo, zone);
 		if (ret)

-- 
2.53.0

