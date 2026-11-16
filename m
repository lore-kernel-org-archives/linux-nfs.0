Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827338;
	b=pqqBVwwtV++V8c6JHaDr5xyb6xDPgqSmCryEyWGeXtNyZ1Rp95xNnIsf5GSXjiWzSatv
	 p7GP/LQxD6m1dY4x6P846Fz/iIksU8pCcpzsV4j3h9qtoiyx6Bo21nTM3ovYiPzETCqnY
	 VFfuB+59pXXh0OauApzs51RDwNLZUpC8QddOvSC7mXrgNg7GAx2sqJ9yurDNfHfNKlJh4
	 ab1a4TyqnBnRI+YAXLCILeBBnP3aakTg3/dsLKbkwjt+N0CU3ZqFr+CjJet/ePNB41N4z
	 8LzSAaXInktjjmeazxd635/m803jrYxpe6Q7REdvcAh1O3z9SA8inbxMkCzcb/YQKpA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827338;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ek7FYduULSVbUq5arr3ZrFc9sF73FP4dcX9AYxY+9Ag=;
	b=spm9xRWIGySKP653RGjcL7oaLRdsjK4Oj1JmHtPIlSqUW2unhI3cIfcpxFFeupkLkkSf
	 FEvcVWaRh8YZYiwHyqTJB5RTHbVRFQY3aEf2eq1LfgDxgHR+ocQUGC5MqB02oUzbZm5nh
	 M8haX/b3khDChaylXYH6FLbAqdTbBQrlGYKvi4ijc0niEZBu3jFpSN2dwFAM9pmrCLWU8
	 IJWOPWhQMbVdH4JQ6HPtLf/ZvEy3UmlfCYQhMzEhpv11wCEopE6E+5VJ8Z6aBMRj3bEWV
	 XkhlP8zvt2td95JibSyP/MFLGq9CiZ2mdrdV0kW8Rw8aYNp2y4DSilGlWPKTqq/NwGA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hqVGQD92;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4766F606BE2D;
	Mon, 16 Nov 2026 11:08:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hqVGQD92
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DDB211F000C4;
	Mon, 16 Nov 2026 11:08:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827337;
	bh=ek7FYduULSVbUq5arr3ZrFc9sF73FP4dcX9AYxY+9Ag=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hqVGQD92ptf9qqnybXZsjl1lBXLy25LXcD3qck0h3II6D1+uj2w0UCe7AnC8yfuUK
	 DBvlP7U/ezRfWQ8Rs5suLaGriT1BSlssZ9axHhjPhAuXDlS1Y/K2QWswiS2nf0hd15
	 mgNz1M9WUrIByUmgj4LNTVaef0wBQawvbuFhB9JsfbJP+PbGz3/XCoYokswy4kK25Q
	 X2hrdX3tY06xzdGLazSIumYwZqYdKkoPSnb1hfbzQy+wt09vb/IMMve/bJQLAIa6F1
	 vAjADxJuDTMP4T1sHKG0OZOaWsM6OFV3enjzvFavLrjqm3CNNR7zTo5aWyeLsdFncs
	 cnHuExJ0EguVA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:04:56 +0100
Subject: [PATCH RFC v3 23/44] fuse: use fc_init_pseudo() for fusectl
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
Message-Id: <20261116-work-loop-pseudo-v3-23-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=999; i=brauner@kernel.org;
 h=from:subject:message-id; bh=7AmoNzP4UOKW+VKhMYMUlDwuPOwZV6Om3UBU1WIAvFs=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9elx50rnV4OoK6YIK/Q26axukqwxsMu5p3Jl8d71vu
 a5nhWt/RykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwEQ6NRj+qb3+utWQ88yGsDn1
 fz35NzrGiu+9VZp3a+fs5gueVgtSwhj+Sh5vPv5J8uPZIynqDy8WReRO0+3vnPshjGGN0vOzJl/
 fMwAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize fusectl as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. fusectl never holds executables or
device nodes.

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
Reviewed-by: Chris Down <chris@chrisdown.name>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/fuse/control.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/fuse/control.c b/fs/fuse/control.c
index 21ffde596d611..4497362e7df06 100644
--- a/fs/fuse/control.c
+++ b/fs/fuse/control.c
@@ -10,6 +10,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/namei.h>
 
 #define FUSE_CTL_SUPER_MAGIC 0x65735543
@@ -334,6 +335,7 @@ static const struct fs_context_operations fuse_ctl_context_ops = {
 
 static int fuse_ctl_init_fs_context(struct fs_context *fsc)
 {
+	fc_init_pseudo(fsc);
 	fsc->ops = &fuse_ctl_context_ops;
 	return 0;
 }

-- 
2.53.0

