Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661551;
	b=e/Fo5s/mk+U0Mhh41zHYWXqLSdLxX9zVlJ7kkBCnJ+gNmtSMn5cSt68e959zNi5Rq9wJ
	 lQHx6N3ysleWtctDjuGdAZKWUv/kJKU/lqW+svAdjq/NGK3OyARqy1r98OLFEyFI6beBb
	 K+OsXsoQJ+fAiZ5CeP7wYuK1jFXEqVyCSxenFl0BSK6sl1bhVHWYVn/wCIw//lGNE45eq
	 WYnLQ7WhJGryzVZcTRPv5mBx42vpMakiIaYBQvyxJMXDkpLgt3MmkUVfwVngDkkx7ikQx
	 5L1JXwizQlSRAByWwtUhMy8CsBbUraFnJtwm2hNzwIgaScrCvyN6QimQ3jelhvqar1g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661551;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=E39AX+G/jh7TUAATD8FoQ3LTHbJD9uA3ozmx0gOpFaM=;
	b=lVd1M+qFOk3KUJhUTtj6SOeOuuk67Thq3Oq5KINDMU8GLEifc5YdAdzUBZQ4rHkhUa8m
	 0tMRQoMxMqU0q9JIT8yLKBi02H1XRHUNy2AVUQxy1DnCfoAhlaT2OgWSoFcECycrDSN+H
	 WklO4t0o7iyTbadrvhGF4psCVvmGosJWCoGo8SMf/4HUG2dE7ukgYY0uYAgHGi7J0XX7C
	 UkROI+SWPJzd3OX71fY3BxETlpvqTFz6lTOIlXAFdScdaSf62mqcCwc7K0YO8T6jiv74c
	 5FYxlD6yTeu8YQuQeCKIsBXC9wPQtd+bUEFi624sfvIjun+dN1mEwp8teFU5b1Ar8fw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RAVzUn3Y;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68424606A889;
	Sat, 14 Nov 2026 13:05:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RAVzUn3Y
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B6C8A1F000CC;
	Sat, 14 Nov 2026 13:05:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661551;
	bh=E39AX+G/jh7TUAATD8FoQ3LTHbJD9uA3ozmx0gOpFaM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RAVzUn3YihPEfR8QNXiJZ4kO+0Ww2rPP5SABGZnl60hGUL2Z0RR98pxZaO/RoCDhp
	 vFYwvxbUW2TAi/HXFTMH17UIgslNBpCFe+PegPbRAYGSEPrqXonsLU/7Mi83e0RghI
	 czwaB96M9lWGq2+Bal8IV3hGZe6UTMGaixjoty54b98sTD+UZ2KloakvmTGKcP2Jtj
	 qKh6CkT3Y7cwABFcxmNSwVcEj2qVq/VdVxme/wkozCtmB2Ld1vYY0zFO17PwNCJ9q8
	 9qOOW7IJz3w0BfWgmHzKZBLNseME+eb0Q9TOZs/6zDxRI/611bKgvwwKnGnKZ+bkRy
	 yOh/Udy9zGjgQ==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:43 +0100
Subject: [PATCH RFC v2 02/42] nvmet: check that the file backend supports
 ->{read,write}_iter
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
Message-Id: <20261114-work-loop-pseudo-v2-2-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1291; i=brauner@kernel.org;
 h=from:subject:message-id; bh=//ir9fc9dMVqltiEAJAlWV+b7M4aWVaisbvAL6AhlSg=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iMn4JfhIyMuq+MC8pis+ES5tTa9bd7/WXjzJ/vXPK
 QH3uOszOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACbys5OR4c7lBycqbVyqBPoK
 F7087SO3W5fzvW6nkVvw5Mw915xkFRn+qe1OU1wTfjyRac5dfqezqXvv/Qotu/+h6FShzocNC3+
 l8QAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The file backend calls ->read_iter() and ->write_iter() of the backing
file directly but never checks that they exist. Everything that isn't a
block device ends up in the file backend. So a namespace pointing to a
file without them calls a NULL pointer on its first I/O. Only
buffered_io=1 gets that far as the O_DIRECT open fails for such files.

Refuse them when the namespace is enabled the same way zloop does since
commit 0c10f8a1a7ae ("zloop: check that the zone backing file support
->{read,write}_iter").

Fixes: d5eff33ee6f8 ("nvmet: add simple file backed ns support")
Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/nvme/target/io-cmd-file.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/nvme/target/io-cmd-file.c b/drivers/nvme/target/io-cmd-file.c
index 695963dd932ee..dfa8aa46188c8 100644
--- a/drivers/nvme/target/io-cmd-file.c
+++ b/drivers/nvme/target/io-cmd-file.c
@@ -47,6 +47,11 @@ int nvmet_file_ns_enable(struct nvmet_ns *ns)
 		return ret;
 	}
 
+	if (!ns->file->f_op->read_iter || !ns->file->f_op->write_iter) {
+		ret = -EINVAL;
+		goto err;
+	}
+
 	nvmet_file_ns_revalidate(ns);
 
 	/*

-- 
2.53.0

