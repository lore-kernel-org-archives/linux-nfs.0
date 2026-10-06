Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F2F73D301D
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 20:44:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791319476; cv=none; b=QzPeoOtW4yaxMwULdiTrVJWt1pBfrFZda66doogdI5PzCg1juR/zk7XzXaFy2S7QRpK8X0suEPNNrRh0vasDQ7dVawLz8EXlJvfm5tS7yOGawXWZwLDErp6CpfRzR1HW8lpY/bhRM9X9aSF1Pj61tcknQDonwAz+VpUrfIg3TPE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791319476; c=relaxed/simple;
	bh=zutvmyAc5iP1BAmUYsc2LNlLsWXq5XrzlJgG8lK4GVU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gDoBqA06UbLoZEhXlwGW809kUt/g3zgBXbeJvimxsr3QAIzEQSvKWaD7a5oCAo7eR/+vEKZFNLswbvmHS+3r/1sL1UT0hYGnXBl7EVYe2uLwFIKIiq34LG22w/jGQgdf6adCIdarrUPZ+1Bwb6RPJy3u52QN9OgMZO8b7CQSyls=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IT3kgeQr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IT3kgeQr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 648871F0089F;
	Tue,  6 Oct 2026 20:44:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791319474;
	bh=VU+1yV1Z661iCvdvbTQZeqayt0JH0WI2bE6oHsK2kdE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=IT3kgeQrYK38itYVFeFNy9tMyuQbofjcUaBZnXhTmg/KmUlCyE405HzETvrfKPKoG
	 TDCwQjzdKASy5v3wxMM/bizwSeYN+tNvReQkm4EDnLQ9L6sBC1g38W72+Dd5V3IlRX
	 2yAcle5t5hDYyaZiC9OhlavVmH99Om/WwZlSOlI4NzGQV3aXH7fgD6PO1V/WbwNbIv
	 2cnOikfGdrYtJEhhxLwprFwVhjFV8vm/KVjT08GwO84FhRH8By1f65zjEaIBH1GBfo
	 ntbK/B0weTujlX9F09CjuAb+g/fAqMjLL/379o3yIPaY+WdQFFLu6QYidjHLDpkFOr
	 JouAIR/NgxlTQ==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 06 Oct 2026 16:44:14 -0400
Subject: [PATCH 1/2] NFSD: Release the replay owner when an OPEN replay
 fails
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-open-replay-fixes-v1-1-0c668a3e7216@kernel.org>
References: <20261006-open-replay-fixes-v1-0-0c668a3e7216@kernel.org>
In-Reply-To: <20261006-open-replay-fixes-v1-0-0c668a3e7216@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1776; i=cel@kernel.org;
 h=from:subject:message-id; bh=zutvmyAc5iP1BAmUYsc2LNlLsWXq5XrzlJgG8lK4GVU=;
 b=owEBbAKT/ZANAwAKATNqszNvZn+XAcsmYgBqxV2xpxsQ2Ug9PdlypCYJPQN3FXeQmrd9V6432
 cykxAMkQXuJAjIEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasVdsQAKCRAzarMzb2Z/
 l92TD/Y0qLDbRiVs6gXn+M95XYpyX2xm2x0jJBPzyHKWgV2TzBg7TDQjEefSJVQwy/CHbT9MV2a
 VK2KoZ4+khIb19j7HxlGEZrQBN/KMfUgMVEvWJhgfFgCigp4wO4dMZNU98jC8XY8MIgE8I/pyN7
 NhsiGgdpEL8fldu2H5SWlb+1Z3AU39Rx4ua/FWkETqJHyVS3WMnks9c+dI+963yXkv8BdrVzFbA
 N4V16/xTZDXD1vtn1MwL86F3DYJUkCb53tKxVyDQclkegZU7oJeuI5ZTGWuiGqlJJx/DCWO6mj0
 AIvUZIK5ueG9iTzABjllD8oxkbaCERyVFGmXTMkMx36lVYEa3RB4Wg40jVZEbGtqFQPWyFpzddJ
 qLM3rrtuc6VfdEyr7ev5rsW+/uSLXaY8UH2FSJiREz/Om58NV81qFBXZO1fG3g5pENgcnQV8ejq
 Wv9SyocSxIE+O0JXaEaC4xCWRVtLn5dQW/hawLtu/fNnYCxzLzEAwkb16TV2TGczseaR65IXkln
 /QMz7ya/NpzdJyxXAduH+ihDVNpd9XMsyG38MtJeL0p61dB+vYHUho2D9xRoFx/RbJnDMSM1yDs
 9BcqzhWltfQtFwVU+hu5ZPQM0iCpnTs5H7QKOwUgaJCK02Z5jzSulBVcyvvvQ0jUd/c5+j0jd34
 g3CzBdHd2Xkco
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_open() handles a replayed OPEN by copying rp_openfh into the
current filehandle and calling fh_verify(). If fh_verify()
fails, its error replaces nfserr_replay_me, but the open-owner remains
the replay owner, so nfsd4_bump_seqid() advances so_seqid as for a
new OPEN. The client's next request carries the sequence ID NFSD
expected before that advance, so NFSD replies to it from so_replay.

Call nfsd4_cstate_clear_replay() when fh_verify() fails. After the
change, nfsd4_bump_seqid() leaves so_seqid alone, and the client still
receives the fh_verify() error. nfsd4_encode_operation() also leaves
so_replay alone, so the cached reply to the original OPEN survives
once NFSD caches the replies of failed operations too.

RFC 7530 Section 9.1.7 requires the stored response for a duplicate
request, but without the filehandle the GETFH after the stored
NFS4_OK fails with NFS4ERR_NOFILEHANDLE, and the NFS client, FreeBSD,
and illumos each discard the stateid without a CLOSE. All three
advance their seqid once after NFS4ERR_STALE on the OPEN.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3393bcd18ab7..db683af11bd8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -707,8 +707,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				&rp->rp_openfh);
 		status = fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_NOP);
 		if (status)
-			dprintk("nfsd4_open: replay failed"
-				" restoring previous filehandle\n");
+			nfsd4_cstate_clear_replay(cstate);
 		else
 			status = nfserr_replay_me;
 	}

-- 
2.55.0

