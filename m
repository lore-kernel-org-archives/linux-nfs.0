Received: from mail-wr1-f98.google.com (mail-wr1-f98.google.com [209.85.221.98])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2AD73B71CF
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 23:55:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.98
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790034955; cv=none; b=c+a0mE/8hqo6eT2X9yj+7gOKBDnC2Bj98GSRnuBGZv7rZZRvgBKjgoDonHHF/PskFgGdhQ5CW+vPhGADdwDDsK1eJYKNLdAHfDoyX1OCXLVEpgqiGObJZ3Dk62rC1Oy6ADn+fpsIBnTENe0F2rBVt51zr9fM4UdU2KRlGZA4Kco=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790034955; c=relaxed/simple;
	bh=ZlZmmE0Ud4HtB8YhKVNsPgOQtYjW6bg/mZoU2cnlRYg=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=T/mmAGhE9WiUb0GNd53/521jeRi5jZ/tPopmf4QKxLMAcEcosGNoebeI1i+IigGSe78CM2koSB/hQ3Ni3+AISF/dC0VJACYakGn2zC0+SFnuIFaNwdChlleGO0/ofSXxCKbjeMnY+MPPEyxrQuDwmJhhUUnC8uAqEbguYb5V9Gg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=ER2Q7Ts5; arc=none smtp.client-ip=209.85.221.98
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="ER2Q7Ts5"
Received: by mail-wr1-f98.google.com with SMTP id ffacd0b85a97d-486e934b0c9so49318f8f.2
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 16:55:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1790034952; x=1790639752; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=DC4z4qLDl0mYRFHdnAjlB1ZKHEqGD7UBjetsY7bEK80=;
        b=ER2Q7Ts5YbfRlmJ9MXUTJbYwo53bCwYEhkicRq3+tFf/MdyHXBv8cEJbxiWOnN7zs3
         8nV8jJ24CKQmOKMlIT4kqpNoAdK6pwxW12+GfiafTmn4P5G/6qCSBai3S5R/F+h6nb/w
         6t/a93CW8g4nRDzVcYH8n8dZbEk94ueYq3L9YQ1nCchZrt1X5lSJ6GLe+i6D4kw6hYm0
         c3h97E1XvWzAGVyCVnAh3ANX+wmSJKxbN7d9rTsurNoZARNVthKqq1JNEIGvqt/empXr
         2pB0CK3CRPV0TZBs0hAen0WWd2IHz/CodACJtGehWDrn26YB1BltdgvQd6sLPDzrztKD
         ZsXg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790034952; x=1790639752;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=DC4z4qLDl0mYRFHdnAjlB1ZKHEqGD7UBjetsY7bEK80=;
        b=w6eim8OfciGigrVklnXKT1o2o9SMKzCsw4TgzofOiKLxHrvEJJsmBT5mTVFNK2E91G
         nx6BaoIAHkTNr92eiOF7yLkOctd/BShHBJbwbVMnDXzF9akaiRjgkvxfET677WGd8dOI
         J3KrLBoRsBq6tFOgWhtNXLEuo5DYALjEBs3i8PrLePE8wjZ749NDbySzLBWqKkl3+6On
         XM6+lKPQ3LS0qYtA4kN1LlHWx/i2ERFmZLPwqnArIHzXEYni+CLCGwCfjrTdf2wFRfPD
         QinTie4PDcFSS8/mcG7OePGyYStg1EwmgzJJeOIEq6vdVjrYH42xXxFOqn56IQn3AvRH
         7TtQ==
X-Gm-Message-State: AFuF++lIMzkd376QYkjfqnsO8SIWpIe1BmTrCWniXetOopZT5OBvPTZv
	p8LBbUbstQjuRdJhT9SM6fbmwrBYjFEv9qlY9amGcD5VXInfQAkLMGit7BRKdgL+Fea7TPkk9cn
	eXN9HnwT7YrRn7+1S/qWhp+ao/9iVDOFx/zOJ
X-Gm-Gg: AYBFou39U8cTDoXenp7ae/WzS7HKWkw51aPOcxd9dRi5wiyXaHLFbtK39H/cxio3PfA
	+e7zCyXRXqyklZaosn7mJ25RZ0i+X+b5N1I2sTt30QJGVg3n3AkGn0PHd5xz4LBjyEqie45N7WR
	oerZscZZq+HHJlaC6uY8OkZ9uz/le+MDKSwxAlnQ4TSFLoXPMiFriGxTCdT6M5j61IVbq8cxW5x
	p3Cq14dFCYOuleVWdHxuiAiL8FU3J2pyvzEOTbOzJUnSAGmc/e9YQd4JtK2+xrF4Wt2Zkty6NNe
	GZbKN+y2/wOPdmrwDjOAq3u05E8fmM9H0jlPN8kzieaCsEA01E2TuWoyKExCRvVo6zPjyQyvtMz
	iKt9BD0nohfIPQ9eirW2OdWn3x6bxDw/LrXXhDkg=
