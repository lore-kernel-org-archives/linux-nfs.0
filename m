Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794256657;
	b=lOhhwIogTCNA0GnzUNreiIO9BqS2MgHvWkEABBJtVozfST+zxt9XiJS+qNTaVOV0IEYg
	 Z1DAyrMjb7PAIQlO60FpjAjItpPwIbcoK6alE2entV528F2WkZAwl+0C/UBXbsdtEhTmD
	 CGDhASxF2beK83621BFnr/sko0AIrhNMTt4rG9/it80IlCUc41LjrlbEJgIiktYQuAnfQ
	 XLkWPPx4mkh9OMYxJl2EQoUYKsUxdOj6HGQrjbGgToGMlxE6t5a4ZoQtWnnCyek+viLpn
	 ZSMMZGlic3ZssXAJU+6jfxVpMYv1Cw7BGPGiUtZ7WCtD36Y05wjWUGnUUhFrjP3ZVQg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794256657;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=+hWMylWSlj5tCzglxie6uxmfNnuVLuaVPMeEsEJxBQc=;
	b=0061LebApDe2HlV29Lorw2eo+IWbQksTO++wGa27xBgF4AfsF9bHlbrpFwbL2To9RfTg
	 ZuG69j6drdYLgz7JmUR3aXjKy6lXlUYccC20I/5Yg86/A7tgbpu9NRxtbWyd6GwVmuDYh
	 KWWSTmmOugGGMM5ObGxn7i1Dz6r9enx6dkximbZ/egb06lIMEXfSOtpdnKqm8UgYZdHcc
	 sVNZoNz3g184jvQELWyPwNqDcvvJTP0TFr98l2ek0d7ewQrqRXb8MmQkTOJ6gJRp9URVO
	 mJZAjYg+6gYyUyh5CYnlET9Y7/DL45Mlo6jbzpH5tjS0NBWkitMqvsKTjbUU5jdzjQQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F6nlit9G;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98E0960A2605;
	Mon,  9 Nov 2026 20:37:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F6nlit9G
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7F6441F008A7;
	Mon,  9 Nov 2026 20:37:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794256657;
	bh=+hWMylWSlj5tCzglxie6uxmfNnuVLuaVPMeEsEJxBQc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=F6nlit9Ghj401JsGRM/4efrBGeW3XgHsYzotBpkHxCYlhHd0yHqX5FCdqhaB3Izsv
	 vdX6L5WW5U9hPG7RkFjWwgdHVutvsYs+sXgKb9CwLIJLdSlNGMxxbeAIPL7FI/ibyb
	 oPI0aXjUN+T2dnVTgRuN0pYSjKJw/2hpEacwBr4LRIrRysT9gVxoqIQHNYYEGWXDQU
	 3E8pM20o89aRzkkUCWD9c4OKfFKbzMG1Bpnw6KzvTA5I/XgRlIDnBUI4ow9GlfgUA5
	 CfMk6g8dtq6dm4eeSze4SBrCPvthAFw6U6JKBMceCCasKU64ugxdAnfZtRu14ds45K
	 nrULd0IXLQ9+A==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 09 Nov 2026 15:36:48 -0500
Subject: [PATCH v3 7/8] nfsd: check a fine-grained time before clamping a
 delegated mtime
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
Message-Id: <20261109-deleg-cb-getattr-times-v3-7-710c7244a6ea@kernel.org>
References: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
In-Reply-To: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2263; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=F6tqKbvnSm5FVTuj1nV1RBbp+sYbqzqtHYA+qtmUX5k=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8i8F3Qt+3vME5frjKVIxCMzARE0EffBIMw876
 VnNqq9DVFCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIvBQAKCRAADmhBGVaC
 FfZkD/0Z9dz4Qn3SuqTR4wAzvLOzblLpzPrX9TqupJLQDlKFwoAyeGN55IymB0mm9SevsWUPTHo
 78t3R5wXBVZt3qmwjSW1lDhLvxj0DseE+kh0Dzov1+R3pliczkqCQOKknI5W6Xnsn/Gox6VWxMz
 mDqHKz8RFdn1I0x5Wsm2IsmjpavG2nK4dd0jAgodMNusz9gMaSLc4IojbtWLcbA1LtAqCsx69+v
 z4+HBDLbusHsgiLvaFMMW9QWp8wan2gvaXUMBnK51Faj57M+aiLOXEN0MaKev8F7p77FNL2LJ9P
 UP5IgOhbMw3+9+9rmRkHAJnhXIDeSYeY8KTv3rFRJDN6y3JayvPfduCxwzijD23LohBzAQSIw9n
 tMe3CGcE2lmEtZ/RDe2NqRbvbSriwkSBAn7zIzQYJpOdb1HsKM1x3sbpphiJorgo+Oe+4UYRlTn
 uG9UWyCdjMhLWSYQeCVjZqek+9YXFCE+kMRpLuCxVJ6RZ/ypRzIhNVgjl0XLp5dCj5uxU5AjjS2
 /ADLpCALYVJbGgG9C0tNUkKt2RZoTQYV4IN5YLia6TFoMZUjfyCTdGEUrL3HmcywOlovj248JKv
 5VB78QHUqq7AOAILzhtExwJ6pmFn6pf4zsDcKBceyhqilewHfPLRL7ULwD3HdG3RnbnouQaQmfs
 Uecnwg5NMJCTfvA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_vet_deleg_attrs() clamps a holder's mtime to current_time() if
the mtime is later. current_time() is coarse unless the filesystem is
multigrain and the inode's ctime was queried and is still equal to the
coarse time. A client holding a timestamp delegation stamps at least
1ns after the fine-grained ctime it was last sent, so an mtime returned
within the same coarse tick is clamped back, and the mtime the client
reported changes after DELEGRETURN. On non-multigrain exports that is
the normal case.

When the mtime is past the coarse time, clamp it and its ctime against
ktime_get_real_ts64() instead. Such an mtime also passes dl_ctime, so
its ctime goes through inode_set_ctime_deleg(), which raises the mgtime
floor past it; later stamps on other files can't appear older. atime
gets no such floor raise, so leave it clamped to the coarse time.

This depends on "fs: check a fine-grained time before clamping a
delegated ctime". Without it, ctime is still clamped to the coarse time
and the floor isn't raised, leaving mtime ahead of both.

Fixes: 6ae30d6eb26b ("nfsd: add support for delegated timestamps")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3bb518270b8b..03e694f635db 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10785,6 +10785,17 @@ void nfsd4_vet_deleg_attrs(struct iattr *iattr, struct nfs4_delegation *dp,
 	}
 
 	if (deleg_attrs & FATTR4_WORD2_TIME_DELEG_MODIFY) {
+		/*
+		 * A holder stamps just past the last fine-grained ctime it
+		 * was sent, which can be past the coarse @now. Clamp against
+		 * a fine-grained time instead. An mtime past @now also passes
+		 * dl_ctime, so its ctime goes through inode_set_ctime_deleg(),
+		 * which raises the mgtime floor past it. atime gets no such
+		 * floor raise, so it stays clamped to the coarse time.
+		 */
+		if (timespec64_compare(&iattr->ia_mtime, &now) > 0)
+			ktime_get_real_ts64(&now);
+
 		iattr->ia_valid &= ~(ATTR_MTIME | ATTR_MTIME_SET |
 				     ATTR_CTIME | ATTR_CTIME_SET);
 		if (!nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now))

-- 
2.56.0

