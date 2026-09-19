Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE14D321420;
	Sat, 19 Sep 2026 02:25:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784755; cv=none; b=PFdC45x4NwUCh202Yt20tp473DYl8gH2XS6pDT9ues+e2rNp0IA9EkttwV9B75djb9ONCTgdio/p3XvpV7YA4E0wCbYyJ1py9TKpJU164sKEu02XBG31t7ZQxdq9XNj0XFUsQv8q8lJYufflkvxUOjAT01Zg+HDNNlXuSK22MEI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784755; c=relaxed/simple;
	bh=wfqizvxZPei2ij0i9hQsZ2J7OASh3boCUWOmai1iw1A=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=SK3PgSOV2HTbdQLvUFDGG3KiFRepOSpAYKLcZP5+EJOIaE+PmA8fAQ4ggWVIJGP+3gW85MqOapVxpvFYyn+6ssSKv3jplySRD6gVuV+UmJl8PROI4BDXnpvGxaq5IP74/G/ZjUBXBFyftzoNE+iP0LfVaMa9VOufI1YkHgmOOGA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=O5zGmsst; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=lHcIRykr; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="O5zGmsst";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="lHcIRykr"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.stl.internal (Postfix) with ESMTP id A288A1D00115;
	Fri, 18 Sep 2026 22:25:53 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 18 Sep 2026 22:25:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784753;
	 x=1789871153; bh=VTsogUSKiIZZJmcrevQhOPyjLPH57QyGIYswI28KG6I=; b=
	O5zGmsstiOIZXq5y7QIZWGfy/HxZwevTmPp0UvkJZil664D8FRAKFfLsI7XB5i+b
	JJb0PTfkZBHun3zJrGvRxSEeWhIOMVr8aAoOsW/BpzQvuhjbZloA7i0BROiyJlqa
	TNICM6nVnLPhqwrtOziduknw7/hASXkB/Td1KjqhGoNMB/gC48WD9+vOv8Wn17pz
	5UD8k/DGJ8i2uhaQu3op6cSL449vYZsdb1wXc5dfZ8qV4pXeEuCSruhtIjezsNxC
	CVqvixEBWvRj28vYX8w4K+ubDz0Jurrb6HknzQSTh/ng0mXAvsCGQAtaRhxMBWIf
	jnJuc3C2slbxkorkdEUllw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784753; x=1789871153; bh=V
	TsogUSKiIZZJmcrevQhOPyjLPH57QyGIYswI28KG6I=; b=lHcIRykryDQ1wIx9x
	890nYe6p0N3uSZVQrPHx5c6ho+/Lpvco8nli6niEvi0PQZZb/Wp7hgGkh/s1BX0w
	0Q//Npv5aGft6C0vrksgJN35AEaPjbbMU5bhRN11zri5FxeDAPjQC/eKzaHlfi79
	41bJKkPkK3DBo8ET10vP181qaaWZKho3+PDrQWklIkpsqn0NMs3tNmqtxPYAHD1p
	xgnTuGvrceQNvJ2JZ6wV+q3mT3PW4YG580sxO4KyPiSLyY3KyRTvkBEoW6Uu1PS2
	ckB8bgbX7zVW597Wy7lwTErbeK+LfwJjh6kcuiH82Dnd3jC54UuYe/GrZ0IY3h94
	jLA6A==
X-ME-Sender: <xms:sfKtamWVkH5iTczT6qRlmuZqkVeBUPAglT5pEM-n8baod1iQ26Blpw>
    <xme:sfKtai8O8-IARhF4IIKkeELjzeQlEKzSb26O3hR4KhbO5PfKuUZ8WRpj3qapWB4Ts
    2MWXOLgCApMDspwzd2MnDrjln00ihSzqbyFVT8pXpSD5SZh>
