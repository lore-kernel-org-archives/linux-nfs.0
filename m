Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302418;
	b=hP/KG4ErhxhlNBWtQep65SBJoSFkQuM0+dLZE8IGjxn2B3zUJODJlAsNbz3La7kSDmHd
	 zoGfaE7kpHq587ogjgSCMRiWZBEjukQULsXpLjCRvuADe1rYycAUSBsPhu56G87qKP6BN
	 GJuIRyW03dQh5dTAze294JmNOr1a0bD/Q9rnMbxE34j0bK/8pitx/B/g9ZsSTRLXZHL/m
	 5MlQhJX0h+YRauZnpk7ngURm5zHHgHT0MGXbVY+DvfYbfYrdfqT6CHRq1AaH280ITDty9
	 qxrjPABNuhSHR5+/s6rBnkweklAiyfAP3u3Yj9TDTF/GIwVyk5byl/r+8gKCq1GAdbQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302418;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Ed8TTuJF+sB6Lawh6bnyp4GQ+ni/YzFsRx+ZLMEdz+g=;
	b=t9FS38LyPAB/RwGuOwScL9g9V+ScGSWHQTdS8BNifit6Tu2cRwmFMkadLlk95IUmUTCq
	 T8Y7ZoRJsFa0B+j461780x1b+/RzTEOi5AfoNT7Ds3N7/htqUerfHQ++LxnINVbzEEGK+
	 lSoNfXwvE9l/1gZlCnsp4oddEBrHJYo6by4M7TZwWKnakB5kbiq0jMnXu2Md4asuP4rgv
	 0sryYT3TVwFy8TdBPhlIYpudRfaL3yt7GI363kKlODEJ7J6wKNKxMVFHuRWeJo3qT7wYz
	 FmmvpkfcmDHfOx8/9IDsj7jgCIS1MkUYwRsj0tniTh3tMk6hCa3mj08cfUUWBnFP2AA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="fljzn/eV";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03DE4606DA02;
	Tue, 10 Nov 2026 09:20:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fljzn/eV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 712051F008A2;
	Tue, 10 Nov 2026 09:20:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302417;
	bh=Ed8TTuJF+sB6Lawh6bnyp4GQ+ni/YzFsRx+ZLMEdz+g=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=fljzn/eVvhxziu7rpDchbBxswirw38dG5Hh8oraieWnFAikJKROz9NNo3QUniq7JH
	 k0pna/SGi6vkmSevbTXH/7hF6ngRgBZPZ2ZczHXlmyUuIpK7skK0i+Do5u+0rc1eoM
	 1QCt2YoDQYnkiJfUqROif2D9EGzsXbQfijTNIK8+ganjoCxI02/hoEZKq3MGmCMO0h
	 I4/M12qrVolo7dcfHz+wl17JewslqYT+EnXNgtBY6b3e8843u68sorNH4ya/h/+lAY
	 VJNr41AO+Mw+z1GcGf7nSnH75QEpkg5/KlZsgid6ulxGcD7CIdFmk46YH/y/seTdPS
	 T75fjFnSWG6Bg==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:54 +0100
Subject: [PATCH RFC 38/41] fuse: refuse files on pseudo filesystems as
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
Message-Id: <20261110-work-loop-pseudo-v1-38-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1037; i=brauner@kernel.org;
 h=from:subject:message-id; bh=rMGXR6zdtbG+6yYmwIdklnSltQxsfLzPwY1iGb1IBiw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9enDgUfStKvuJ/w6Jptq+5PlSbP9KPn63MV/6gs8ZA
 ckpeuf/d5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAExEcisjw4GLdt6JSusi2NxU
 1iey9qUufZbz//uNFbOOedou29eyzJjhf+TaNUei0tLOZd18O98+VMavi+/sDjvd9a28azc/0L9
 1nxkA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The fuse server can register any regular file as a backing file. procfs
and binfmt_misc files are already refused by the stacking depth check as
both set s_stack_depth to FILESYSTEM_MAX_STACK_DEPTH. sysfs and the
other pseudo filesystems aren't. Reads and writes of the fuse file would
then be done on the pseudo file with the fuse server's credentials.
Refuse files on pseudo filesystems just like loop does.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/fuse/backing.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/fuse/backing.c b/fs/fuse/backing.c
index 8c21a8a74efb..4e4fb810ddaa 100644
--- a/fs/fuse/backing.c
+++ b/fs/fuse/backing.c
@@ -147,6 +147,9 @@ static int fuse_backing_open_file(struct fuse_conn *fc, struct fuse_backing *fb,
 		if (inode->i_sb->s_stack_depth >= fc->max_stack_depth)
 			return -ELOOP;
 
+		if (file_is_pseudo(file))
+			return -EINVAL;
+
 		fb->type = FUSE_BACKING_PATH;
 		fb->path = file->f_path;
 		path_get(&fb->path);

-- 
2.53.0

