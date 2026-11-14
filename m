Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661699;
	b=N2XhheNnMAnVHSdiwTEWL+yzqKqLM+zI9+GlS+321jRGREGUwResrKF7K5TBMf9vsi0P
	 N9ac8OrgIpIQZ90J21qLzLOCFs0fZEg+MVU9abZ4vAIGTk+ienaoAPEG1SSZakJQSkzI7
	 U9OpPUa8IVx/e5AFsZkvnvwOffiizPcIb5tmQuxxAFFv9k8+DEIG/pmqlesleN5I9a4ra
	 qyD7+QAjC7nGzQPP/0CPBYxCF5u/h0VWj1HoeN4GTtryyHcGxFqja670mi6SvJkmgYgvH
	 avY0H6BVqvl7EDeIastR47HbolRdK4n0zZ6bY08RRiU/14eS4I5vFBU/Llzy0AUr01g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661699;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=YgZhtD2KV2KLabc0QJjPTehcwCNTaDbDvhsPGGFCai0=;
	b=u68Ked/No4J86Vk1dfvbqs5KU6RPWCoAi+8KL8PeCScljKTD6+G1AR3BKofF/yaTB8Il
	 IyZmakY9CAw42By7ayFcNFk7EPtD6V/eKumXkmmI4PIBGbZcHH4Jk69A+/A0wn/Y2I5Tn
	 jJzvqrgXuH+6kiD/Jorw6aI1/YMS4THVlUjsgLZUSCaBirtI7yBgQu0LbBVMiTq3Bi+C9
	 08jg/pcYPEYg1hSTKw6YDNNXoNBuvmHImOMpLbo2FVDIa3i6EagsoprxD8kQgiFGOrQC/
	 /nnn/TA9PGp8PgutSBKugP0YNkpLvIPlluXTFkjfUwEPsF5xEDC54gWuufDMYQvw0Pg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CPIiv7kI;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 65942606BA13;
	Sat, 14 Nov 2026 13:08:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CPIiv7kI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 858C91F000C5;
	Sat, 14 Nov 2026 13:08:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661699;
	bh=YgZhtD2KV2KLabc0QJjPTehcwCNTaDbDvhsPGGFCai0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CPIiv7kIlPjOab36ov86SnfUDzmkpfa1Y92A6ehKtlVHTIqCbDbxLaSph+jONs2Tb
	 LSgZlgiffCsO/JpMzKSIo4Bqw7ro2iV+VuM8Lgw5HYeaUVevwna4ucvZdgD7CMfg37
	 v6lx11AiyHvyiNlpYuwzAkQ/BLWonAOXTguqBCXfTtmkLsbiKbpecyzp4FMvOPCc1N
	 LbJbBc74lGhQKkHAGY3nQAZK1Lpq3a+xGFZdBwSAXMAUkGq7t2V92c1ukQypIL4+WZ
	 7tsqPrdqgFICsXG2DDkikpnj/7w12eh8JiLWB/4dRGie0/g6rFv4AHXFeK0Bhpqo46
	 xlxuPo0nSGdMA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:04 +0100
Subject: [PATCH RFC v2 23/42] fuse: use fc_init_pseudo() for fusectl
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
Message-Id: <20261114-work-loop-pseudo-v2-23-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
In-Reply-To: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Alexander Mikhalitsyn <alex@amutable.com>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=951; i=brauner@kernel.org;
 h=from:subject:message-id; bh=OTVHfr96xgBpFGFHGPd9YzWwNGICdkd4ukGHZq7+6V0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iGnwlZ19N+BN1O05M8J1gxnSpkzRP388jOX8mec5x
 cs60+9zdpSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyEjYmRYeL2Rxd6LogfN6hX
 6fA32Go6kT/p6w7/aw84omwELm89xs/IcFl3m/5f38aLgdyOZ8p3FPxbt1eR64KN3frP56Qm3mJ
 4xQ0A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize fusectl as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. fusectl never holds executables or
device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/fuse/control.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/fuse/control.c b/fs/fuse/control.c
index 21ffde596d611..4497362e7df06 100644
--- a/fs/fuse/control.c
+++ b/fs/fuse/control.c
@@ -10,6 +10,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/namei.h>
 
 #define FUSE_CTL_SUPER_MAGIC 0x65735543
@@ -334,6 +335,7 @@ static const struct fs_context_operations fuse_ctl_context_ops = {
 
 static int fuse_ctl_init_fs_context(struct fs_context *fsc)
 {
+	fc_init_pseudo(fsc);
 	fsc->ops = &fuse_ctl_context_ops;
 	return 0;
 }

-- 
2.53.0

