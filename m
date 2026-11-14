Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661788;
	b=0kbxMEQmCdqqyQy9iqn8h2TbAgiuHzEA5THSX6p9JRRNqzLmlcymMJ+d6bae0MDZP0n7
	 AALhF1L/B3v2+hGWeWzFW6tKYRbSssP7WbwUK/IMWXFvXvds1c7Bn0GyIlNxT36cb4qdI
	 VVirDrlQ9/Wsuv4QPm08Tle6VEb0ymHCV53Jw9dtORx+quypnAqOleXvsqjTSWnhbJilD
	 Qg5oJuUwolWQxIR34U5PjYo+LDDJLALJN9MTTlk74VuqRKaog54aFxoBtwHdO2OHgcS+z
	 O96DWll1EfFAU3+gDP5V/wqlHCpbxxBtGJJAa6eQviK5ekyBpusYVv4fP2ewItHzXEQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661788;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=TzlH4lJ7ZSZIblRm06H21pfwXJAWDZmkD7RxeUrwAwo=;
	b=feWPRbmBvaAcfSgqoWPXMSu3F1SZc5re0T8rw5bmZKEp99DvDq9EnHCMRz7dwMR5Wc6w
	 sjF9MLGjxCojLbSKOUPx9vVpNI4O4mzPYQkjPJvuaNvqpkbD8BA+yXdUp89LFUn77u+wH
	 5WsMH8qF7J6IjzIeouUqAiyTK2bslZhrkf1CpDzL+xc6HvdzXG4W0F+vadRzGw3Pyk4Zr
	 jOuzOxqA/c3yfMGDpoQggdbdmmYdq0QK/o2/Yxby/kzqHaJcJGIEvdvLCg3TTGIdhJe3x
	 kcgF5LHhXSSiZvQZgbwG3O95ve/IIBdiytVksJCRLXHTXRs2J/nH9ePzHE8KP0cu8cA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GlyL6zOy;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 21ADC6079E1F;
	Sat, 14 Nov 2026 13:09:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GlyL6zOy
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AF37C1F000C5;
	Sat, 14 Nov 2026 13:09:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661788;
	bh=TzlH4lJ7ZSZIblRm06H21pfwXJAWDZmkD7RxeUrwAwo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=GlyL6zOy3U34aQUy3eHEQO1vIyJXeAiTdOGtABLlkjbMnvKHjyhKDScl3Hk7rbn/i
	 bUN/hnUMxKho/1WWAiF8JiculAXTejCCuJ3FonfhnSNp937ufCy4qoRmfbGVvZHsH7
	 9rlf5d2C3SdZVqBTg4J8yIIUsxC5D98LB2FsGhf59wAx6+iIV/zNQO/IKTaGaMPHTI
	 VX46CiB8pXPS+hXzwpsFz2BDETD3xysRH8Rj/RJaz/eTFDnVWydJvu5JEiwzj8rnWQ
	 EWDXUNsiasluJEgOXK7yZCzr+ogHhW+EDBwb4kKVBL61Tujac2yGBy06BywSGLd7Mo
	 Pny//KWEyQopg==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:17 +0100
Subject: [PATCH RFC v2 36/42] nvmet: refuse files on pseudo filesystems as
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
Message-Id: <20261114-work-loop-pseudo-v2-36-98639a2286fb@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1428; i=brauner@kernel.org;
 h=from:subject:message-id; bh=T+p95LnTvG69fzj91gxDjYpoYRzamfjNk16RgT8U7v8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iOn/sX7W5ofcrzdtZCmXtdsrsyZy06+ylnkxnetWq
 G9bLL97VkcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBElN4x/E+qPMN83LkkV8+9
 6emz+TtUM58mNc28vP//+pR517bGGTYz/NOw1Z5h9eBm2/zf+wUFPT6nLXtx+IKQe7yGYPaa6P/
 27ZwA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The file backend takes any file that can be opened for reading and
writing. With buffered_io=1 that includes files on procfs or sysfs which
then get read and written by a kernel worker on behalf of the host.
Refuse files on pseudo filesystems just like loop does by switching to
file_check_backing().

Note that the helper only accepts regular files and block devices. A
block device ends up in the file backend when buffered_io is set. But
so far the file backend also took anything else with ->read_iter() and
->write_iter() such as character devices and FIFOs. The size of the
namespace is the size of the inode which is zero for all of them. So
such a namespace was unusable anyway. Refuse them.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/nvme/target/io-cmd-file.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/nvme/target/io-cmd-file.c b/drivers/nvme/target/io-cmd-file.c
index dfa8aa46188c8..2249ad3bb46d8 100644
--- a/drivers/nvme/target/io-cmd-file.c
+++ b/drivers/nvme/target/io-cmd-file.c
@@ -47,10 +47,9 @@ int nvmet_file_ns_enable(struct nvmet_ns *ns)
 		return ret;
 	}
 
-	if (!ns->file->f_op->read_iter || !ns->file->f_op->write_iter) {
-		ret = -EINVAL;
+	ret = file_check_backing(ns->file, FMODE_READ | FMODE_WRITE, S_IFBLK);
+	if (ret)
 		goto err;
-	}
 
 	nvmet_file_ns_revalidate(ns);
 

-- 
2.53.0

