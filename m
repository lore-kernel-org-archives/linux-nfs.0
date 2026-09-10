Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D92882AD00;
	Thu, 10 Sep 2026 00:29:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789000199; cv=none; b=pAUG66myCEhrmSc2NiBQpfHZqjAWbCQwCLpVxU9//cViuzitJtJFBYTwIMTXgRiyNmQcFg9D1XU4ONe6ntpyahhGIF0GWsdf77qkElHoaynXxbmXIX9CAO302rmiAMjy2Z4lfasEiEHYi5j2jrAOUhSfISUCAAPM3YgYVT3bhww=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789000199; c=relaxed/simple;
	bh=wuxeMKnYN3RnSZ46XBbO0/SV7rqJKWQ5KA5JbCF8KjM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DeVkA6Ee6R7Dp6TwspWYQ2K742/dSP1L3ugqtkioXalHifiR9nAo79jZnL2ke+Kpuf1vTEF03GK2GdB0rVZggN6Io+BXvySjIjNeAYBw/kTzUxrfaV/2q/AuGecBz0oXEwxnzRxG4Iv6CyAiCE9jsgSwmm9HepyP6ruf9C8y7gY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=YSeaN4tm; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=gp5pmDii; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="YSeaN4tm";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="gp5pmDii"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 0B1E67A00DF;
	Wed,  9 Sep 2026 20:29:57 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Wed, 09 Sep 2026 20:29:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789000196;
	 x=1789086596; bh=skfRaEYRr9ReYf+krhPtkr1pz+ybtTzKpNmMOROloTo=; b=
	YSeaN4tm83cO1jt+o6ong9om0WGdgYZH60UAcWij785xgA/Y3JM9+Wn/h0jw6id3
	q+ZqFaaL7TyzKI/ozZLGIGQOuYkaO9YHI8u6/OxhojcwMwpwD9cEaw3PmnqkQ6bZ
	7fOKOqMGWt1aDJwztfsytuMKyV/l3dlpu5eOJ9WeHEgICFUtpVM6ewbXTZB660VO
	Nz2AIvGlI4vOBcxJF/4wS1agH0ffkaAZKzrr5MUI0gef4s6tKXltkQXvnyWx34aP
	M1Zxw2ASvUgQxrZOb38OerOMdpLd88yX/jGUnG3hJHeu5mMLHLVTNyMZBDem8KqW
	6xvsSsM9KfJodw3n76TmsQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789000196; x=1789086596; bh=s
	kfRaEYRr9ReYf+krhPtkr1pz+ybtTzKpNmMOROloTo=; b=gp5pmDiiNA1MH6eT4
	ZMokrIl5NKforG5eMtRTfZlLJxUBum8o5roGQWGB6JsAdLkl1R/2Ha+A970Hu+JU
	G/x0mqW7GeT0V2oqRZrOv6YtoOAh8M4EtvJKy8KVk+R+xxeOvSJv3mvfw7jBkBez
	CHAn6qJ0d4VGYQLv014vNL/f57IxwpjAiiVtcXeGasM+rsh7dqI7EXKY3nAhDALf
	+t4RlUixIRg0keQftazhqkx6lUQQshb68hII6AbCRm9btfs7ZvqB0S/30Ut5D1iR
	oriL3zGwEcUQ/hxMBylvF+YZUmujH5TDJhaxvVmGEozU5EEvXVA+/yT1Ax5xwjuJ
	x5XPQ==
X-ME-Sender: <xms:BPqhat1bgSZbv9QBSZQgocm2CJ5RgWwtIZG3bRjFfpM_wuWDAfLa1g>
    <xme:BPqhamWvJvLmk5TsIRxq-z0aqAvHxvu2wgVHoooL_n7m6DiZxJ8Md6qeKZmQwMypv
    JjgJbA_AUOi5cP9ph5soqcK98wFzqY-svhOUGyix6staeN38Ns>
