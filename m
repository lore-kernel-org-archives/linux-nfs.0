Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CFA4D438014;
	Wed, 12 Aug 2026 18:08:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786558104; cv=none; b=Yl6QkCtlbbLeAHCwGOBNcAVEET2rfZ10Zx+Cm0wTnCyhcWOCZFMEgGCI1P8sMDdfQggtYJDfNRF6LET7XhcBYKh2hDspoDVcjowNZ0JlBIio6jLYEdDnLLm+pxjFChX8FhO7fK4ZF8HxFW+gIZn3IFHF5OVGxFobwWHjcoSYV+U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786558104; c=relaxed/simple;
	bh=4DeAa4rT0BsVxW4etZPbs/1VcPcEhnfHzPzMxaUmqD4=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=lV12hT+UjbcYF3fVpdkze6ncvOa7nsUZifIOD+ZzGPeccPPwcyCn0iEiDn1JpDUOESGtUq1pURpkA2dZZCf6R595FysNxF0WzWS4KiUTuevzlZJK/qegHIs6rmduusgDaWg+NBXjveuEV/tNqoxIG/8Z69vcnBg5asDw0xhV9+U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WoDMx6uV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WoDMx6uV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BF3F91F000E9;
	Wed, 12 Aug 2026 18:08:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786558103;
	bh=3Uv7pNjynvU6ujSQx0aJYVj6H2aXhcHRKdr7BWbkb3g=;
	h=From:Subject:Date:To:Cc;
	b=WoDMx6uVxVnK/MF2uqzmk3AD5jlOHaDn8ojeTTa9IRaDqoXECzRhuB8qB+9FPuC78
	 eNUusXkN7aNuna/uw1MMonKNXV8v2U4pl0/K+oCFiLRgw+JgndIVTIDkGzkdfoDjDi
	 qVgU7WO27yKJq9cNwpqtEzNYVxsC+/KgPVxezs+0AR6GymmA7s5UiEpqPI0aMZTt99
	 TrRWfrJIVfYIZpQo8MSec4lAR+krDCGrL/NyPbiL/fqER4zwGD8V/wmFUlbGRBdhww
	 4WsjvgbS57m9nVo3dt/7xiHRuJDMY4lkbob8EwmLHxWaa0DI8S086XUn8SfB6nrUzs
	 C089fs6UU2JWg==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/2] nfsd: don't use the xdr buf for temporary storage in
 CB_NOTIFY
Date: Wed, 12 Aug 2026 14:08:13 -0400
Message-Id: <20260812-dir-deleg-v1-0-411faa713068@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDC0Mj3ZTMIt2U1JzUdF1LizTjpJTkJAsjI2MloPqCotS0zAqwWdGxtbU
 ABe3qWlsAAAA=
X-Change-ID: 20260812-dir-deleg-98f3bdcb8223
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1090; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=4DeAa4rT0BsVxW4etZPbs/1VcPcEhnfHzPzMxaUmqD4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqfLaRi8PalDdAne199qBRDFZrH7TIZ0lfUqrfw
 6usOXpKZRWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCany2kQAKCRAADmhBGVaC
 Fd2XD/426tkL0wuueTlt5V6DiJDiuvDGMDIu/4UbNyZNFj4q1XCYy4WZsf72r88uGBm7uKjVYZf
 cWIm9S1Ln/rmPi7nhAUlBg/11SIcCaTyDXjn/0LSZ8+qa7Ls0RvsGd6PjsstlwqnHLFsE5iJekj
 gvz2sF8govcQRomf7GsDhzrB5fYnNbXidnz1A55nByWKQGxNHNEu/i8TmevUVLcU1fRmCLZyiAM
 WfwQNAsQM0CJrRg9GeU8gqcPLula3SCIvLuv+kk1tUvRC6MM3o2I4SyiIJRSL5ewi8sjCrvi6jh
 VYdSWb2UsHHcsJt+6IobZE8nC7hwHtv84rIWg4oQqLqcX78OAcupujCZYNcsNQr5CmZQy+9GBgr
 6D3Kar06B2i5xFWRll1KMabi+ePCeIE67yJwFPvrhwQ2ZDYHp45FABlKvkDX++GYU0sMqZUQKzz
 QNhP9xmnpQHVUuFQCAwkSbKBvZ7b/POOfHgRcDMSb4G4sdYLrpE59cLYEKiT+zgyYi7k0DESebr
 bF5+Yf46sl7hlQ1q+4G+jOL6M3jSbpTXY7bWR+PsldtPKir75EfHDxOXynK95T7sfCWV8rM+HAA
 l16PMa75iON4TExLV3LiGawocDm2mJjwVf//vZ1vHdg1qM62fqV+bhxrYz4sX2IscaOyZ3vgPiS
 nxWGZ4L6Ncda0Ew==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

I posted a patch to fix up a sparse warning with a cast a few days ago
[1], but Chuck objected and wanted to fix this by moving these
(host-endian) allocations out of the xdr stream entirely.

This patchset should do that. Some of them are able to be moved to
temporary stack allocations, but the mask fields need a separate
kmalloc'ed field tracked in struct nfsd4_cb_notify.

Please consider these for v7.4.

[1]: https://lore.kernel.org/linux-nfs/20260803-dir-deleg-v1-1-51be76861821@kernel.org/

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (2):
      nfsd: pass caller-provided attrmask storage into nfsd4_setup_notify_entry4()
      nfsd: back CB_NOTIFY notify_mask words with per-delegation storage

 fs/nfsd/nfs4state.c | 20 +++++++++-----------
 fs/nfsd/nfs4xdr.c   | 28 ++++++++++++++--------------
 fs/nfsd/state.h     |  1 +
 3 files changed, 24 insertions(+), 25 deletions(-)
---
base-commit: d33023dfd81b31e80fe65c2921993b1a6cd7043c
change-id: 20260812-dir-deleg-98f3bdcb8223

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

