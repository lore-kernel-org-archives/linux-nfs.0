Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B8B7472F63;
	Tue, 22 Sep 2026 11:34:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790076861; cv=none; b=sE4hL3/etmUASAoYeGd92lgixx1KtMvDoDijBkMrBZLQUQvkEhvW9eA6mNKuY8v/IhV+nBupQF4eQnMqyLImQFOhxNny7ljRgpJrVyELQvRDBkw5UlkkuvWcVb0HywDCXBkZKpJLnDjlxEIiJEJfUroMUGjT07GaDV9exuk17Wk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790076861; c=relaxed/simple;
	bh=tetoouqKM6x3srM9fS0s9Rmg2CTzXDOW9oGLZrjQ9b0=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=fdducSPdxX8qLPPnXwCOgRWI1uf1DRG/sdNYACSMDTa70wtkRWC3jcqccu1N5EHBAO++pY9e6bD12YEQ6v2LCQpnlo0DNdkqkNgqJAAaEb99SpLQSn8n7M6ehth54btMmcuX5opSluqWWwmFz+KHp/22utzP72LFfwdvcuoadnQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nBbEb8eg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nBbEb8eg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A0B231F00893;
	Tue, 22 Sep 2026 11:34:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790076859;
	bh=8MPz51/AleVqrB9iFqCx4mq9xp/agFzW+2KTIHJEgnc=;
	h=From:Subject:Date:To:Cc;
	b=nBbEb8egguabqjrVzmzMNSUqdTo4bs3RSq/ArplsVaIb9l8ajUQvjFAb2oU6RmhIp
	 EAwH7TV+CMZoiAYuGGY93rxNfPAckENr/+b+pVy5U9CP7pAhF+gHbljxwB5K/wczes
	 WGiCwTSfhrpCVgVkh8FU1H1tnCZvRziDJcWAnX7mixtltlhuQC0L4j9d6nSqAxLHsH
	 7PUd1WkNFryhNeH4AexvPsjlyzIeXN2OwIVLzVL5wXzSaI073WRlC4myWq6iTEFoO+
	 JAuh4XFgjpI6NxlpnMlumOIZicSlSahXtENpqc8FDoASPyfWoggYTnMLMM180z8LCv
	 gFp7uN6IGp7Kg==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 0/8] nfsd: reduce the scope of the nfsd_mutex
Date: Tue, 22 Sep 2026 07:34:01 -0400
Message-Id: <20260922-nfsd-per-net-mutex-v2-0-4a5da8243a73@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22NQQ6CMBBFr0Jm7Zi2aQu48h6GBYEBGrWQaSUY0
 rtbiUuX7yX//R0CsaMAl2IHptUFN/sM6lRAN7V+JHR9ZlBCWVHLCv0QelyI0VPE5yvShpU1prS
 61qLtIA8XpsFtR/TWZJ5ciDO/j49Vfu0vp+S/3CpRoG5LVZWDNUJ31zuxp8d55hGalNIHe37fg
 LUAAAA=
X-Change-ID: 20260918-nfsd-per-net-mutex-8655764940ac
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2996; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=tetoouqKM6x3srM9fS0s9Rmg2CTzXDOW9oGLZrjQ9b0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsmevVh/20L3zjeMpksNMAyjJxwaz1PW6OTxRa
 VOFxrNJDHOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarJnrwAKCRAADmhBGVaC
 FVKPD/0aXeeF8iIti+pN23JOjN4G9uIdYc929dgtr73TPjJz8Vqljs5vAUixQjCAdQRAz7S4N9r
 ehBrJZsYj9hP0F16EoMA61raWO/5TxAWZQvctIj75w9Ag+CP6YbsG1h14WaId6FlCaSU7HhK1HG
 zDg2/U6JUJslKssqx5HgPc7eFeTQn+gClHKPXUWwB+zA7/c/GoqAjFxtRsDEj1DLjU7vB1YLa0/
 1fcU6jWcNVpvelHzpTqZbVdfdyXSULuNgd8H70Kx1dtPjFyUKTn1bKIS4kvGvk1udgrVe7trwC5
 Xfi9ewRVLAGLpHKPwWvMWXjhEVPYbrpqwXMWLn/m2ZEuI77/nUS/kG4gVrFd+bfO3EEXXGSfxP0
 dcPXuhoHipraKPJHRtLIjDpI0u0bu2EEQvtyD9LmYN4i7zbytSLusDChqIV26z9rxs9f9soM/TU
 apuk7xjDG+NtfFoI9oeQ3vtyCJ97nvpkxqCLgE5v73UHVXw6KYP7ePYol+6FIJijgWR1Yr5/G/1
 cn3Y0sTf+Cgxr43AVfH8xZ8YeIQ5DbFCq/cPkj9SzjMPEOR/nlq7NFBvkiF9UNjzgICvlEJolS5
 aHfldJ+XGTwATx9xPu0MvfKiuHQ7/e1fe83kz98fSBbvFVRFAGyuMrcE+9cKbzWbS29Tx23jZ9Q
 sYd/AjoU5ABocjA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This version fixes a couple of minor issues that Sashiko flagged, and
also implements a suggestion by Neil to use guard() with the new
filecache mutex.

Original cover letter follows:

-------------------8<--------------------

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
Changes in v2:
- Fix potential deadlock in cross-namespace isolation selftest
- Drop binaries from selftest patches
- Use guard() in nfsd_file_cache_init()
- Link to v1: https://lore.kernel.org/r/20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org

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
 fs/nfsd/filecache.c                                |  26 +-
 fs/nfsd/netns.h                                    |  16 +
 fs/nfsd/nfs4proc.c                                 |   4 +-
 fs/nfsd/nfs4state.c                                |   8 +-
 fs/nfsd/nfsctl.c                                   | 129 ++---
 fs/nfsd/nfsd.h                                     |   4 +-
 fs/nfsd/nfssvc.c                                   | 146 ++++--
 tools/testing/selftests/nfsd/.gitignore            |   2 +
 tools/testing/selftests/nfsd/Makefile              |   2 +
 tools/testing/selftests/nfsd/config                |   6 +
 tools/testing/selftests/nfsd/nfsd_netlink.h        | 319 ++++++++++++
 .../testing/selftests/nfsd/nfsd_netlink_listener.c | 301 +----------
 .../testing/selftests/nfsd/nfsd_netns_isolation.c  | 468 +++++++++++++++++
 tools/testing/selftests/nfsd/nfsd_netns_stress.c   | 572 +++++++++++++++++++++
 tools/testing/selftests/nfsd/settings              |   2 +-
 16 files changed, 1592 insertions(+), 435 deletions(-)
---
base-commit: aeaddc6a3711283c09a9183068897d4fe1fb464f
change-id: 20260918-nfsd-per-net-mutex-8655764940ac

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

