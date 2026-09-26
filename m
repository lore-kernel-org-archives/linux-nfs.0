Received: from fout-b4-smtp.messagingengine.com (fout-b4-smtp.messagingengine.com [202.12.124.147])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA776547073;
	Sat, 26 Sep 2026 00:11:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.147
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790381487; cv=none; b=Ed9pR0Cj1LiiMw0d5guCs6iqLgPH20hGwscl8FKw3tqW9za/A7aY20R+Fz2JuJKOBAuC5kZS6SUxq0K0PpK8OkrfHkU8iH0p6QbGGO5r5VvWoeEehjNmWrPxF0XrGjuCx/Ved/+jhXqoU4fHoGYI04gi1Nz5VmIpHjM45Vj7vk8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790381487; c=relaxed/simple;
	bh=EfWh64QysUFbjIemnblmlybvAe4atwfmr88hBI9U9EI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=K+TA3nSHnOn1aCIU3JhjiM7R00hpRXd2WTSpMRK+2A44+8t16bWaEZNjjTZ75hSoPwmpXuJ4Zyik7Twux860k1w3ED4bLE2xO7gCY3e3U3rRi0UEBtm8k/wttlrVs7zFe0k58m4X+x75Ii8MiNevl8sfSEEtrCamjBpn47biaJw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=IIlmviT0; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=TBzSyYzs; arc=none smtp.client-ip=202.12.124.147
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="IIlmviT0";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="TBzSyYzs"
Received: from phl-compute-07.internal (phl-compute-07.internal [10.202.2.47])
	by mailfout.stl.internal (Postfix) with ESMTP id BAB851D000AB;
	Fri, 25 Sep 2026 20:11:24 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-07.internal (MEProxy); Fri, 25 Sep 2026 20:11:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790381484;
	 x=1790467884; bh=FQJiSm0sxljgJ5jrK5+uHAcT1QtwmCKT3bGzW3ttg+4=; b=
	IIlmviT02tqaWBBsccDZbwhRhb6CSf36t0eybohui8p4svwuZ08mb9WiFx8kGIep
	F00NVh+Rs+hs0pQMdbUk3x/DEdpVh33j35IcAfsgy80DOB6lOjMkgGpnvtzxTEWY
	NmfpqfBD/6hNOQ2+Zvz0E7ueOxVrtj8lZZmgPL7RkwXngfQ3Z9/fw2CnGDSWfWde
	RdDXZzrBk8byqzVslRt+vOzN8MSF/9qRTvquari7hHNxJG0gtNg5JOP1vaLb0Gv9
	jXNqnGtPYIp5EcgjshYEI42QXcNdqM9t6icI23VuouH06w8U8UibFxz7KFdWvKfE
	b9B51DkcoUKWTPXzrI0DrQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790381484; x=1790467884; bh=F
	QJiSm0sxljgJ5jrK5+uHAcT1QtwmCKT3bGzW3ttg+4=; b=TBzSyYzsUINCHpj2D
	xgNiEyGbzONz3ic7NkfCAlrtDJqTXLY0b8oirBequOXJso2f1ZQTGlmqf2DpnfcQ
	y0wzBhA4jo0nUcFzi3OsJhGMIsbmjlhfKQgphDMf3krt27HK88S48pqVoNPZamE/
	5cpeaeWybpyeTNPhqkxVYZqzeZvaGTZ25flD7OnD+edMH7CS+B6HXTKC7b7EOris
	7VXQd6I0AJoTRsqzrZ3qZj1KC5d570GAYn3EACcb8lDtydig7d0xi84L9TdeAjhc
	5j1mvDr3EZ8moaY1xcQ6jnmAsjLb76cy3yKpJx36VfsPEOo8ynSyjOMbfQAYFYHc
	P5c/w==
X-ME-Sender: <xms:rA23akYcYZ0IbbqVwgkRuSMY-gvKf6U9kA7C_TSvXTESOcp2XshMow>
    <xme:rA23ah_O-zhQCgwjNDoUYx0il5njt3rgw4ey10knBft3lb6yAd4D08-x5lKnKDzVj
    YU5xBF_KAHOaHHsxAway8lzEiWFvCUP8eTk_dRRpktS4P5Zig>