X-Received: by 2002:a05:600c:1daa:b0:49c:fc6c:bdfc with SMTP id 5b1f17b1804b1-49fc574643bmr157725415e9.19.1790034952055;
        Mon, 21 Sep 2026 16:55:52 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 5b1f17b1804b1-49fdab8660esm1052625e9.0.2026.09.21.16.55.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 21 Sep 2026 16:55:52 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 6F2F73417EA;
	Mon, 21 Sep 2026 16:55:20 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Badger <ebadger@everpuredata.com>,
	Jon Curley <jcurley@everpuredata.com>,
	stable@vger.kernel.org
Subject: [PATCH] NFSv4/pNFS: Preserve layoutreturn seqid while lsegs drain
Date: Mon, 21 Sep 2026 23:55:20 +0000
Message-Id: <20260921235520.502987-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Commit e20772cbdf46 ("NFSv4/pNFS: Fix a layoutget livelock loop")
changed pnfs_set_plh_return_info() so that a zero seq argument is
replaced with the current layout stateid seqid. This ensures that a
pending layout return has a nonzero plh_return_seq and does not
continually invalidate newly acquired layout segments.

pnfs_cache_lseg_for_layoutreturn() already passed zero to this helper.
Before e20772cbdf46, that call updated the pending return iomode and
NFS_LAYOUT_RETURN_REQUESTED state, but did not change plh_return_seq.
After e20772cbdf46, it also snapshots the current layout stateid seqid.

This is problematic when an lseg that was already selected for return
takes time to drain its outstanding references. For example, suppose a
return is established with plh_return_seq S. While an lseg covered by
that return is draining, successful LAYOUTGET operations can advance the
layout stateid to T, where T is newer than S.

When the lseg's final reference is released, the path is:

    pnfs_put_lseg()
    -> pnfs_cache_lseg_for_layoutreturn()
       -> pnfs_set_plh_return_info(seq=0) # advances plh_return_seq
    -> pnfs_put_layout_hdr()
       -> pnfs_layoutreturn_before_put_layout_hdr()
          -> pnfs_layout_need_return()
             -> pnfs_mark_layout_stateid_return(seq=lo->plh_return_seq)
                -> pnfs_mark_matching_lsegs_return(seq)

The zero argument causes pnfs_cache_lseg_for_layoutreturn() to advance
plh_return_seq from S to T. pnfs_layout_need_return() then uses T as the
upper bound when selecting lsegs for return, so layout segments acquired
after the original return was requested can also be invalidated and have
their I/O cancelled.

Under sustained I/O, those cancellations cause more lsegs to drain,
whose final puts can advance the return boundary again. This can form a
positive feedback loop in which newly acquired layouts are repeatedly
invalidated and cancelled.

This was observed on a one-client one-DS system under sustained
direct-read I/O over pNFS/RDMA after restarting the nfs service on the
DS, where the repeated layout invalidation and cancellation caused
severe throughput collapse.

When the draining lseg is already covered by plh_return_seq, pass the
existing return seqid to pnfs_set_plh_return_info() instead of zero so
that caching the lseg does not move the return boundary. If there is no
return seqid yet, or the lseg is newer than the recorded boundary,
retain the existing behavior and snapshot the current layout stateid.

Fixes: e20772cbdf46 ("NFSv4/pNFS: Fix a layoutget livelock loop")
Cc: stable@vger.kernel.org
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 fs/nfs/pnfs.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4f9c0f639014..69b085482921 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -596,9 +596,17 @@ static bool
 pnfs_cache_lseg_for_layoutreturn(struct pnfs_layout_hdr *lo,
 		struct pnfs_layout_segment *lseg)
 {
+	u32 seq = lo->plh_return_seq;
+
 	if (test_and_clear_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags) &&
 	    pnfs_layout_is_valid(lo)) {
-		pnfs_set_plh_return_info(lo, lseg->pls_range.iomode, 0);
+		/*
+		 * Avoid resnapshotting the current layout stateid for an lseg that
+		 * is already covered by the pending return.
+		 */
+		if (!seq || pnfs_seqid_is_newer(lseg->pls_seq, seq))
+			seq = 0;
+		pnfs_set_plh_return_info(lo, lseg->pls_range.iomode, seq);
 		list_move_tail(&lseg->pls_list, &lo->plh_return_segs);
 		return true;
 	}
-- 
2.34.1

