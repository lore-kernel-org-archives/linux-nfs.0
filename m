Received: from mail-qv1-f54.google.com (mail-qv1-f54.google.com [209.85.219.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9061493625
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 12:56:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788526579; cv=none; b=j6JcY1UnvrCHWJYNlLIDwuG0zUXTpJQ94urTyt0+2GS+H4ypP64nT6MaCE6/xisRIbBrDQM8Km1r1oeMfV+m6MX1Ddu5l0KnhsggGR2Th57BmU8i9D/NB/CwjAaDx/0WTtEV7L5y/8auhurkdjphpeSIKnMB5xDerLuHXVrfYIU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788526579; c=relaxed/simple;
	bh=uKiwJrZ2jaUdP1c6FLeGZMylh3k5Nm9k5RAR9wxo1kY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=inEbeTKwxt+lUpAGILDHtDyDkgksYlJfzwcKo5eeQQUVrjiIIWDGc8dVL1vKOxhAnixLEfDBtwmIuj2FCKr/gGy0A6YCH9OsTTT9ELHd0+3vX2FFnQNyGcU0X3Wi+OO2HSlhDxkvvNVx26gxxjtNUic+NbA1+OqUYSDNhXJndFc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=RUa4WmnS; arc=none smtp.client-ip=209.85.219.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="RUa4WmnS"
Received: by mail-qv1-f54.google.com with SMTP id 6a1803df08f44-90cc372d6b2so13494386d6.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 05:56:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788526577; x=1789131377; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=p5iEvTe7N32xo8uZC4X1eyf1Zq7rUeRoKfMbO06gKwI=;
        b=RUa4WmnSfeCZ3UkqWmsGluoHKScR1gJtSmfGbuTffk47c972ZbSQ/6wSIENuPL+DOe
         WkH8wqzrRHJkHH+Eqwsd+9Qbb2sUQLrQ5OLD2CFTdR7qTOmzDyVX6p3NrQVaBYaNNezz
         5GrtbNtYJJ8/bltv5z4HavATdCrXclXuq7KejYrO8B3bCiCFyN1T3d4VzEoZtwVg3hVJ
         3OxHs6NMiFZSdNIPxVShz1B5/7sOA9T2WVyhZwC7x0yg9LH5aUBZCm1gcRq3e5ZJIyuk
         Vd9/F/0Qo+p0nof/HDjYef/qYlIEfdmUeQEKQb90/nN61EjjuMQiVviQdDJku75pBMP+
         y4mw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788526577; x=1789131377;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=p5iEvTe7N32xo8uZC4X1eyf1Zq7rUeRoKfMbO06gKwI=;
        b=J9jqizjkVU82t0jZooOy1bcfoao2Xqsl+XtqSqy35SXsNAN4/mKBmOLV2ujA35fEL6
         rOGH3bUglAU7kwQMiuWf0RfTnkQIa7CBY+pDkC7V6RQl9vVWHritvv9mtxXJ6A8OGazT
         mNwdlppRH6Yf4HwNF6ZnYjp4svcawZIxFkaulAvQUh+63UuF0jJ+g/RhSn9NvLW3ZHFl
         TyeehWXSYCB9JNjDJ5GWZZggQ/Z+5329ik8KwGlnEXp3ENKaeMP1GbJauFk4g7IbUV1s
         WskTgE9VlU5pZCx+Y0vh1LcmSr0MNNefllTB1z7PLSQIUpg0P+Lo1K0czvDMQidEKuje
         kFZA==
X-Gm-Message-State: AFuF++kvwx2Bt/QzO/01SBGLD2Mrmy3Ej/IhLpz0NF5SP18kAIIboyxo
	5c1fEQJ09kLiIQP7NTVS9ko0h7NNKtrxeGfDMqI/tp3NqvK5Ob1OhYHFlc8+BvM3DVw=
X-Gm-Gg: AYBFou1n727m0ePcScD/CLYmoAXD2fYbg66fHzGlJLi8tEsJFZqLemgcgMfELXfH/bs
	BA94B9VgXe4BHcr+NpIubyUlevRyDStpiwQHez9mf2ycgJCBPxWxEXaHAywErP3Pvz9vA+AzMX8
	aYnT+IOBrBRRX0Wf/ZLhVp2hDqKfF1vFY85Ux1u+pE5pwu0b22Eo0c6cH4LQZj4R0Tq3mE4ai4W
	HldSw1sGYox/woiyVQHEZLeF1Y455mV0ISH1Ri0/tV98uJ0lyxcALJAZXOTnbMPIhkvngN/GMYG
	Kf6bK3NKXh3TWjc3ZWx8cEKRma12IUgvgNHq3pDVU1fIBzjDVhummY47r2eQhjb6I+e1YLBju7a
	sFS0mQ4d6tUj8Yivh8GZ03jwp4TuRo+8lsCF4K3F8GdKSB+qbSrlNXP3x2WpjAyvfnfLomYDb5s
	kUpuISgNO8azkX5gplJ0ucISFECGcfN3HqPNF4ZZBE/rxmvnw0K/5TmqPyZg5HrI+t/XMxDS+a0
	eKd3WM4KSjP9vmC+/l3oIJr
X-Received: by 2002:a05:620a:17a7:b0:939:57ad:4586 with SMTP id af79cd13be357-93980360d91mr550181685a.16.1788526576569;
        Fri, 04 Sep 2026 05:56:16 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fb2fd82sm203324985a.17.2026.09.04.05.56.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 05:56:15 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 2/6] NFSv4.1/pnfs: derive loga_maxcount from the LAYOUTGET reply buffer
Date: Fri,  4 Sep 2026 08:56:03 -0400
Message-ID: <00b6104da8c79abb2213c3ef9deed7db63330a55.1788453839.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788453839.git.bcodding@hammerspace.com>
References: <cover.1788453839.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The client advertises a fixed PNFS_LAYOUT_MAXSIZE (4096) in
loga_maxcount no matter what reply buffer it actually allocated.  The
two only happen to agree for layout drivers that cap
max_layoutget_response at a single page.  Block and SCSI layouts
allocate a session-sized reply buffer, yet still tell the server it
must not send more than 4KB of layout: a server whose extent list
encodes larger than a page returns NFS4ERR_TOOSMALL even though the
client has ample room to receive it.

Set loga_maxcount from the size of the page array allocated for the
reply.  The client never advertises more than it can receive, and any
future change to the reply buffer sizing automatically carries its
wire advertisement with it.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c5d1951d5400..9bef2997f512 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1210,7 +1210,7 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
 				lgp->args.minlength = i_size - range->offset;
 		}
 	}
-	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
+	lgp->args.maxcount = lgp->args.layout.pglen;
 	pnfs_copy_range(&lgp->args.range, range);
 	lgp->args.type = server->pnfs_curr_ld->id;
 	lgp->args.inode = ino;
-- 
2.53.0

