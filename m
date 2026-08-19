Received: from mail-pj1-f100.google.com (mail-pj1-f100.google.com [209.85.216.100])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DDE934B697
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 12:41:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.100
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787143308; cv=none; b=Ls1i5RDKDUoeJwq/L6kpYVTLrylt3W3R9CSlm6vLng0NcVBC8rL0AOSRV98+bWgu7x9ls+AeztUbsRYDn+D0hiGu/bsCrncG+8+EBcxmiUiE9XuEB1e0nDPtobPgIaJZ44eroEb++0eX2WG/52jiDyi/+W8WQqqdOAQbifWlieU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787143308; c=relaxed/simple;
	bh=aQ3chw+TmLBBlFTIr8hyMuy13DfCMu7XaE/jGgy0w70=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=gBrI+0KKJZMU7GalEiGhz/0NtBV9qCG0JKFvLKvodQYQ2y5+s0mDor3RITTzzcLP7aUud1hkduSq+FdBfkQ/7Q3S7EZPI6O2/b/8z429SUAxrW1eJGn7MbamnlLC2uapXYDmVqIfc89HKKgt9q3PiY73HqLYNM2qUxeq2OYjAEI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=purestorage.com; spf=pass smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b=DcQRsoh/; arc=none smtp.client-ip=209.85.216.100
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b="DcQRsoh/"
Received: by mail-pj1-f100.google.com with SMTP id 98e67ed59e1d1-38dfe910e9dso1158577a91.3
        for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 05:41:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1787143305; x=1787748105; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=WfPoOzYuuPGzk7adfHONL8e3h8QVdygeJyFqLyOvqnM=;
        b=DcQRsoh/tLlpPBIAxxPHqKWP3eD+EEG0FMQjMd8UHBy+ufOt30FYneWdPMzF4JKeZD
         x8DuUqLj6u7SHXMLOg6YS0UChXvkpIdEPDWePY1Rl58pW0p/y2aCRt9IGFzeXxECTP+K
         +vR5OG1eCrncq2JzzH86Q/DJbdvW+M4Z+VGDPHAggoOfTd6FENfOwyp5qmxweoJrXKZl
         XzBAUfGyod9CG+srTscUibxuoIjbQ1vOxRQhoXWMAfzigvTyYYXndmqhS29AIlGdm5Hi
         pNxaySskrOjyDkWk8NcV4tJdcTxPncqVViAIpET6j4TBCty+fsEZJ5oDgHyVwpzCaGUy
         kKFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787143305; x=1787748105;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=WfPoOzYuuPGzk7adfHONL8e3h8QVdygeJyFqLyOvqnM=;
        b=l4j4lfOYvJjUcd4m+7WIXGSN1MEU42QPCUxtXvSywv9Jwo69ZM2YUwKoB+BtLtxtgt
         tltNP3LLrs+Sa3FcE56d8+156qeR32gJzo2bnJhFkc5RSC5Wf20YM7sruyrPdBSskLwf
         DQ5hsjUgHyi/0PPNxaJqjSxJoTOr/NNUPaa8/sA0odOdZTCALRE3+x829YktlqnXyoBJ
         2oZ90YwtJSCQh5o2iI2D5HGuc2HTArAHcA5jeeUZfhE23sCZXfbTMg3jdAa+2pF84OKU
         iDXZQc6FRkfDPZTiIze/uCcSR3CWx3abApbVomY/hJ/HcoNf8mrQPEzLoXUTfqjHrYGq
         c4Ow==
X-Forwarded-Encrypted: i=1; AHgh+RrrCIcuedSWb2y4NmTOe51nxdppxuJrZXLlAaf/Dmx+ROqRacCfw248T2g7eH2OlF/gkB6hhSzlsHE=@vger.kernel.org
X-Gm-Message-State: AFuF++m6152O/lii9LzPgRN2c6rOqi2R1hWyZiS7a+P9eAeOxmn3m+71
	dhJGNF3qDpMGAIHKTslomOb5Gk8wRTjNMXWH28ONqcPEJlK2axCfesfciUIrJJvgd9GlQXGlL9/
	hW63lysnCZpei9aFR0bhfAsS4G7Pvc8r5immY
