Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D6754374A0E
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 14:16:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792160184; cv=none; b=nfTAdAiZ0EBjPSqXxXCstRRfEXlVx/ZgFvGW4lpoxfaj18FHXlBMtmI3exN6dyb0pYWMbiFE8k4KBtWa5xRFHk29R82nXSvyYabKE7JnZelcXDboTen+JEwwOUC0AdkPmmOLxD7JJtpjqkd+FBTUbcbR3HEu1hDJKwbfB9SBS3g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792160184; c=relaxed/simple;
	bh=aZx4B2QBHHQvaK2E2Gykhed2yxyn4ytCAuCqJQQjtpg=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=ab+jQvgrD2aT1J0oDrG0wVEANtJ8WIlyg5GLIkrqbZOj7P+1crJ2DAsLbnLGQdEdryeAHgrp+YN9AICftIh3k8O40bgEbx8DGFpsp2tMMPI2mYFaEKiUw38aM8AsfeQU1OTedlAPLHlBxXKKL7faQduHNDiQzFYQlvAdWeS/FWo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=oCLiHFmj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="oCLiHFmj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DA8831F000C4;
	Fri, 16 Oct 2026 14:16:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792160179;
	bh=EYF+DTwlH8HG9GT1oym1wNouDiZbeB1gOJePvU5XWpM=;
	h=From:Subject:Date:To:Cc;
	b=oCLiHFmjIFM/hu+YAhm/20vFgP4cULa4VOOZw0JEh0Z8KeED16KZyXj5pBnqB++ji
	 BFf4A7LStJPST+AK8w4K2gXIQ9b8L4jV7/KwT4692X9OthYmWYbconyRcfnagsIN6m
	 49MDaHbdOg1hS65JoXtsTGnDDS08HOdvo79mjYmyX4aNQRcYSvaHKd4ACZA6v4SRDd
	 VITm12EtqdfRbFuvp92j1jA9dr8+9OsPcmgruGxxFo1+2B5LhxhJ3zyFOGNDkUtxmx
	 qkfsUmFhRgIVTuriUB3UeiALMppTkTqQpdFsXecHsBRpu7Mdm4/tBtH84XEruz8Ihu
	 B2CaxonybjcqA==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH nfs-utils 0/7] mountd/exportfs/nfsref: netlink loose ends
 and bug fixes
Date: Fri, 16 Oct 2026 10:15:36 -0400
Message-Id: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MTQqEMAxA4atI1hNoqxaZqwyz8CdqUFJpqgji3
 S0uv8V7FyhFJoVvcUGkg5WDZNhPAf3cykTIQzY447w11qNQWlkWlLDF0GNDZdfVlRmc95CjLdL
 I5zv8gYyKe+JV4X/fD1p3qOhrAAAA
X-Change-ID: 20261016-netlink-noproc-8e3bb540d266
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2010; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=aZx4B2QBHHQvaK2E2Gykhed2yxyn4ytCAuCqJQQjtpg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq0jGq878Q1JtwfZYvEus52jDqUtYF/DAtLLQzd
 TEXvBaNfEiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatIxqgAKCRAADmhBGVaC
 FXLND/929b90Hd7E+/0VwC4LNhLRPu/86RiyXKGwe9DzAMpFJs9+ixwa99VeNFaQFLuGB1Y6W3l
 QHOgY9nsZGBDb55lspGi3ie39vAathY51zUiwBR4bvjgRie0yl8qef9I0OxuycaH1IdTmwXdx6C
 FgT/SB92mbAzVQFex/LK9kEGdqlwFAqebU3IFmjhLwGta9lCl3BEWO5zDBPyt04y+p8uJgL1iaf
 uMxH+qv4bxilq9ErNHIBpgsqDjdFiLT2tHIDL9Onyo+CelTX4gyc6JPm8aqwZZANggxk7WC5S7K
 UF2XBZmd79UztURBFQTZkES3kNtgida2kJmj5RhYySG9ViYISLS1/rnjDkFNtnuZW1WXa4vD/gZ
 ZDzaKlxkAtIuyRflNrpnGtg25oIaqODXuvo3G84w9g9apWHQlP2IqYxn1dHMm019izNnTr8Dyvj
 WgtzJANdyzGVlbXs0pADy6Ozy18G5eugciEtOH2/HuaUVuleWOhF1lBWZ6nH4O90JRmrfLxMLFt
 zbh4tNS71dRFaGxa+6YLe+dDQVROgbXOFkbVAgZ+c/7BlThGYEWnbg0mRLCCFXvtlqyW7wTm7ot
 b3ur3oNaBmkhGxBrTOmmyw0DXGjSXXItqt5Xhm87w6UWf+f+MUwZa0nJS1T4/7UxsLX5cqtwqZV
 KJ0aDH5aVIWwVYA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

There are some cases where mountd will use /proc even when netlink is
available, and agentic review of this code also found some bugs.

This set fixes it to use netlink in more situations when it's available,
and also throws in some bugfixes and cleanups. The last patch in the
series adds a MAINTAINERS file and the machinery that allows b4
workflows to work properly with nfs-utils.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (7):
      mountd: accept -L for --no-netlink
      mountd: prime the kernel caches over netlink on MOUNT
      exports: describe the kernel's export features with struct nfsd_export_policy
      exportfs/mountd/exportd: get export features from the netlink policy
      nfsref: flush the export caches with cache_flush()
      mountd/exportd: always give pseudo-root directories a path-based uuid
      Add MAINTAINERS file and get_maintainer.pl

 MAINTAINERS                     |  58 +++++++
 Makefile.am                     |   2 +
 configure.ac                    |  24 +++
 scripts/get_maintainer.pl       | 375 ++++++++++++++++++++++++++++++++++++++++
 support/export/Makefile.am      |   4 +-
 support/export/cache.c          | 124 +++++++++++--
 support/export/export_policy.c  | 263 ++++++++++++++++++++++++++++
 support/export/v4root.c         |  22 +--
 support/include/exportfs.h      |  15 +-
 support/include/nfs/export.h    |   5 +
 support/junction/export-cache.c |  82 +--------
 support/nfs/exports.c           |  47 +++--
 tests/Makefile.am               |   2 +-
 tests/t0003-get-maintainer.sh   | 101 +++++++++++
 utils/exportfs/exportfs.c       |   2 +
 utils/mountd/mountd.c           |   2 +-
 utils/nfsref/Makefile.am        |   4 +-
 utils/nfsref/nfsref.c           |   5 +
 18 files changed, 1007 insertions(+), 130 deletions(-)
---
base-commit: 5090e0bb662c53b4552b28b121ac2c2c434adb2e
change-id: 20261016-netlink-noproc-8e3bb540d266

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

