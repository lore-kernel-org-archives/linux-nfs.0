Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 469E44A2A54
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 20:20:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788294001; cv=none; b=rTA/FiMHyQN+aBfpS1AwN7Rd+gLUrl873ro1HHwikiKwczIilBY0edDH7JON+yVtTUyBeA9+xWx397ntmgBnAxiy4SU1UkJKgTVkEzI4czKyB1FRzkQD1fFBW7zpC0w84CK9FXrcyQeKXFqKQ3A4XBBufbqcBFMIXTLXJC92wqs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788294001; c=relaxed/simple;
	bh=ScX4d7wrDRNhPQNJTEUE2yzLUg3bTMhPS9lK5qO+Lr8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Lma8tAdOEU9gSxWz1z33TORxx6cBhLtpouN4s77Lw71XJB7iEQKJ3wQw5vFT1LyRPTVBlIVXiKSMrUyrFuR5p6KGSjKCYKabDbKg6Ngv1IjKQ8aH2D6WRR+tWRPuMDUFiPQS/MZFgxQpAA06tkDW37URwzJv5YUB0ITyPFRs8sk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=P3FqukLG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="P3FqukLG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 620A01F00A3D;
	Tue,  1 Sep 2026 20:19:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788294000;
	bh=NPn3le1KJPE3zU07MZaLDFYFC+TK0PQDlVIP5jjzi2E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=P3FqukLGMVX3QRxlrWm+7+5c3RIH1l1KFWoASGu7bAaM+H1L292+DWexByxAjL3u6
	 KPitZtVlO7ag1nKZ0tQB00m9IAAd0MYNVQpsi+8BYWU5vRM2oMsqyFV9Ze7xpiKZHr
	 bdLjQT7boVGoTrzPOr6aLu8ef6AZf/r1d137Aj3a1YmfL++PXhiGxqZx1IWBMNuQg0
	 Bj5C4afOfD0fgyBJEet0xKDGXcgq4DmJtmHa+64qW899Xzg6Qdy3dwykpmMcO5DSWu
	 eo/ERY3afQDm6+g+5pZpFAo4+/gubBqdnSg4680MUvhBO+eLxNfYQOuhqotwEVjGzi
	 dNhOPZaEWANlA==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 01 Sep 2026 16:19:43 -0400
Subject: [PATCH v2 3/8] NFSD: Complete a cld upcall when copying its reply
 fails
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-alemi-v2-3-e163f94a3a6e@kernel.org>
References: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
In-Reply-To: <20260901-alemi-v2-0-e163f94a3a6e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Scott Mayhew <smayhew@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1467; i=cel@kernel.org;
 h=from:subject:message-id; bh=ScX4d7wrDRNhPQNJTEUE2yzLUg3bTMhPS9lK5qO+Lr8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlzNrdJ0RFourpfvDDwmAjoMXsWuiAdMg8K5nz
 c8E2orX8wKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapczawAKCRAzarMzb2Z/
 l5vWEACZ9FpoJw5RXn0POwKEQ+nda9SYXikeIPj6iWmbMffe21WHMWLCa1mcC2AgqFKdvd1JVoa
 n4/NtPVOM8pDhcjy9tw+3/1jmccC/BuUpcxm5u1JRGHcnYdyjpoNkAVwjXt/ITnjoGmsH0OgRkt
 nIVP7Uv/HYe6sIPfvLi26j73TrxAZ3IBsAo86r4VDB3C9PBkbMsmFC7j3o0niVdVQgLO3+oxlBe
 XP5IajpCH0QepT2kIdjreD8tmw6T9Z+v6JgrNWvBXALQHgRaSX7g4PoXYJdPVDQenY0xzN191dc
 YMPXdrVwCa4awTX1yCtZDd1x6RUjecTwIV4wwpZT7vT4kILB3UGaZbYePZPe2BXMfGvO5T28rtf
 JDSGbhpTvpw5PulL6JQm/7hlnjxvbiJ3Ll6mVYZUuhpU5rjsnyV6XWN9RFOB+jaD3oz9mdeXK6f
 pW4o4QrXHEOwQFqc/Z5j3Fgfkoz1oppWrPBsLBMavjotl9+WWaU9Va5E63cEIQnjfRDX42hMFDU
 yYEyZK8TfUV34n5MLNifG3bpXApjfiKUhhxoMLV5/5xHcXQVbMPlmrkr41kkfeMcnrai9GXq/d/
 CkcQYQcrCN9XZ4iRGtH+l9OqK3PpnfIZp7el5AJi1xImazDaBrWvz7a6afJF0i65YeJYBIkpXIY
 oNH3TkhER+U80vg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

cld_pipe_downcall() removes the matching upcall from cn_list before
copying the daemon's reply. When that copy_from_user() faults, the
downcall returns -EFAULT without completing the upcall, and a
retried write cannot reach it because its xid is no longer on the
list. __cld_pipe_upcall() waits on cu_done uninterruptibly, so the
nfsd thread that sent the upcall is stuck, and nfsd shutdown hangs
behind it. The pipe is mode 0600, so only a broken or hostile
nfsdcld can trigger the fault.

Record the fault in the upcall's pipe message and complete it, so
the waiter returns the error to its client tracking operation.

Fixes: f3f8014862d8 ("nfsd: add the infrastructure to handle the cld upcall")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4recover.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 8dff351aa832..999694db9981 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -835,8 +835,11 @@ cld_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	if (status == -EINPROGRESS)
 		return __cld_pipe_inprogress_downcall(cmsg, nn);
 
-	if (copy_from_user(&cup->cu_u.cu_msg_v2, src, mlen) != 0)
+	if (copy_from_user(&cup->cu_u.cu_msg_v2, src, mlen) != 0) {
+		cup->cu_pipe_msg.errno = -EFAULT;
+		complete(&cup->cu_done);
 		return -EFAULT;
+	}
 
 	complete(&cup->cu_done);
 	return mlen;

-- 
2.54.0

