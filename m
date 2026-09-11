Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1325349B5DE
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 16:25:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789143943; cv=none; b=aofcmP/s9kZwhnjU1MySQyMXwLdMRx4bxmaZXQ7UuKuHtD7equtQABdIgbazeVMh0pwJ/GRJ+292EQHsA2VYhwPrzW5EiUcDs/4EYzyPh7AxG6E17oHL9c6FeLQ2zElF7WT4difid6buhtYY5yYUH8syN85I2Sa7aUkvcEUa8jk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789143943; c=relaxed/simple;
	bh=tx/FOIt7dL4UWAaHZFLbNXkZHulegmpzBPoF04GA0kM=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=naQkEOl4prt30Jl/55DDB4kH0DRwkaAhxYq2ooACzCKllGAYMXU871BhcANioFghqAgsnn0VpaE9AY8jEhg7QPkcaJdR7XRO44GT917nlZR7ZbcACGDq8tvr5k3+zTrLcjs4vGGKM4GX5RxMEhmyauYEVl7c9qiC6oTBqqrnk/s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=f/CAYGsh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="f/CAYGsh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4DF8A1F000FF;
	Fri, 11 Sep 2026 16:25:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789143941;
	bh=UVBJXEc5R+QpoqVMU+1t7SOXcJ46T2qKBGF++Soi5/4=;
	h=From:Subject:Date:To:Cc;
	b=f/CAYGshXmLTKR1Ej5ikrfBBMus1OC7fxQIJo+mphFke6GDTVTQLfqcxtvD0gthRz
	 RZZIvuopgo0ebM7mpbBbs5vCeuGtR0mYdcXszx0LtLJfB2PZCxK2BaCP/uKzGL4zcC
	 hfiWISSS9dhz5CMftW0np80+BMY7zNmpunhaPFGdBlKBw+xV32VyEySz+yOi18TayV
	 0KLUkTM1RA+9RShAe2JOVgDnPsOh9rlYCVXO0sli3aWvgbrDjKOaWH016LUXMTalpP
	 ROByYFeLkUYU9yw7kVxQ7SskqkJOOxxmSt84m0/i0Ozwy0g+6Mg9jBINUz4EzA2PaR
	 XbKdRzpp9anIQ==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH nfs-utils v2 00/10] mountd: bugfixes for up/downcall
 interfaces
Date: Fri, 11 Sep 2026 12:25:25 -0400
Message-Id: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/1WNzQ6CMBCEX4Xs2TVtpVA9+R6GAz8LNGJrdpFoC
 O9uQ7x4/DIz36wgxJ4ELtkKTIsXH0MCc8igHeswEPouMRhlCnVWDsOELUeRR5jRWevyptRtaTS
 kxZOp9+/ddoPQC75mPwlUKRq9zJE/+8+i98JPef5TLhoV5qrIG1ufms7Z65040HSMPEC1bdsXy
 lCQnrIAAAA=
X-Change-ID: 20260908-nl-crossmnt-85584b71c721
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1868; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=tx/FOIt7dL4UWAaHZFLbNXkZHulegmpzBPoF04GA0kM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqpCt+mxWrw1fl5JH+INSJxJp94MpXHExBwC9wC
 itueoPdcPWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqQrfgAKCRAADmhBGVaC
 FdiIEADCuX2SJO4edlLQel87LyW+WPTEedeoPE20WalqIIFI0Y62JIT68lCWtUFlcDcICNjzmvE
 8kdDBuxmEx1Ncd/yBWNrm9Q0zSxHoXqTZebAeFGyevJ+RvArcU7Q2j0CnfhmVE3/kHEHkFXN0/g
 voxMJO8duqdNOjMS2HWvYQUrzPs926vzA5roqEw1YC8KxC2As5E7rQIj/rLAW3B0UdeFyqkiw60
 8cd98wbnFf+jiD+tBFE7UjLdlIvTJJVIlL9iXKTL8Wvp9jscGibkHpFlDQbVceRUNWLBnVxEop2
 Mr+iBwlSlXrBfZZ4PPUzUINvzzmwVP3UhTPi1slLt3uiqTkyzh4eTW88oFzAwArAwNE+YCfUtxf
 8hQCTokUplVQ4/1JPHCDu5SmEaCpfHRAiOB7KbwPFukVS3QGvVKoNZlUJObwLSKi9CFWSHZu3bT
 5DE2LYXK2yKrDDWmVE/o6y73x8ZHTOwLOTiT5rreHxCnPPnVlJdd2wnE0jk2vWO6l5OQa6fT7qX
 bADsV2JB2gh7qWaaOm9CaniE1XnHRyQgMVV5+FwA9DofKjBMW/r/Gu+LqNBzxNkJts+kB2alSu4
 o2jDrw2PV4CWdBLn8kWCeWrySj4ni8ic1iqJ4qaUgRSnSA52/Saek2swvmAJq1//xce2Utlzj8+
 iKK3zJakST/9ovg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Mantas reported a problem with his configuration that was using crossmnt
and autofs to export a number of btrfs filesystems. Some analysis with
Claude also uncovered a few other bugs. This version also fixes a
number of problems that Sashiko flagged. Some of them were preexisting
but seemed like good things to fix.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- Retry instead of caching a negative when the failure may be transient:
  kernel errno, statfs, fsidd, and an undelivered negative fallback
- Drop a deferred request once it has been answered
- Bound the junction path copied into exportent.e_path (preexisting)
- Give each worker its own netlink command socket (preexisting)
- Bound the retry queues (preexisting)
- Link to v1: https://lore.kernel.org/r/20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org

---
Jeff Layton (10):
      mountd: factor out the per-path export attribute computation
      mountd: handle unmountable paths and junctions in the netlink downcall
      mountd: answer requests the kernel rejects on the netlink downcall
      mountd: don't leak the parent export's fsid onto crossmnt submounts
      mountd: retry unresolvable fsid lookups on the netlink downcall
      mountd: bound the junction path before copying it into e_path
      mountd: give each worker its own netlink command socket
      mountd: retry export attributes that fail to resolve for a passing reason
      mountd: drop a deferred fsid lookup once it has been answered
      mountd: bound the retry queues

 support/export/cache.c | 1331 +++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 1026 insertions(+), 305 deletions(-)
---
base-commit: 630393e9c73667b3fda6a7507cb5171ec0ec38dc
change-id: 20260908-nl-crossmnt-85584b71c721

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

