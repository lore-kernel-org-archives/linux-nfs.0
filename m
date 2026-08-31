Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E0A8274FE3
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 00:38:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788136735; cv=none; b=Z7VR5vPMtAvKopbnvMyan4uhtvzPE6Cztv9FWXnsR+z7lP6b51+QDseX61k63oeaAns5nGARwL53tFD9GMq/031sQil8w5CQ3oDMksrFyZODKzH7w986FWuBv1VZg54rbTkWpY6dnOHRUG+aGk6qtB4f0xaSwIHHjzctITw9fvI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788136735; c=relaxed/simple;
	bh=ScX4d7wrDRNhPQNJTEUE2yzLUg3bTMhPS9lK5qO+Lr8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Oz6bGRjPpD6rCA9WYrxQ4TLZTU0iMhpFLL1N5O7ct0+6ZiYyfDLywKYk5MXnz6JdKkfIRyMkthvsC20/L+LLNwyTQ1mTgUlxZYuQfP/sQB0H9MF+fuLR7Sl9rigJ/j9IfglH7aYQvMlOlriJkZR9fc6fNoFa032WqOa59gHOv/0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Hilgk0OZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Hilgk0OZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 69F931F00A3E;
	Mon, 31 Aug 2026 00:38:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788136734;
	bh=NPn3le1KJPE3zU07MZaLDFYFC+TK0PQDlVIP5jjzi2E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Hilgk0OZv6ApOsyGUs4eHovhFWNoqAlSrpGRv3JUJjUN3nsZK6BAWM5vG2Lu6OCTM
	 IRjbEO4+cfG2yV3DiIaEa22EHghCibOkqdYD4lF73uRYFDBfwqTTOH2GNjbKnWFmvu
	 Ln9tJWPSaoJSv2WrdbxSF3rG7J+hoTxq/h/JGQ8E4TudF4Cv1b10ILjfRB7HSlR7Ex
	 a5jpKLidQzv4w5pHpTYKW7bDUhM1swAxNbvmFve5rRMHQ4ygqWR4choTp6UlyfjZYc
	 KeMo1ah9HVUQzPts0Bs3VvA/DDPaq9mwJfDc8jO4CuOE5bpWUOVuMw+H17HRaLo/7N
	 wxgWUlwfM7E+Q==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 30 Aug 2026 20:38:40 -0400
Subject: [PATCH 3/5] NFSD: Complete a cld upcall when copying its reply
 fails
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260830-alemi-v1-3-463f80b9e9a8@kernel.org>
References: <20260830-alemi-v1-0-463f80b9e9a8@kernel.org>
In-Reply-To: <20260830-alemi-v1-0-463f80b9e9a8@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "J. Bruce Fields" <bfields@fieldses.org>, 
 Scott Mayhew <smayhew@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1467; i=cel@kernel.org;
 h=from:subject:message-id; bh=ScX4d7wrDRNhPQNJTEUE2yzLUg3bTMhPS9lK5qO+Lr8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlM0Z8DYZxSx6U4F5VYQF9v720QkNqISdj5+iz
 ZqlsOJQFNGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapTNGQAKCRAzarMzb2Z/
 l7+aEACCYdCxLnKQbhsOize7rW0siDQthrh2xCTT6zodI8osjcpk+geJDiDeB6RcDfh7zGO5MQS
 RmliWZG6zCEzD4+vX/Ra5Mj4+VRwqxMb4gM0Ro8UcdR8yOvW8CNk4Ru4DlO3MEj7P11NVh+FrSD
 mFkL5xoWNQH7awl+m5NMJNA0IRWmJYqyGiYeb3bXpeel9E/hh/BY8Pgr38CLDKoXxdLHf0mFHKb
 d3+rREc//EOmt8F1syhtbadlfxI1GBSpyD1xXjbZCpHo92j0ltA2YDMcMLv4XBQBedg124EuBBp
 wliCEIPxbcrPxz7KKGZPui60Bx8ErumUdXknB2GdXVtg3cRQMyy1IrqT7+j03FQ44GXpGLUK6WG
 MULN0e2NCwQOvoQ12ZnZga3S0bNav0DC4H4yFhbLc7tBnaiQIfycHGiI9fDfp9aYPNFd0OdalXV
 SavxAML+vzUIXNHGf++HbgOES86sHaBbfZMDJ2Z6sQGk1YNhS6GhGhjht7K9xtRiwWOud/s/HsE
 JArr8P5bbYlamMoDxEWPljFbDZHMiFhc2lw9wGGYMS/qz5VgVnpfbcz8byj2FvzhVk3gDQZUmWq
 BmhgXWrWD+VoDf3PoxydilTVD1gB+oqyt4zYUZZ7IR169gd64fQfE3smWhS4YloDbGEsdP3odS/
 GvmPmKqQN2RtgxQ==
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

