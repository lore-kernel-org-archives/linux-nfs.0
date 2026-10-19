Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 775F34DAF89
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 11:46:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792410403; cv=none; b=kUNOT2bi4R5W4kGRNjVqUAGIiU0ZTAV5mt3dnUFL3dyK6DKCJeD2o8oJJBVAX2JwmfJyT942a7JmnN5Q4yqYfMoml99qLPQPgPAxwhRd/S2iSAVEB8UA4yaR+gu/M9joJR0rJsrpnKkwMvisQ2pbLlOQjllaFiQ0xhmwuj3d7nE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792410403; c=relaxed/simple;
	bh=NsJsTl2Rnxk5IAqht+n6K2wYYUHrbxohSbAVB8LovEc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=MWQfGLfsPzguiAWUvwYcEaxnvXP+wh+SNtnJ9nVuid36xEM3gVaXKMJNb1IeHEAPEY6cF+XTmdmZZZ6NhqLj5bnFz7XVRvLnR9P+eZDwZfHFlBuqgTAgTviBP6gbccg9YQnOor1TsRZ4Ouj9jlbhBgWb8QaYVJmI7TV5HvGXWpk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hi4P0xEQ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hi4P0xEQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CD4831F000C6;
	Mon, 19 Oct 2026 11:46:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792410402;
	bh=eejpco5iGD2omL0mo5gni4fQvBBxLU4LS4o4OPdGS5o=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hi4P0xEQkMxmmUX7Zl/04a98ipvxAQoCQmXI2idsUcefrQ0B6iKRWdMKR24kk+fIy
	 k3rxiHKyrygL8LFQbSw5ZPiTRHcO8P4d7hcV8uF70tex1j3e8hmMQePPIGgPpHnU48
	 JwhSpz0S6ugQphaDj7UZacKFnZ9N7TxN52UfYfkcA/rdIj6f81dYyW2FE6aDkhq4vE
	 rtIyrTyzKjW+eQfzpVw7BIeSrQvTJPRE7KpmTVo2KkNSO5U4u6q6aZST/3tnuF1OPe
	 5IpkMgTVXw41XACBebLsflbgnxDBywwT8tDo+tk8NMqbzk5QfwMS/R8qjopDfeyQav
	 VlIff+IJqg/Eg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 19 Oct 2026 07:46:26 -0400
Subject: [PATCH nfs-utils v2 6/7] mountd/exportd: always give pseudo-root
 directories a path-based uuid
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261019-netlink-noproc-v2-6-7d09a49b574b@kernel.org>
References: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
In-Reply-To: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: Ben Coddington <bcodding@hammerspace.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2909; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=NsJsTl2Rnxk5IAqht+n6K2wYYUHrbxohSbAVB8LovEc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq1gMduPpfVIK6mxmPCC+DDPdvn7FJZaRb91Inp
 Nx6/ux0vE6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatYDHQAKCRAADmhBGVaC
 FXaCEADXJBcgfYZqQXDVz1duhGzTRjwWtSd+4cPBwEirOkGxOyBolfsly59iEnwrdyJn3C5j/D6
 k5Ig0JbUWpf288BOlsDqMZMG7XmZ8nnEnuFSwem5GgUyTTWcHvNhfs0hjlc3EcappTvwlR/uQFE
 9/hgdp002OXBt9ruf6zWeB04wxjC5Xu/Ko0vQwv3l0eI8jG5rvKGhu4iFoeuHt3Q6bH8Kql/F5r
 s96+nxJisuGFSul2mdcF5XTsFMOiz8HuDivj3pHCW2ET2jfHiLK15JjgyjDj9C8sr+KAre9EByQ
 rylF4pVnSPd6GAx2U1RT7fyDuP8Y+3DXd7XV5ZP+nnGfO6+Blp6ORFT4ax0RkKFeHDtJER4OZSN
 OPmiloUpwD9kxI8aYedaHYIiHJoi+nAYc0fQv2+xGnzkMR6e7szIaVYf7xRpOXBwv2+DQZI4Rq1
 bmC5izySTbMivSMhkljpKz5V+0C3hvihwURqxknLS8w8uU0Q8OfEnW40OEEQr6HtJWB65NWDnoi
 sZfn/ziC/KQnxyXthOoPmkwWmpfXyt3OiLLTsiM42orJPYzOeDVwC+IFZnsRdiX4p/Tm3U2GFVc
 kILQMhXvozHVQ8CLihOU3xkNkMmjm2aevUB+nGdHfGx5+XJ+pMqc//hx2+ziGq03vTttQ87IJo0
 vNJVeALaEIRh3Qg==
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

Fixes: c5528f40f9db ("Fix NFSv4 export of tmpfs filesystems")
Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>
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

