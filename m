Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827447;
	b=jO+FHe3NiC6gn0CJTYpecjj4F1HzCLeCjqXuY768E/yuvU1ACbYJB8cnqw7RLzO6uZtD
	 v+ctiZzmznvlELzi6/lFwaRiCue3E1zxgGx6A0NrrxlZV5ASZoCcr3NjFbQSQ+dL1VzzT
	 t7jIdrZDtjhxY0QrpHihB3COYYvL9/yZ7JMS32wcX6rr60QBU7IaleWjdCxHxOc7VTV+G
	 2TIr3gM+us4N2HDcaz32h4L8dHOgJSCFVo722XVXa7p0PnyISZOlOA2JWECMVSSKzLARI
	 WjQYdluYkN3Sa3enn6e2wS+Benzroh7+mhft26llS1HZ4uLoWT/XKOp3o947Vr5u/eQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827447;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=zLEVq+Bpv9BnXZuXWTCC/0nvI0V4xS0vAuEcIsGc5V4=;
	b=QrexgCdEwGBHXpPib0ob/IhPIxwa91V4hkFItMn2m6C30COW1xz21rJUNZZHhsLRnv8C
	 xfPMHVA3Y0snzmwulwt87IYMU9hlcUNyixtmlg9SvZJpNPkgPGMdHTdBzSnBk4pTFVIXZ
	 OWWx6ejZFTywD7ilKswNIugLiZoyOIAGzTBtkkNId2n7HJNFAF0MoDYpmh/i/QiBK4y+k
	 WRj+XATgM9ZeQGdE7g1fsV94m3O9gKVZyg/eL7ipVbnXYY91uzUec0rTRRf0/pCh/AsjO
	 74H9xmkqvVlGNIYe42k0dhgsCbA13t9rlGMtr13XJwqItzgK5EVNiwyF1GPmjx5av+Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NaYwloll;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3822F607182F;
	Mon, 16 Nov 2026 11:10:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NaYwloll
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 16C3E1F000C4;
	Mon, 16 Nov 2026 11:10:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827446;
	bh=zLEVq+Bpv9BnXZuXWTCC/0nvI0V4xS0vAuEcIsGc5V4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NaYwlolld2jESWvGwOaWTxEbVaAHPZNh1LLvFE6S5MpCcqk+cf+N1nQf8Dku2zsdc
	 XyHOtJ8BMGc1mA3Vrxn4Eg8Q093MTrz9Iup09iiuZHg7wX4L2QsIw7SS3rcteqNV4x
	 b2D0jxB3MFKFxVIJVhXxLhRSg7PnHC/W5FlkEc/+kxEk8S4+luBw2VcOlfQxewVtA2
	 Je4f2PghzObAunRtq7HCf0FD4sQiGwd31Mb5U6ODKV2wDoPSHpEqY7liE2IB/srDhO
	 TJV0xsiM7pK3poFBzZlAc0Ax4uP8AaKDIftyXzMvuQ3xcrXUli/E6mrcx/WrTrnOUK
	 ao8EBSnzLQ2lQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:11 +0100
Subject: [PATCH RFC v3 38/44] nvmet: refuse files on pseudo filesystems as
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
Message-Id: <20261116-work-loop-pseudo-v3-38-8cbbea1cf34f@kernel.org>
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
 Chris Down <chris@chrisdown.name>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1522; i=brauner@kernel.org;
 h=from:subject:message-id; bh=tRTfMWpi6lEvvGl+lxY+pO25cW/8KtdlIZFwjvLJslM=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etxtsODnTr4jerrvH7gkzS+68Piv7P69JfsYWHfKz
 ZL03KHzv6OUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAiu6oZ/nC0OV4+zWbuG5Od
 WKaZOmHv+rI3Rj5uPGlXu0xNsxL5oxgZJuv++PSw7/mNRcX/gqK/z/nk5+TzYvUj1cNC/H+yOEQ
 Y+AA=
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

Reviewed-by: Chris Down <chris@chrisdown.name>
Tested-by: Chris Down <chris@chrisdown.name>
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

