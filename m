Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192822;
	b=4FAaR4N+hletIvObU4c9TPLGlrU572YAvBBvVUrwrAimGHsI8NAPUP7Kcu13xs1cyTJ6
	 KAN66ryVo86p9yc0lz7SIf0Ju4V/okdgoPUpHwyk4zAJDIbnQ7Em7Qw/Kil8+0B25FAdA
	 7Na1v1OC/XXxwVqUtyCFtP9W72Mp0D3Rs+dkPmrvTH7pxPlBX6hU6zbEZ1PQtunHRC1PB
	 gk1pqrlBmaWfhwJ2aHgkzcXhow1bLZO5a1xY5SaxPkv1AxIja18TVusvV3Ksvf1YzZnhY
	 p3bTcwQ1/A6R+epPdZB/JdLnoI8mVUHa1Od1SDlN3boJxh7K8jq3N+tJsuJdeGVi2lA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192822;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=WJqVGZjMtctY6r4eWY7GZwmgKDqqQoGn02fkSjE74RA=;
	b=4LOxo3RLPXPx9FVCSqlXvlGx7NrnfqGuW7mb76AoEoMUX6UkqNJKCVof7fZXIidTqlWg
	 yaAO5djOclR3Z1PONiCE1WdZVAzXfjonLqPwdYBC3VqYl8RyR5XaJ41hdIN0+s6nDuQLC
	 KEtd7D0jAgZAp2u2QcseyUPcNadMjCN40PVffZMFQBWlDxHhWFfUReM15ML7gxmiFHNzo
	 ce9LWWjPZEdXm37QxjPpPSz/1GJQGlw9+sHwnKaUbQ1x4c1LiGE39pdbOq5GtG9ciDgXU
	 REYWhThBVl4rq5AKe4JqSgt3O26/I2GzSjM5LF/rj0pjQpYd98ZZv/eLNZVdteBunXA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mhVBqb5K;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5BFA260A2614;
	Fri, 20 Nov 2026 16:40:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mhVBqb5K
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8B4651F000F4;
	Fri, 20 Nov 2026 16:40:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192821;
	bh=WJqVGZjMtctY6r4eWY7GZwmgKDqqQoGn02fkSjE74RA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mhVBqb5K0OETZCOl87eTCP5+XnLDcq6pOiGCaIx4ad5nPVUOTytHRA+qS1TgkPldZ
	 OEr67DlQh5TdrwIRdMQzin8mD+9cQ6qoEJLWRdyhh1LApDbuX63oM4dg7U23nWqlUO
	 av1UxTcAWVTPtEFFvqcYQ/QqQGQE1nPNiJUabdlyDYpZU8F9Y0v0anQ/W2hjXZLacu
	 /M8aaJ1iZV+TZ99URseWeZdV037j0iCsCN8iK1MHLy9vYHSt9EmhyVCDaOJJQBpHj+
	 Om97MWIxGwDC+MXntsKPBRpPpibyBsFRFdhC0nk2YrY6fK8xTLamzIanDz3+xl8nfJ
	 z92uPQgmN/B6Q==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 08:40:09 -0800
