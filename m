Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7F343126DF
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 14:16:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792160192; cv=none; b=H4SiIoc9zWcN/PvNLan5BsGd9BxKCUzBYRwFBTSavQqEGDcgF2Jk4pMZFKjTp3dYqpG4CiE4TWGfW9s0uZQOkDQRxLC6GDZNIMFzanu1Kfq+2SvbLQzJAOHPRS//ZtfKknENyrG8yUrWQfxY0nsYv4GbPsC3ghgUfvPThMmMGYI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792160192; c=relaxed/simple;
	bh=OIzcKedsg6wAvnP5b+NYIqacuSe8RX3LimqiKTu0jQo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=pc+JD+SLj7W/rnacg9Ueu4zC8jIKChLg8W2tiEyWStwDOEdXGMiWQAWZAJkAHSkPP+kTqLpHTLAy75yIt1QdC4eZsooIBEBRDOVn4dBwkPlPVZUIXegTTlNb5yxcMBunONzJRvZwco1Dc8ivaF4lzg5uKgCpoHBs0TvPtWwza7g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mLvaYBUH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mLvaYBUH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C35541F000CB;
	Fri, 16 Oct 2026 14:16:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792160182;
	bh=rY3Gq3kifKMQhKgL90Tx78lyyxNSsIIs/86nskXHj9s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mLvaYBUHniYWeomfrc7bQsM4kIoFqFP3ldujyuoY8beJJy0+oUKGZah77MPxoezTA
	 zBEgC2lthX+fOkMs4ytiyW2flL9LOGUd213uheMauwBEb8qDzlw1WmC7OZAEv4uO38
	 YsGBe7lF2MZkUVYIMgm03Hfm+8JJHNXIbLkZBJNpE8oNGYvBdMwbbIur9HiHHIJ5hL
	 wND7qVxEZOezRYKr4nu7vjQtyaxAS6erli/jnkLSvtQJEAIMIf1tY/ydFOu7hbBbiv
	 Eu+c1paIbgD08sNCX1gX0tyKCwsWrtQ660ezoZ2Fintag0zewB9d3zolQk/XNY0vDQ
	 xcGbcd577a7JA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 16 Oct 2026 10:15:42 -0400
Subject: [PATCH nfs-utils 6/7] mountd/exportd: always give pseudo-root
 directories a path-based uuid
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261016-netlink-noproc-v1-6-42791f4b6eb5@kernel.org>
References: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
In-Reply-To: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2785; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=OIzcKedsg6wAvnP5b+NYIqacuSe8RX3LimqiKTu0jQo=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq0jGyGXSW2K2w6Po4RF9umoMRgDy7atsqbCqud
 /omQCX95gqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatIxsgAKCRAADmhBGVaC
 FR3/D/0T+BYR+os0ILaaOvmvfoHEuV/nVQi9si9NSZuLZdJHVh8QkLckdP46ylz+bIsGvC7fCF1
 CDeMQwawZDpmRjTUOAaG7cw4NJ99p7plQoXZkyGy8RW1RGK8FvtowMReToRXq2QEq30RuXfYJHU
 38J8DOQBeqtlezgtJ9IuXkYva6UGo63afxFU32IcFBbraJOVBS58AzAiscYcPZR3IG0ziJJFboC
 kiX1dO93i2PVwtKKWAPlU4+HVkKWV3fYXZkTWn0KrMwZDU3nnSGhv/BDY/q8937r5gBy4L6OxoB
 ZaA6xrc0upZ1Vf6o6mllLdrZqXY5DApve48Oqmjpf47OqIorvyd0hfMCcxzjfguFsRGVoMuEVFS
 lpkC2QCmSTm+nMKH0/RcERhx2zn4aNN0SYJJ60/qjFAxUctrOIPQTWPy+numrX1JeE70bnhmZwd
 MeJK+Rv/SJGJzX3Ex3ypv0ZcCBorpgB2C6IhRdtiHc7E6GxiMwXD6GifwVOVzCbv4gK62PPO8HB
 0rR4JT0oj4rCz9GVI0K1YBARb1g/R0jvG8T34lTiqWd38rrBMHksgrSLikwmK2XyxU+pYwPj4fj
 YQmsOfWqKgPqrccyeRhu0jXyMSYbTgYJI7PB6LEB/4gvNeHmSjVhqGVdqH4n3jnMPuSOBN6QQoU
 4wAJbMKvVh0tvRw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

c5528f40f9db ("Fix NFSv4 export of tmpfs filesystems") made
v4root_create() generate a uuid from the path only when export_test()
says the directory cannot be exported without one, leaving others on
the filesystem's own uuid. In practice export_test() fails nearly every
time, so the path-based uuid is what pseudo-root directories get:

- export_test() needs the "-test-client-" auth_domain, which only lives
  as long as an ip_map entry that references it.
- With netlink, nothing creates that entry: exportfs's can_test()
  returns before writing it. The kernel answers ENOENT.
- With /proc, can_test() creates it, but exportfs's own cache_flush()
  frees it before mountd rebuilds the pseudo-root.

The fs uuid is only used when mountd rebuilds the pseudo-root during
the brief window in an exportfs run on a live server, and then that
directory's filehandle differs from every other time.

Always use the path-based uuid below "/". That keeps what servers have
done since c5528f40f9db, closes that window, and drops a write to
/proc/net/rpc/nfsd.export/channel that ran even with netlink.

Also keep uuid_s in scope until export_create() has used it; eep.e_uuid
pointed at it after the block that declared it had ended.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/v4root.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/support/export/v4root.c b/support/export/v4root.c
index ff1d6e1c0bde..38286b91ede0 100644
--- a/support/export/v4root.c
+++ b/support/export/v4root.c
@@ -85,24 +85,26 @@ v4root_create(char *path, nfs_export *export)
 	nfs_export *exp;
 	struct exportent eep;
 	struct exportent *curexp = &export->m_export;
+	char uuid_s[UUID_STR_LEN];
 
 	dupexportent(&eep, &pseudo_root.m_export);
 	eep.e_ttl = default_ttl;
 	eep.e_hostname = curexp->e_hostname;
 	strncpy(eep.e_path, path, sizeof(eep.e_path)-1);
-	if (strcmp(path, "/") != 0)
-		eep.e_flags &= ~NFSEXP_FSID;
 
-	if (strcmp(path, "/") != 0 &&
-	    !export_test(&eep, 0)) {
-		/* Need a uuid - base it on path using a fixed seed that
-		 * was generated randomly.
+	if (strcmp(path, "/") != 0) {
+		/*
+		 * Some filesystems (tmpfs, say) cannot be exported without an
+		 * fsid or uuid, so give every pseudo-root directory below "/"
+		 * one.  Base it on the path, using a fixed seed that was
+		 * generated randomly, so that its filehandle never changes.
 		 */
 		const char seed_s[] = "39c6b5c1-3f24-4f4e-977c-7fe6546b8a25";
 		uuid_t seed, uuid;
-		char uuid_s[UUID_STR_LEN];
 		unsigned int i, j;
 
+		eep.e_flags &= ~NFSEXP_FSID;
+
 		uuid_parse(seed_s, seed);
 		uuid_generate_sha1(uuid, seed, path, strlen(path));
 		uuid_unparse_upper(uuid, uuid_s);

-- 
2.56.0

