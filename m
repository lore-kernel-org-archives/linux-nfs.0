Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A07E2BB1D;
	Sat, 23 May 2026 17:56:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779559008; cv=none; b=HJ5KFQoUPkuZ/aNnpraIIc7zZZ+PxJOQl+QeApBuXkeofvj5wMZVgDX1atTMVGwQ2LxAu/xJhqILOkP62opqMB1Gc8DbTznXi1bJeW+xkYo4kO7azEATHcDKQ0CdfPCWblC1YYuqeTKSPiZFZ6Jxro5/GFR2K8fJvVls2jlFTwc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779559008; c=relaxed/simple;
	bh=ctfgg59w3W9Ve9cILqgBzW84u/gnz1aQjpp1bYMsf+M=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=KzhLlHQHV7uLf91Le/IRxCRl8XieuUGsFGjPlLgGKko6r78Z+ihN+ICFnBI5WTQHJOBlIYcjAHaLz01mez0xwTBu3ROFEwOGTViqPK/QWN+XdZPESZrfG+E4qqCwe78i00+ZKTwY/9SCjrTyCS2eox+WsR+zWdl948+gXzVfR/c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=m7xL6A+P; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="m7xL6A+P"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 251481F00A3A;
	Sat, 23 May 2026 17:56:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779559007;
	bh=4ZPGEhDpFGQ4u9PuMAl3Sd2ga9kaV9qTLPAdSB24HI8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=m7xL6A+PruyXrPWvmsAoypMnFQsfwqCPeKuQPez0FgnKXSO06Un5FB8QHqDpQb4H3
	 8QknBb1CUFzuPKF4giiNNpeUdLdIIIsPnz1Ln2weva2frsm2ejuVEJ0bFmsRwjAxNu
	 i/DzE4LeSWzHIfmW+ns99umidgSpMcOIIIYllFd6PYxpQLLXwQ4XMKHOu1/fIaLcCt
	 zhdM2i/e3b8Ke1xmeXKtbBVQbZpbUhT64iUOlh5+FfVjeiu90PmDJCNxVosZZxEitS
	 O561RMw4EqfbRr+CldkljoL1KHUYKOwku2ScXQEPToGxFFI4OwACtEaaJ5nvb9VOZi
	 6JI2zyrKgrbMg==
From: "Mike Rapoport (Microsoft)" <rppt@kernel.org>
Date: Sat, 23 May 2026 20:54:29 +0300
Subject: [PATCH 17/17] bfs: replace get_zeroed_page() with kzalloc()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260523-b4-fs-v1-17-275e36a83f0e@kernel.org>
References: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
In-Reply-To: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
To: Jan Kara <jack@suse.com>, Mark Fasheh <mark@fasheh.com>, 
 Joel Becker <jlbec@evilplan.org>, Joseph Qi <joseph.qi@linux.alibaba.com>, 
 Ryusuke Konishi <konishi.ryusuke@gmail.com>, 
 Viacheslav Dubeyko <slava@dubeyko.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
 Dave Kleikamp <shaggy@kernel.org>, Theodore Ts'o <tytso@mit.edu>, 
 Miklos Szeredi <miklos@szeredi.hu>, 
 Andreas Hindborg <a.hindborg@kernel.org>, Breno Leitao <leitao@debian.org>, 
 Kees Cook <kees@kernel.org>, 
 "Tigran A. Aivazian" <aivazian.tigran@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 ocfs2-devel@lists.linux.dev, linux-nilfs@vger.kernel.org, 
 linux-nfs@vger.kernel.org, jfs-discussion@lists.sourceforge.net, 
 linux-ext4@vger.kernel.org, linux-mm@kvack.org, 
 "Mike Rapoport (Microsoft)" <rppt@kernel.org>
X-Mailer: b4 0.15.2

bfs_dump_imap() allocates temporary buffer with get_zeroed_page().

kmalloc() is a better API for such use and it also provides better
scalability and more debugging possibilities.

Replace use of get_zeroed_page() with kzalloc().

Signed-off-by: Mike Rapoport (Microsoft) <rppt@kernel.org>
---
 fs/bfs/inode.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/bfs/inode.c b/fs/bfs/inode.c
index 19e49c8cf750..0d7b95371271 100644
--- a/fs/bfs/inode.c
+++ b/fs/bfs/inode.c
@@ -311,7 +311,7 @@ void bfs_dump_imap(const char *prefix, struct super_block *s)
 {
 #ifdef DEBUG
 	int i;
-	char *tmpbuf = (char *)get_zeroed_page(GFP_KERNEL);
+	char *tmpbuf = kzalloc(PAGE_SIZE, GFP_KERNEL);
 
 	if (!tmpbuf)
 		return;
@@ -323,7 +323,7 @@ void bfs_dump_imap(const char *prefix, struct super_block *s)
 			strcat(tmpbuf, "0");
 	}
 	printf("%s: lasti=%08lx <%s>\n", prefix, BFS_SB(s)->si_lasti, tmpbuf);
-	free_page((unsigned long)tmpbuf);
+	kfree(tmpbuf);
 #endif
 }
 

-- 
2.53.0

