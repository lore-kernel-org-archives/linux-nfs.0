Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827315;
	b=0YZQkc4M00blHV3o+sI2JJW5PS+sPgeR80lwdz9WYvpFM84yTFK9DmQRKSeGiH1l5i/p
	 5FraeRX16cPcfuOFXIPi3NNSFAHOXR1oQteev8aTEA0/IW7AtZ4kHPYAHLUrJc3v3Qc9r
	 JSR9efekwX3Q9I/pGy662K+4AlAWJ6GLrmsT+fAuEGwbRcw70mxfLyt1+Pt4yH3QmTCrE
	 gEnpGDb570IlYlMPc+xRr6hLv7+q9s+EbQ5aoSRnMbnedVu8d7mk68gfWyNBDsi8Yy837
	 b5FiIuqe54qOEcQ+ZZLsDt62RIAeW2YPbFxN9wWzNcB8mB5C5JW4zYzjqG2lfJv0CPQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827315;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jWvZBvrR1DOnVrw2+TUZXk3eg5enGUE+5GG/CSvPX1Q=;
	b=Z0rjIZhNVmB5RxQb4yWilWPW4lUJPTldo33Iu9S6L6pCVgqNsGhnF/sO/Yxj2uKFA2fC
	 hRn64puIrDMV7iwiPSw7luebzGInSOQFzTvcIUrIXbxDO13MffmMTz7BkK92YjL9bcpMW
	 ztkaKpAUKg/1dfZdQN4oZ18Kbfn776TaAldUwnzrzf9767FikHAuKMryWDmZKMY/mdn3z
	 l7Dmd4kUoCTYbAStWReFzgoHdD9G1hUHdsASBUy1TPZ8s0uSaAFMU6LKybnFlllGJQgvz
	 H7Fz1+sp+5FF4jGmgFI6W/UbXyKOdGa8fB6UgWuN55P6gT2IwLUzAKQyA/Jho/0JiXw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M6eYgI6Z;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C70E6076E06;
	Mon, 16 Nov 2026 11:08:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M6eYgI6Z
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 75F771F000CA;
	Mon, 16 Nov 2026 11:08:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827315;
	bh=jWvZBvrR1DOnVrw2+TUZXk3eg5enGUE+5GG/CSvPX1Q=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=M6eYgI6ZSCWFmdAv+fAKXRWQeKnBvNmi3ZGo637XqBmytIJecsOCK8L3K76JPXXYP
	 ZDPxK+Ub17iANZxNSKyVdQBi8dIcKzwcfFwcTCWZPHberYy7Dgy2T/eRZfYiblTD/U
	 c6GlWKRoWjOZBL0xxEWztgdZ+LarTM7lnyr+L5QUayqTvcDKYMI2riwgHl2jprvZgH
	 USZr2oeMdzb8nM+mcT8jPB0bEtaNdZsis1cazQz7ZkYniO5Pq48EYVmjMP3dWQBom9
	 daQQ9/8p1AQEcogykoG50jophGkGugVTSDHtKXkiD8LEQcS8k5lbk6G80EZfEpoPlN
	 0Q/R/MMLzKqVg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:53 +0100
Subject: [PATCH RFC v3 20/44] apparmor: use fc_init_pseudo() for apparmorfs
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
Message-Id: <20261116-work-loop-pseudo-v3-20-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1081; i=brauner@kernel.org;
 h=from:subject:message-id; bh=NfojWSg09WkliXy6sDezT//cu9zqICvIe5+KQz3E+8A=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9elwq/vSPWt7KO3sOFNTGK89qCpZfP0G03cB2BnODS
 O1VoQXbO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACbCsIHhn4LYxbUVE/0Uvyou
 mbw9Vp/12f3yXZEdk7pN8p6JL681O83IMMWguV3BybXeKuJN4+fvR5NTypbM05p2R9owKS/KuHA
 ZLwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize apparmorfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. apparmorfs never holds executables or
device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 security/apparmor/apparmorfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/apparmor/apparmorfs.c b/security/apparmor/apparmorfs.c
index a993664672173..351ea3a7120e3 100644
--- a/security/apparmor/apparmorfs.c
+++ b/security/apparmor/apparmorfs.c
@@ -21,6 +21,7 @@
 #include <linux/rcupdate.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/poll.h>
 #include <linux/zstd.h>
 #include <linux/string.h>
@@ -263,6 +264,7 @@ static const struct fs_context_operations apparmorfs_context_ops = {
 
 static int apparmorfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &apparmorfs_context_ops;
 	return 0;
 }

-- 
2.53.0

