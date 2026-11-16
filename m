Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827248;
	b=yX7t/FnXIWEJNXfArFmQnJnNoarJGXMhcKfV2ATJTeMVf39O/mOM+fXDc+DcQ31z+HKL
	 yP1Dm3b7RhPHAY81R1P4gPSI73070aC5UJuKvOfWG7ZVFZGY/h+gD5DUaq5CpX8OBNpiU
	 mpO/0kQdfrPHJto5M/04oEQ0WxJsk/f7EJxuMk8I5KsxDfAPRsq31RTbyyoe3a0aX5HB3
	 oCX/DxGtUlSXeWOCxUvVy3cnejWpOFjQdsSgJmJtKIA3Vpm8hH/XDKwGNWT0offBquWSa
	 l4ttr/r09SMpIY+55dkMopIP8vB+l+rG3PIPMT88K2Cc9b2ZE3mCKfHvKpnxh4U1dtw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827248;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=WqIZi0cu6VIwI+9lCXiohYR/wzGXA5+EoTR/jNdb16Q=;
	b=Gb0jc7fzpCrZD/in/1YmZPsrrYjdB2xyH7tujw6679Hxxf2tphBcX+nERHsr6LxojCON
	 79y6afkNcn/4S+LQZMsOXx+cg8+93DWQrw9yZcXrfzewXS+00mYz0w+IXdO9+f6prLbpW
	 veYd+8jCafoJQj76QfpxW9YYxpnGBkF/EMEByqHycTY4kWW4yh4iSu26aHRdI9/57RQ3N
	 j5ozECQIi2gvielPmLl7zu6OOH+1iJKw06kXRJ2ZUyKGTssaJdADukqplAL7HoCSuT/Ob
	 ofnxRppSba4CrSpoVvoTxZzFEBqu28iVMTMSXayDyCkRIHvylFziLEsvOraRVXVIxnA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g2frNxrg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 01F58606FEBB;
	Mon, 16 Nov 2026 11:07:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g2frNxrg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AEB291F000C4;
	Mon, 16 Nov 2026 11:07:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827247;
	bh=WqIZi0cu6VIwI+9lCXiohYR/wzGXA5+EoTR/jNdb16Q=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=g2frNxrgZo6gLuMwR6+xhSzuQz+NeN4PVS9PDKJxwGORwkeyKjneTNcs+fOXdfC0l
	 RiANOUi2u3Nw9Vjt5yQENMMlt2EbmVD9lpUujX88ZtQwjdWgVyUWDOMyPVuk5v+kdF
	 5NNRbJZ5dMlswOWW1+VX2aiKkmFocxNzYdlRCv3rX+6xwPv1g4Qcuh+KqAzxmlSL2Y
	 D19MD06Zt7l/6/v1MV+tZrtsA5OEEdLYhuFnRi6vP/WLBwDKdf40fkzIDuPnjMz8xR
	 dzG1nGsc0L2M0llokOCNc/BbiBjwr0VV5fECKZc6IdgZGS5W+/CRlryJSKAc4ThDZ7
	 GHqrx5WtpvCCA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:44 +0100
Subject: [PATCH RFC v3 11/44] failfs: use fc_init_pseudo()
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
Message-Id: <20261116-work-loop-pseudo-v3-11-8cbbea1cf34f@kernel.org>
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
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1012; i=brauner@kernel.org;
 h=from:subject:message-id; bh=iq4zyAUpqzVmiSNBanL4il/lHhHkqTjKQJsO807AsZU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9epytN2PB6sVPK4Ls46WOb9KbO+HDinbZW+LiVx6qS
 0YIPZzp0lHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjAR5wJGho/Kk16y/xT/9GVr
 hPf6HXuyP0gtWSXm85b71oS8V53MAvKMDOtOs7GW7A+SE/Hk3mjdNMUzMG3LLqvcy41pByWaLmw
 u4AQA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize failfs as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/failfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/failfs.c b/fs/failfs.c
index 437cdc981c2de..f03334f361c0e 100644
--- a/fs/failfs.c
+++ b/fs/failfs.c
@@ -3,6 +3,7 @@
 #include <linux/fs.h>
 #include <linux/fs/super_types.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_struct.h>
 #include <linux/magic.h>
 #include <linux/mount.h>
@@ -132,7 +133,7 @@ static int failfs_init_fs_context(struct fs_context *fc)
 	fc->ops		= &failfs_context_ops;
 	fc->global	= true;
 	fc->sb_flags	|= SB_NOUSER;
-	fc->s_iflags	|= SB_I_NOEXEC | SB_I_NODEV;
+	fc_init_pseudo(fc);
 	return 0;
 }
 

-- 
2.53.0

