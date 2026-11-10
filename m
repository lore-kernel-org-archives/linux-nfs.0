Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302219;
	b=WRexICK3vYd42nB4lnnGyJ4qQnC8jQFDnxMxDxROPyjtn5umz1eFQYjMXcfGa+d5OR+W
	 voldUakvITsroHgzNdRcCh3uW6owDXFpZLKjysGW35xlGQiTx7gqb2xQQtWALj6J5HobT
	 JiUNmNc+VObMtPsQ60kIVcwpsU+e8eRWGdteveY3id9hBoijv8+S1rneXkdsC9h5Rh8Na
	 3yqsA6/ii61mSUu4rzvRPp32hLkLilkVSOw+2NWVdslZqHe7eUew5xv3vJnUxOCCFNMp7
	 j0GjD5qe+MLmlCLJdrtISvzTwTLD9QQn45MtpeA2DCHrm5ye702uftl/M73QPgZ6XpA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302219;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=WY71Uo54gYhZKR4pKqr/19QlXycB+RRfAfSK6SBkMOo=;
	b=N/pM4b+lR6q7G6ACk7vki8NrmZCVkCar+YPc1nA97WJFMKgGZ8oOLEURUkie0YSJ09g9
	 skn3SN+WWobiSbWAtOg0vvbHmXMjtK9acCBJcmlH5W6pswvkchO5rrop6rL0qjji0cfAx
	 kQOCusyWIrvhQ3rIdEMD4n4Myt5phSqHIz1TqxnJ32MCgvz+jX3Da9oDjdqTQTHXfVfNx
	 OhIh70wlFcgFEUqz6+aZ+MjvXsK2z7AJD27uOpwAgAfl94n7WXiNkf3xgSYMZ0GV747Ja
	 7nCU2Ee03Tx/CLsGqXVCE6E4Z9bDXFgmoI5YWnR1VkRl2WpDOYr3e5pYNxkm4Gsta2A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LlMaKIGP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D09C60A380C;
	Tue, 10 Nov 2026 09:16:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LlMaKIGP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A02601F008A1;
	Tue, 10 Nov 2026 09:16:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302219;
	bh=WY71Uo54gYhZKR4pKqr/19QlXycB+RRfAfSK6SBkMOo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LlMaKIGPglPkcvGNxGDrg7KApXX+gHKG5SrrawRrOpvdcrBWjo8TZvaYC/dVHXPkL
	 o7Q4vzGLaTH3tPVI6EK6P52H//aWm8LX6LNA9wx7GzZylS8Tm5t7Uihc8gqN/tYIDQ
	 PP3rUbIEqyxUIjeAdPOxrVHEdBQihQ2084RfxCjhwr5G5bFc0E6zHMFFmmj7AzSVaR
	 tXO6WvEI79qn/4DPL9toj7+CN6z0DqQ1WOgva9FN1PkhAS1Orh3mr0q9GB2K5qslXC
	 scXEvlIXqJ5srN3BcqIAjqdwqr7UK9xIGt0dTlwV0MKzMAeX4GxKcYRYlOYndv3UdD
	 j0+mmKCFyRsXw==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:25 +0100
Subject: [PATCH RFC 09/41] bpf: use fc_init_pseudo() for bpffs
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
Message-Id: <20261110-work-loop-pseudo-v1-9-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1203; i=brauner@kernel.org;
 h=from:subject:message-id; bh=NuPA4jHbua+UQUqvE1NH9WnvUCJeB7nsXYSG49yrfac=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9ejBv9qN9iY0qd75n8gck3laXYJGcP/Xvwpp6nhV1l
 +fz+Fhu7yhlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIHQmGvyJmG6+tnBjH3qJw
 I1e/7XGpNFv1HyWFz9buJ/bVbr2pzsjIsPmDUI3mIZewOZLzrAJLZy6ad+vu3j8/r72fuW2C0oR
 /b/kA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize bpffs as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/bpf/inode.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index c6f328e4752e..57cf3775c076 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -15,6 +15,7 @@
 #include <linux/namei.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/fs_parser.h>
 #include <linux/kdev_t.h>
 #include <linux/filter.h>
@@ -1197,8 +1198,6 @@ static int bpf_fill_super(struct super_block *sb, struct fs_context *fc)
 	sb->s_magic = BPF_FS_MAGIC;
 	sb->s_op = &bpf_super_ops;
 	sb->s_xattr = bpf_fs_xattr_handlers;
-	sb->s_iflags |= SB_I_NOEXEC;
-	sb->s_iflags |= SB_I_NODEV;
 	sb->s_time_gran = 1;
 
 	inode = bpf_get_inode(sb, NULL, S_IFDIR | 0777);
@@ -1261,6 +1260,7 @@ static int bpf_init_fs_context(struct fs_context *fc)
 	opts->delegate_attachs = 0;
 
 	fc->s_fs_info = opts;
+	fc_init_pseudo(fc);
 	fc->ops = &bpf_context_ops;
 	return 0;
 }

-- 
2.53.0

