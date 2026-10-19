Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9409D4A2A56
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 10:11:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792404717; cv=none; b=ptx7emOfZVqhyLrPqwXK+nqYIAQ6dPXKygrqkXzdoAAEBFC6dkiuj8d5+JhoipbAu+MnRXeAA7tZ2o37YhjJtz1TxL1UUKXakKu2MN1G5YkFxHosoFzftfG8oy4zxo2Mmop3MBGdHO2YwaaWMVSXpYYQcz2/qXc32z+oOVn69Gg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792404717; c=relaxed/simple;
	bh=jWTEok0paj4wYBxHWebM3QwVcjvEzsCSuh7Dk8XhRis=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=BIaW5M4hMLnp7Xjn2dl0VZ46TYODu+XMRW5pk/R297NEYzpIYwtLboNxr4iuqBn/r6C3BtwW4tqK2cOndlbMMSfKgqWjzDaZl++4eJsOkofMdaFQ9dq8sHnZmp1OA9mOeS+e5sDMIxwf+Iddc66t7aReB6i9G99ZS6sjrinYWgU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=FCnwo4Sk; arc=none smtp.client-ip=209.85.128.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FCnwo4Sk"
Received: by mail-wm1-f51.google.com with SMTP id 5b1f17b1804b1-4956869750eso14566395e9.2
        for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 03:11:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792404715; x=1793009515; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=2ESX8jvKxc64R1yrNwWQ44kHJ1omr9swT5HG7pWrcCo=;
        b=FCnwo4SknpJWfUngU67M6TinoO07SpBLut5Nfsp197//k1VkRYGwQX5uS2WNojfkCr
         AlRr2b72x2DYaMhAKTPTe3fqZoXbmQXsCzpoLpxTD7pVCqzX2u8mTx5EcOn9RsNuLnUH
         /DppWyE3ttNw0WdSd/mmGr+MCdPvB+uKHP4Pn6lxexWanuoSrDXFy9xg8M7VOAdjBzxz
         0nqku8On10QNhNot9K/Ts3XRXceVhn5d1bIJzSXsyPUGMJSoIKF2nzxwkd9Mu6rH9gah
         71oDamEbL2GQ+Jv5hzUcoppiBYd5DhaxtfYrqXHtRh+ezfsg+HmttXnh9XumOU4hRvM9
         KK7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792404715; x=1793009515;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=2ESX8jvKxc64R1yrNwWQ44kHJ1omr9swT5HG7pWrcCo=;
        b=qk/GzpJksajxTfLfqoDplJX6tD3x4maeUnHHJYes3hJGUDvwb63CgV3RcHc/jciIXj
         +Z3eEzneCV9bES2fbgKf1LqZ/EewvEiBsDmqwehSeT8XMxqUwLhUIvGMsZ8GmB2/7u9B
         2hCGf7u+/Nj3Ql0t9IkYab0x01Phgv4fiNQ+jLe0bV+xSxax4hd5O7ezSSIIdVqKiOHW
         RjU7eXcxk3o1S2HkvxUfs3SeirqRohr6Tqrhy3RrHcpQxupdAVQ30DqtJjMgB/eQ+6jA
         chZWFjRZJCR40ZEX4PcuwI7v3LrNrGhPuYwSOaNbJO+nX4ng3GxYZlhNyfBFPn/l8hAu
         F+Tw==
X-Forwarded-Encrypted: i=1; AKwUvBwL0hUQ3HL5VEZDZ8tuBuGWk9wF9uikEKcIqbsXlHeQqlrrbNHpeOQu+btqPLW5sBE0qKFaGWMH72k=@vger.kernel.org
X-Gm-Message-State: AFq9FYJq90Q+aAewWQoUEHCJN0P7b7ssPxllyGis+SnEVVJNJggZTbXT
	0JmogY6T1riloTZfHvQDVbseQscJ2cKo14LNYG7UQs6uhtsYo06YDOjc
X-Gm-Gg: AYBFou3URE7vPJPXyzjyHSQ9lzLnugN+/m6lm97jpaZHqeNlRP+u9cZsynHzChw44QN
	igJfti8An4HzMC/yDo8j03D+sMF6O4DfbxLdS+aZoEcwLRT/7UxfmbDUsnsZv8oMs9lz4nnQ+5J
	o7OWDT+B1f1gYpFjzBQ0+L/Fb3+QH0jOd/+vokfTVBV6a6leGQbXAYdwYX3wXqJsv7akr4zKUTg
	kFGcu7rDQiOccMggzSm9qLYQfhD5zJ4AFSsSThXR3sajRabH7L9GGkWaCJXIVQY2JXsmTShc7l9
	26ZcNuaizFR/bp8t1sldCOAWpdAeVAsSFG+xtd8FOaGbT8dXivj4X1FVYi/TpxGLEixeofuv80O
	Cbmg2qcDdRnVQI7LcA3FM2cYgtPV9D46oVRB0pY3iUugBG0YEITeqCAuSmGQmK2HNu/5d0TxbZj
	K6F1nHJOz0eIslLhK88DjVQG19YsJYWBdmOYB6+oGgZHBdf89ezJJ2XuwkS3XHD0NXJWjSvioJj
	EK7zqgpCAm+cCVNv+kuing=
X-Received: by 2002:a05:600c:3ba7:b0:4a1:e6cb:25bb with SMTP id 5b1f17b1804b1-4a1e6cb2ad6mr65909455e9.2.1792404714420;
        Mon, 19 Oct 2026 03:11:54 -0700 (PDT)
Received: from LAPTOP-AVI.taile24b5.ts.net ([2a06:c701:4778:c500:b2d3:8bcc:9626:2887])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4a1dea678cdsm182559845e9.1.2026.10.19.03.11.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Oct 2026 03:11:54 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Avi Weiss <thnkslprpt@gmail.com>
Subject: [PATCH] sunrpc: instantiate rpc_pipefs dentry before publishing it
Date: Mon, 19 Oct 2026 13:11:17 +0300
Message-ID: <20261019101117.54038-1-thnkslprpt@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

rpc_mkpipe_dentry() publishes pipe->dentry before
d_make_persistent() attaches its inode. A concurrent
rpc_queue_upcall() or rpc_timeout_upcall_queue() can
conceivably dereference the dentry while d_inode() is NULL.

Attach the inode before publishing the dentry, restoring the
ordering used before the rpc_pipefs conversion refactor.

Fixes: 946e2256775e ("convert rpc_pipefs")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---

Build-tested with x86 defconfig, CONFIG_SUNRPC=y, and W=1
using the net/sunrpc/rpc_pipe.o target.
Runtime concurrency reproducer: not run.

 net/sunrpc/rpc_pipe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 9d349cfbc4831..6d005231bc334 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -665,8 +665,8 @@ int rpc_mkpipe_dentry(struct dentry *parent, const char *name,
 	rpci->private = private;
 	rpci->pipe = pipe;
 	rpc_inode_setowner(inode, private);
-	pipe->dentry = dentry; // borrowed
 	d_make_persistent(dentry, inode);
+	pipe->dentry = dentry; // borrowed
 	fsnotify_create(dir, dentry);
 	simple_done_creating(dentry);
 	return 0;

base-commit: c03c1a14507dfaf8b856c2608f9ac216021fc222
-- 
2.43.0

