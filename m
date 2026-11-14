Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661607;
	b=dSFJL/WCxiUu0VuVV7UvzIzLG0zwMC7ot43foeiH5aQm8uuyZBaLG5qDF/dsqWW9EX/0
	 kX0Wrba4QCRileA9b5n3orjG8eTHPSUc4AQZk2R9TRceJ9YI3G0v0r1nwNxnXmbUdw0z3
	 bWZ2+MIDqpe1sKNQ2OPI4J/SavxYjggU0iF2HwXkxiPudLzXTdEq1w8oU9MuJ1AN9WtuR
	 7XeIyUxl6WmIU8cwo/0+UXax2pWH0h7CKpM5178/DJsda537pTD37dh1t7JdSwXL6G2iO
	 S9dtseMLHMiENi5bV33HnqnlEh3gel8RH+ko8X19LHcL5Uzaox9gFruNBHQnK2BhDdA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661607;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=FpatCwjw3dsO4JQBQMC7kZ13u2vnGsecGcPNuVpa3KA=;
	b=reGOGbvX4ySENczi47T39IwF0fSAfgocisw7wXKyaM32gDWDr1m07eNVT4zVelIN5EMp
	 vj56ZZ82Zao8KC+HAfQXeS+kFUa8iPJvvNWDqfML8fGn6VPEtWItCd4oOAEzIOjN28Uqn
	 ePdpOkkhSaWlgU5v7l7KnpRNTrQsvtEwOY/gJTMM/9D3Crcz/VzNbW+dhoo4GKLfQzVr9
	 8aQ7Y0Eayhkp/YXwSl4B8/TtU3TzgSvpDRAJOiIC0ZOj23GBWMG5WCjuw+WNuLoh4yvok
	 6ZHn3xHaHpPINpbYMLQQpNzvCiWkLtVohCV4lQGho/iKXAUzbgOPjYQxG9yIfu7KyJA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mb0GFpd2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE3E360A3811;
	Sat, 14 Nov 2026 13:06:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mb0GFpd2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 62DE71F000C4;
	Sat, 14 Nov 2026 13:06:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661607;
	bh=FpatCwjw3dsO4JQBQMC7kZ13u2vnGsecGcPNuVpa3KA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mb0GFpd2C5fDNr1HezZ4StZUVzaHMoEClA0IeuQL8e+ljakrtqDhCEASV8IAXvP4d
	 RC1oa5y1MsN5q8MWN8GXMEbVUZRKyYW/fl7AOLLjvARkDSTMVvI+gSxb3II3v2DsJg
	 96C3cn9NrBLsKPz/zWvh7GCVaCkTb4ADqAaobil0bVhIyLY+X8wvCP6duLHOwmTcEu
	 nUOIlhP4wuqWbLoMwB6uNjziIgKsIHHQgxQhQSZBtr6h25GDdzhH7Odii9UtlPy/VC
	 EmCy06jsWG4U6l5QmzFbeJBNBHn/Dz6c/O1FULUO7sYXxvju+nwGNQCS8SodWc8ZVk
	 Uvl0fK6ioapVg==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:01:51 +0100
Subject: [PATCH RFC v2 10/42] nullfs: use fc_init_pseudo()
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
Message-Id: <20261114-work-loop-pseudo-v2-10-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1042; i=brauner@kernel.org;
 h=from:subject:message-id; bh=5XsIgU6fgQKzvWW2wDjrcokIetPacs/QWCdr4iIPKEo=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iCk8KTdXmVfntRBnvfSi6up7tXNUNn2+7OgpMrv+X
 X1Phd3UjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIkUvmD472Toe9Lf1rqM+4vC
 vnQTU32GmsSg7adtuL+nHlrQZ//mDsN/16arDJPabmxYrPfimrJMB6/AxA41v/6kPF6G+28aHm9
 nAwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize nullfs as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/nullfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nullfs.c b/fs/nullfs.c
index 319c2f5c5a671..2fe24cb97160e 100644
--- a/fs/nullfs.c
+++ b/fs/nullfs.c
@@ -2,6 +2,7 @@
 /* Copyright (c) 2026 Christian Brauner <brauner@kernel.org> */
 #include <linux/fs/super_types.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/magic.h>
 #include <linux/splice.h>
 #include <linux/uio.h>
@@ -174,7 +175,7 @@ static int nullfs_init_fs_context(struct fs_context *fc)
 {
 	fc->ops		= &nullfs_fs_context_ops;
 	fc->sb_flags	|= SB_NOUSER;
-	fc->s_iflags	|= SB_I_NOEXEC | SB_I_NODEV;
+	fc_init_pseudo(fc);
 	return 0;
 }
 

-- 
2.53.0