X-ME-Received: <xmr:BPqhagJIbQ6Tigm_TCVLjfuFdu_TeEZpVJq3rVo6yM_vgPjgLtc3e9kUtMF7TUZaHjoDU7FkFDOMQ3Wv2zy7XuXYRthQfSg>
X-ME-Proxy-Cause: dmFkZTG2ZuPEN34R+utP3ESxb9Vdcejdvq1qn0GN2MsSCwESAHSyvwppLG2Yu+T030L2Os
    C8wXU3PxCkVzFW4dp/42EieFv6R0T70CdXif1RWlK2b+xBeP4D18DTQhJEghKWlRjrKyUb
    GdlNnxTgZ+lDp+o1Kz2BsylhbrNhfAZgPcMxHnaH8xn6D8vPLCsNPSG5ApS8ATGgHc/HWj
    wRdbCBCalK8qL4He0aXC4Lyqu1cVz74DhCxPFDqYj/33GFHQ6XxHNgTamDOpUZSq1ebJcO
    0bZ7djSj1c7whFp8Heq+QUaxe+WPB/b+6uiBLPfuZqukj1/5KZnVgOb+3nKerXH+iKGBGP
    MmJKyZrcGVxIuXgZHdDYmCoT+vbe2+2ainxP5FBnOScKYFXWJsG3K2zF3X76EpwWEE5lg3
    CdczqAPrBD3Gugp/kUgVkKp2J7ggI8UTaG4cF2FGypnsNYh1TGmN3Yw3YLjZZ8biXC41G3
    2datsmQKAyITqExIF+0FqtvsVoqO/W7nRuz+1fLDqSRShRI8f+aoOAxeM9NP3O8H8qbVds
    mbbZwWVCNgtvL9fEhlrZ8yFGSjQDltCKm+UC0UQHh0AMqGbrwjdklZuWV9ehKkao1BGJoq
    HX4BAv8DLQU25brrOd3/gLO/kEedD8IPoiAjzLNh94tq6FEokvR25/KkGCnQ
X-ME-Proxy: <xmx:BPqhag3jwP_PzuAtl4Qy9xrpldRuanK5mdDBJUqz-17nWJLr5f17Gw>
    <xmx:BPqhau4uzw54PGEuAngZnemIhJl9BVg6jnXzAaT_90c2cSNcP2FYUg>
    <xmx:BPqhah8vFmzjUvg5NisLlMPNM1eRG9TkVmPlq24f8vZaIDmXJE3ziw>
    <xmx:BPqhatVFNrqAQ1rV5RHLQdzVnCFNZL-aHQ_N8NinIfR1qlkcRZ5HpA>
    <xmx:BPqhavih2GcFWKHyMRtX1Ex61AoteW0vFgchM6PLCnnjUiEQOQGiAwbL>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 9 Sep 2026 20:29:54 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 2/7] vfs: O_NONBLOCK|O_CREAT open shouldn't wait for directory delegation
Date: Thu, 10 Sep 2026 10:20:48 +1000
Message-ID: <20260910002934.192979-3-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260910002934.192979-1-neilb@ownmail.net>
References: <20260910002934.192979-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

An open() of a regular file can block if there is an active lease on that
file, but this can be prevented by opening with O_NONBLOCK.
An open(O_CREAT) of a non-existent file can block if there is an active
delegation on the parent directory but this CANNOT be prevented with
O_NONBLOCK.

If nfsd is to use common VFS code for open/create it needs to be able to
prevent this blocking.  It is conceivable that a user-space application
might need this too.

So extend O_NONBLOCK protection to not block on a directory delegation
when creating a file.

Fixes: 134796f43a5e ("vfs: break parent dir delegations in open(..., O_CREAT) codepath")
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index c9ac703110f8..c4be59213352 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4554,7 +4554,12 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
 		goto out_dput;
 	}
 
-	error = try_break_deleg(dir_inode, LEASE_BREAK_DIR_CREATE, &delegated_inode);
+	if (op->open_flag & O_NONBLOCK)
+		error = try_break_deleg(dir_inode, LEASE_BREAK_DIR_CREATE,
+					NULL);
+	else
+		error = try_break_deleg(dir_inode, LEASE_BREAK_DIR_CREATE,
+					&delegated_inode);
 	if (error)
 		goto out_dput;
 
-- 
2.50.0.107.gf914562f5916.dirty

