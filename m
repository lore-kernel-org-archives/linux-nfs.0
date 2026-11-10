Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302164;
	b=FdbvbUK+GLBkOQgaztPrjC5AyvlwfeK6g5qCCKvPIAGSYsPNB0+w33Es9298osBCWyu6
	 apsTs2XV8QIKKAzWjCo8aj2AccMkMNO9npi/NZKD54ZBwXIiefcQ/WbvW2BBBsU4qsQHU
	 hkhxRqVMWLi56coGuG0RWDOO5xxQFG3mGIHa/CZt7W4UJD1+wafKWW9b/0wXfSp5j7R5x
	 /yHiXFMLwjk2Ah+X7+UDfYeKj8AgleYPrJxqewAH+ogQf0OIzOgS6oTs7M/d8Ue78cInq
	 8cax40wfLAyqCnPelSDWTk2Qrf2QmuxcmEHnZss3nMMEGc519hqjI5vyfXk94JTs0kg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302164;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=2Uxnm4Cd0mizACq2HNobDQRQcgrPnhEO2KA80+bveeM=;
	b=Czr4VCEzsGA5KjLlvOoN4FHNyHWabD/A2YSGAbacuRue8HfTgSRFTe85z0Be0Z0SOIS8
	 UsU0syR8UWa8p1gMZvhWvnxZf72NO8ypSqHIiexG+0shvzPXYIv7klZSroBs2HKch6JS4
	 pAhByfoKJ4A06cuDEtVUKc2rr/SdYBswEGwT8lgjCE6H2Lo73dDn9qmeNx+Xwsk1uNEwY
	 JH6MABSaLbSrehge133cUAfi3gDbSkTpb9kjqWoZ2LlCwmm0ZW97PlOqRPW66p4gVzIQ0
	 HF+BWeANU/8yBskBeqGyMw28q6EzDAvmhyiKED8ycPOxcxABb6SwFrQnocvKcxmLeBQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ba3Pyp5O;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9EF40606A33B;
	Tue, 10 Nov 2026 09:16:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ba3Pyp5O
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D92891F008A2;
	Tue, 10 Nov 2026 09:15:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302164;
	bh=2Uxnm4Cd0mizACq2HNobDQRQcgrPnhEO2KA80+bveeM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ba3Pyp5OpjsLWNS18IN6KJmuJFLn691WGOW4O+tQFCTWln2eXYVZ3JE1wBRhcmoW6
	 hLpwpT4jz67cKW4CJB9uIhzhbMhfgiFHlr2CZK53VaqCwK5HM1YqSaiFHCScsFMBkn
	 Q0OzOCwsepsGyP/WRgtRo4+3FcZl8eUfyuWZ7KuL8XDVDG6tcU8rd25pxcEBVszf1y
	 XJvR4c13VrmJU77uH8rLkN68FB+fLrhpSvF6buW7PxoKBBbfZNWSogmUA09LLIYVWc
	 o8T8B1sqCgT2o3NyN+rjS4hlvf0pw7ESlo7MI8nYdimYq23hA2cdZ9j7+asrP+da9o
	 Z/f8j2gHp/WZg==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:17 +0100
Subject: [PATCH RFC 01/41] loop: refuse backing files that aren't open for
 reading
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
Message-Id: <20261110-work-loop-pseudo-v1-1-4c998976c6c7@kernel.org>
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
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1688; i=brauner@kernel.org;
 h=from:subject:message-id; bh=k5rFTn5qwSY0P1NIV6SDcJMZmh5p3efbZZ8FHYDs+to=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9ejBVvfNKBs+f5kIhpoaev8LtD4oXZ1xL0i19ll21p
 i5fZsmkjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgInc3s/I0OHqXaH2k1fp545n
 UtNUpkUwfzq4/7uEmpjnzfcNZ9bvT2JkeCygm5CxsPhqWqRgSqf6D/8dk2afLnMX1LJ/rjh/3zZ
 BPgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

loop_configure() takes any file as long as it implements ->read_iter().
Loop itself never checked whether the file was actually opened for
reading. Buffered I/O went through vfs_iter_read() which refuses files
without FMODE_READ. Direct I/O has called ->read_iter() of the backing
file directly ever since loop grew support for it.

Since commit f2fed441c69b ("loop: stop using vfs_iter_{read,write} for
buffered I/O") buffered I/O calls ->read_iter() directly as well. That
commit was about O_DIRECT handling and the FMODE_READ check went away
as a side effect.

So whoever can set up a loop device can read a file it was only allowed
to open for writing. Open the file O_WRONLY, configure a loop device
with it and read the contents through the loop device.

Refuse backing files that aren't open for reading. Loop always reads
from its backing file so a write-only backing file never made sense in
the first place.

Fixes: bc07c10a3603 ("block: loop: support DIO & AIO")
Fixes: f2fed441c69b ("loop: stop using vfs_iter_{read,write} for buffered I/O")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/loop.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index a3325ceab484..c96e35c3ef42 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -528,6 +528,9 @@ static void loop_assign_backing_file(struct loop_device *lo, struct file *file)
 
 static int loop_check_backing_file(struct file *file)
 {
+	if (!(file->f_mode & FMODE_READ))
+		return -EBADF;
+
 	if (!file->f_op->read_iter)
 		return -EINVAL;
 

-- 
2.53.0