Subject: [PATCH 03/11] nfsd: count a delegation in cl_delegs_in_recall only
 once
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
Message-Id: <20261120-delegts-fixes-v1-3-c89b37d2d462@kernel.org>
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2289; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=qsRP3xm1/AuFTcbMrL5CDKmDok7IhSnQ1tTbYl/i5ks=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfxAgo/Sjy+G23RzRfb1Hsp0nwALCLk4bhBg
 lYX3+4yB0uJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB38QAKCRAADmhBGVaC
 FVzYD/4jIPSAkErgrARmIOofMf+zwcsAJbLCiEGxXrg/++hpFfRLBUMCdNMLnqiqjmNro59kB8A
 w6ptlIG51ycDi3knHrDPeQuw3DOe6NyJZ0fo2RIAu3m7WGt3vS5+4n6F1sxR9errWWpAGOq6FB3
 B923/+PYk0hRdCFwVCMmOdsXrtvAQjUaxM6NMVNa1unpQpLevWLQSEbxvEhAw77RB2eAARwXsPe
 /SowIxvVQAWPpHkT36qwi5A0grbMIfwiXz5nWEWN8QrlORbdqZ+GGJpUeG63l9OQ30ssV4qZKUe
 Nbwx6K4EWVFyGN2rtFBGgqICoAHwJ8/bjqLbT4JpNQU3TLWrEOF6JttmSHH3Nev2VX5cRqB4ERk
 hEG+UixfYsk56mmQvWUIgIl2vpyVikMVuon0xQzkLALzLnD+z8eAFByljHB8MrqvozwnzUf22Bo
 4ASws71n7oV7I6ZkeTcb3Nba1gjoh96Mk6vTTuOCkeuW8LJGjDIF/FD9dOF97g+9S+5yVkSVo/L
 nHOI3RPEwW/Cw6LeaYrAwEI3d6NbuK7KdyxSXoNWusGUvDfY7VImrg4nu7CliG+rSvRVYEf8uuO
 43UpYD48jHUqYByU1acksh4XB6By1QAVuOiyGjQpmb0fk2+qsEzAcvqK4oszjUlvb0lUlRaYoX1
 0EIBrIxW3YpQZBg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_break_deleg_cb() can run more than once per lease:
- __break_lease() calls lm_break for a read breaker
  (FL_DOWNGRADE_PENDING) and again for a later write breaker
  (FL_UNLOCK_PENDING);
- nfsd_handle_dir_event() and nfsd_recall_all_dir_delegs() call it
  directly, possibly repeatedly.

Each call incremented cl_delegs_in_recall, but nfsd_change_deleg_cb()
decrements it once at F_UNLCK. The leaked count keeps
nfs4_anylock_blockers() true, so the client can never again become a
courtesy client.

Skip setting dl_recalled, the increment, the client expiry, and
fi_had_conflict when dl_recalled is already set. All callers and the
F_UNLCK decrement run under flc_lock. fl_break_time = 0,
nfsd_break_one_deleg() and the false return stay unconditional.

Fixes: 66af25799940 ("NFSD: add courteous server support for thread with only delegation")
Fixes: cb7444b27c85 ("nfsd: add notification handlers for dir events")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f6a01ab0602a..490fefaef52a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6645,11 +6645,19 @@ nfsd_break_deleg_cb(struct file_lease *fl)
 
 	trace_nfsd_cb_recall(&dp->dl_stid);
 
-	dp->dl_recalled = true;
-	atomic_inc(&clp->cl_delegs_in_recall);
-	if (try_to_expire_client(clp)) {
-		nn = net_generic(clp->net, nfsd_net_id);
-		mod_delayed_work(laundry_wq, &nn->laundromat_work, 0);
+	/*
+	 * lm_break runs again for a write breaker after a read breaker, and
+	 * the dir notification paths call this directly. Only the first call
+	 * may count the recall, since nfsd_change_deleg_cb() undoes it once.
+	 */
+	if (!dp->dl_recalled) {
+		dp->dl_recalled = true;
+		atomic_inc(&clp->cl_delegs_in_recall);
+		if (try_to_expire_client(clp)) {
+			nn = net_generic(clp->net, nfsd_net_id);
+			mod_delayed_work(laundry_wq, &nn->laundromat_work, 0);
+		}
+		fp->fi_had_conflict = true;
 	}
 
 	/*
@@ -6659,7 +6667,6 @@ nfsd_break_deleg_cb(struct file_lease *fl)
 	 */
 	fl->fl_break_time = 0;
 
-	fp->fi_had_conflict = true;
 	nfsd_break_one_deleg(dp);
 	return false;
 }

-- 
2.56.1

