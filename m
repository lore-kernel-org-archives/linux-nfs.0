Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302247;
	b=uDVFi5S2Gyu04BN/pk6I29gGLTYAUoW5zYYagPBVQyCWHHmEgx5AoGfoWici+vc8GPYt
	 ST0eGwkHtqLshZ5Z7lhi8BOFItaWzdKmvHUL806Sj1GUdldg+FuJrzgGxrXgpSiJ2fpsi
	 RVj17cQz1LgnpD60RAZK70d0cCtH6LFmwUGaMxR84QsOkMN+agyYv6uj7jSRZ63vJNd6Q
	 FMMzA5o54woKNhti+x1XcR3AN4SWsUA1HoAwB26KiLDV47RrAno8lf/urdpbp1+MzKjJg
	 4UVG2I4kScDHKHXBGS4zMiGrkbTipnv1ipQODbocALt7URH7NUbOlwu7CBAn1qtXc5Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302247;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=nwdvLDg6bh1u0DzBGVwm7FjMDeBdtqjQseAh0xTl99I=;
	b=ooWJFP+f6tQghK8rgNGRW9fpkGgOsiTP0uQDJfHmOAVaSGH+/BIlHKkZjTxLBp/djfvh
	 4KL3pKKL0Eoc8+VCrPz3ApgpCRvW+TUb18GZcPcArGtxhwlGJkDhebZ0LpEE219f+Ytyy
	 HQIPpFjI+9k/UeQJfTjdZ2936qXPlwz45bREKictGVf1T0QxP0/BTPMniJkVZ4iXR92hn
	 ejvkvLjSw3gm0lLHboJm1kk0XyOkN3YXG7dsg0IxuYG3s/F6oHfvquPZGimIdfURsI/X6
	 g5xmLNVyRGOtYpgOhvfzS7Hn5geGN+0mIVeOhddN8Th0LkSxSuzAEFpm2uz6ByOcHrA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VFBfo7hd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 072B760A2628;
	Tue, 10 Nov 2026 09:17:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VFBfo7hd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 458491F0089F;
	Tue, 10 Nov 2026 09:17:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302246;
	bh=nwdvLDg6bh1u0DzBGVwm7FjMDeBdtqjQseAh0xTl99I=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=VFBfo7hdp6CeqpCV/lTJ2YVYrsN+l15aUN/nPrx8Rg7U/JoKUXLTS/O+qt5CD668b
	 Tvg82H2hCyRZdK0y09cJVY58Rhl/zTfH024a37WXVgI61JHTo+hhQ4sAK9pYHF9Jyc
	 DzcnFl9SoR42roIHoSyhOt3f1yUXXQ9XEu4wnL6doNmOxGOTC2UxCXLYIJjUWc61Yf
	 k2GkpKuijQrA44JhQn1HQ4PgE/MbIqiot91NvXxjd/Re5Y7uEX3vLft3JgMtpiT0CH
	 /c90C0EJy51OUlGahyRcvr5j+wOW65ab+AmNA2qoyUDajcckrSrMy8qdO+IXNuXqIq
	 YuNNlKf10iZug==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:29 +0100
Subject: [PATCH RFC 13/41] devpts: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-13-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=916; i=brauner@kernel.org;
 h=from:subject:message-id; bh=NbjUJKnUFt4/WnttO8t6CLNMaU7LsVpFd2X5tAMzhrk=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erD4sV7JnhvtkV5xL4MZSyqkM9c3WZr+jvrmFegxf
 8Ze75f/OkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYyLZeR4ZqalqDRG+1nqwtL
 9i369KNsxlvXLdmFi/l7l0SdtWZQ8GL4X312nsC5iU3+AX+yRU57OepI7oo7eS8qNuHM0k+v58a
 n8QMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize devpts as a pseudo filesystem. This raises SB_I_PSEUDO and
SB_I_NOEXEC. devpts never holds executables. devpts_fill_super() keeps
clearing SB_I_NODEV for the pty device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/devpts/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index bd1e8eb26edb..47ef12241d92 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -13,6 +13,7 @@
 #include <linux/init.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/sched.h>
 #include <linux/namei.h>
@@ -438,6 +439,7 @@ static int devpts_init_fs_context(struct fs_context *fc)
 		fsi->mount_opts.reserve = true;
 
 	fc->s_fs_info = fsi;
+	fc_init_pseudo(fc);
 	fc->ops = &devpts_context_ops;
 	return 0;
 }

-- 
2.53.0

