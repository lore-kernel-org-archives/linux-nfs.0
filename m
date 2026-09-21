Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71910492E5C;
	Mon, 21 Sep 2026 16:31:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790008318; cv=none; b=FnTjdHoxnfZxN5dszrZ9h1uZn6MT+jb5Cn/0VbRGdV3WydAkWZSNPq/hoVbEArcDYSmuQQmykaNosybkBhSsvJZJdbhcSx5MWPynrgepTe1Yr6E593uvtrUZWPKAWNI0K1helxWi3d0kjYpz3yIFs3O3w7YvlWj6xLN1RxpmTrQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790008318; c=relaxed/simple;
	bh=ofYRUACXIOHSiN7om7I6Mv56G8lMIVNgty2jM3XLfQU=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=hyHNr2xtXtRz1Tx9RSdv/bbFkDihRPmdwN/EfOUTxh/a4Kj3NYgTM2E8DGTkZp/0IYxOJC7H8I+AVKEnwbwOHp0lQH+ROcUvEdlSLDGE/RUDw6m4vnYsk4VgbnlRl/7XlsrnWoQ3eh54/Ing7i7t6VTXvKQajzUNMPeX6DkLtMU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=j/saWYIY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="j/saWYIY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 937411F000FF;
	Mon, 21 Sep 2026 16:31:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790008317;
	bh=pAiVDjQnqANbx3607JY0pUpg6KKkPEJMDRzcxM3nW7w=;
	h=From:Subject:Date:To:Cc;
	b=j/saWYIYjq5sUJehueZKK7GdoA05qXpCTj2kMexI58tZAI8829f2vYdX5/lM168Yq
	 iOn/ZBRek9YJjv0OY20QHUetwZKsW5jKpOujViODAuDh/WbqKQZOrkEvN8aE4N6k7D
	 LUkFFrCN3XnOCkkHFOT0mPfVtvjnj+dgDrxKrTpxksQHuC9OFT8ZY6ByFWA7XYILrF
	 iKU2vu7QnnQk4JmSVEBbJ0ia/vWtwn4qK20FIp6BGjRHcS/ydbltMd3os++/iQeM5C
	 5juaQx8gIVhu++A2M3Y9YG8+bKsQ9+Zi0JyMLaXIhhpPiiO5AtaUmNfFloMJC6eKqD
	 wdqKjZNDrz5KA==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/8] nfsd: reduce the scope of the nfsd_mutex
Date: Mon, 21 Sep 2026 12:31:39 -0400
Message-Id: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MQQqAIBBA0avIrBswKdOuEi0ip5pFFmoRSHdPW
 r7F/xkiBaYIvcgQ6ObIhy+oKwHzNvmVkF0xKKm0tLVBv0SHJwX0lHC/Ej1odNt2urGNnGYo4Rl
 o4eefDuP7fkWP/h9kAAAA
X-Change-ID: 20260918-nfsd-per-net-mutex-8655764940ac
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2585; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ofYRUACXIOHSiN7om7I6Mv56G8lMIVNgty2jM3XLfQU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsVv2sn0sYvYPH60kiVAUObkBX8v0rf15p6kuk
 /MJnwqcCBSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarFb9gAKCRAADmhBGVaC
 FbC9EACgvHROzNFS6rLD+9j1iW23hBZvcHtAODANSM99p073rBysfBmp15Fs61PwatzA7WtEsqG
 b/CkaNCcpB7Cz5IDZ1DUEULYGBHO1aVvMsP6r9WMCOgpPJFmtNDO++Hhv0nG1/621g09KKncVGH
 2RoWKS0yI905zrt2ZN04lHyySPLsnQhUNiJLh2oXmxMG96vkPsdrQgHb6GJxctA97GnbeheQB2V
 4WUPUWNcsdH1fovsqsFT7oSscZ9XV1mqDqZF5zr1BbYxPRIO3W+pHmdJJuk4+HiOLtNm8dZ9NlW
 mOtfWGq7Anrb7Qlvfbr1oe5N3wBrg4wq6LDiosMNy6pyT6JHWjSRfpGdDKQzfffjzbSwMhGxgyT
 8NOBaF70lGXgZOIBlx7YBA5PyVwUfmues7whfSHdFpSVrT13xWzChO78ec3TC2J77FK0YmP6jWF
 LQPDfEmf37e3LXpl9uJo2te4vpzQVmqJ8pm7LQsJ7EyEdwNuZU8NpTiYqMaUdHaRWi3n/p7Citr
 um/9QWgzGZ3A+JGAQEkgqDPRzFiKWzJoR0ONGTNZN98b/GbqLNUP3wvuCAMJPR1P2+In8H7egx3
 r8mK4ZJktgxeIMRrE6CQ2wh9pL6CyQ5czFld5Y43GStJNjkinDKX/wL3w8lSfIYMPThDYa3xS9H
 YWTREYNBQ1PdUDg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Currently much of nfsd's administration is serialized under the global
nfsd_mutex, even though most of the objects managed under it are
segregated by net namespace.

This patchset does a couple of small cleanups and then adds a new
per-net mutex and moves all of the appropriate per-net data structures
to be protected by it instead of the global mutex. The filecache is
given its own mutex, and the global mutex is renamed and left for
managing just the few remaning global objects.

I also had an LLM cook up some selftests so we can hopefully keep all of
this working properly in the future.

Please consider for v7.4.

Thanks,
Jeff

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (8):
      nfsd: clear NFSD_NET_UP before dropping the generic resource reference
      nfsd: make max_blksize a per-namespace setting
      nfsd: move the control plane to a per-namespace mutex
      nfsd: rename nfsd_mutex to nfsd_global_mutex
      nfsd: give the open file cache its own mutex
      selftests/nfsd: factor the netlink plumbing into a shared header
      selftests/nfsd: add cross-namespace isolation tests
      selftests/nfsd: add a cross-namespace control-plane soak

 fs/nfsd/export.c                                   |  22 +-
 fs/nfsd/filecache.c                                |  36 +-
 fs/nfsd/netns.h                                    |  16 +
 fs/nfsd/nfs4proc.c                                 |   4 +-
 fs/nfsd/nfs4state.c                                |   8 +-
 fs/nfsd/nfsctl.c                                   | 129 ++---
 fs/nfsd/nfsd.h                                     |   4 +-
 fs/nfsd/nfssvc.c                                   | 146 ++++--
 tools/testing/selftests/nfsd/Makefile              |   2 +
 tools/testing/selftests/nfsd/config                |   6 +
 tools/testing/selftests/nfsd/nfsd_netlink.h        | 319 ++++++++++++
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 301 +----------
 tools/testing/selftests/nfsd/nfsd_netns_isolation  | Bin 0 -> 49192 bytes
 .../testing/selftests/nfsd/nfsd_netns_isolation.c  | 450 ++++++++++++++++
 tools/testing/selftests/nfsd/nfsd_netns_stress     | Bin 0 -> 39232 bytes
 tools/testing/selftests/nfsd/nfsd_netns_stress.c   | 572 +++++++++++++++++++++
 tools/testing/selftests/nfsd/settings              |   2 +-
 17 files changed, 1580 insertions(+), 437 deletions(-)
---
base-commit: aeaddc6a3711283c09a9183068897d4fe1fb464f
change-id: 20260918-nfsd-per-net-mutex-8655764940ac

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

