Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661579;
	b=Rags3tSoeXDuO7SeAmj/+WKoUvvbiGTvEIm7n1/VG0gpaUzTKN9m6Sj8kf70ran3W3sC
	 ejY8+5oHVu57bGCe4kzmSTv/f60sT16nyu1ADZJ4sPaho1ZS525QLJAwx5eZU4GdyzBZQ
	 IzWZNZs64tATQjWOKWzeBG+diWhbv9S2R0CVqwdyc0zMAk9JD0m6a8gFkkj6BMwGPgRbc
	 mQnuGn25ESlnshWdbF8VEV36CNQoac5sla1/hHZYF/vP3ISRXKF0DG+Y/YMIVpKanKW8t
	 7NEPY8LszJu5rfWcRGjClaouHt+Qqv+ggJTdp+qhQRcz75SKriwITmYLjyIX62xhajw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661579;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=NnRPpMKcN9yVfeXQRaQnGebNudMmHI+DUOfgXRvZF2k=;
	b=YhnnJSnYuK2/AZhMh2d361FOmvbBcao44lqve78T71CNODGJrF8exUVXT8MfIa5SiiOD
	 ymMnpoOwjx0azlIzpbVI/5HET+j5vXsgPk90/vRWDBQfTXjaqN7k762MExNY6P8TWgM2d
	 xV5+jS6AsvuIEazmgy1fvd51+PgkQFzidgN3519RQKqTGHQIPtYkv+kXx5Q5iFfGb+ZjT
	 268vIni7WUkyrOafEvO/xlYj74+5c9gbyIcPSC2NP4QhthTuXXXUnmKSsS+q/EIfWd2do
	 aYEgXtdSZuQVN+2E/o1HowhWs9nj9cN9bAI8I81K85lslP758dAQM+WUP4toKMCcYSg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="N/ubtL31";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 147BB606D292;
	Sat, 14 Nov 2026 13:06:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N/ubtL31
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3C0B41F000C5;
	Sat, 14 Nov 2026 13:06:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661578;
	bh=NnRPpMKcN9yVfeXQRaQnGebNudMmHI+DUOfgXRvZF2k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=N/ubtL31jom4eCsfCr6WpwL+MzKUK+rWwpFr4vgqMUy06gbO86k3xFL/VlhTtjybt
	 o3d0PDdbLEy9jHXv7T5i3zo1EBRIqVAu/ZacRS1retYyYhxmkcSel3BM1zOn1JXfvT
	 j1dl7rLX/nE/c0hHw7WYlCxm5LtmKhEmBxCBiL0Rx0/pMBD9F5WQlfq+VoGsYrh6sB
	 EoBC//ArgbDcTnWusWXsxEQCVbMy6hCKCNl3yIXPnFUODMjEzsMezuDoTZo4Jytdw+
	 VM9ybNeR637U1rMcm9u8t7d6wvsPa1ke2eVusyEuf1MTwKev4R1WEMPGbBHytx3Eq8
	 fhAsIGxVLYMEg==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:47 +0100
Subject: [PATCH RFC v2 06/42] proc: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-6-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1408; i=brauner@kernel.org;
 h=from:subject:message-id; bh=wvImD7sMv1Zo1NPwHwuuoeuuUg5KPRN98RPqhNbSu40=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iMnpmesutyB8V/b0LVcfp532arap6m4r+hdd5Hsq7
 Xz78q6OjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIlIsjMyvFL6nBbm+cmh7cNW
 o+/+y5gDpu7PW1vMKy676K58p8+pVwy/WQr/TZnocHWqxVPTHZNuH104SXi/kiln1+yjJ8vj0nb
 O4QUA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize procfs as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/root.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/proc/root.c b/fs/proc/root.c
index 7fbbe92bf73a7..ca0e75081934f 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -17,6 +17,7 @@
 #include <linux/bitops.h>
 #include <linux/user_namespace.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/mount.h>
 #include <linux/pid_namespace.h>
 #include <linux/fs_parser.h>
@@ -265,8 +266,6 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 	if (ret)
 		return ret;
 
-	/* User space would break if executables or devices appear on proc */
-	s->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	s->s_flags |= SB_NODIRATIME | SB_NOSUID | SB_NOEXEC;
 	s->s_blocksize = 1024;
 	s->s_blocksize_bits = 10;
@@ -350,6 +349,7 @@ static int proc_init_fs_context(struct fs_context *fc)
 	put_user_ns(fc->user_ns);
 	fc->user_ns = get_user_ns(ctx->pid_ns->user_ns);
 	fc->fs_private = ctx;
+	fc_init_pseudo(fc);
 	fc->ops = &proc_fs_context_ops;
 	return 0;
 }

-- 
2.53.0

