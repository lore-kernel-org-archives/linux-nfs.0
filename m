Received: from mail-qt1-f227.google.com (mail-qt1-f227.google.com [209.85.160.227])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E75FB42376F
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 15:40:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.227
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786981251; cv=none; b=VG3gjhfDwunzgYEcjlMprpb7TwrMMN8L5bXZh+3B3SV4Cw9VX8petmmuMA6ihvbVnVwNj4WJtPv5WVwTCKKwDC+Iq0X3JFGF65+C2OfcBRDjmozK5icoj9OekgQiiOjKaVQZKe1a3o/rQp+IzcgeWvCaA/vvcrZD6L/+G/E3fvc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786981251; c=relaxed/simple;
	bh=KwsvnoEHCvYF2uIrLWwVXtjUnI6GmMwqQ4JSbvpEjRI=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=tUEgoch7bY8WhAyoUQIO3bO1+FZgI8DN9pQ1pDib8dLSJmfRa/BitIDbp0+PyWYcHpi1/97eJhlxGm9vTegWOb4zL6POVfZwOA6uW9b1tSVbudZ9Yi1cHgKk0wysm8LANrMzE0YguNmKwU0xFqx+L/2VJDEFqslRA4g1QbHtkIg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=purestorage.com; spf=pass smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b=XpZnFeyN; arc=none smtp.client-ip=209.85.160.227
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b="XpZnFeyN"
Received: by mail-qt1-f227.google.com with SMTP id d75a77b69052e-51c2a818fc4so23660861cf.2
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 08:40:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1786981249; x=1787586049; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=48/o27CH4bla+GkGB+3sO8ImvqwmZCfCNEfhnKyYNX8=;
        b=XpZnFeyNNzT5GV+57tJyL+wDZ83DaBRIufwmR9GQvjdurwA/QIAX80GAZ1rgB9+hvb
         ym4LGJRCqIxWKlhrQBzWGZXB0Qs9K5RtVJgbCVcyQ/lefuzBZcDXccTICm5KEIuRKs0E
         fM0y+NfBsVVbZptnv0io8a/ORiGh07TCLmR7PU5wJj2waKsZPH6uTAnBcAx/xKmfOdyc
         FsMA3rlX0NRlBdGle219HZ8pn7nSZiPLHRLouRtn29BJfZQ0jeOf94TS3QqF1YKLKiy2
         BeMf108QEyknzybU8KNnB+2yKPUDf1sJobP6+knkzauJqXFCViusKWdWqxlTV3W549AI
         TsNQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786981249; x=1787586049;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=48/o27CH4bla+GkGB+3sO8ImvqwmZCfCNEfhnKyYNX8=;
        b=WCRUZMGiNPCR14EsDE2GYq0tJbHFMtk+xWrzlvRvtgws5Owvy7J7CAIC/kwNMWswl1
         w3AXHbyJYit9LEKwxVKKcUegTsidmGGaO8zHFE2+GOlz+FXbIp2VRhiE8j+AFDlSeusT
         z/TKEW5ssx4SbfPV887HohkP6AiTpAKrE6SkMnCgVIlL/46OewMMtG7wfxBmnnhsA8ts
         vT8xDbzaiLQ1tvQRUFfJ4lACJdwJ3D9Jqh176D1UCgUiSlf9XYC9vOTXnhX2yNKi7P5u
         4ikJPOQoK60KkZmdM7fjp5+WM5gM+s1WE2ChSP0uurOLJAQZijZLeaDChzzxf/qTptjJ
         Ik7g==
X-Forwarded-Encrypted: i=1; AHgh+Rqf7m10TXKOJcO7gQ9CTHUDfuRFBPip3r/t62KFp+pvdTNqvIU4g6G9yMEyYicNktVmp1y87iaBlfM=@vger.kernel.org
X-Gm-Message-State: AOJu0YwZkRPNh7KAtN4LTuZ/ay3hNGlJB5V00qayX6jQKdYyezXO4CjG
	0hHWhyPuB3PBP8JPy1F4kXKt1rN59zxChwGJYfn8g650TFRnAUlar9is6cZR37/0X3et2n8WkFe
	FiiXmdc/4hsoQU/7RcZJruij8J0aeqXisWqAs
X-Gm-Gg: AR+sD11rV6dKsUzOEoGuhvDcJEO6EXsDCPeDIq7kUy+i7xuppLH2snQQHYnKmiT76Ip
	X9xYX8C9qnao/Y2UGmvW7HJfqqumkvHhq0dRU6Mg6s9bfdmB/EmTxgQ5aoVfA9sA9A1tim4k8nc
	i68V1c19bVhsRc727h07nkboo/lOAHFJBwOpyguzh0YK1cAvxK2pX/hLshbdp/DDtaFry5FWWvR
	0YjskYC3knJaOkVrzADwAJGzCiJBv2a9a518kmHMXsVpKWDPx+0iPsoPIu+Sgt7XcNm2CmShxXe
	IBIM70upAA51AcXMMRxG9y6Am6H8tOW6hwWT1u9X+jIBd3CsS3+iu4tVl0gOGVoOGeQJ7wRAtBZ
	6mkn9jbsfblEPZqR187BkobxnaJYknPKGABQzTw==
X-Received: by 2002:ac8:5805:0:b0:51b:fc67:c73c with SMTP id d75a77b69052e-52d8536169emr269542441cf.16.1786981248628;
        Mon, 17 Aug 2026 08:40:48 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id d75a77b69052e-52db6297d8esm260121cf.29.2026.08.17.08.40.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 17 Aug 2026 08:40:48 -0700 (PDT)
X-Relaying-Domain: purestorage.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 0D25834018F;
	Mon, 17 Aug 2026 08:40:47 -0700 (PDT)
From: tmenninger@purestorage.com
To: trondmy@kernel.org,
	anna@kernel.org
Cc: jlayton@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Tim Menninger <tmenninger@everpuredata.com>
Subject: [PATCH] pNFS: Fix EBUSY check in pnfs_layout_need_return
Date: Mon, 17 Aug 2026 15:40:44 +0000
Message-Id: <20260817154044.1799634-1-tmenninger@purestorage.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Tim Menninger <tmenninger@everpuredata.com>

Commit 41d0a8ead9720 ("NFSv4/pnfs: Add support for the
PNFS_LAYOUT_FILE_BULK_RETURN flag") changed pnfs_layout_need_return() to
check whether pnfs_mark_layout_stateid_return() returns -EBUSY.

However, the new check compares the return value against EBUSY rather
than -EBUSY. Since pnfs_mark_layout_stateid_return() returns negative
errno values, the -EBUSY case is never detected.

But pnfs_layout_need_return() calls pnfs_mark_layout_stateid_return()
calls pnfs_mark_matching_lsegs_return(), which returns 0 if a
layoutreturn needs to be scheduled.

Fix the comparison in pnfs_layout_need_return() to check for 0, i.e. a
layoutreturn needs to be scheduled.

Fixes: 41d0a8ead9720 ("NFSv4/pnfs: Add support for the PNFS_LAYOUT_FILE_BULK_RETURN flag")
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9f32dd7c4c63..fb141cef4d54 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1389,7 +1389,7 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo)
 		return false;
 	return pnfs_mark_layout_stateid_return(lo, &lo->plh_return_segs,
 					       lo->plh_return_iomode,
-					       lo->plh_return_seq) != EBUSY;
+					       lo->plh_return_seq) == 0;
 }
 
 static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo)
-- 
2.34.1

