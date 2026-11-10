Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302233;
	b=GH/WQnPamwX9UdPk+9/zBP6vncegTm7mvkf6U8YP7nXbGxSiT4GW6ROzNRlMb29xeyCh
	 o0FpSNZz2WeD484SrsyBzNFYCRzyFeKCjLJkP4+ZdMM40EsLsCKXyU2CFpCNWUB/DTDsJ
	 b3pk5s8BLRyI4eD5xcE8/wVrhQBGSa1b3vYMYumBP7zm8E/bFn18VBcom7reIP3hebyu9
	 FMYvvJ7zBwi86SyW6hX9bYDTlZ/AQz7MQkzSQVwmy7+2oEGlJIBWtqVXh4p1eFvCnk5MR
	 hOakOtJa98r2bleWEHTmso15So08UM6TFS7Tbc1BcEIU1fX2adTIysJsqxxK4pHmyag==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302233;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Aeiu3UyUCzSAfqYn5Q8bZyz+wYYebjsNU8IIX+ZzMDg=;
	b=arNT1i6enV+d4VNRSFmEAU+jXkwF+gYcOvsMlHwJPw3WLNRqynwAjdzM9ITq/CwT/X0E
	 wi+b2JQimaTOVOYj/aFTlGxHj4jI92BVb3mktgTpmrP+QrR+jzz+23SP0HFoTnXzoaixp
	 zPQNMPk4eTD6AQVQlsQRMLS4T9pQTFyjPmKbR1WknQV7UdzuVZ1sSglQXpL/UdA2vDPYl
	 B71np5Sh1uabndVNqYw9cXQWUWAEErZ0vUQJkRyQKIIuyu7nlYZDqhEQyBxNDQuJ0N6Yr
	 2F1xSJ6arpOOqBU2wn8RLDZJPhUWnoFSqUu0Et40Tr73+CyRbOvZ4enUKMcZbKk/VRw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="oIOs/EM+";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FED560A5BDC;
	Tue, 10 Nov 2026 09:17:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oIOs/EM+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9A3D61F008A2;
	Tue, 10 Nov 2026 09:17:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302232;
	bh=Aeiu3UyUCzSAfqYn5Q8bZyz+wYYebjsNU8IIX+ZzMDg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=oIOs/EM+KXYJ1grlTivKYR/ku8jTJ0m+cIlI+pG3YVNmGlTgU+6mJXjsBjanfGWq1
	 8T4XFq0QNRg8zsAR7ESB+aTONXWP2FVgpzDjvL9j6/UuounNAWxRDH5vAS4BK+FriA
	 AfJ2mWd7w+XhNvm479SKkBvm8bw9ZW4l45/S/N6hJoGcFILfLfz/Qcj/WnSIAKKHlR
	 aZu74imaFzIlgEUKmwdk+yZz0BxAbckL3QBgudLh+hdwVCHz4VM3nz2NTqfxr8RO87
	 0wJDp5SY816Gwv6wS5IRgzFg66syGlemxNOlITSZvr+VV0w4yn0U9xfFOWxx2iUo1Q
	 ypT2aD1Wz0XJQ==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:27 +0100
Subject: [PATCH RFC 11/41] failfs: use fc_init_pseudo()
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
Message-Id: <20261110-work-loop-pseudo-v1-11-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=879; i=brauner@kernel.org;
 h=from:subject:message-id; bh=jMBLnsAt3YLGCzcD1+vp96riKCztRaww7Mw52ZY6Vqk=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erDgSsTlaLm0BaZPb2g9zFBdk3jqJpvVSZWp6w78u
 SDN++zJ2Y5SFgYxLgZZMUUWh3aTcLnlPBWbjTI1YOawMoEMYeDiFICJ6BQy/M9iFhSuKGdsOHT4
 K5PvuWfptRIcgVqXrHXW3VP44fKMUYvhn/I1R41K+fPTD11o4sx5ED/hfMxLg0sltflhfgn7d1b
 yMQAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize failfs as a pseudo filesystem instead of raising
SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/failfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/failfs.c b/fs/failfs.c
index 437cdc981c2d..f03334f361c0 100644
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