X-ME-Received: <xmr:sfKtarhRSVRR6z0WLKsw0xekPffjMyCLgl10gcl1hx_uNZLmN1F6M-nM2Df1q7wTFjUmAcg48b094L-0ExMefseUZA8_hSw>
X-ME-Proxy-Cause: dmFkZTFUxtpJPr0wJylVpOyFo/hYpPxJlWJsU2kneB5LQwmE/1bPBf5WimwYRq9G/RSHop
    cd67mpR6kdodvjvM5+A0Hy6qzZ8Ko8SqdNOTIJzy7c+d6tMnDAxXqsy0YBkNm7W7G0O3Oi
    C+HbHK3Q7oCwFi7BWWlz0w+dKVZBz9eX5z++fZziLDPcgqNFJleSUHp6DWFQvBAPGljgQI
    3x2PbCgQa+kYvSP/txt8odSee9dYanCBOCGxpwCumtR6whu+WbZMEF9SEMWqsmPHFkDl+Z
    v8nyFTezOUsVyBPB3w0vR2F+0D6M/r3/EcJGT/9chMzwprB2NIwzgS0TEpdIz3xaFCSHTL
    uq3tjQf4JvUzUapPSLUt7+l+yKbO7PZyJ7poxWvIrLxCYe8ymjJyfLeCkF35RQeek+d2NP
    os04SPELgmB6SCROvkUnX2RiNCs8ecJpyQ5oBqqGvZZ0zdK/ge93972xmF7uIDL6TR5M5r
    PEYZP1QqLnKU9xu9fUzdPpQ5nwteB3YpeiZk2QLASLOM/RvXPtCqkjYa4SdS1S/BnUu/ss
    YmxcKKNT3IfC3S38gM+QqcHtcf2FHUtv8BfVxqZscX4LWEIEcAMScB2Hr28+wI7WZkV0CR
    Cz+QlwTNL4sc10Vue6XUT+YwQkVgBiwUzGNk8NtuCc4GlL3HvlYoGXrACaYQ
X-ME-Proxy: <xmx:sfKtapXMFEbdobCTsGOqamXWBpmjaDTWN79gSTjxDlYhHoWwOBvesQ>
    <xmx:sfKtavv9M_G4rAiYGspba3ONMzzRIkCaAvxNnwE5jCBaLsEWeMpt5A>
    <xmx:sfKtaq9NcuHZ9XGHqhPT0VUDAIXa74sEDtDL6tLB-HWxAX6uTSeSUg>
    <xmx:sfKtavvq71S0z9bexUQjgGxdhuyYYvjHnaxedm7gRKWgJA1sqcVcWQ>
    <xmx:sfKtalJSrqIk7d9xY7UnJT_VguYWaVrCcxC-JHZnWM0K312Nfz58jRgg>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:25:47 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Jori Koolstra <jkoolstra@xs4all.nl>,
	Mateusz Guzik <mjguzik@gmail.com>,
	Dorjoy Chowdhury <dorjoychy111@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	gfs2@lists.linux.dev,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	ceph-devel@vger.kernel.org,
	Paulo Alcantara <pc@manguebit.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/14] vfs: add some allowed open flags to vfs_lookup_open()
Date: Sat, 19 Sep 2026 12:06:10 +1000
Message-ID: <20260919022441.3305170-7-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260919022441.3305170-1-neilb@ownmail.net>
References: <20260919022441.3305170-1-neilb@ownmail.net>
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

Also O_NOFOLLOW as we don't/can't handle symlinks.  In fact we
should enforce O_NOFOLLOW for the same reason we enforce __O_REGULAR.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 0f69abb3743b..a08f37aca3e1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4632,11 +4632,12 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
 	int error = 0;
 
 	WARN_ONCE(mode & ~S_IALLUGO, "mode must only have permission bits");
-	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR),
+	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR|
+				O_NONBLOCK|O_LARGEFILE|O_NOFOLLOW),
 		  "open_flag has unsupported flags");
 
 	mode |= S_IFREG;
-	open_flag |= __O_REGULAR;
+	open_flag |= __O_REGULAR | O_NOFOLLOW;
 
 	error = lookup_noperm_common(last, parent->dentry);
 	if (error)
-- 
2.50.0.107.gf914562f5916.dirty

