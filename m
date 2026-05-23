Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD09C31E835;
	Sat, 23 May 2026 16:17:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779553064; cv=none; b=aH99t5h4CelSyDrl/vn4HZw+d7q17mixofAdnKjdN3y5qnTyR9bsTmTh5XcZBf07gaN3QmC7ygfv9wFxpNqMqUHa9pXevvtDQ8toxdqjOMzFxUX7KHtCr2UPHZCtbkbmhV7ja95q7A0o/3ibwHxYewGuZnFaM9oSk4UTYALSkKc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779553064; c=relaxed/simple;
	bh=50Jjd/MZcYcuzk0DIxXK6q4r6I98G+V7MPGX5Tl64qc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=nUHHnFUo1CXfJd2u3MQNI52j5VJZObV6DNNClDobqMCQZxJZRCTlAvA6SR1Xim9Gq0ivuLaDz4yZIe6jLDZGXxhuDrnLJqQK/vz2ct25toe5JiX0lJwXuEX3uqGC65LuhJmEy0UsPQxCHvaTmTml7DGlnIcinf97vrEgv/dmFis=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aF+o504t; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aF+o504t"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DE0521F00A3D;
	Sat, 23 May 2026 16:17:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779553063;
	bh=AqZiBDPYP2NRvY18IQ+oxkT1uHBglTinZPjZOnLjYBc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aF+o504t9+gkGRUbuF1LzUqOe/7wlic3DEBH2n8fT2Qjh+8j54Fd6VZ9E832alDx9
	 StI3JHPLYHCY2bI3OqUQz/HP4SrwAw8hZLMfMyDhfe63S8ohn+Nl1e508dry1AavcR
	 AtaQQkOyVybPdxIp38rVOaRw5rRKyXplKlOxuWS7YxdmerTipyFuXbbjRHUASBErBC
	 x7VwP+z8CGwMK0u89AvXTiUQjA6MWJrpR/jw7k9kUrcsGPan6RTR7KirUBuY/4m7fQ
	 X7V8W4Lx9rC+nCTsz4dKqxPeU/AGPiH5sLHErQt/lPkJyU1d/OYSuVl8KNtMuAZrNs
	 CXcYVNj+RUvXA==
From: Jeff Layton <jlayton@kernel.org>
Date: Sat, 23 May 2026 12:17:36 -0400
Subject: [PATCH 3/4] nfsd: check delegation status in nfsd4_cb_notify_done
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260523-dir-deleg-fixes-v1-3-142c884f85ce@kernel.org>
References: <20260523-dir-deleg-fixes-v1-0-142c884f85ce@kernel.org>
In-Reply-To: <20260523-dir-deleg-fixes-v1-0-142c884f85ce@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1073; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=50Jjd/MZcYcuzk0DIxXK6q4r6I98G+V7MPGX5Tl64qc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqEdMj2uDZbkO24OxzerFV21OkVnkmLKXt7Yi7c
 d0OUIyooBuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCahHTIwAKCRAADmhBGVaC
 FaTvEADGMcdNQ8bMA5p08DVhWzN38XxWmOC6ePQMgc/efg7HPWZbMimKdks9pUmz6wITWc+PxLb
 9edE3yqUNiJ9C32GntZ2NvL9kjD8yJMhAD/nKFPqxZkyuFY3uys0//vMOvztAcFmoCy/FPVjerJ
 dprwfHLuAnct7R0Ba+uC/VBsd1CFVD2w8esfWb5j7AEMY+x7/ClhMq3qXH8JdQJFRUEDG67jKsc
 woBnA2rBHCsR/Q3z8aKdWEPYQh+UI40lqs5aNmYwAUV7nMgfEpYFXNOrmXfAEhQYzo8PHp+jq+K
 Xw+2+brrCK2E7jz7cAXASv8wZkT4d/ajV/3/a5Pm7mX7ZGGcyB2mHEUg020MjhB+uIQVjjmTH4W
 7UrquQu5ijjf9Z3xYqz+frOOzviG6atXU6YlerwxnO9kRNqTxeqPOu/LSpYdlUPooemCe5ii5Ld
 wK6eDT7uCxV5KXFFcYLF4XS41TYlPO3or+VqRQKO/dOUBGq/f0hjwHhDe6J1TehH6yyhJ4gngGA
 cGAiEi4O+ZrRoCqhulmEZjYbqQhJtmpP1+Q8GNYvwa6MCmcwdQj+5Cz/0xGqQ6allB5kSptIt5K
 63bjrrkruo1TYOO8IiY15iTzeinJX6c7zb4uZuhW0xEFT4Uc53KsPc2ifezOlPEKEJO3fGaIcNC
 yXSn7YpY3G6yBEQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

If a delegation has been closed or revoked (sc_status is set), the
NFS4ERR_DELAY retry loop in nfsd4_cb_notify_done will spin
indefinitely. This holds the sc_count reference and prevents the
delegation from being freed.

Add a check for sc_status at the top of the function, matching the
pattern used in nfsd4_cb_recall_done, to terminate the callback
promptly when the delegation is no longer valid.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index acddd55a99d8..5e391f01d753 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3593,6 +3593,9 @@ nfsd4_cb_notify_done(struct nfsd4_callback *cb,
 	struct nfsd4_cb_notify *ncn = container_of(cb, struct nfsd4_cb_notify, ncn_cb);
 	struct nfs4_delegation *dp = container_of(ncn, struct nfs4_delegation, dl_cb_notify);
 
+	if (dp->dl_stid.sc_status)
+		return 1;
+
 	switch (task->tk_status) {
 	case -NFS4ERR_DELAY:
 		rpc_delay(task, 2 * HZ);

-- 
2.54.0

