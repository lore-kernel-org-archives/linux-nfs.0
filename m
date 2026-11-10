Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302226;
	b=rO0mxl+arGntcVkkKsYOGEnFGKaQeCd9vunrY/8dWo9PeU1F8d7ozUIwZO9Uzv9XCJfv
	 WGiNNrsrLO69xObcycpbM92WttPEA/pSqMXxoUOFHboNShnP0bcJ6aFbJ9WhFrMEhOU0W
	 0G0PLLH4YUIKqjhAqkdSQwYlOPrVuHp5qdBQzCPAqRr2a/uzt38vi+EZNECjG0kB0Tdif
	 2zCLvHKKW43+ZyPOeHX7Stq3a8rOal9AElQMXTSEEN+bm8U0JIhX9FHQUQmga0o2DkBYi
	 EByZR62abY/3vtk+PUk1Cuir9lPhYmyI0GR0TrrOkPVxstc10sDLMJthtqTZsVuZAjw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302226;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ZmsVWE65gHf0tYCZOotZ2fbgGfTg77o991kqs+Fgm8I=;
	b=yxx6+HbQTaE7H3zLMM0sqttqGclhCvT5XzWpgEPyzwhg7rpHTHzRdRDHpk1BtjU+B9ir
	 dnz79nD8huiqDa0DNs1ExxXN7vctybkbaBjVzVZZmqB1vS8Ie27CggwTcjYYljNDlA/FH
	 F3tropWKsE1Ub4+rnZyjc/hsns/udxJCoufFwYNzOkeSC0FeK7z1QGtAj12GB3gUmXxMz
	 5zYdEu4x3rQimjQ+NQ3vSSoKZpVDL49Ig/vCxQZgDZ/ddKdzRfAnG+M2K2s5MEHnE/Apg
	 tgYifbp9lNPNT7FIRwWMA47CsCYyn0SyvVXBH4pnKPq4n/BSPDMzXdyo4bhF1D25rIQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BW8cSBu5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 34334606DA05;
	Tue, 10 Nov 2026 09:17:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BW8cSBu5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 977E81F008A3;
	Tue, 10 Nov 2026 09:16:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302226;
	bh=ZmsVWE65gHf0tYCZOotZ2fbgGfTg77o991kqs+Fgm8I=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BW8cSBu5u5r410tEcT+zMEpXHphJlFpdpAvRKAvEiKkqyi0xID6vk2b0Tbjr4F3K7
	 awaBsefdY+MBphndwr9KbPvoSGcCvsFqAgttwi2fLxH3+R18Qt4275it2lfQHkFKW3
	 UWJSti38mAmdmLS3tX3vRlC5H3kzbz/lg2YywjKPfSIrMY163nLZvxRzgh12Gfu740
	 fCVYcWuwLy19s6iKyC6ZAEcLuBFbK0G08kyGDUPlYe/7HLPPSEk9rvbQ36ZpaFxa7H
	 vhskSHci2E1kOmUw3DCi+DzAu6HlXgBa1yUahbo2TZ2iHpM1c2csxa56tO5nlkWHht
	 owe5/3f9zcJNw==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:26 +0100
Subject: [PATCH RFC 10/41] nullfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-10-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=901; i=brauner@kernel.org;
 h=from:subject:message-id; bh=sE5h4xDpaVEC2u2QAThbBNjL9uzfl1yRVOrJAX0MUt4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9ejD//EYdt1/rJsiFfvkoZ/8qOqx4q8M6HwH1m6/ZZ
 AI224nydZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEykdCnDPxurz9VH1LyPmPhq
 vwyuY532xsvTcZ32qt+q1sFHglVuuzD8D18Z213yU2Sl5aU3uX8PWyTKlr/7O0218syUZaL+TwX
 WcgEA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize nullfs as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/nullfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nullfs.c b/fs/nullfs.c
index 319c2f5c5a67..2fe24cb97160 100644
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

