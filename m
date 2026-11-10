Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302404;
	b=5HQwyfr6SDL8Ki/iPzSTNdt6/uI8XzAAeYZekR4c/4HEkCJBHaXxZzNMpv6ANw+z8Ixb
	 4ZORe18LPt1znEDeu6qPlSbWbgb3f2ZBkv8LQv1efE1+JkpSWvO3ZD1fGK/ZyrGqbwA6O
	 Rd0b7oLQLALrbDhGLyznMOfU5x2EfOaBrcUi83QpCmjE6W98j/VEm0tgIcVykPEgruUkM
	 yF0WNRtwr6Cpz2jQ0dtKqPIS7D/foPBPV5CU0FpgZvu+jYQIZvtu/lyGO/WSWoWa07Bak
	 qjCTMQ2ZPs0C3ldGJzeGp+/rtHqtS6cw4yxP6drAnL9m4PuWdvHTemLTQDlj5enVLlQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302404;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=E+IOyvszTPpv67WVfApXcw8urPUkzwLhKXwxrxd5Q2U=;
	b=jqnG59mLReAFTyf+vYQYb9HtoFxWppUtJh6evm6LHklriLxdDrPV3yt0ZlK67OIPJt00
	 A09KcWOHLn/8tAybmk5iiaa0jxhtfyLSnWZ2NUUJGyhJlk5X3jIyYcpuQuvXmOjJJJ6Ur
	 L2M8SLWrfoUzP+NSjnek+3nrydvsZIOUV/sJTRkrR0g4GwpPpB9oI+MJrujzfZLQKi51Q
	 IFElsQrMdGxbdgEdHy+kXeiwPvf7Hl06Eelr7D5Z3LSri1wtqCcIG6j0kHA16Gp8EeABL
	 UIbwznUImdDa6FgaiSCgvy308hGY0OLGU7nLePjhkKtxS+E4qH3/3Uf8lDPv0ckJTww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GRiIgHwN;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54D82606C66C;
	Tue, 10 Nov 2026 09:20:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GRiIgHwN
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5968D1F0089F;
	Tue, 10 Nov 2026 09:19:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302403;
	bh=E+IOyvszTPpv67WVfApXcw8urPUkzwLhKXwxrxd5Q2U=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=GRiIgHwNZvImcyL7ZrhwcHTim1Tcg8ha0BAVLvCt63eibDuBdqoGnn3+IZ3T7OBIq
	 kT6r8YMuTD7me3jVVO4LuvwQYkPqosPEVX8f4q9eZuJZsQvKrNsIgO5JMMLqqeNIuC
	 5Cpr1r58rbzBBX6KMjeREg5OUsa/9eOU65Z5i70WZg176K2uk1tQ1kAhA4U0o0Rctw
	 xZ/y1A7h5XbjDTP8H3oewDpTzB4kJ0kw8bjZG9JUpDxnNRmZc91S3mqwbwSIu6bKQ1
	 710KWpylBRJOXcVv5bGIBzE03omQg/l6rlLylLNvB6cAWjRRFZkeN1M+920TaGjY0B
	 2UXvy+J5ImDmQ==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:52 +0100
Subject: [PATCH RFC 36/41] nvmet: refuse files on pseudo filesystems as
 namespace backing files
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
Message-Id: <20261110-work-loop-pseudo-v1-36-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=834; i=brauner@kernel.org;
 h=from:subject:message-id; bh=agqenJdWQq7gypo76jkCFbW4mXy4h6l0lNCXX+ASm3g=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erDvm3yLxwpNhn3Vf/xC/LZIi53fJ7yLL7tHITliz
 91kU4+kjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIm8FmJk6Auyf5jNeWOi0OnH
 C2RnbHW9nXtha/oTsYTE2efzD909cIzhf93azF97BBdfrrbP5nki8XXrjrDbU/+oPHgTKJzVsWp
 jPzcA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The file backend takes any path that isn't a block device. With
buffered_io=1 that includes files on procfs or sysfs which then get read
and written by a kernel worker on behalf of the host. Refuse files on
pseudo filesystems just like loop does.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/nvme/target/io-cmd-file.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/nvme/target/io-cmd-file.c b/drivers/nvme/target/io-cmd-file.c
index dfa8aa46188c..71c69bac5394 100644
--- a/drivers/nvme/target/io-cmd-file.c
+++ b/drivers/nvme/target/io-cmd-file.c
@@ -52,6 +52,11 @@ int nvmet_file_ns_enable(struct nvmet_ns *ns)
 		goto err;
 	}
 
+	if (file_is_pseudo(ns->file)) {
+		ret = -EINVAL;
+		goto err;
+	}
+
 	nvmet_file_ns_revalidate(ns);
 
 	/*

-- 
2.53.0

