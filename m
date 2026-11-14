Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661801;
	b=N840/Qpb51bUToLERYBQ4Mi7MwXJYPSewmziMJqA3ZewIUSDMpNE0UncJW/vLYuh7Zi3
	 r+Q7q9boaTTcYcD4ebFQkXdlPDR13KYmeQ01seiuydBo/I+ZJrNPUlZzqxB36AfdQTzQi
	 wEKFz4JaYBlKc/+HcYfGJ+RvW5/O3nln/YE8jqKlncMDISYkgRRiHQtsrHxV726tbNoBn
	 AFT3PajvsOrz4cIXo3IOT/axMkbFcE2s050Z8VE6wi2PVhfMHU2bTKY4SGW/zgHGfHz7D
	 f+fgF3La/8avGnNdJhDYah3pP4dtP6DRzNf7AZmCKosdhMk2jkGuP24wEqoaIcY8KLA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661801;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=BtdVhasomzr0bfxo27t8Irh0dfW28m0T6GW65uzhTXc=;
	b=sBASe3PlbUyN5BcizZM3qyvSaoSS8g2m1He9vq2wNUdoT+36juPDO6pJXqTm9SXZlEYz
	 7o/e9wTVwB2ek0ZPoaUsO6REEstXrDAjZO/r+IMgJJPuno0flD6SZr+1n6ZK2KOzzWO9A
	 SjBe6+z5HjxYMQYmxbgZNOPl9S3tC6mTsTPxssJTd/Z5LxhkL5E7PeOZWTr2V2eAmhT6J
	 1DngtEAxqSqQZdoFlJf9ebLFm8S1LcPrE3pIvHx9Th0fLjTLimxHYxn40R7D+9n2cn3gG
	 IYLglBFNa1tiA2zyTEopjy5wrRKQXxPs8BKvQoJSMJBw/6NjZC8fsRlJTqkcDzQXlHw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RHocOdW6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 48522606EDCE;
	Sat, 14 Nov 2026 13:10:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RHocOdW6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 20AF01F000C5;
	Sat, 14 Nov 2026 13:09:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661801;
	bh=BtdVhasomzr0bfxo27t8Irh0dfW28m0T6GW65uzhTXc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RHocOdW6W3FpasM0EYmnFsXgxF36o/JK6WS2DdytW5tVYqJjWMISgUoBOsWmYXoz8
	 8cuAgHtoR3/4JGCuVTBVa6TNJzyWo7Rn8kALoXvU81rS7TBOcX/WeoOhTQDeQjMX1N
	 KTmcoH8tEAJXXnQi+46MgcKsaJ74xkFRIMalxhSu0fRwUdgfRAmprIgYcxclGQpVpv
	 m/OYB5cOGueEYAb6sJxKMVFXTu9cdUT7Nz1FJ5RJGAOqZBnLtSGyEic+ZCGuIFWNTT
	 NyjKBdSXxoQ0RtqgYl2GTfzZ0SkSuzexfL2JtdazdHQZOrpYXI9dQcaGC8BVxNjlwb
	 I3tgtCasNQh1g==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:19 +0100
Subject: [PATCH RFC v2 38/42] fuse: refuse files on pseudo filesystems as
 passthrough backing files
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
Message-Id: <20261114-work-loop-pseudo-v2-38-98639a2286fb@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1390; i=brauner@kernel.org;
 h=from:subject:message-id; bh=2GPVGdPmuRydfdxygQI1vepom0ppxgkvC8v8Lqvdx8k=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iJnomXd12pWfUVWTpW7s1uFaJbz65rLkQEZN5j6RF
 KY/m6Jud5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyEW4Phr1xIEuNTx1T/Ht6n
 hlVu3fM+HJX4fO0n7+/d4fcSF9yrfcrIcJjh3o3qm9JZX1wXNHfOCRb+0heYGJQ1wecpZ/6UMiF
 XTgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The fuse server can register any regular file as a backing file. procfs
and binfmt_misc files are already refused by the stacking depth check as
both set s_stack_depth to FILESYSTEM_MAX_STACK_DEPTH. sysfs and the
other pseudo filesystems aren't. Reads and writes of the fuse file would
then be done on the pseudo file with the fuse server's credentials.
Refuse files on pseudo filesystems just like loop does.

Note that the backing file is only registered here and opened again for
every fuse file that uses it. Only its path is used and O_PATH file
descriptors are allowed since commit efad7153bf93 ("fuse: allow O_PATH
fd for FUSE_DEV_IOC_BACKING_OPEN"). So pass FMODE_PATH to
file_check_backing() to keep them working.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/fuse/backing.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/fuse/backing.c b/fs/fuse/backing.c
index 8c21a8a74efb9..7527f3ecb90dc 100644
--- a/fs/fuse/backing.c
+++ b/fs/fuse/backing.c
@@ -147,6 +147,10 @@ static int fuse_backing_open_file(struct fuse_conn *fc, struct fuse_backing *fb,
 		if (inode->i_sb->s_stack_depth >= fc->max_stack_depth)
 			return -ELOOP;
 
+		err = file_check_backing(file, FMODE_PATH, 0);
+		if (err)
+			return err;
+
 		fb->type = FUSE_BACKING_PATH;
 		fb->path = file->f_path;
 		path_get(&fb->path);

-- 
2.53.0