X-Gm-Gg: AR+sD10jXDEgPPtNtNgTpDFUZ6HqTnOqVYHYX0yXW/YcU+JzQli4VSq+XL4IdTfHXVU
	BPrxhJZyCHgpzn4N4yKG0FfAJaWf8pgomfXxJUMo6X6kWufgBAf9PDE00FyqN1gesDHYKFAgvxU
	DDjp1JfbPg1c/y2QYxI14fvBQjX8bn3GFjKYg05Rs5DEJ45N8xfeVs3MDggy0hzVEmiw4SAq/zg
	IZ/ds2H+yAvzOzGEfFhTQ+gPOHuEUHuY1CR3zOqWcuBNlfL+W9aDfP2sMl69+ZU5ue91GiGWuth
	9ssAeONeqqP8h/RlrfZKN+TAjOWUhzkJ8DzqkX5mlDVOlCwXUTL2w2xS35d5kuCwN1207UVItMM
	lnAmVqJdGadTkAUJ1YNLbRf78vYg2qS4U4Y+4mg==
X-Received: by 2002:a17:90b:4cc5:b0:37c:6130:7a5b with SMTP id 98e67ed59e1d1-39580ed0a57mr8772921a91.8.1787143305199;
        Wed, 19 Aug 2026 05:41:45 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-3957f71eb70sm202407a91.0.2026.08.19.05.41.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 19 Aug 2026 05:41:45 -0700 (PDT)
X-Relaying-Domain: purestorage.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 6BFFC34029C;
	Wed, 19 Aug 2026 05:41:44 -0700 (PDT)
From: tmenninger@purestorage.com
To: trondmy@kernel.org
Cc: anna@kernel.org,
	jlayton@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	jcurley@everpuredata.com,
	Tim Menninger <tmenninger@everpuredata.com>,
	stable@vger.kernel.org
Subject: [PATCH v2] pNFS: Fix EBUSY check in pnfs_layout_need_return
Date: Wed, 19 Aug 2026 12:41:21 +0000
Message-Id: <20260819124121.1587969-1-tmenninger@purestorage.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <ee8f174933d00fc58e2f54fd2fdd98d67919884b.camel@kernel.org>
References: <ee8f174933d00fc58e2f54fd2fdd98d67919884b.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Tim Menninger <tmenninger@everpuredata.com>

Commit 41d0a8ead9720 ("NFSv4/pnfs: Add support for the
PNFS_LAYOUT_FILE_BULK_RETURN flag") replaced
pnfs_layout_segments_returnable() in pnfs_layout_need_return() with a
direct call to pnfs_mark_layout_stateid_return().

The old helper checked the return value against -EBUSY, but the
replacement compares against EBUSY. Since
pnfs_mark_layout_stateid_return() returns negative errno values, the
-EBUSY case is never detected.

Fix the comparison in pnfs_layout_need_return() to check against -EBUSY.

Fixes: 41d0a8ead9720 ("NFSv4/pnfs: Add support for the PNFS_LAYOUT_FILE_BULK_RETURN flag")
Cc: stable@vger.kernel.org
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
v1 -> v2:
- Preserve the -ENOENT path so the client can respond to recalls when it
  no longer holds matching layout segments, as pointed out by Trond.
- Defer only on -EBUSY instead of requiring a zero return value.

v1: https://lore.kernel.org/all/20260817154044.1799634-1-tmenninger@purestorage.com/

 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9f32dd7c4c63..594350f4ed2d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1389,7 +1389,7 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo)
 		return false;
 	return pnfs_mark_layout_stateid_return(lo, &lo->plh_return_segs,
 					       lo->plh_return_iomode,
-					       lo->plh_return_seq) != EBUSY;
+					       lo->plh_return_seq) != -EBUSY;
 }
 
 static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo)
-- 
2.34.1

