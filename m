Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661557;
	b=pr4xU8LjXL9SPDItRFGKgClzb4RCCsBTI5+Jbo+59uSkN8JkpyCbTwOkMcJomX2PTD7M
	 dUhnPhv+0U+4m97UYAo+wdoxdfii/QaQBcYUN9yZuiNw2tr3Jkqd0bsLFflYuu+24EYcG
	 w81e5E9tCiaNAf71mAOSEFEWb8P6QMHgpN73DWu8wRd9/tjeVpV5PfEfC+Lx8bQfDhz+D
	 /jPibg1KJUyX4iGa3kPSlWMHk5Cm7CDzYaW0hsgaA+GDzg5BD1iOe+1zZJd4l7MjJE6y5
	 Ydu9ZHOrOJPYLFajEE8/zvwKuvmYE/j1yxe3fAQ5m1kEdvba9WahBcWaOiEIQ+/4fSA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661557;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=r6ZhD6v1VAC9LFMiPIrPjYVjUm9OFEumnB2zMtz0O/0=;
	b=roHTmBcSGgnrXsIo8xeF6RHNae9ej7HPRhH8+wGc7Me/WOwFBEt6Pmri+CBXDEMgQlWL
	 73nSO7g1EK8EyLWQLblErmJb54y6ckiWfFYT1n/tEdojxBVyAwNxx3hhN2s3+J8bEY7Te
	 5E2fFEkGzt1WUwu3WKIAxAOngmirfaxzbod+4qWiKmWdJ9LolK/+9B/SjwQByg18Dz+sP
	 t2RTA9BLL9Uj2U4hGWLdH6z1kqNCje2Hdq7pwyL6Eu6/iX6Twh2tRCPHVK0azjjg3BiBV
	 sGxfR2DcpcjJwfU5v4CixzEuNExZKkeHoRq6Hl/U/ZzQnr+ZMGZFs+VGmUnb1+9uhJw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MpJVcMTY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C45BE606A335;
	Sat, 14 Nov 2026 13:05:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MpJVcMTY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 71E051F000C9;
	Sat, 14 Nov 2026 13:05:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661557;
	bh=r6ZhD6v1VAC9LFMiPIrPjYVjUm9OFEumnB2zMtz0O/0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=MpJVcMTYApPZc7VozOSSmaXGxWwwgxOxiDGjTzhesY26ZSs/xNhwwdDIDL0zR46b0
	 W24cPjHL9Gyz2tmsdI2SZ1yAOIBcFIhBnPjCrQg2xaMcZtEWnbfvhWfVUXxY1N/Y+1
	 x7BIMwdp4kJhjoQq27aXY340AMvCIq9P2DrFIOyfPVCPJ5xs9RWXl9JHBQYKOWuud8
	 wvITPU/pQjvqn+W9V89fmzuCuW4Cwhv2tpUp3HqbUNBmkJwQ0riUqK0zrXSlsQ65ZJ
	 l3Cj8QQbq5mCnD/EO8LJr58gJzqPZx/uTT9g4OZqsMUvqRomSCrCoZjw8Em01eokpW
	 /XnZdvsBfixeQ==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:44 +0100
Subject: [PATCH RFC v2 03/42] target: fileio: check that the backing file
 supports ->{read,write}_iter
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
Message-Id: <20261114-work-loop-pseudo-v2-3-98639a2286fb@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1460; i=brauner@kernel.org;
 h=from:subject:message-id; bh=+p5P27LAsW3o7uyqtxsmCGm9+GYqGVB9cSFLMBczGcU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iMncq/F3Gqdfy3ml2pz6Cf16VQLrWpz9Pe6Ltv6/x
 ysXsqqio5SFQYyLQVZMkcWh3SRcbjlPxWajTA2YOaxMIEMYuDgFYCI7fzMyTDnBc2fvPj7dwBbt
 Y32T7r5v36qWePZ+2WHraW+0ZwvH32H4H/HwwN1Nz2oWldU/1cn9XNqxx+bkkusBpYfP2X5oK3x
 8nh0A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

With fd_async_io=1 the fileio backend calls ->read_iter() and
->write_iter() of the backing file directly. The synchronous path goes
through vfs_iter_read() and vfs_iter_write() which check for them but
the aio path doesn't. So a backing file without them calls a NULL
pointer on its first I/O.

Refuse such files when configuring the device. On the synchronous path
every read or write that needed the missing method failed with EINVAL
anyway.

Fixes: 769031c92c8b ("scsi: target: target/file: Add support of direct and async I/O")
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/target/target_core_file.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index ab9824a4852f1..a5391e57e9aa5 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -144,6 +144,14 @@ static int fd_configure_device(struct se_device *dev)
 		goto fail;
 	}
 	fd_dev->fd_file = file;
+
+	if (!file->f_op->read_iter || !file->f_op->write_iter) {
+		pr_err("FILEIO: %s lacks ->read_iter or ->write_iter\n",
+		       fd_dev->fd_dev_name);
+		ret = -EINVAL;
+		goto fail;
+	}
+
 	/*
 	 * If using a block backend with this struct file, we extract
 	 * fd_dev->fd_[block,dev]_size from struct block_device.

-- 
2.53.0

