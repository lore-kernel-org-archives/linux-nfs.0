Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795105363;
	b=tsQy11LFjGOeZjt4DDC8G3p13YAU8hA3V3rhr8hb6Ww1XerIDe/ReoCI0IZobUOLAxKG
	 05poKbF7SIy8w6H1EecdNtxBlzwBOHW3z1+csDMBI8oSlfa5cE65ecIZijjFjpl36SEDt
	 ffXcfP1zlh9coaoin2FcLJyZR8iCtw91dQxILNRLvyerPY/pAxlnjFnYsHc6PQK9LJGUy
	 EzIqXBlvS/8g7xvxQSU+rvqRNlLPOvfR8NPYzEgqtUi9yzWqt5w5N1WybbBzkg9wINIJS
	 pQo8KKOh/nbsQHoyZrgsh6sssty44X6WFSyANHk8YjXfmAVk/0l0/7+srzwL8XgrS4w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795105363;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=JYrk4VAUHfTSUyCvYz1otc/07YDf8u+vR6+XMAZTSkA=;
	b=FuJVpU/PaHwtKTuptJ7fF87u+FsRgELlrK3gSR7Jlu2UlzLlrev/EWARztVqJX7J7fU0
	 rUxId6QImkGQGYtexN6aT7jvMJ+WdDxi/VkjdLNvg/7qIeG8NOAPRkv4onYrE0xO6dfif
	 WwgPwzDSfdW2YnSMbwQm1qY8QWaUZhfjNA50QJ5NrylfVlV/k+DSBMDpRGYeLfoJDDeuC
	 CBauKROvwj4Y2hj7hxXJZmB/dpTODc0gY2fWv1pKma76zRMvXzOkydCympTXZqetURFoH
	 z6NuL7jkbc8yCUiJU+Ntk7VJOUZUZz7Bh2nB4Uy4cB7bOPkhxHUg/RYTNWMRBSzM8Cw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CP6bEuRv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30112606A338;
	Thu, 19 Nov 2026 16:22:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CP6bEuRv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A68DC1F000C4;
	Thu, 19 Nov 2026 16:22:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795105362;
	bh=JYrk4VAUHfTSUyCvYz1otc/07YDf8u+vR6+XMAZTSkA=;
	h=From:To:Cc:Subject:Date;
	b=CP6bEuRvSYQPSspsW0MmluMIZyo+y/ms/jYluZWQkLkPMbujdRW4hnrhJzfe8mmAw
	 BS0YvpyayTL6XDZMbpch6FLurwELbo3k89Z8h5ZYUD2OVcVri7D84Hs9J2pTt39Eof
	 50vnXSlCt1qPrCKOn0hbGcVH7xYwNDwL7MBbXWkN3RmuckmpTGRmu6aWrAoaSZZkmt
	 puiivNFo0eSxuqgZQ2Ul955AcSEj+i3tpLfLGDPaROP23+fMPh7EhnFHvO/n98cAGo
	 O4hbadWQkNs1YimdysqUlQWUwubgDQVE3XKVwyTQRT0NmM+OBBxIZU1hZFWEaWcVNy
	 ffVEj+bpGfKlA==
From: Chuck Lever <cel@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	<linux-nfs@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Subject: [GIT PULL] NFSD fix for v7.4-rc
Date: Thu, 19 Nov 2026 11:22:42 -0500
Message-ID: <20261119162242.1467-1-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The following changes since commit eafb6de800781f0a1be5cdd98d150620041d8b27:

  SUNRPC: use assign_bit() where applicable (2026-10-11 23:13:07 -0400)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.4-1

for you to fetch changes up to 1ecc5b7c95ae585042ccbf3c587897dd99e2ddb5:

  nfsd: unlock the locked parent after crossing a mount in CREATE (2026-11-19 11:14:13 -0500)

----------------------------------------------------------------
nfsd-7.4 fixes:

Issues reported with v7.4-rc:
- Unlock the correct parent directory after CREATE crosses a mount

----------------------------------------------------------------
orkunsari (1):
      nfsd: unlock the locked parent after crossing a mount in CREATE

 fs/nfsd/nfs3proc.c | 14 +++++++++++---
 fs/nfsd/nfsproc.c  | 18 ++++++++++++------
 2 files changed, 23 insertions(+), 9 deletions(-)
