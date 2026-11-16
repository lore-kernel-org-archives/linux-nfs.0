Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827218;
	b=xqYbKT2nsE39oNOnBaMn+x/h1XnNqsGHv65v7XASD+R0GaMv6a5UfOGhtW+Gz/AUU4MQ
	 AlCwdr2q9OEQGzuHew5RNPJ/KNILVWWotNv9saAAvrI9+ICPZwCHi3evKOGeUdVDqMY0p
	 p3RaPB3BuUuEB+kmiDPc9Y5bv1HvoOnvDtWlGrDgnN8WRP65Bn2B1cF/5xQhfcHk4r1xL
	 h3jRohJ53ylteNsLBykdEAI7g0pIygB/ZWKy6kgegIKY87S99sw5qXI0aOmbQuu7+fGnd
	 wY7Y9qXKIY7WBqo5KQNE7Scu3J0ku/2AAMKO1g/t1d5QJhba5fc78AXPuXw6f5cizzA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827218;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jcuZgfEAu/QV7fwp1VLyFSljuB6ko+rpbI5oo0xXTbA=;
	b=bZeGjXFKwcXhn+ajLHANYOYHeAfRVzzMABnlL5Ruq2Ri4XTPBie/jzpkxFBzivzbw8SJ
	 iCs6Wx/vCr2e7E6IhXluJkwcw8ZwzYBpPtEorrYf05jYQJCK8pbPoRcWe2vxz9aY5WQxQ
	 Pi3sDr3FXGsgEbU5LmOGggn+D/DYUg82E7YRpCizBytiTcARU4CxZMt7kRs8XZvOtf947
	 68gV1Rj8UWeWhUAHGG26RxXL4HET5mJ937U0m5VXt5t6vVi0ktbdJdk/B16pLirvHQETs
	 BBTVjjqWVC83V1ruKPUjzULxyuTtFkHCI1AaJzGhkoIwtYnLBw3GCc9k5AVbaKAL18A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VlWUdDLV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F396606FD92;
	Mon, 16 Nov 2026 11:06:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VlWUdDLV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DBF281F000CE;
	Mon, 16 Nov 2026 11:06:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827217;
	bh=jcuZgfEAu/QV7fwp1VLyFSljuB6ko+rpbI5oo0xXTbA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=VlWUdDLVuU7+1W5AfKDV8A6h7bpZD6EsCzKV3QkLOwQIaYytJajpFIVxFa+tZJ35S
	 tI3uPLWgSo+No0yMgSs4xL74IpVyEJcOMhOK9feVdhR0gz/3OsFCh+HBGIfL5bfaQy
	 EeWwUQfCTADTYpl3kYIVLHrKD0071KrFYjjll+kMtoKchmkd0P4z7p5mleDk4dc4RI
	 FfwrK4jlOLZbAGciN7FsmDhx1C1Isd2oeRGeEvBqEwGSDwcR3+swUmLjG4HKFAeiXz
	 c1mW+z65Ldx/VReJb1LQr1zBRFMkwzpCRVKF3SJQ+PxD2B6SIRjYnlrbYtR7otXVX9
	 51azYy6ntC+8g==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:40 +0100
Subject: [PATCH RFC v3 07/44] binfmt_misc: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-7-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
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
 Alexander Mikhalitsyn <alex@amutable.com>, 
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1381; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Op8caQB40yLDgM+EzuEIWYdaqzetBKTmauJ3/A8MyW4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9epz2stXSV/bIi9CLVUrrcpeXPvuV4y5RpjX9R2Rox
 r/jidW7O0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYiKszIsPeTS0+B0pFmdk8l
 p0n2046ui4zZq/L5S64sm9fmmVf2dTMyzMt9rHkle3Nhwf2a5nkBe5i1t7ttYSyfFqfzfN10XlU
 eRgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize binfmt_misc as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/binfmt_misc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/binfmt_misc.c b/fs/binfmt_misc.c
index d945b4f6e1581..7dc233becd98d 100644
--- a/fs/binfmt_misc.c
+++ b/fs/binfmt_misc.c
@@ -22,6 +22,7 @@
 #include <linux/file.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/init.h>
 #include <linux/kstrtox.h>
 #include <linux/limits.h>
@@ -1575,8 +1576,7 @@ static int bm_fill_super(struct super_block *sb, struct fs_context *fc)
 	if (user_ns != current_user_ns())
 		return -EINVAL;
 
-	/* Never exec off this instance and never let anything stack on it. */
-	sb->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
+	/* Never let anything stack on this instance. */
 	sb->s_stack_depth = FILESYSTEM_MAX_STACK_DEPTH;
 
 	/*
@@ -1660,6 +1660,7 @@ static void bm_kill_sb(struct super_block *sb)
 
 static int bm_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &bm_context_ops;
 	return 0;
 }

-- 
2.53.0

