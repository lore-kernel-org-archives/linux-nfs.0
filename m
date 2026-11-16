Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827484;
	b=4khqA5ZavbtoNempcCTNkuSP25z93qHYvO4umQiYuPPSWt+oLSRIRUfIM45Ub247+nRl
	 mH9cOy8yMdoq2vLTk6Sy0+Jr/bHDjQwff9tz1J3FpkWa+KVN4TSneuWr1Y5D1YjLLymwk
	 HG4vZ+S15syVFYLkdDFY8gX7NNV/UFsOJVCT+6vP4S1Ks9YeVR9FQB7F7zms5i4t0AdLd
	 aFHqwjb/oZ4tLg/w5Xr3181spo3s4LRt0VdVcjPHSBzCNC9jMU8nlJC6VGZZoENyqJy1H
	 l+TyI6lJ7Z/p7U6G8pg6jEW+FBJGMEI32O1fuGvC5btRo8vf7cYMimKHW+gOsv2rh6g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827484;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=8CwpxM6nYTuBn1diZMKE8u8L7OG7WlbpBDnW4TTBYyk=;
	b=0qOQJcDtFmy+j+itldogNyqiOo75/FXFfrc0aLv58efNkOxj/eIMbniLRjpjCXN8Kz80
	 fr7bXfRDaSPQ5Q6Y07V+nolyZpLtP9/JisDevdn7ddeIzsP/PhcHDSc7W3v8HThzj1cLo
	 Tu4GhOWw4Me5R1HXKs1TMP9pPmEHKHNyeKHNUll9U8kXvif4V2QOto/NDtu284dWFw60B
	 rJgilnRgpMUNMk/2xIemJ2aqg4WcRfl6fJJmxFoD/RJ8CpAhUgOZppXItCG3xQjm/5EIW
	 BXyJ4oTUkndw94xd/5oC1GOWE7B+sPp69mNcneN6aUv+EgaOAw4ua7ty7pCxfzIprpw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TgjMN56K;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AFCF6071B3D;
	Mon, 16 Nov 2026 11:11:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TgjMN56K
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B07B31F000C5;
	Mon, 16 Nov 2026 11:11:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827483;
	bh=8CwpxM6nYTuBn1diZMKE8u8L7OG7WlbpBDnW4TTBYyk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=TgjMN56KOGGjy4LWUYsZ8zVo89DB80z6mNiJUIXdyCxzkfdDPL0CceRNnYEB5ZMAg
	 PvkD68BWJ9caW2s/BGPrGC91Iq9CXON0BvEYC4o9C6G7FIaTwo+zxVlOEz2OOHPj5k
	 4vXH0MjVLq/jft4abkooK+ZUvlfxnZFbaMziEvjtIgG2hkF85u9Jdu0B1Z0thxS1Vt
	 ZGARk4NS/4O6UY4E9/nGiGeDdufCKu3ZzScYIpnsUw2WoGqih1dN6XANIxyQsbx8j7
	 /P5GGzoXoUbjqBYgg50FlLRHJWxCQQmcH0xslfduPPlaC1VbV4Z1ZBjTDb0GhtHuP2
	 ZujQbdQe5sKRQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:16 +0100
Subject: [PATCH RFC v3 43/44] acct: refuse files on pseudo filesystems
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
Message-Id: <20261116-work-loop-pseudo-v3-43-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1795; i=brauner@kernel.org;
 h=from:subject:message-id; bh=TBLyDKw5rIlrAxe1WyLhAIBRdo8Sa0ool6FMcens/Cw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9ejzBrFZos83lvdOmyU1dbrg+U5ejPTdxwtWo7L1VD
 VNiDrWpdZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyE7zkjQ4fU9EqupZErcpbM
 YdFl11N9/mKWoNrBrC3H9UQXrluybwojw9s/fcqVr01abSYZ5cX71J9+ofyxLFboXoAX66kl1eu
 TOQE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

acct(2) already refuses to write its records to files on kernel internal
filesystems and to procfs and sysfs files. It recognizes the latter two
by FS_USERNS_MOUNT_RESTRICTED which misses every other pseudo
filesystem. So a cgroup2 or binfmt_misc file is accepted as the
accounting file.

The records are written with the credentials of whoever turned on
accounting so this isn't abusable the way loop is. But files on pseudo
filesystems aren't a place to store accounting records. Use
file_check_backing() to refuse all of them.

SB_NOUSER doesn't need to be checked separately anymore. It is only
raised by pseudo filesystems and by tmpfs instances that are either
kernel internal or can't be mounted.

Suggested-by: Alexander Mikhalitsyn <alex@amutable.com>
Link: https://lore.kernel.org/r/ae189903d4cda27130317a9312d94b53d07415ba.camel@amutable.com
Reviewed-by: Chris Down <chris@chrisdown.name>
Tested-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 kernel/acct.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/acct.c b/kernel/acct.c
index c440d43479ca5..0c502f778fde0 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -245,11 +245,11 @@ static int acct_on(const char __user *name)
 		return -EACCES;
 
 	/* Exclude kernel internal filesystems. */
-	if (file_inode(file)->i_sb->s_flags & (SB_NOUSER | SB_KERNMOUNT))
+	if (file_inode(file)->i_sb->s_flags & SB_KERNMOUNT)
 		return -EINVAL;
 
-	/* Exclude procfs and sysfs. */
-	if (file_inode(file)->i_sb->s_type->fs_flags & FS_USERNS_MOUNT_RESTRICTED)
+	/* Exclude pseudo filesystems. */
+	if (file_check_backing(file, 0, 0))
 		return -EINVAL;
 
 	if (!(file->f_mode & FMODE_CAN_WRITE))

-- 
2.53.0

