Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795007802;
	b=s+HVcvVlA+URfv2dcK50zoWt7VsPdv5G2rVwJXBuZz14/7X9etVFMbl0iXF/w2D9byKt
	 JeZiRdc3As3pYTGu7QAiLbwC1Y52om+ux0Sfxej9l+5YN1b2SrSCiNrGeLCsrZnvZHA2n
	 nUmwkh4vA/lr2HXzqjmBUVFPW1Fd1cwp0ndkTSwXghCM3HKDtFCpe5x+sWmiQCzInU5rq
	 vBRYMZrjomFZe/jEIPsw2Dcx780ITT7vM3f8Otd2zty95n38L6GeWbYhFa1ydZLQWs7uA
	 IIRFDGo2NR7DpOtlsFayt9GmZfU1z3rFDrdhJ9YhuIhImWJ9gJUQ9DnOg7/Ie2rrjXw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795007802;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=hB9UzleAIkWHJrqq6SqfTW60PW5YtSUer1QfUULJtCg=;
	b=0IPA9dnc5pUZLv27CV5QA2DUvVXdpUPPZ4Fc+ja+GIVIaIGXw/5SagUQzTuGEZXYUQck
	 V/d2KXYV8lMngcu7ZPde615cBplJxeSiLfuQa3XW28v/PfrpIcUvph6SYBfTE0XUsyi4d
	 nvJ/pwDIc+zrhV6hPYwOVGxDKOtU5BwhqQvM8MiHv4PIoTO7cXn5H1JjfDyiXAO8SmObn
	 L+/+pA9rp4LAwwO9fdhrd+c/PMKFTjOdTo6BNg7uH2BTPaiXwQPcWd/ptT47m5vLV6hFc
	 r7gzAE3EDQ2S6J2uxJ6ruR1EBq9dy14ka8RaKZNStoFQWYL++mcyao5vTksiroISCPg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CKbNLiOt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7595E606A32C;
	Wed, 18 Nov 2026 13:16:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CKbNLiOt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EF9191F000C4;
	Wed, 18 Nov 2026 13:16:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795007802;
	bh=hB9UzleAIkWHJrqq6SqfTW60PW5YtSUer1QfUULJtCg=;
	h=From:Subject:Date:To:Cc;
	b=CKbNLiOtnQArVEW7ZPUs5wZ+GoPNnxHHl/IA4Kigx1MdiDJYsF/TfqkvXPOnrf4QS
	 CLMJekPxNF+BXbpTwHJURn1Mq11paeCU7zbXP4LDsBJjscDxBtI4/V2wjLx/Mag3ZV
	 xwuOMSzYbIQpR0xnJjPsx5g8QPO38nioygtWcsZpG+T//MY1y13oSF3ims58wsElcy
	 tP+1JUwKodT9MrGypya7bHV+k6A1JKOcnvoia2U0F0UVKXQsJhQM/5iG89E5+n1qJm
	 U6BgZy0nRf2q2/dVq3JXp+WuiXBF5U9IJj343bl5reWMHPfrYsbf9PQElZMmuFu2MH
	 CVr0J62YV7hMg==
From: Christian Brauner <brauner@kernel.org>
Subject: [PATCH 0/2] fs: reintroduce SB_I_MULTIROOT
Date: Wed, 18 Nov 2026 14:16:16 +0100
Message-Id: <20261118-work-nfs-multiroot-v1-0-66e4458b7d32@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMyw7CIBBFf6WZtWOEGm38FeMC6GDxAc0MrSZN/
 12wy3Nzz1lAiAMJXJoFmOYgIcUCateAG0y8E4a+MOiDPimlOvwkfmL0gu/plQOnlLHvNLXt0Z2
 10VDEkcmH7z96vW0sk32Qy7VUH9YIoWUT3VCn2ct+M9b1B1jiur6SAAAA
X-Change-ID: 20261118-work-nfs-multiroot-d82e334c72a2
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, Amir Goldstein <amir73il@gmail.com>, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-04696
X-Developer-Signature: v=1; a=openpgp-sha256; l=1477; i=brauner@kernel.org;
 h=from:subject:message-id; bh=XolEZKg0n/Jhtb65dQs63UYEaAuPALwcP0dpFXFAw8w=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9XWrUqrbmPm/HHZ4/FjXZf84tbVx2+3jSmph9+btuu
 /ZW8nxQ7ChlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZhIzxKG/0V/E3tevQu4v/1o
 0rQw9+DanwKBYvbPz+TuLpQvbXhueZXhn66QaSL/n6UTk/j5NDKkZ+UI1E75H+587nvlmeZL99L
 E2AE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Welcome to 2018: Since the nfs conversion to the new mount api in v5.6
".." can escape an NFSv2/NFSv3 mount again when the client shares the
superblock between mounts of different subtrees of the same server
filesystem.

I reproduced it in a VM with knfsd exporting a single ext4 filesystem
and the client mounting two subdirectories of it over loopback. On
v7.4-rc3 ".." from a directory that got moved into the other mount's
subtree lands in that other mount, from inside a chroot as well. With
the first patch it fails with ENOENT. The first patch just restores what
we had so it can go to stable easily.

While testing this I noticed that the same setup trips the warning I
added to vfs_dentry_acceptable() for open_by_handle_at(). The handle is
correctly refused but an unprivileged user can trigger the warning
from a user namespace if they own the directories. The second patch
uses the flag to not warn on multi-root superblocks.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Christian Brauner (2):
      fs: reintroduce SB_I_MULTIROOT
      fhandle: don't warn about multi-root filesystems

 fs/fhandle.c                   | 6 ++++--
 fs/namei.c                     | 4 ++--
 fs/nfs/super.c                 | 2 ++
 include/linux/fs/super_types.h | 1 +
 4 files changed, 9 insertions(+), 4 deletions(-)
---
base-commit: 94ca49563acb36a19fb578499b04c84d5b0a5181
change-id: 20261118-work-nfs-multiroot-d82e334c72a2

