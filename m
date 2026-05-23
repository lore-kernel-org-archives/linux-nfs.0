Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4657D2EA754;
	Sat, 23 May 2026 17:55:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779558911; cv=none; b=cI8TpjcSAAJxpv0l3Gm8ddlrb4wccLVlKV5j5Md64qGbjIVd2ppjkVqnMLz6JxhhkfOCZWfv64jZGUPw2ct95IHtOZ2Zr+ouks/drRC1uzge0kZsSfg70NpchTY+H0GEmPrAn0BKPxl3b04dRNqKCGqw+aYjTMw3JInYIhhCDec=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779558911; c=relaxed/simple;
	bh=V8MCTKePA3znEFy3ImfiLkTvdxvI3yL3376d2q7SQ5A=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=R+zVWjBdifySdZ3FlCT4jRFGpbfCt209OefY97qwuLgCHAZesQVv49EXa/mdwRf9axhp5t3hHel24iVYbFCtUvC7z529vxqyIQlDUpy3veAAJF98jM8Spk7euAcJscuk47/hGfXA4ULh0tQ+KxHWwQZggEyha7+X9fy5TnnwrRs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IK+wo7hI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IK+wo7hI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D62951F000E9;
	Sat, 23 May 2026 17:55:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779558909;
	bh=v/3ZZK1cCDduXYXcxKeKlOpSrmrsqWH7N/ziUw2jSZ0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=IK+wo7hIR3ThlZ8Syhumfwrnj90K3fG4pOcL68OF1GGVeRIyIE55lypaqrwhkPQBp
	 TR7+D2SKUENtlQm1ZJfKj1rpPgJEwB2o46mX/TcXx2bMBEmBF/XeID3EiM7gWCjKBR
	 6VXPIg75qWarkDd1bOPZvZO1/WArLxZZ1fXNQ+SNBWzFHWwoLDA2ghQliJUZaLG5yV
	 RZU5VhCre+vUVnCKvEtvHsisSf4UJSscfwKHONUrvvD0yN4AbdKIMb0VKvCjZXjjzq
	 xejc85BC4vEANUbQl625iHtC76mIYLb8lEerln76aSUcPnNP6oY8bi+TWI/w6zyA36
	 vAq3u0qURaKMw==
From: "Mike Rapoport (Microsoft)" <rppt@kernel.org>
Date: Sat, 23 May 2026 20:54:16 +0300
Subject: [PATCH 04/17] nilfs2: replace get_zeroed_page() with kzalloc()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260523-b4-fs-v1-4-275e36a83f0e@kernel.org>
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

nilfs_ioctl_wrap_copy() allocates a temporary buffer with
get_zeroed_page().

kzalloc() is a better API for such use and it also provides better
scalability and more debugging possibilities.

Replace use of get_zeroed_page() with kzalloc().

Signed-off-by: Mike Rapoport (Microsoft) <rppt@kernel.org>
---
 fs/nilfs2/ioctl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nilfs2/ioctl.c b/fs/nilfs2/ioctl.c
index e0a606643e87..b73f2c5d10f0 100644
--- a/fs/nilfs2/ioctl.c
+++ b/fs/nilfs2/ioctl.c
@@ -69,7 +69,7 @@ static int nilfs_ioctl_wrap_copy(struct the_nilfs *nilfs,
 	if (argv->v_index > ~(__u64)0 - argv->v_nmembs)
 		return -EINVAL;
 
-	buf = (void *)get_zeroed_page(GFP_NOFS);
+	buf = kzalloc(PAGE_SIZE, GFP_NOFS);
 	if (unlikely(!buf))
 		return -ENOMEM;
 	maxmembs = PAGE_SIZE / argv->v_size;
@@ -107,7 +107,7 @@ static int nilfs_ioctl_wrap_copy(struct the_nilfs *nilfs,
 	}
 	argv->v_nmembs = total;
 
-	free_pages((unsigned long)buf, 0);
+	kfree(buf);
 	return ret;
 }
 

-- 
2.53.0

