Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4CB8A4E2F38
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 11:46:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792410400; cv=none; b=C+dhYzvIs70Z1NI0j1dftxMdklFlqaOCjSl33b/UoC8/CNnFAvlT0kNNrB6m8KuuJQyiZq58oX3BVUZdgRY76Q0bewcEt7OvzrAKnqa6IhOHPvtY7SyYkZYhacnir/n/WyK7iM8X/ulHubJK/S6mT5/qrJEzNQ4iR92S17IJj+c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792410400; c=relaxed/simple;
	bh=gFpDGvWSKjhPZk8D0f+umJMOiDhmEi3VG/Jd0eONB60=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=fJqao4BPkhryRLHOdwUfZcGEhoF9SDPyPyQE24TT5gtDRg1cxsAg6BM8xbbYjTBUfjr+zP6VsOAyRukNwOOKAO+OXPUFWFTj1/mF4268sYBNGwQrP48nHOYAQyiYVXD3WZ8byqU8pwe0Rpm4ZQLr/PEE42llnYsa7MpRVHwxUJk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MeObMwUg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MeObMwUg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 853C21F000C4;
	Mon, 19 Oct 2026 11:46:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792410398;
	bh=u3UyF4vZ3HlXstieOl7+gdGlfY67QKeSPGEx9NaZ29o=;
	h=From:Subject:Date:To:Cc;
	b=MeObMwUgXS6l2JJllfTv8hGdLgTwqBOPCgqxCqEMBlWeogzfuFUxzh/w3NlKAaAMU
	 9dKqFNRpsoIIsMy1oiW0cJFk4ABAi8LXykk4Gv8Ybuaq/lt3VQhjGSxn+aNZzWmI0c
	 n7a1KHgtcQH4X9c1sICG+qtwwnyx5WCHyZO6PguhKvbanusTazHUVySo7paSfUNNAu
	 CfKeoTaaDnUPOTQKYQia9cTbMpT7wprpm7JJNmH8Oo0N9qtsBs8Sv+tq/+yArs0/vc
	 s5aHyVK3p5r+EeQWI+V8HCPDNEvR1NQs333ZEtAsHD8mZxgP47jNSdLzdK2ZT7qlkr
	 F+Y03CzTW+CTg==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH nfs-utils v2 0/7] mountd/exportfs/nfsref: netlink loose
 ends and bug fixes
Date: Mon, 19 Oct 2026 07:46:20 -0400
Message-Id: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/3WNzQ6CMBCEX8Xs2TVthfpz8j0MBwsLbCBbskWiI
 by7DXePX2bmmxUSKVOC+2EFpYUTR8ngjgeo+5d0hNxkBmect8Z6FJpHlgElThprvNI5hLIwjfM
 e8mhSavmzC58gbcL3zGOCKkc9pznqd79a7F74Z10sGizc5WbbIngK5WMgFRpPUTuotm37ATkPm
 B+4AAAA
X-Change-ID: 20261016-netlink-noproc-8e3bb540d266
To: Steve Dickson <steved@redhat.com>
Cc: Ben Coddington <bcodding@hammerspace.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2368; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=gFpDGvWSKjhPZk8D0f+umJMOiDhmEi3VG/Jd0eONB60=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq1gMXrNlptuJVRNc1oRwDDQegXEXjTCZ5N3Gqq
 1NmrsBhGFGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatYDFwAKCRAADmhBGVaC
 FSE5D/4sCesgvkUwq1oZ4oSXN1gpNpFNiGXRYNWUEc/ixDCkLwHyjr3zt7hlLcIWO3afSfDemkQ
 AIJOBrVzfJzxWQzAO7jmjVG46A6O/tAz5/jq6e6ZrYRmDqZKG3+F+kTuKhTKyxdADCpVzfqfgln
 4g9JaVzqu4Z05nESIENiWmROsmdilloRFDZndNSzvPJlOSHfpbobhPwHyI/+kI+j1ci68LoOolA
 +sQNf+ZscrAFSG9we8zRnNetGXpKKAuG/xLUczm+6EFsOhIL1lyhRnM3pSqo+9FnX7GnV/e+l9Q
 Is1RcC1Q6kHCN9953vqFYJbA+YH7YVhB5Kp8DihPaIhOXCPyku4NMwATPD1YgI+pbEcLEb5iNmv
 0/92kFjda7BJ/k4I+ZonL90aCN5weQGzoo5pmalSMHCpUx1DJ/8sFNEL/dJhd3yDkrPYBySDrW3
 OkVHNiEJVZUOz8Fd9V6OAYPZr4fjBLuhAPxfltEINPhYHVbnWYcSedmCsy690tPMZ1UwPLj5EOO
 HQ2S8MJ3dZf1eNtWD0HqC0ZBANNxfsB9x99XMbR8k32/k0a7Bbx83qVJ7Gju7DmqoCYMjJxiGj0
 IWEW7Ki8A5l1g+EheX1uo/EihNpU+8lCyrFOBpu8lGSnjOqT8MVtbRoaaBILSM2swtwtRlNTBFS
 Utkh8TjsKiySyog==
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
Changes in v2:
- Add Fixes: tag to patch that forces a path-based uuid
- Drop the currently unused max_attr field from nfsd_export_policy
- Fix default value of $output_roles in get_maintainer.pl
- Use script location to determine top of git tree
- Link to v1: https://lore.kernel.org/r/20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org

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
 scripts/get_maintainer.pl       | 370 ++++++++++++++++++++++++++++++++++++++++
 support/export/Makefile.am      |   4 +-
 support/export/cache.c          | 124 ++++++++++++--
 support/export/export_policy.c  | 258 ++++++++++++++++++++++++++++
 support/export/v4root.c         |  22 +--
 support/include/exportfs.h      |  13 +-
 support/include/nfs/export.h    |   5 +
 support/junction/export-cache.c |  82 +--------
 support/nfs/exports.c           |  47 +++--
 tests/Makefile.am               |   2 +-
 tests/t0003-get-maintainer.sh   | 140 +++++++++++++++
 utils/exportfs/exportfs.c       |   2 +
 utils/mountd/mountd.c           |   2 +-
 utils/nfsref/Makefile.am        |   4 +-
 utils/nfsref/nfsref.c           |   5 +
 18 files changed, 1034 insertions(+), 130 deletions(-)
---
base-commit: 5090e0bb662c53b4552b28b121ac2c2c434adb2e
change-id: 20261016-netlink-noproc-8e3bb540d266

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

