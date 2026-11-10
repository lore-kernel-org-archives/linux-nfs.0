Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302349;
	b=EBqVlKXUfxkzdUDUNcH/VnVr4C5v62hiEHxTlC6w1xlI9qV59lseJCRzbvJW0H2n9PUX
	 AuB5qj+Gn8P80DuIcl8NpgQsMNYd1VGASluuiaji2OMKWUMO/atNPOXeEohDZEuGrRL74
	 mQFowCynnMsYS5T9jCjOKryhcRVwokE3Dzf+jonoyvgYcFMogvWcc2ul8A+mU3rGnwaDk
	 ym/Csc9rivOEOz3+fSWu2vV56MbWrwfyx+1j/LTQng7m4NJpdDYccTiBxo0zy41tUFXm6
	 5wbRFjk5sn+Dk+7YYj3R5/EgjbtJNwF+MVeo9g110xSatGjgP4zpBy62tCcXKVzRpCw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302349;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=5VuE4/weECRM9eIO6+lamMRzkXENJc2tSdRrjKtP/6E=;
	b=kPuCc6B2gUdSO5G+kaQpVP7Zg5TAg32gJg3G+/h7fjqnOuqtWVF+8KpaidnYx5bYTB5/
	 Gt/dBZbTeiQ+VgLe3drFs8cYHYO5Mnw/73j7csHzqFWZu5cQ7WIKF3OcIehf01eW30eas
	 5JxEdvDKdLVPm+9pqn8tA3ikJvfuXDzjaQjxGTzuuD/HV3MXa4aq+90F0brc/z4pXFN23
	 b0gcr964hxvuA+NMhPT6d3ztSEI389GPV2mJpMOhVHDFshug/MowuFT4y0jAAfzHEv2uD
	 yU/TrRhw/n+Z7Ctve+nBf/SVQGb7uQGwf8log8EIwcWt/GCYoWExTisZRnPyns1mhkw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="iQA/sxsh";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64F2F607695D;
	Tue, 10 Nov 2026 09:19:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iQA/sxsh
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A77511F008A3;
	Tue, 10 Nov 2026 09:19:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302349;
	bh=5VuE4/weECRM9eIO6+lamMRzkXENJc2tSdRrjKtP/6E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iQA/sxshAM8lgjVZtwQBlBlt6Ccgq/KLZUd+ak37Q2oUOuNb3EKD2IEz5QKL7HSuJ
	 PzfYZUUU9t4mHJQyXpGh/FegWtFPckXXEaWIZpe18Dzveuhdh412cFkoYX9U6GHhAs
	 FA3mIwVRbXfRG/foFS7hgF8f2XdzXBVoA2mbPV/1dW+mNpe42vnBoqn1KQUo3a7IH3
	 OShJM3zaQPTgLbpL8PYQYa3MhajH2yuDWbFWTSzcixuX/GpsV21irhlminf8YwjK3i
	 FcMM/10RV269QdY1WwY6VGtRQ1P449Wk5bY3A8Uk5z3MdBjKp3IUMwp4dCZ2nOAdUX
	 a+oxx0hQk158g==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:44 +0100
Subject: [PATCH RFC 28/41] ocfs2: use fc_init_pseudo() for dlmfs
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
Message-Id: <20261110-work-loop-pseudo-v1-28-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=909; i=brauner@kernel.org;
 h=from:subject:message-id; bh=IdNufAsq5EGNNcdE9WV9rVN1DCJjWbb8v/riZT7kRA0=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erDl3LqF3BIxnOW7s6R69N3au4r1m0WSo7rUW0tPb
 d3ziC+no5SFQYyLQVZMkcWh3SRcbjlPxWajTA2YOaxMIEMYuDgFYCJLTjEydK1aEV6R03Dp6Qur
 9ReajrtK9AT09OsHms5fHf0wofDSUkaGzj38rmzbCz87b5+14Zu8c8plz01rglO+aJ1tSLofN8u
 eDQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Initialize dlmfs as a pseudo filesystem. This raises SB_I_PSEUDO and
also SB_I_NOEXEC and SB_I_NODEV. dlmfs never holds executables or
device nodes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/ocfs2/dlmfs/dlmfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/ocfs2/dlmfs/dlmfs.c b/fs/ocfs2/dlmfs/dlmfs.c
index d3bfcada3e3b..1789ec96dc13 100644
--- a/fs/ocfs2/dlmfs/dlmfs.c
+++ b/fs/ocfs2/dlmfs/dlmfs.c
@@ -21,6 +21,7 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/fs_context.h>
+#include <linux/pseudo_fs.h>
 #include <linux/pagemap.h>
 #include <linux/types.h>
 #include <linux/slab.h>
@@ -563,6 +564,7 @@ static const struct fs_context_operations dlmfs_context_ops = {
 
 static int dlmfs_init_fs_context(struct fs_context *fc)
 {
+	fc_init_pseudo(fc);
 	fc->ops = &dlmfs_context_ops;
 
 	return 0;

-- 
2.53.0

