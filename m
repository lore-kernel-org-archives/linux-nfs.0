Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D2523494291
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 12:26:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792412806; cv=none; b=eP9KRz08IayI2A9Tc5UslOvgFNmCm7X2SQ89OJch47ggXa1sDrQr6FxolyMGG04lpF0H19Cp51gwiA9XhSZSH+EE0wIJu4EjBtXuo/BS8FdFqH8RW8+R6V0wYCuPibJENJ0mqsnQFT9T/tPLO7aaV127+I9KiqBQ+JejtQdFqAc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792412806; c=relaxed/simple;
	bh=2J4QDg/aPsDzAlpppkrAn+r7m+C0v3TwtrRFcMn0Hq0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=UlZjL3/OQUdy2vxvIj+z44UXUGcumiyhakq7vwLDq/3V7QyIfiseSdLBRO4E9PxR4USyDrr75uPiJ/42rcvM1fIeIJDbv6tTJD/2O4B4CPLAzjR6AY3PXwrefPBxNHgOxwXv8bOvRVZKOdweG57Cui+FVKyLE4g3czSAoxc3RY8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=klLcXACd; arc=none smtp.client-ip=209.85.128.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="klLcXACd"
Received: by mail-wm1-f44.google.com with SMTP id 5b1f17b1804b1-4a1ec92f655so6309515e9.0
        for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 05:26:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792412794; x=1793017594; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=EtKFCm4Kb4fRyfZVN6sFqWcdE1J66fmbQkE6r6uUAyc=;
        b=klLcXACdA2X+s7HCk4dX/NKhaCCFnczanr/W2bKJSEjkf3+aVXYcl5Qsk1fD9xGBH2
         LwvVNje72D993rHpXuM08ZiqwrZmr9uy3ChTkPWDwzMWAmPl64DCAqTtXvwLYH8SylET
         F4bFDLrGVAr27oiUN3XAa6h/gqSGmw4Z9j2ws9/zYQUR2VKOPre3kn54ZD3BmWCcX2Im
         IpXEWXQYiCcNIh34dyE0XwHHIZ8frX0kYd/0YoB2ndR0qEv5NRo/OC0kKCqkHbrpKzM0
         Sf/EXIVxurWWMEQIkMArr6o7bd8I9SEzcbLB7Tx//32T6whFxw41ih/81ZCC9P6ZbpYP
         v8tQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792412794; x=1793017594;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=EtKFCm4Kb4fRyfZVN6sFqWcdE1J66fmbQkE6r6uUAyc=;
        b=ZZivIodTE8hjlXaJgAcMkEYslBb2VWmGrhIIHKihhop5ukddXMFLL/W1nWoAkFLe/4
         irSDvO25DEFxOzR+S7Ue1igVCnZUr0jiI1IA/Y9VjUYdsO1cq+xpkaEXr2i8ZshA7CNP
         cET7DJEKj53uQ4/TguHtS4r8d55eLnSQG64PkIx1Lyr/MPA/rbTnH7Rw4OE3tvFUcJtJ
         q7U36GrUloZguwnpFVzBuTEfJK4nxZ3llTWwkpZokSkREibhOINWMl9vE61zUygnBlrW
         FHp3m1iqYlpHTb4XrnqOfzhEtsMVbuI0RJYLgL0FPQLtSoP0UrP09UvJqKqBEYi9AasF
         cHEA==
X-Forwarded-Encrypted: i=1; AKwUvBx6ZG0d7LzpgCoVnYscgNIn9hMti396orvFu9MU+3eknXBVlv5Yu0vVwC4V9jpIufbgom3uQo12Fpo=@vger.kernel.org
X-Gm-Message-State: AFq9FYKUpbMcGAL0nhy4a+9UQW3Ka4skn+tAtYNMXEGJmTExvZz3cD4c
	uxItm2EqwrlLOFXbkR6MPSQ02n1UC2f+QePkBV1D/eOekKScANtG5VOk
X-Gm-Gg: AYBFou1P8R/sQ/5IEqKH8Ac0xpJVJXwAyqzAdYSJZ/x0w3F6yF8XAKpsI5TPvVkanWe
	PlyjYhCWAMkFZUzoafRW4rh11vpA+N6aHEx2MBi/jIjA44T0wYcHk2I0LRpHz1FkZJvFkQQf4QH
	tZum1klZo2O9rnLJ5hyKQ/UbMDha4QSEX0zKUx4UJr8hmSXGTMEE/6LScEuDbfQKIX5AKsQGJEk
	ao2HMM93cfmJ6LxrFXw+SKUmx7xx93I4AhZlgyMjwH5x7x5kMQWimuw7amNc1uyQ/pkmrNlvY8E
	7mGxD+UJPr8qQUJzAL3JJ6RSoBF3AKRTZuIwle/UimuUGfvg5D2CrcMMJ4d6XFSGImT5jtTJp38
	LqmFfTw5MUmFel6zHMxSEpx4jjxtf8m6AUqjBpMOE2r4ZNO+ppN5eYzt+dbFlh+GnnYfNMTLv2P
	dxl9mc6GJR6pCunEAXz3fxtIjzQB8zN5fvUZ/s8uyB43GNMmA0NIIkTT8HCVnZdSCuG6qyMOCFS
	PNGRU2jpWp4Tyg=
X-Received: by 2002:a7b:c3c1:0:b0:4a1:8849:17ae with SMTP id 5b1f17b1804b1-4a1c663b460mr182215415e9.1.1792412793709;
        Mon, 19 Oct 2026 05:26:33 -0700 (PDT)
Received: from localhost.localdomain ([2a06:c701:4778:c500:e497:1486:f91f:acf4])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48dfd4e7889sm23101961f8f.24.2026.10.19.05.26.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 19 Oct 2026 05:26:33 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>
Cc: Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: restore directory index when resuming readdir
Date: Mon, 19 Oct 2026 15:26:30 +0300
Message-ID: <20261019122630.200561-1-thnkslprpt@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs_readdir() restores the cached folio index and cookie when
resuming directory iteration, but leaves current_index at zero.
In 32-bit index mode, nfs_readdir_search_for_cookie() then
reports a folio-relative offset instead of the absolute entry
position.

Restore current_index from the saved logical folio index before
searching the cache.

This solution relies on the current behavior of 
nfs_readdir_seek_next_array(), where folio_index advances by 
one and current_index advances by nfs_readdir_array_maxentries()
for each full, nonterminal folio.

Fixes: f648022faa68e ("NFS: Convert readdir page cache to use a cookie based index")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---
I tried a couple other ways of recovering current_index like 
tracking it with a new variable in nfs_open_dir_context and 
deriving it from ctx->pos but the first option ended up expanding
the change-set drastically and the 2nd option had an issue of 
freshness after directory changes.

I was able to reproduce both the failure and confirm the fix is valid
locally.

 fs/nfs/dir.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 49394123bd09..a1ad04b2f307 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1253,6 +1253,8 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	spin_lock(&file->f_lock);
 	desc->dir_cookie = dir_ctx->dir_cookie;
 	desc->folio_index = dir_ctx->page_index;
+	desc->current_index = (loff_t)desc->folio_index *
+			      nfs_readdir_array_maxentries();
 	desc->last_cookie = dir_ctx->last_cookie;
 	desc->attr_gencount = dir_ctx->attr_gencount;
 	desc->eof = dir_ctx->eof;

base-commit: c03c1a14507dfaf8b856c2608f9ac216021fc222
-- 
2.43.0

