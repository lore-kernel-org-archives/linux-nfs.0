Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793057274;
	b=k8O3sURxjdO5bn9P/a/wgHPAtByrx0tEZlnn48X4y4N6B0Fnh//uYWEIAoYK1Lqtr8U/
	 IrQ/fVBtZ168/sWxLj0zQVYjlYmqhsj+SBmgiKZgRNax2mM9kaGc2z3ZmoMRvqxUGr75Y
	 DG176UNUYoFJobq3Wx40ZonldX6/9dfudIEkbXtrvggCCCkSV5YsyNtUr01eUo6YS6+Gc
	 VplLEoKaumBnCsNM5AllNr58nVspaDpj72ydHIpmqZ30TP0sO+bxcLhd5hW1xLRdx+P07
	 og2a5mRTckYmhdu1IeoCk60YGqNGMnaL2kh40VFuVVQXaBSpIq7457kbx2KpKu4aXDw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793057274;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=IUZeQP6zWoDBevTGz755Qp6CZmqiuevebAzjTg0ZcXg=;
	b=jf/TRguHsWgMMs5ZjCFdqTeHJwW03pGij/9niRaoJButoeEGFFkX3uVrhYQ1UAmr9yGE
	 SrRR+0QaXXNEcZiwok9pkPb+V0PRbrkT0ltk1m0eDMTkc+arGHko/PF4y2h0autDvpb2K
	 0rq97pvLR+KSmPIpbC5PIZwoSDRLZ0lrOXDPc+Yn8GToz8V9Z44SHwrNzv+lRw/0MAzs5
	 mtbWtJnVPrTTYH4xb4x2/cYISeJBz9l01Ae/SErOfgaNcZ0VSsLqUB2lqZIZfwZNQQQph
	 TYx5VaZdgnaDj3S+62YuH3M/iJIWm9oduFGneu8W+yOeN539Sxmzrl2wpFaUFAnnSRQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ZYkEvoSJ;
	arc=none smtp.remote-ip=209.85.210.50
Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DBD7B606A326
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 23:27:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DBD7B606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ZYkEvoSJ
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-81b54d0cb17so3658387a34.1
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 16:27:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793057273; x=1793662073; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=IUZeQP6zWoDBevTGz755Qp6CZmqiuevebAzjTg0ZcXg=;
        b=ZYkEvoSJIGykfnRQ7Y9JWvXASdKFjU+5mihk0D6nBczB6fc7FCiTSTdCyxiQ1MJWTF
         rI5ttEdcZN+ygneksIevf5cDIBgmn0pqWBiVSWIDqO65nfPLzu9ABBgE+VNQ6iCg0neP
         xCzvtbjGkwrssu4EbzMl7XcNW3R0r0ssqJrkcWIBZQ5J0nq2t5RhpekUJkT4yQUvA3iO
         Tuokx3S89CJK3/k/jlJxOqr6HrNsiuYVR8L1H17FLM8h2LoKMFJ35Zh307HsBgtb+69K
         TAbCz7DJFiuB+yKuF2varTDwbboL405Ajaa6cikazZLM/+LEc8gHBgwB7xwSVUj9Vc8i
         V+Aw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793057273; x=1793662073;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=IUZeQP6zWoDBevTGz755Qp6CZmqiuevebAzjTg0ZcXg=;
        b=FXbrk5xtAt1ZPOjUOf1Em9LWlPIiMjQZcaZi0w2EC9cwW2+1QsytpuuA6N5CB4ya3D
         af2unOoaTe/0Yhfr63cE+5xp1cd+OnwnPEE6KZ/oeTSKkStwebJA/68+PULtTvMNmd9Q
         KXu/n9GTovjgDGxd+5y/NLHU78r0EDjlnOumI6k7lOV7m2uOOoB/HZGUGdLhjJJOLIhp
         JedU256fQZA9pEMG09O2iHnXQkPr7Luh9j5zGIkusqFIGteeprWGwT/85WcYP6eWoP1+
         CSp+L9bxSXYTo645R2eCxms0XLwwiWVI619RavlMF+pZ+5h7DPHcmPGl4VOr5jNN7uiX
         mSMw==