X-ME-Received: <xmr:rA23ailyGOzB_OBLeu6NIHwsUsTlqiqvlJs5ZzZRMrX6Z3axNjA534O65fEOF12NV41OQWDrXjWNM_W2Lf5EKqY9b25hZqQ>
X-ME-Proxy-Cause: dmFkZTGWxL+qwdF+6ogkc37vJ94kB80sV7VXoJ8roDlzdBJWE/FvVbq7zIGeI/14s3bjfY
    PZ63hMXDtCn28O+OsBFVT8Lm8Zqg7CpGHhkVez6qq0BomB3jToNE7dTj9ZUZXLbdXqCRYT
    DQaUnAQkugRydtr+1K+LLGaVyXqEJqmPa7NLlhJXRvqrixtMbIXVrBRTexUskOKQtuRA44
    Up2nmNI5eILZfOJCe/8SNctZVcbRibXRhcczp/dwJDzqO6+PMGUNmmXjrYgGfRN5KIV4OC
    4pq2wbc3NCSm+p5BY9gayIyR/lwnX56zYlaZqUUUbPohaMarmwAFqylfe2foCywilnorDS
    votIdcsghObtF4A80GAi3O9OnlLb+OVjaYT7aMgYPXdilGSwXLxfg6kkbQdPiXro97KZdN
    T6vWgP3/562juJxggk2kwEp4iZidTrGzIuYjlaBx5hL+VC6AbxbA6bZv1yg+lQ5b5BmqfV
    a3c9nlUuuidct3L1n1fgUpDiR4fJ71IE03jIh3W0unPnQVihz2LkwycpBjURCW/SyRyo6V
    7KS2mzdMjA+lA0dJAEr3uo+0QuH6DKQ4wIMEc+2EaTvJs0uS98EQVmnwIofpw1LSvj86Nk
    ct7c3KCMZhzxZHTiDGkhVNuz0u6YaFL64NNMvi/Lsmwm4FmGnyDuqOptYxPw
X-ME-Proxy: <xmx:rA23auwmUlZMnvc_TMZ5Il4QtwT8ERE6w4gefWh_dYvvOpAVzE9trA>
    <xmx:rA23ak7KApsCZ4iHwAaxKJ1O6XBeP0wNf1jfEbcy10kbufNzeV1bGw>
    <xmx:rA23amXte7fiEEzMvTZ-7oCj3dUSXTO6AkcguzmiojISHOnsghivog>
    <xmx:rA23akLOL6-wg9-5AAb5QXDwFaRX9BCFLc58nplqZqXpsk__eIq9Dw>
    <xmx:rA23amRqifFgkK3UjRmjk5EvYx0oCY0G-PACApeAyB6anOAbOPWs3aSB>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 20:11:22 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 6/9] nfs: don't d_drop() before d_splice_alias() in atomic_create.
Date: Sat, 26 Sep 2026 10:01:23 +1000
Message-ID: <20260926001011.401824-7-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260926001011.401824-1-neilb@ownmail.net>
References: <20260926001011.401824-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

When atomic_create fails with -ENOENT we currently d_drop() the dentry
and then re-add it (d_splice_alias()) with a NULL inode.
This drop-and-re-add will not work with proposed locking changes.

As d_splice_alias() now supports hashed dentries, we don't need the
d_drop() until it is determined that some other error has occurred.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ee8a718b9695..8650ca2b6fc0 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2180,7 +2180,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		err = PTR_ERR(inode);
 		trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
 		put_nfs_open_context(ctx);
-		d_drop(dentry);
 		switch (err) {
 		case -ENOENT:
 			if (nfs_server_capable(dir, NFS_CAP_CASE_INSENSITIVE))
@@ -2189,7 +2188,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 				dir_verifier = nfs_save_change_attribute(dir);
 			nfs_set_verifier(dentry, dir_verifier);
 			d_splice_alias(NULL, dentry);
-			break;
+			goto out;
 		case -EISDIR:
 		case -ENOTDIR:
 			if (open_flags & __O_REGULAR) {
@@ -2205,6 +2204,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		default:
 			break;
 		}
+		d_drop(dentry);
 		goto out;
 	}
 	file->f_mode |= FMODE_CAN_ODIRECT;
-- 
2.50.0.107.gf914562f5916.dirty

