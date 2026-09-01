Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3AE984A2A5F
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 20:19:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788293998; cv=none; b=pHg21WNhJqzq1X44gypJj/Lyf/XqlroOD91pkm3zsV7RdBJx1PqrzKkCqcpB5rjU1TlFpkDj3G7yuJs5MF8fOVjBvkhFU5Y9HX3Y3CBI2Lm0sToh82HFqJfaKIfv/Ai3oXpNtdCVNXlRI36btc81HGhUJTlxYUWYhoPXPMFiEHk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788293998; c=relaxed/simple;
	bh=QagBxvQYnQSPjJsoXuKVKcwlQAFPp3swfYwZy6ZZRg8=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=PxDc2iTfuCpqBXYvbau8cDCzXaBRSl99kJMEEbpBqIEYVYUnhv2Q0bfnWZJVwe4cV9e/ebSI1ICKDCHJFBoeHO1wPGiZbXWuH/3iH61/DK294FRrLxbHPsOlXVfxvo5JIQ+d8RVdzNKBSt1MS+Nf4R/XhZX0oNPP2hoxCCBJYkg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AoiMUC+U; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AoiMUC+U"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4408A1F00A3A;
	Tue,  1 Sep 2026 20:19:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788293997;
	bh=aoCNlMqVhBQI28nIgJMoGDDfXrSFX/+EkTDwo4An+OU=;
	h=From:Subject:Date:To:Cc;
	b=AoiMUC+UPJ+vrmsQBrHHr7WLeER816XurvO90OvsnAjjBaZhflI7JE6HH1wgFvy4D
	 +S34a9KM1YeJE9UY52XO9ijG5PhsvKjlu1FE71kcBRJNszJ+okzGSqWrBge013LXhg
	 Qj5dz0PXbJaldQsBeYoIrjJ0iPpFpNOhkrFwFe/IrZJWQ34JFqRKSPkeNq8OTZpBYZ
	 Cbk2uDvPnMey0TrsS5Vn2XxpM3OnJiBxlZameppAwp3ZK3QtMwB1CEERIGsihMcNhn
	 Zu33e6b4/LoisVMXYs3T1Ua4iTJz2uPIHe+iLp2Ri5U0swj6nmkiAGFzaSicNsWdeJ
	 KnaCbipUKmQzg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v2 0/8] Fix premature completion of rpc_pipefs upcalls
Date: Tue, 01 Sep 2026 16:19:40 -0400
Message-Id: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/12OwQ6CMBBEf4X0bE0pSFpP/ofh0NItrGIx3Uo0h
 H+X4s3jm52ZnYURRARi52JhEWYknMIG8lCwbjChB45uYyaFbISqBDcjPJA77Wsp9KkB5djmfUb
 w+N57ru2P6WVv0KUczg5rCLiNJnRDloInxxNQwtDn84CUpvjZd8xlrvl/OZdc8LqpvBJWgzbqc
 ocYYDxOsWftuq5fl/vZOcwAAAA=
X-Change-ID: 20260830-alemi-d9f420956e8d
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Scott Mayhew <smayhew@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Farhad Alemi <farhad.alemi@berkeley.edu>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=3218; i=cel@kernel.org;
 h=from:subject:message-id; bh=QagBxvQYnQSPjJsoXuKVKcwlQAFPp3swfYwZy6ZZRg8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlzNh0oc2/TaxKpc+lEROX333zZE9NagHWeNNF
 JcPx/iuT+KJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapczYQAKCRAzarMzb2Z/
 lxWiD/90zTa7eRu3jAEQNyvqWgxTroZSqOXso5ySvLbKKflVMr+Qf5s1XfRj/bVXfy8jtB6lqei
 gxKHjoAVyi06UfIdLPqSDCLGkL0n3u9kuSZEkersxS2KlAhRkX+G37OBbbN3JAHe4SPQUHatMos
 YVYv7a1DKZx34vJnY7mQ1aYcvff9FsHm/W3A4b1Fu7F6B3rRB1brbRxdzA1Dc06IBbHyaEuIHlt
 C1ZtqMF3nNpoLorxhKYNdvbmxaTUTH6NcNsEpXoi/bdI3DEmbCAmiP2Uzc6GVDJvXu41T8KZZ/C
 6DDG+DoGc+72WxCaxrXlxIuxCjHuP6bf5iFRZFFaCylHrg4fCFCBMvDpybhaDarnjENQFjIQMtE
 fhrq84k+SXAqtUKNC4lL8JM2DWe/Q1ntH8nscK4HGjDU4ttP7efyGFcyTuLI4lbM10K5daFP9EZ
 oLuj0Imki4AHfELHwvJNs+adcsj0Hn+K95mPnYz3Bbxw21MYOLzAfT2Y4/HJ46sP8itZ5SFrfRc
 w8iMmngxEeltWyRJstb5VcXhpIVpHiMrhmAYrsjjv8Z/nKckR2bmwC75gtltuyjL9oJICaCb+25
 AoFAoxy5wxa9mPK3VUtEqQN4+vKNUBYNUi2t9saoG0UioYcOibhaHlLJAnjkiDT1No4qcDCLeST
 GEqipjIfzg1s7gQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Farhad Alemi's syzkaller run against 7.1-rc5 hit a KASAN
