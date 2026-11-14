Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661586;
	b=cdc+8qd/n7aHKKKwjBcRWIblj34rWHG6QOISmg8+UKnI9/L18Gg/jgiF1AX85BgtTu+1
	 SocyRalra8Y9yrh4dL9H+lwzwuuWIvcjOu7c1cj8hzSpj1SvGNrhvaagDR37XP6a9dYof
	 Qcs4n8UzAjCqf22D0VmjxDt79DuRscKkupsZ15QujfVS2jq2Sq8guqYBvxgutGML7xxGX
	 EWYaIBRNJHpJUxK1NkUdHf5Kp3Y/6owTuF4kVgMikE+fq9UrwOc9jcS6mrY4Rwg0271KS
	 IPv1P12VoIzZevzREel9wnVuXI36mVmUFyKJ/oVCnSXCCPAr4Mb4igSPHRZ5KwlhFew==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661586;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=sgs4W2I6jyh9uREhF01VP/+x2A31fQRHH6KrlL4045A=;
	b=xhxvs0HJOkY22cvcT0IEW8hk2fHzfUYQyYhZlLgYoqfEfZFjeSncBBxmBorXywudkbtp
	 lnV/UgWHgzISW2EsFkTFjjj5TnHeyfml0ECfPuLJRlIl29Rw7CEYspMAoDHyTdN1xiPdK
	 3IvbiIeTq8nMKzA6omjF/Yu/mz2gdHDUWzupJC+LmD/h9I6HP7aZ8vCKUkS4Zp72UfeIF
	 ShHox/LzG66bxKiEMvFztNmhc5C59Ro0Hog3FgcKKKFU+7hHdQ3Xlx8VrsOSt8xZ/bthm
	 JErdSdidZ5droBd1eqt43zVWKxDjoydoVTh9I9XXZmo+OLJA5Kxw9x54fbqyKt5hyGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="I9B+/s3S";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44E0D606A897;
	Sat, 14 Nov 2026 13:06:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=I9B+/s3S
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 36FFF1F000C5;
	Sat, 14 Nov 2026 13:06:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661585;
	bh=sgs4W2I6jyh9uREhF01VP/+x2A31fQRHH6KrlL4045A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=I9B+/s3SELG5SM0WBcJJ+bzQ/9D/re85FCznroL591YvUWc373nL+cSoL9KAp5RzK
	 UAh2zDRAYca50XtY7i3Tv4dodLxUqwxwTo2T9y328XqGTzT8IyJSGT3uFDH00JS2T6
	 EmiF1Vj4PKvUBCKINcK3PbEeYMUAMCvP9Gwl/5SG+hbMaqVkskZ0molDV0KZnu3Dmp
	 NgeJizS1V2OJr/io2hOpe8FKvhrr83bhr29d2bsfERf6pIH/dHMJUK+wRnrFmqvU3f
	 798wauulfg3yNQCuADzs9Ljrm2YDVHH17AWN68OdKsAAZ/GzaSDoSqD3oCKUBTXELN
	 V6mLbqYofrsZg==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:48 +0100
Subject: [PATCH RFC v2 07/42] binfmt_misc: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-7-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1333; i=brauner@kernel.org;
 h=from:subject:message-id; bh=ExZBUVvx9r18SdKJrfF6sZNEu0ZA1ZdlFfR0zqTTCHU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iMlN/XnopuTFo6lJxTd/lFacnmUbf2Z+/TRuvSOBu
 QvLsicc7ShlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZhI9CaGf2YzWpQXz5uauPyd
 QYfojx9XuhxufHopucU0dfExi7nVe3UZGeYEPZk6NXJx2gyhu7MtpNqPZ5epOWzy0e3YWn9nhtf
 PRWwA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize binfmt_misc as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
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

