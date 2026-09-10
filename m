Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 998A62EB84E;
	Thu, 10 Sep 2026 00:29:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789000194; cv=none; b=gtQ6XXFTtaBFQmK4fp64cA4lAHiVOOfRMfhxMkAJWxKvjXZHYO6BtLjVxKhJS3EUhbBcN2XYWMeibn8ke9JT7nGY7AykdWwIO+9J1Y5mZBwucPalBB4UXDPdHx5OyzoFJRxIx5sTndtVmq3fS8feyO2i0Tww57iayD+S1luxoFw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789000194; c=relaxed/simple;
	bh=i5ePilHMvU8/Bjw9mHPDH+DFa5gBoN8fkuEGzCFqU4U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gIhvBXRMpdf9ymjSve3U67Hgh0hUeuwESGePueZS4Gn4v0QWpw0aK17qfdGK0WNvCdpUUb08BCUlObUX5x1Axr5CYAGNGI34bD9mndsmB0SZfx4AkBIow7ctzXB85sQxwRUsS+SWa4zWzy2g/uK86c5ZLvI3kYjdOKqsHHfR+do=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=GFRWOH0X; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=FYXJ+R5m; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="GFRWOH0X";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FYXJ+R5m"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id CF94C7A00BD;
	Wed,  9 Sep 2026 20:29:51 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Wed, 09 Sep 2026 20:29:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789000191;
	 x=1789086591; bh=3wjFuA26s+kNszuiuYCwMZM7DoBId5JAVvEtH5hTa3Y=; b=
	GFRWOH0XEe5Xu4RUk41Y8tkwuD+PxwZZN/41xF3nIcrNsQ0c4iIwYRLC3AhfXa63
	Ed5K3bpB9BEHxA+/kjyhH+eKZ8nUBwsF87QV4fV5VnuB/VG14/djySJgVF3576xF
	TDLLBxF7dBY/uCLghEDuT/Dtn/hWwk7HOGqpyTukNaIRzyPFFJTVbyEVmEDRFM45
	9p8PZHC4Iq7BT6/M1oMJ/7gappzeXoX7UdDk09RyAGc+IMBlVlcoQoquS78zH5gA
	AVBpy19NeojWtzZnTVySmYLNJfQQJg+ywRgI/k1OZACGPDK+z1JG3AbqIBC36AMG
	UthGlttdTYxNLFZKx90ksw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789000191; x=1789086591; bh=3
	wjFuA26s+kNszuiuYCwMZM7DoBId5JAVvEtH5hTa3Y=; b=FYXJ+R5mkc9KLo9wo
	HHoh85kQQaXyzfwLRhUtKGwwxzi1V1oz0SIuMw5rq7uFFvPmOhn3L8UznisD0V7Y
	X6pxfgCjNtCWJtCE8SxJUUmYIHEZkj9qRqovcnEEoGXA2xsLXsCs2XghhRze0IGX
	rGLsVBS5B7KFNPRXDI6oDuPyZmHqbqVpOQABa+0sp341fjn/Bl6E/M/oeQTDgdL2
	b2Z7/klT0QiGc3tVoOdoT+NqOYxxJ0iXHYSc9DKwXPwHc/oyV2BHTiMf3AgbYV40
	BwNXg+m2Q1nsd8iwsenO80uq95NMUyTroRzf4rYo/F05eX085zxEoLHbwqsYc7Je
	LkhwA==
X-ME-Sender: <xms:__mhamikz9K232Vx3kn_thIc1BfMxTQ1OKpvfRTYFqoT9gKRvIN8-Q>
    <xme:__mhapR0zA6xSS3JyP3G07pD30SuWzw-YKIa2ePHRotjPVZpSDhItxYm0IFTXs9QD
    AVwLCOuIP2oxh2nJn0X1a_vyaxZJnnfKEueG9NKSFIXpCp2o7g>
X-ME-Received: <xmr:__mhagV3frkQIepeqJ_Hc_cjGV45xlSqEmj7qdggU_bs6LLGa_LoOLN0F8Neso49Dfk028UYfY-ywvomPq6YA0hL1YUWbb8>
X-ME-Proxy-Cause: dmFkZTG2ZuPEN34R+utP3ESxb9Vdcejdvq1qn0GN2MsSCwESAHSyvwppLG2Yu+T030L2Os
    C8wXU3PxCkVzFW4dp/42EieFv6R0T70CdXif1RWlK2b+xBeP4D18DTQhJEghKWlRjrKyUb
    GdlNnxTgZ+lDp+o1Kz2BsylhbrNhfAZgPcMxHnaH8xn6D8vPLCsNPSG5ApS8ATGgHc/HWj
    wRdbCBCalK8qL4He0aXC4Lyqu1cVz74DhCxPFDqYj/33GFHQ6XxHNgTamDOpUZSq1ebJcO
    0bZ7djSj1c7whFp8Heq+QUaxe+WPB/b+6uiBLPfuZqukj1/5KZnVgOb+3nKerXH+iKGBPu
    nK+9+dylFkT80BFnrGENTxjKt+ViVw0Zt3L7wwLKTP4hQ4kTk2oBLwCk1Ffl90Hn/9Jfct
    /xdl3R0qaCsv8vMHWGVgdACS93hDoSaCTKLnH6UPtS7mObXg1Gu0/LCW7uxwy3w+WSSxc/
    goL8I6BmoE7pIy3LP2irJn5yHfL76kq9cUti1OZA5QjIypPhcJNb3Lm/A+AiNaDZ+gDbE0
    lN82VXkZqy9HXqLXeqgKLJdmOxURWsQw0VLfXTPfOCjy2H3ZTjxFDJrGf2+9Ta38RjyjuP
    iljV29GlkgEKw/KO+jXRjqtPn9T8/6EJgGZHwVpiDBdBX+GjXH+W6GESlpWg
X-ME-Proxy: <xmx:__mhalSZEjd690kE7bn1uec52lrQvA1s7YGInmaPAeQgZhj9ukHpyg>
    <xmx:__mhaimV0aEom3nFJYXKqMleJ3owEOBM-tBfUeDy29xr-OOi-3AA8w>
    <xmx:__mhaj64WJRVHJQxI0hwW-f9GCcXCaZlCSn0D6W0Qj4y5QgOvGYcTA>
    <xmx:__mhagiCUPCFB0q_mv2qDdyPAOr7lrdh8VXFXrtLrZgvTZ5PD0s6yg>
    <xmx:__mhaju1JCG1BVzWJg2ns-lGHctdY33tc1YuZRAzlZJ23pTNEwQ3P15i>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 9 Sep 2026 20:29:49 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 1/7] vfs: add some allowed open flags to vfs_lookup_open()
Date: Thu, 10 Sep 2026 10:20:47 +1000
Message-ID: <20260910002934.192979-2-neilb@ownmail.net>
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

vfs_lookup_open() must allow:
  O_LARGEFILE so that large files can be opened.
  O_NONBLOCK so that break_lease() can be asked to return -EWOULDBLOCK.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index d95249dd527c..c9ac703110f8 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4632,7 +4632,8 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
 	int error = 0;
 
 	WARN_ONCE(mode & ~S_IALLUGO, "mode must only have permission bits");
-	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR),
+	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR|
+				O_NONBLOCK|O_LARGEFILE),
 		  "open_flag has unsupported flags");
 
 	mode |= S_IFREG;

base-commit: 9189e6a6f89e32d3a604b221ea64e67e1a35957c
-- 
2.50.0.107.gf914562f5916.dirty