vmalloc-out-of-bounds in rpc_queue_upcall() while NFSD was starting
client tracking:

  https://lore.kernel.org/linux-nfs/CA+0ovCjVF58WLeen2ctdzHyWUASAAW3Y=Yjihyq0pFApYawtDg@mail.gmail.com/

The cld downcall matches a reply to its upcall by xid alone. If a
write arrives before nfsdcld has read the upcall, the waiter returns
while its struct rpc_pipe_msg is still queued, and the pipe is left
holding a list_head into a dead stack frame. The blocklayout device
upcall has the same bug, plus two of its own: the waiter can go to
sleep after the reply has arrived, and a reply left over from a
purged upcall is taken as a fresh one.

Guarding the reply exposes the opposite failure. Once a daemon has
read a whole upcall, rpc_pipe_read() unlinks the message from every
pipe list, so nothing the pipe purges on close can reach it. A
daemon that exits between the read and the write leaves its waiter
sleeping uninterruptibly with no way back. bl_resolve_deviceid()
holds nn->bl_mutex across that wait, so every later device
resolution in the net namespace blocks behind it.

rpc_pipefs pipes are mode 0600, so the writer is a daemon running as
root. These patches guard against a broken or hostile daemon, which
is unlikely. I consider the series as hardening rather than urgent.

The gss and idmap consumers keep their message in an object that
outlives the upcall, and gss also releases what a departing daemon
left behind. Neither has either bug.

The application order of the patches matters, so I'm happy to take
the lot through the NFSD tree. An Acked-by: from the NFS client
maintainers would be great.

Farhad, a run of your reproducer against this series would help.

---
Changes in v2:
- Retire the upcall on accept; drop the racy completion_done() test.
- Retire a purged upcall in bl_pipe_destroy_msg(), not in the waiter.
- New patch 6: set nn->cld_net before the cld pipe can be opened.
- New patch 7: complete a cld upcall when nfsdcld closes the pipe.
- New patch 8: complete a device upcall when blkmapd closes the pipe.
- Link to v1: https://patch.msgid.link/20260830-alemi-v1-0-463f80b9e9a8@kernel.org

---
Chuck Lever (8):
      NFSD: Don't complete a cld upcall the daemon has not read
      NFSD: Move the cld upcall message out of the caller's stack frame
      NFSD: Complete a cld upcall when copying its reply fails
      NFSD: Reject an oversized principal hash from nfsdcld
      pnfs/blocklayout: Complete a device upcall only on its own reply
      NFSD: Set nn->cld_net before registering the cld pipe
      NFSD: Complete a cld upcall when the daemon closes the pipe
      pnfs/blocklayout: Complete a device upcall when the pipe is closed

 fs/nfs/blocklayout/blocklayout.h |  5 ---
 fs/nfs/blocklayout/rpc_pipefs.c  | 79 ++++++++++++++++++++++++----------
 fs/nfs/netns.h                   |  5 ++-
 fs/nfsd/nfs4recover.c            | 91 ++++++++++++++++++++++++++++++++--------
 4 files changed, 135 insertions(+), 45 deletions(-)
---
base-commit: e3c3b1a8188b192b125ae1fc9861d9a5d8d43d85
change-id: 20260830-alemi-d9f420956e8d

Best regards,
--  
Chuck Lever

