Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ECC09307AC6;
	Mon,  3 Aug 2026 14:49:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785768584; cv=none; b=IrvQGwtybSnllcu0dNlkvTZl/HhQeEeVG7Kg6/AqnRlSqTOSLQu3CN3nVAe+n7DncJDfB5syPPyWrPF98iArviiTIH68KgtaRTVA3dVvpC3Fqonk1OTQc4arAVSV/dpryldWqbtdIeZmYB1NtQfhi483uEaktaTS+2iYyA3McOE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785768584; c=relaxed/simple;
	bh=m8rcrEbKFxNhyol4zn6wKFY0EhxfkTOjFMGq4MnUE6w=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=iKB2DYR3yR6LZ3V6UzvbD+N+bPn51cyOy5+aGwo256ZxCpiJbIHNr7sI59zsZZulv1zwTOgHFeblAo9zjkTu+Z9L4i9yzF5y2lbIxz4qkFUkkybzNjDAZ8txAok+jvgMk5w/U2vPCzmDtUQi0qlPtfvlJAsY4zualqz9dRYhzMk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=l45vvSW1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="l45vvSW1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B8C71F000E9;
	Mon,  3 Aug 2026 14:49:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785768582;
	bh=8zMFFmNzVfQTybRk7SGD5eJgRjX2AyybzU5Kv0VTAMI=;
	h=From:Subject:Date:To:Cc;
	b=l45vvSW12o9+qkapKwlemT+gyuiwfMPhNah6Q3yPFJmTu0w1znjY7r391o0aqLFx0
	 /I+h6TPbu/YWMnPrB0zU5JV40ggI4CtcBi91oKm26G3Gz2n9TnUO6PyWsbrCjjF6uv
	 0z85ZlMChRhoM6eXze8c3IYi6aEnFBLGjQwtP5D6jsTpN44laSmyuNOn+JQefTBDCg
	 GG1A7CGNjN/a+Y2xxgdw3C19s5059r6uNHwbljJ5tLqPc8+UKEgTF4wgsbpDNUIs8d
	 UdSIEm/YvydutX/Lp7sOTIUDLcz28T4S/vd8e7ekccChe+bDojcZDz6WAEKIFHBwgz
	 cT0Hx2oIrNK/w==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/2] nfsd: fix up some sparse warnings
Date: Mon, 03 Aug 2026 10:49:26 -0400
Message-Id: <20260803-dir-deleg-v1-0-51be76861821@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDCwNj3ZTMIt2U1JzUdF1Dc3OTNNOURAPzVAMloPqCotS0zAqwWdGxtbU
 A6M8sFlsAAAA=
X-Change-ID: 20260803-dir-deleg-1774f5da07e0
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>, kernel test robot <lkp@intel.com>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=723; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=m8rcrEbKFxNhyol4zn6wKFY0EhxfkTOjFMGq4MnUE6w=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqcKqA00/70enBtLKk/iZoeabqqrcwmTFyiz+t5
 XAYxNEe/5GJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCanCqgAAKCRAADmhBGVaC
 Ff9LEADEle5PChIYjX556MhMZiRNwpSgvWIR412shY1NuQOKED8MCuItTFkEnC95NE+i7QqD5fX
 OWPXt9YeS5gO7+RkMknfF+81OIQ2Gm5yfxgXLqq/Ykra0EiCe+Jefm3Xkktrfc4DoqGBcj7kuBc
 KVIUqAHPrXMkyaxMVola7ydNA836nyLMupSf8WakT8TbZgmkGPPbO8AhQZiQ0XVfc8gh4PBY+ap
 UuHxI6Ac2sgyiGfMeMz7yj38LxEX//K15IzRsPp65PO+KHDjUH0VLTLYiFXRGm2ZHc2pMgmU6Q8
 ZJ/2zJEeSZQpauUQHp9/06LGhX96RsRh85uVidhokA84tmNGN8jGL7QhfdUgQP6oz+L6YLvYZsK
 RdeVNHwyNZvonSIgWK8ecaRiGTLm5GH1lp2BPPxpC3Mj582DxVf1rZnTONDIZwh2+yjPNO2+ONf
 rA9lnugvzez6GVXYwHp7dBT+ulvJq1TEGEuga/I2vaKY15hJINy7vbDzdW+WCdNymcaHPWijFiT
 n3UVufM60XxDuZ/x/g7YkuqXeEpeJpTY32EQIYLyLgAA2Ktagooiq6lu68DtOrIIN4H1nWALHDy
 RMkpUdAnu1UUjBVEsLJ91Poh3JT7euhkDVg9gejuLD7Sry6nYADRhOMzwgnJLa2LLqCnt7b/ckd
 KFBZ1wTWXdsyyNw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The first patch should fix the sparse warning that the KTR noticed last
week. I also took the opportunity to add a comment over the weird xdr
stream (ab)use we're doing there.

The second patch just fixes up a sparse warning that I noticed.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (2):
      nfsd: fix type mismatch and explain host-endian xdr buffer usage
      nfsd: fix nfserr type in nfsd_lookup_dentry()

 fs/nfsd/nfs4xdr.c | 11 ++++++++---
 fs/nfsd/vfs.c     |  2 +-
 2 files changed, 9 insertions(+), 4 deletions(-)
---
base-commit: 106c31f3d72c56fce98bb2f0e8b3de1a0024228d
change-id: 20260803-dir-deleg-1774f5da07e0

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

