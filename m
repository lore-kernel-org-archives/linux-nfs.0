Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192827;
	b=nLgMmVdkm8gV4vLaOV8uQqS6G+2AY0w8Vhi6uIo1Cc37bDgEJGuk19pAFUdmefHi6PBB
	 D7bPKLKmz+HatLYimyor7TxGqeROsjSvFQ755jpcb593D/N8xlD6D1TDXsHN/RFXoazr8
	 8ZCC6Fx3l58/ujQTE9nJxgnetJgFeyDFTuxKnqMs+lPcwKLrxW15R9lrgXTE6a3lirl1m
	 vHyCgPrDox16zv+wajJmwM5SuuMv2Kso8sw/4h7xrPs1dDyP4S077xqz+ghl3U8rPHq38
	 fDOhUlSMy4uf9ubcBMWDvU17A5evOoh6l9J5xWDM0v/p2EAsJ2yY6F2F6W6n/fXKXlQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192827;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=PJ/fv/d3jETaoNrfElXtkFa+Rnbz6g7jixITqCd6PBk=;
	b=i2OA7hgrrTGiJ2ZX/nqwH2zMQ09hGHcItgTSsBX+ojWPzD9urvEzeQp31eTxz1OW8EX0
	 IYxiXbXZ4DGgfvbsEMUoaTbCoLGYw1Yvsh2UJkQpWDFnl68dFMBga+QMlLiH2Pm6s4TDt
	 +wU9dAZcEJzx2mzec5ZL74Jlh04jiPTKN8bODya2zH8FbMrIPW1XWsX9ssqAGX3UaOw3I
	 ADFgX848i7wFbt/M3RGO0WINnBHJT1IlU0KOYx5wL1vSrcSkvA1Vy1MGjDC3zUsldDqpo
	 sPJYEQpuGVXkVt1anyUeGPJYiW0V2tUqfRpWPfUe+tjf7XJq0V4l+/8lOnTSYZiyqBA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wg+NK1jS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03DBE60A5BEB;
	Fri, 20 Nov 2026 16:40:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wg+NK1jS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 401581F000E0;
	Fri, 20 Nov 2026 16:40:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192826;
	bh=PJ/fv/d3jETaoNrfElXtkFa+Rnbz6g7jixITqCd6PBk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Wg+NK1jShpPgQft6H4h7f0HuNuBsaldSyUnekIJwu6Do1uQaBI0vaq62yApgTypJY
	 XG2KAy71qyVlffwIFdS68vFNLsIFGvktZThN2XB9jt6aA7i7eLCrEDly+T+Zq9J7+t
	 xtgQiE5xDZN4gHYTsVHhz0Sq2P+/xW0thcGoZ7O2KGhyp/NoccseT2EBi2qa8Up66O
	 rUHdjCgSGkaEwxn4+Il0f8wHq4sV0J+J4JXGllCEpe5lBFg+hSquysqUeYtcFatZHQ
	 8oy6xvweeydyjVdaNDIHxnLYTWDAip3igtAAy0x4LI7mvxqyaTOoZMzYO8LKeUD1Dv
	 ZX5gIDCFbWm1g==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 08:40:15 -0800
Subject: [PATCH 09/11] nfsd: grant a plain read delegation when timestamps
 are wanted on a read open
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
Message-Id: <20261120-delegts-fixes-v1-9-c89b37d2d462@kernel.org>
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2041; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ShRd5U8txV+vVeHaT6QOjxNbV1p4L3WYOJXxquNPjhg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfyhu6CGzmLfqP7uepeWx1GqNJzr+ou5iUNU
 J393aExVFKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB38gAKCRAADmhBGVaC
 FT2ED/9lJI5VNRepp0hUcQVrgTrcxm0RL9Tf0JkY/TORJDGJRTSPXD3wmHNSqH7xYCU9bMjBbZJ
 E42+ld5SBh++5zAMJ2Nfwvq+G42uEBK7JGi5QkJFxADnf9oXF6R+YR93U6a3rvX8Krdv0I0DRDE
 BTc/qZEzS0SP3FGiPfhpJclzFwCt0/o/N1z/vjIkZhYQ9MgY+myRNCrIb0p5odmGmrL8ao+4ldU
 A0jPPMuIfrONj0G4auebuiFntYFgH8kXVp2YvgQoH3cxSpkGPAZ1uwtQrTZ8lv36td9JOpUIFrI
 UZR9RM/3njE2KV2X2MejkNL+dGoT0p2lKYirGuOy2pUouDhyYCh1BDfzTnqj2UXD1Y4CJTtJ6AX
 BeZ9ssyXCTLAjFX3qGjfW9CgV1ceiiDVrJ4ecwBuyL8cq9IjklW7PSThYsHfajkSpWi+V/xALPF
 l8XqwyiBWjl4k/CM5sZpf2OnIMdddGOAp7RM3UtMOmmg7770fk3lrLKeSCOT8bnhK5Z0gJ5SUQ3
 5JpbgRJC9c62dkMjgP/W6d0WGRWwxVFQL9Oaedbj6y//4uZygwhM7ZqyeISssRs41z4yb4vPE6X
 M8/aB+S91Stt5fr0i8xHOl1lnhW3TJfM/ApOCIj+13fh/z79m8lszul2GXiUfosMxsmQUaB5o8Z
 LIIMJcWDbNTiCuw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A read open that wants delegated timestamps gets
OPEN_DELEGATE_READ_ATTRS_DELEG. Several clients can hold read
delegations at once, so delegating atime correctly would need exclusive
authority over it, or merging the times of every read holder. Neither
is implemented.

Grant OPEN_DELEGATE_READ instead. The want flag is a request, so
declining the attribute delegation complies with RFC 9754 section 5.
The XDR cases for the type stay, since the enum is on the wire.

Fixes: 6ae30d6eb26b ("nfsd: add support for delegated timestamps")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eead615aac0a..fc01ff50c8b2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7328,10 +7328,14 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	 * A read delegation can go to a client that holds a write open
 	 * of the file: nfsd_breaker_owns_lease() keeps the holder's own
 	 * opens from breaking it.
+	 *
+	 * Never OPEN_DELEGATE_READ_ATTRS_DELEG: delegating atime correctly
+	 * would need exclusive authority over it, or merging the times of
+	 * several read holders. The want flag is only a request.
 	 */
 	if (!nf && (open->op_share_access & NFS4_SHARE_ACCESS_READ)) {
 		nf = find_readable_file(fp);
-		dl_type = deleg_ts ? OPEN_DELEGATE_READ_ATTRS_DELEG : OPEN_DELEGATE_READ;
+		dl_type = OPEN_DELEGATE_READ;
 	}
 
 	if (!nf)
@@ -7629,9 +7633,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 		spin_unlock(&f->f_lock);
 		trace_nfsd_deleg_write(&dp->dl_stid.sc_stateid);
 	} else {
-		open->op_delegate_type = deleg_ts && nfs4_delegation_stat(dp, currentfh, &stat) ?
-					 OPEN_DELEGATE_READ_ATTRS_DELEG : OPEN_DELEGATE_READ;
-		dp->dl_atime = stat.atime;
+		open->op_delegate_type = OPEN_DELEGATE_READ;
 		trace_nfsd_deleg_read(&dp->dl_stid.sc_stateid);
 	}
 	nfs4_put_stid(&dp->dl_stid);

-- 
2.56.1

