Received: from mail-oi2-f12.google.com (mail-oi2-f12.google.com [74.125.231.204])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 497DA3BB669
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.204
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474978; cv=none; b=M5JN75B3cmPHYqSARKdy1/xG2TvVru5wWdk9B8UY7AymCivOR5NQoY8SLQStGT1/5pyO4pnwKDG4AMA+1XusW5vG7cQF8UJntvI5kEwa2EqA9/28qhY1HDOv65+FjGH9MkvaFSYLxNGe2lHO8Xw06Mf3Gh0RfvbPGDG2BnYjGvw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474978; c=relaxed/simple;
	bh=uwyW9w/1ZciAbVAqAmY0cI45bHrXrtOA8e0h6tY65/8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LLHGcYcBkB+jYFCjvPDBC9NJAv8OmTvllY9abSctTi1oB5AaaQmhlp4DWhF/vUus1XwYGkoEhatYHT4GFrvAgu46pB+O2egDgEYT8jzSi3lc2TNEGSswawTJN/M6XOCPkXSPQFRQswjimO8figwnb4vBr88GzHzQwhlo5r8JZyg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=jUQzbOq5; arc=none smtp.client-ip=74.125.231.204
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="jUQzbOq5"
Received: by mail-oi2-f12.google.com with SMTP id 5614622812f47-4b37a3c0d7aso270476b6e.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474976; x=1790079776; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HxD/tKN5i/ZhMh3kPjgA/bAelNOrwdAP+IUTKzFlpc8=;
        b=jUQzbOq5YaTZBi+BEs3Bebz4gmzHT7oWaBYo3DZXE07E2NgFZPcjAzch/bRDx1seCi
         UYSk3huAofqohyM7QPFwwlTyrSb233oo96dmxY5zLPqOBox6BRFvrXu/6vrUq6s8JT7N
         7WHrRm/mjqgyj/0PNDWERn8EpGbuwb/37lr6hElXnTh3LZjev07YW6IcuNZnMQkHIJgW
         EcwlFq0Qo/ErC+i2Abnvf0WSskjKWH4auxVRXuI/lreqmGZasywLzCZpHZsqVnMWfdPE
         Ts20J2T2YHIyxpKghLMMzE8KK3f+iTxc52QDFMza3+FshyHYV7W8n+a/Q49CmqlbqkkU
         7XDg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474976; x=1790079776;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=HxD/tKN5i/ZhMh3kPjgA/bAelNOrwdAP+IUTKzFlpc8=;
        b=pBNGW8Oa4iKqzG9mD4ZHN5/hEAlYgClThWdqmjSPhWtZT30oxfGjiVHI2Rh074BBbU
         9MDi9fpAvbmGQHO2tAVbpgHECWGs+iHT1lnDS5zIYQIBeLwV7blyRAKQYp1Y2B+RA8OD
         n4oIjxZKPesBqspc2k3zKyYv9zmf92uX8+w9z3RVRGqg1x7d3qX6zE6hg87qMs8JtDuV
         5r60EXX2Oiu63HODotVdPnF9ni/sGm9mVa/RPMmR1mpLOUkOc9Y/iqa14v78gCv0MmoQ
         5lzOheEZZ5K1V0GFDj+PYuOPCZu5qGQJLAtDiTqxdvF587dqc9xvO/7FXRAK2OrjGNom
         GpRg==
X-Gm-Message-State: AFuF++l+K1hrEW78fVdsI5fM3ceKHu9W0A1A1Lwc4x2GpTtUC7fub0B0
	A6DokgeRfsut64aSAaK8RPSXXeLQFMyd/6ld5FvFJRoUFYo052xZXsiar5ouGu7qn0U=
X-Gm-Gg: AYBFou3T1vDNJeK3UWXUpzkawoSg2i+VWqC39BPLYLBt4rYf+nAovrVUl753JZYx3+h
	2F1ZL6p1AujA6Ukk4ulOUJ+j6nh4J2GHa6gpvv/7nf6vv0SeuPs9NU3aY1/CC5KLnmXOixZdwPF
	HKzmsOtP0m9a6G9su2Ml0FTLB88aLoj+oSiq/bqVHOyVmJSghgPbxz+dvoEe/dS3oh0xGYhgAcj
	jysii40VpMjS/SqbaW/mb2z9LX/CAoUeLR7X1ElCHvRHcQw6gXbBrhVEn7w1hmo+72ongZYSzt2
	sftdsMMZEkKDz5Lix/2gXnt/CdIh3MXFNmq7Q+g9yyvR5Rf57b4Pjmywr+AHT6r/6fmB4J039yz
	CcsbPt44EOWUCmS1V4UZrNutqw7vVPmXDvbgYk2sLHTR7UWR0jvxoWYqi3xzGkimkCGgKMB0Yeb
	t8oZPq7x3kHhI3+Jk87PhS1Mo5NJ1X6wKk/Ep2vRsQV8vKZvrQJjapoHLEg/Ap4iSkoIewcJz9E
	/ijWp2TTOW6pGO9OCaAX58O7hTqVdC7YiY=
X-Received: by 2002:a05:6808:1a1a:b0:4bb:efe7:51ee with SMTP id 5614622812f47-4c8a1a15233mr1780683b6e.19.1789474976012;
        Tue, 15 Sep 2026 05:22:56 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:55 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 21/24] NFSv4/pnfs: Grow the deviceid cache hash table
Date: Tue, 15 Sep 2026 08:22:23 -0400
Message-ID: <160ddc7a0299b62c02c202bcd3c1fb4b80e36aa1.1789474702.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789474702.git.bcodding@hammerspace.com>
References: <cover.1789474702.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The global deviceid cache has 32 buckets shared by every server and
layout type.  Striping deployments initially anticipate device counts
scaling to 1024 or more devices, which leaves those chains 32 entries
deep for every resolution to walk.

Grow to 256 buckets, four deep at that scale, for 2KB of BSS on
64-bit.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs_dev.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index a3b28409539a..e8143977965c 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -40,8 +40,11 @@
 
 /*
  * Device ID RCU cache. A device ID is unique per server and layout type.
+ *
+ * 256 buckets keeps the chains short at the 1024-or-more devices a
+ * striping deployment expects, for 2KB of BSS on 64-bit.
  */
-#define NFS4_DEVICE_ID_HASH_BITS	5
+#define NFS4_DEVICE_ID_HASH_BITS	8
 #define NFS4_DEVICE_ID_HASH_SIZE	(1 << NFS4_DEVICE_ID_HASH_BITS)
 #define NFS4_DEVICE_ID_HASH_MASK	(NFS4_DEVICE_ID_HASH_SIZE - 1)
 
-- 
2.53.0

