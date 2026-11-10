Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302274;
	b=z+93YwyRZJcm0HWWvHj6jWfNlHKKzJYK+vLXSB/TLa9VCgBHxnvpCjtmpv2LvfkvOokQ
	 sEKq9TfVQmE95hKmHHrluJCiH/pyunJT5dZa1eib/Aa3nv4ENJcZGxnHjv8PBacQV7SOP
	 4bdimYCgiMW3My04fb+3paURRu+6Q/AMIh/OuxBGefTw3scQGXT+3/Wq3w2dAsgCjWFY1
	 HNPelHNvE4Ro9vtAF+50i3NXGiW25kN5M2J9uDZC8V+TCvU78U1eIMVTqe1Kn8vAvR3Mi
	 XWWck3C31BuTUx7cKRFSDK2/hxYCbGDlvQTV6w6QGkbtq20CB9D0tG2RsPsGBpy8TRQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302274;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=V5BWJw5fa84POo80x3ibKreEFrHi8L/+0M4nKiAomaU=;
	b=VclSOr2dlNZE167D39tWkq0uk546uucxrFTC3/M74w22urDXeCNZxo0K3aYfLWvbuPP7
	 APYpKbonzJnc9Ssf6PmhX/ggKsV0FVFcEkvEPq1yEwPxPFh4K4Y1Sud3T5aV1APlwSRZu
	 KheqkeQlk3n3VL7K0b3D2TTHlZrBfSGump4pv1vh6CVn0Wqtu3TDIye3AsrPDFwkcgMD6
	 AWmtSNW4PczDVmi6ADqBgeLvWMykq44TR3KxUez65Tj9zvVfmIt/UlCpl/tIRo7ZEyFR+
	 uIFta06uPp14YsdI3l23a+BWZQPxuhKe7z2bxt4QDn8tsBeZDg0vyEg9hfSP2lV4Jew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KN56aSxE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 32A4B6070B05;
	Tue, 10 Nov 2026 09:17:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KN56aSxE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 58BC01F0089F;
	Tue, 10 Nov 2026 09:17:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302273;
	bh=V5BWJw5fa84POo80x3ibKreEFrHi8L/+0M4nKiAomaU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KN56aSxEcIL4HezFtJpqamXDQkWCizrnZgnkUMIpPJsU7rRuUGbPuKCmoeZKs9Z8T
	 KX8yIwO5M/hIAuohYYoYuaalWbYYVGCWyj3OPI2eTlBmHabq5gQXT0Q9S0rZ4F3ut5
	 C4zEnhc+UMJ2cgIQGGeaEL+qrQxNqtC4KAdzr1uwPXxDiu2A5V9MYGtecJfiijcWEU
	 2ZNMp5ydhnhMaivDafrR5m7QBhsQux+h3Tx/1FbSjFTpvpg7tD2QL9hYdoAqvzBL6y
	 XALD9so6bBSasGgjOreqMXh2TJ7gKHcAOMhp27y+3npGTFNV3GX8PCI5KY5SzKdsrT
	 HZkVBu2EyzxNA==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:33 +0100
Subject: [PATCH RFC 17/41] securityfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-17-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1036; i=brauner@kernel.org;
 h=from:subject:message-id; bh=MwHP9YE6cjEfGAuH1dNASl/A50wevLh7f7bfLWi2WsQ=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erD8krTE09Ofz2cIRrPJrvxZXfW5i2mz60HLaz3/t
 aacvaGV01HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjAR0ceMDF3dd12/pYZrKTE8
 Ycgt3jlH/vK/wh9r1zpfPu+pqC78O4rhJ+MXzsV8icqCDBsCp8j+vcN8x+XyLeYvblvbTnJ6hSb
 MZgMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize securityfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. securityfs never holds executables or
device nodes.

AppArmor puts a .null device node into securityfs but only ever opens
it via dentry_open() which doesn't care about SB_I_NODEV.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 security/inode.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/inode.c b/security/inode.c
index 080402367674..93997a9f16fc 100644
--- a/security/inode.c
+++ b/security/inode.c
@@ -14,6 +14,7 @@
 #include <linux/kobject.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/mount.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
@@ -64,6 +65,7 @@ static const struct fs_context_operations securityfs_context_ops = {
 
 static int securityfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &securityfs_context_ops;
 	return 0;
 }

-- 
2.53.0