X-Gm-Message-State: AFq9FYIGOLY8NmhLJXEL2ryMu9I4TjVQOlBaEi+Ld/0s81y/v5PJ+w+V
	iDtpIGk1iTgGwBeWOQ7/vfkz1+kejpQB2I82wxxDoW8FP+B9nPYLFSW9MLlEihquRDc=
X-Gm-Gg: AYBFou1TIX+wP790w9VuWunMixXya1lz2XkDXItEw0PCyxz8zhcHP5JxA7I3eEmPt2c
	YcvgLmM/M69FW/ojf3nqmjpb3P33Y3InkfSraWpp0sTYgRHxBuiip+4/SPvS2lEd4tuFNHMJVaX
	T62j79A2iP85R2Obnm1ZqdIdNRKCXm01TpJR5ks50FvoEqAhFOndWFpM6x916daL9S2XXAUaq51
	wr2BzMvi8XDOATxp3QTVS3I1zWmBftogbJ0nm41ylf+VBhLFOYGqQOmdOZ8A+ym30PvZni58Eg9
	ysk2o8gqp761wS08EUI3bxw+IOy8BuSfkLSDpwlMlUaT11V5Jwc2gaRxhk54oIk3MP4Yzb7Es86
	AzKoMVfVKytc1UpRaZJVE72LU31B/KHrrTf/md12kNL4lOxmAcJQGdkAprq2sC4ht9T1gUOebT/
	BpC/IKkD0CLnzBMrIPDx54Hl/HZ7DBhrhuhGRz4t9b0ZeUZObRNyJDU9HbcERwLoBmNLuXRTuqe
	J1Kzmh+TvEUTn4EQQxiIUXuJbAmK8mj90Rui67jL8lZKQNkntzyE+Qt5GuXjqD77kALHszIlffN
	B+CTJn1OtWjZPr8LQyz49422/8M=
X-Received: by 2002:a05:6830:4408:b0:824:659a:adbf with SMTP id 46e09a7af769-850fde29ef0mr6761148a34.5.1793057272791;
        Mon, 26 Oct 2026 16:27:52 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-850fc002444sm9060774a34.23.2026.10.26.16.27.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Oct 2026 16:27:52 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: [PATCH v2 1/2] pnfs/blocklayout: don't mark extents committed after a failed LAYOUTCOMMIT
Date: Mon, 26 Oct 2026 19:27:48 -0400
Message-ID: <8b5b2e8ecc7e1150c9b4505d1094da893db2e1a6.1792157092.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1792157092.git.bcodding@hammerspace.com>
References: <cover.1792157092.git.bcodding@hammerspace.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

bl_cleanup_layoutcommit() decides whether the server converted the
extents from res.status, which only decode_layoutcommit() sets.  When the
compound fails before the LAYOUTCOMMIT op is decoded, as with a soft
timeout or an error on PUTFH, res.status is still zero and
ext_tree_mark_committed() turns the extents into
PNFS_BLOCK_READWRITE_DATA, although the server may not have converted
them.

Fall back to the task status when res.status is zero.

Fixes: b2be7811dd94 ("pnfsblock: cleanup_layoutcommit")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/blocklayout/blocklayout.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index d54a141a89b3..aafcb8e30057 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -794,7 +794,8 @@ bl_prepare_layoutcommit(struct nfs4_layoutcommit_args *arg)
 static void
 bl_cleanup_layoutcommit(struct nfs4_layoutcommit_data *lcdata)
 {
-	ext_tree_mark_committed(&lcdata->args, lcdata->res.status);
+	ext_tree_mark_committed(&lcdata->args,
+				lcdata->res.status ?: lcdata->task.tk_status);
 }
 
 static int
-- 
2.53.0

