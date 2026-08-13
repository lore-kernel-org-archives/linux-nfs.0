Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CBCB476CF1
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:40:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786646453; cv=none; b=fr/PCCbd2FPwYTrMH7HRMpsowL64DQ+2ClzFOSMZ9kLW8KdAeYttXuW2zKmyPGJt67C9w3aBaO/aTbeHHtN6I82hwkiBY+CaCA+/Rgm5vbGF2S3d4mg3AQOad2DYvY/XfGXQw6PFiBPmiaEmzvddiKxrA1BWNQsZGYw8nGv7pxM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786646453; c=relaxed/simple;
	bh=a+ZyTmPUgxbj4plLZpmvVDNBlgFQLvSecxfIrzTTirw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Thv+eKZvKaJgeZA4LoZmCP1B6OaDAAgVW6NjdojiOcuH+VDAwXDWR3PH+lBurnJQbNVJK6hjClmrTuJDmIPJNafRjnrCTyuv0DT6gg9DEZqdgSBOJgCF1p6vylGEOzyTn7KEiEDD7T+pFeQdznZNWCVNUTCHaLHA9EttcERvv7I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jYQQJevx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jYQQJevx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D22A11F000E9;
	Thu, 13 Aug 2026 18:40:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786646452;
	bh=JyD65001FyIs2rd6ZunuB2RnkOkvWLX/bpqmC89BH0o=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jYQQJevxW0ijvv36D27qiikIFfwfHHUumbU7vrWtyi3MjrEz5AXYtDdmomljfej1X
	 fU970wjjGdOEsgO7U28WanQg1eQPjdRilDQhMlQBnGGOrQ9i/jMmT8gNzgExOmOZT9
	 eTDOi/Vy9UoscxkcBoYd57A8VRJwk1KLaEUTkCojS/LN9iiLfKb9xYMoVaCwlMovzo
	 X6oIPZAVuXhZi+PVeqNajVEMikvys6N8SqeF52SzT1wIikDTAs53aP7QbZbFZO15Nz
	 4DQftfZ1U8x5PMUUd7lvEdWjoPmrbhyompMyta0WpkUHXk4hIoee5g76YzZQgfdBdx
	 3k26cowaDAEDQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 13 Aug 2026 14:40:32 -0400
Subject: [PATCH v3 3/8] NFSD: Name directory delegations in the
 CB_RECALL_ANY type mask
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260813-recall-any-keep-count-v3-3-a96d243c0b13@kernel.org>
References: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
In-Reply-To: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1456; i=cel@kernel.org;
 h=from:subject:message-id; bh=a+ZyTmPUgxbj4plLZpmvVDNBlgFQLvSecxfIrzTTirw=;
 b=kA0DAAoBM2qzM29mf5cByyZiAGp+D7ChH4JKlVZBpE/ecNyH5l+I5CmWRsvJB7hJU6wE2Fb4d
 YkCMwQAAQoAHRYhBCiy5bASht8kPPI+/jNqszNvZn+XBQJqfg+wAAoJEDNqszNvZn+XHt4QAJSV
 3DnC7R+JLvHco+lCH7SDbfNL/jPVrLgcjbK6gKfntSqLFuZotPsB9O1QyhqPOzfl2E5IP47vE1l
 PfZPur5W7cjdMivPjbXJ9NfXcfoSzWEWo1Cbkeqzp6NwcF/Yajl3mIiF/3e+q4pNNOANqIhlRHq
 Gsd3teGByaJZtdRSZylh388K/bCYKDDGVTd+qXuB9AChl24y9K3viKOIPmEheuHYLmHpIsPGPE6
 Bi8Kl2P5apc4QLzy6jo66GHN5hzgRW7by+1/9qQRY6ZkNixd52rktuP88QgI0iHQmAdjnENFOwp
 5tDXFHRy+GPl5lamWSQduRN+lZqHKWKOf6jv/k2twYOBDJ/0FRCHZY7iH2gmh+c+rUZ3GOcLEtO
 euc84Czf4Wa6zO7cVQ9s+krwPn0XXXVipsNoMqJQ2liQF3h7UhxQKbXqWfl/v/dHvxhr79Cc9YH
 WEBKx+8r7QKz7xquKNmSZqspzz1jjey9MhURnPAVUj07aFLbM4Rzhqk9LUOFIMdTrtPxay1nFgC
 nX1pvWtkxc/ZWhgUUF5vL2qQVnPwY66r02bZAFZwJ/aJNcERyIL7OOWH0lwB/9pQZPSWtXALjfl
 /q9cvKLx59OA/SKFuiRaDJaNU+bBYR6g5Q8pV2yAJ168sIHH/t6IBLQpvv+/rhL8ueBTWDb3kmQ
 V9XJq
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

RFC 8881 Section 20.6.3 distinguishes an NFSv4.1 server
implementation that shares one pool among all classes of recallable
objects from one that keeps separate pools per class. NFSD falls
in the former category.

The CB_RECALL_ANY operation's craa_type_mask argument names the
types of objects in the recallable resource pool, but NFSD's
implementation does not name directory delegations, even though
they are allocated through __alloc_init_deleg(), they are counted
against the max_delegations budget, and the state shrinker reclaims
them.

Add RCA4_TYPE_MASK_DIR_DLG to craa_type_mask so clients that
implement directory delegations consider them when choosing which
delegations to return.

Signed-off-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2ddc77ac7312..3017a93261ff 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7969,7 +7969,8 @@ deleg_reaper(struct nfsd_net *nn)
 		clp->cl_ra_time = ktime_get_boottime_seconds();
 		clp->cl_ra->ra_keep = 0;
 		clp->cl_ra->ra_bmval[0] = BIT(RCA4_TYPE_MASK_RDATA_DLG) |
-						BIT(RCA4_TYPE_MASK_WDATA_DLG);
+						BIT(RCA4_TYPE_MASK_WDATA_DLG) |
+						BIT(RCA4_TYPE_MASK_DIR_DLG);
 		trace_nfsd_cb_recall_any(clp->cl_ra);
 		nfsd4_run_cb(&clp->cl_ra->ra_cb);
 	}

-- 
2.54.0

