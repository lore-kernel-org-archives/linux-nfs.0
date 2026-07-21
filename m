Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 840A92DECDF;
	Tue, 21 Jul 2026 18:15:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784657747; cv=none; b=mXDF/91wq0kXyyFx2Bj9HNMtR0ZRXuyNvRrzCm4RLf0I4CHkq7yxwj2tZh5hPg4aiGiuky5aBR7hDqWFWzwSWCOtN4n4nIHZZjJ4LSL956oAGkoYuX9ksx/baY2DqAa1L+1rY1rcInCo0v5U7+Ux8TlkpgZ6EupTb33MDrfX8ig=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784657747; c=relaxed/simple;
	bh=ddFCboniD/jWZBmYj08o2b42d9aNyWU0H0GfxkVW5OM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=P8JIszjISs4xLrz6uhTXe+wvXYWRthnIGqqCBhUaRJ8wSG8lyJeUlJQW/kNOGZYc2RJoYmpYrQUv3DEfhsF44e5dVgBcVbfoT27dpXDFv7h50jo6Q6ui19tPyZyAj+uOTYgjQArNJTBHogUOC/dBsvu4jk7PvX8btxIgmyTh2xA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=L2F8tA/1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="L2F8tA/1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D3A011F000E9;
	Tue, 21 Jul 2026 18:15:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784657746;
	bh=rpEOV0Ama/FTldXxmGpDQNYrkByl2RCKiuBP7lW5rJk=;
	h=From:To:Cc:Subject:Date;
	b=L2F8tA/1NywIs1Usv6uU6U3M6mZZvJZjzS6qjsdtzxowpoY+cFhApJTLfAUZkfDbI
	 WrI1eelQNsXoXGyvL71KeJurProIqPZR3dSYyCF/u/MAYdhMURp6XMRcT9y5v/jCbm
	 IcdXPVYz7Ih04XNoRWIeEe10UuaOwD9UjwG1X2DSZhKIvqnA6WlOorC+MlBM3A5tVn
	 cnJQ56rrFSn4tA05aAJyXMn80+0iDTdM8iEc3Nq94dq+ByVtEuRBB+bl1bh92jC4I6
	 /OB1dnz9RL9PF6e7hRkBWfrtyYUPfcPemGmQmvRkkBnKGlzhi7Vqb8IAZkHUhsiWAY
	 PWf2+iS6QdjWQ==
From: Chuck Lever <cel@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: <linux-kernel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [GIT PULL] Another NFSD fix for v7.2
Date: Tue, 21 Jul 2026 14:15:44 -0400
Message-ID: <20260721181544.3048006-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The following changes since commit 92ea163c773cb4d0d5eaf103ed80c49d6758b96f:

  NFSD: Prevent post-shutdown use-after-free in NFSD_CMD_UNLOCK_FILESYSTEM (2026-07-05 21:09:42 -0400)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.2-2

for you to fetch changes up to 5c4851e4cdfc3204128f88991be64a6e3929d3d0:

  lockd: fix NLMv3 GRANTED_MSG handling (2026-07-17 09:31:50 -0400)

----------------------------------------------------------------
nfsd-7.2 fixes:

Issues reported with v7.2-rc:
- Fix issue with NLMv3 GRANTED_MSG introduced in v7.2

----------------------------------------------------------------
Olga Kornievskaia (1):
      lockd: fix NLMv3 GRANTED_MSG handling

 fs/lockd/svcproc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
