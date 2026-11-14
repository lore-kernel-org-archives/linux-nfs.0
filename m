Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661664;
	b=YWYgIi74u0hykKmeds5qSz1i524gPz1VKpU3P/KlUv4nbWN+lIytC5UowuuRPUHj1Th9
	 Fb5j6U3zc/uwTMAwpnCBMQMIxmV66kNLPxqQ2WmNiPCY1qQ8YkXmGqDmu9MPDKvNzrT++
	 /DGAWO0xcxlGX0oSVyhg1XX6MYavjcfVO+mltcRe+o3Q52C7bD75L+jfoAYwxtWS2EJA7
	 pbkDbgZz4zmhPJYx/rafKxTSEAFmTvmuHCZt8WEdZebLKTiHMX2U0B7lN1Uo3ITZmEaj1
	 zsRYw2on0e+6zxJc5csANSFw3PxlL5tIbWEPnuoGoITvS34Am4t8qqZm3BcubxC330A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661664;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=PsEZAEo2EWjwlrQyS8FDrkYLrSxc4EoXaQ3VAa3T0to=;
	b=45rYBaYtD2uxQgwKEHraqMJM5n3rkpo/AYurQ3ofNYjR2yeBo99zLfHokLCR8AkbvHpJ
	 pt9ptPEvPd2SvTR3wfutSEDIG+llIXl5fUz543XNi1MW7Y4Ey0n6oufhr2AujRw75KshF
	 pzCQ9bi11FOxk4Ec5Q9iXTs1QwlLgcsNUzEcfMbQn4QjUOg9+C5gAT1v9pzYTHbebAUT9
	 pb+z2B8PeaTcQ4lcT15HIm30ZIfjdJlj5q5+S8fJKVbj+RgPM8IWUbh3bN9FqIurXwSM8
	 yZeIiBqqCLfDEt10A1b9N7bZyZFuTsEp/byLoqWBg5W1OHrfiCwPLA4XnDY0OsMCirg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RP6bdqxg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20CDB606FB2D;
	Sat, 14 Nov 2026 13:07:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RP6bdqxg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 254A51F000C4;
	Sat, 14 Nov 2026 13:07:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661663;
	bh=PsEZAEo2EWjwlrQyS8FDrkYLrSxc4EoXaQ3VAa3T0to=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RP6bdqxgYdTOvKQFb6NUJlAnzP0iuFZn14JV3dopj4eOhvt4mal1MYZtl7BQYCoxt
	 w45XbT2grNM6Qg55/tsCLUdM0CQBOxLR2Kunja7yy54lP9Qfg63cbpj/uCek58LMdr
	 2g0icThdvpsN4HTsfTKz9VeiMePWjWf1Q1K5NnEjU8lTRxQrEHOb8z5qeiSteKne2v
	 cZsD/rPxnGg04mAtEBHiWHv5l/XXKkWr1ku1sBIHTZe1CFwHTqP1ghScoLp+fr2OPo
	 fJrxBzLLgHTvheGhtWCqgnNRz1198UueTs5pHbgLcHIkedb4JvrikevLf2qm5DDpBH
	 /871dihUSqoKg==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:59 +0100
Subject: [PATCH RFC v2 18/42] selinux: use fc_init_pseudo() for selinuxfs
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
Message-Id: <20261114-work-loop-pseudo-v2-18-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1689; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Eg4JynB39S+cJriPMxPoEFKswaAikvmz7VyAKkVX+DM=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iKlyMVy9yP1TKKNxrIjSmW/cGdIrJik/frn0dv3to
 /8K4+ukO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYSMIHhv2uEhSiX6eXHduxb
 hf4+qrT5tnTptBUl2zO0TXL7X/736WFkWNSWEJ/+ZOJcg73v3vA+s01c+03lUdAuJu+uVeeshCM
 ymAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize selinuxfs as a pseudo filesystem. This raises SB_I_PSEUDO and
SB_I_NOEXEC. selinuxfs never holds executables. SB_I_NOEXEC also
refuses PROT_EXEC mappings but the status and policy files are only
ever mapped for reading.

But selinuxfs needs device nodes. The kernel replaces file descriptors
with /sys/fs/selinux/null on exec via dentry_open() which doesn't care
about SB_I_NODEV. Android init however opens /sys/fs/selinux/null by
path as /dev/null doesn't exist yet at that point. So clear SB_I_NODEV
again in sel_fill_super().

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 security/selinux/selinuxfs.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index 310e19efff1d0..d7ae853b6d685 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -18,6 +18,7 @@
 #include <linux/vmalloc.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/hex.h>
 #include <linux/mount.h>
 #include <linux/mutex.h>
@@ -1852,6 +1853,9 @@ static int sel_fill_super(struct super_block *sb, struct fs_context *fc)
 		/* last one */ {"", NULL, 0}
 	};
 
+	/* Android init opens the null device below by path. */
+	sb->s_iflags &= ~SB_I_NODEV;
+
 	ret = selinux_fs_info_create(sb);
 	if (ret)
 		goto err;
@@ -1955,6 +1959,7 @@ static const struct fs_context_operations sel_context_ops = {
 
 static int sel_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &sel_context_ops;
 	return 0;
 }

-- 
2.53.0

