Received: from mail-ot1-f51.google.com (mail-ot1-f51.google.com [209.85.210.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 42211374E48
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:41:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653700; cv=none; b=tgmxkWlTQx8fB7aa+GT3ytFaRY00yhm19wM4Y0QGBoyQhj7r/DMIhdLjIYa+txvMxosVFxR6MYwC2M8IOELgvU3gV1IY3KfrtOkpEaPT/4tRFFzJf0T5zG4HlCpLyZCFhonZFU4+3DLiMSrMgN6tMNak2tg2pSh/qAS75YK9YBs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653700; c=relaxed/simple;
	bh=u+ORa+RKNbjRVg2sFjZF9wc7JldnQnUZSIUHHGSdJGg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tEDyJ5JQgRxkYOvAhaVF22xektN2550bTtk7vVItUMs6bqUlu7qHK+tnIcU9ZdkQk3uUcNyjLr5rl/mxmd8NxpvVOQVsuyWsWtQ9EuHIKSzpc36hiAMQl2RR1tYF6srN/MCSq/Bw6GzdLCNNepot+vjdGxnT+gSP5R4YYvA87YU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=PFwGhfOk; arc=none smtp.client-ip=209.85.210.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="PFwGhfOk"
Received: by mail-ot1-f51.google.com with SMTP id 46e09a7af769-7ec1e9d3359so305149a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:41:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653698; x=1787258498; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=VplqIesP/lbUj0psrSYInwxjGxamaCJ+7Qq2TJ4ICt0=;
        b=PFwGhfOkffE6uTRyPSADs+ThOv1uVEtz6Y4Ipm5Jw4AGhMW/t8nbSGle3Y/49RDJ+/
         MeNhZrrlPbDsBTfbg0HxKa4VbK7WIiDGjdDdaZLeCG+llcxR+C8nhlQ2bl9Ds7Cnw/J4
         whv+HBZkQ6kEnsHSiHwGxi6OzeNnTsVEAXLK4A8cwMnGXs0M24zhk7Ggi6KpokUZ/jPO
         djIoXihckkEpTvQkgkxLvkDuVb+XKUnnbCMrApQLxPK1amaPg5KrptSzX9MamORoHspu
         Rdhtf9IuAiURgBjewBtSPvYnVQaIOeU9n8J8QLr7r0uevXxcw6wc+yijeIVdrp/X2LZB
         bq6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653698; x=1787258498;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=VplqIesP/lbUj0psrSYInwxjGxamaCJ+7Qq2TJ4ICt0=;
        b=PJSexhwP1R1jSji75BfnrGPToDgGqyjtXTRjvIFcA0KP5Db163YXPgoVqpayJ2UafU
         zzbFI9Jnt5l9W08cp/aiJ6XxOta0Y/Gl/WOyxF8the/c1g8ktWN74GxVHFRNA/LIaUW+
         MXs8lZ5TJcZrFCx3s3OXhKtZ6rShdYze/+aJnfwRwP+hDLBfTsU/wXWVYfqgmDj3GfCd
         seqALnWRaJWnOTXC7PD5CopL0RP8fGgd2Mn2G4qtlH3Qzj9RUA4Bpvu1UUbxW5xAODmA
         h98CENgiffwJt/xFkPy72O7x5UVFZeydc+C9DPyoG0pfyvU3pi2Bu+EYbazVd7+rBrnc
         sgsw==
X-Gm-Message-State: AOJu0YxHDWura4ForRgqPTdLkk9AGzmuGPMjDyxVPu2OjuuNHaKKwJy1
	FPiJLXowqteuOQm92WF/Ob/tO2UuHVbrSrBfQ50jQry3MWdV+ItjxinTabNsnzonxkQ=
X-Gm-Gg: AR+sD10ecXz/bgQzu8Vq5ZHZ5IwfVAQzc5PM9YaTd+58V8thg/0PJakaD8QDJkrbZIA
	4BOdwEyPKsmtqoJnJ7VT27hkt8hUJSexdHoCLugPTsfGcKSoQjlcAYtmS/U0rX3iBM7fCOOtMpo
	AXEgnkfJP0AkElVHlYL0Y9Vp0Ofj/Y1A4oJ5WXazDNbbn7kUEc/H7UNCvA4k8ivdBVqfPdovW5j
	r1/mzSD6OFkTPZKAUGV44Csv0G/UviK+e3ZxBKTHeYeSrnK5Xr8Sb7bLf03tYVmu6wXuze9P1jf
	dXUutLwIpHz2o5Jd/lWobol0mnpJWZTiWtRHVDmcbpmKCad2JIgtPwh+trZBhF6z3wR1IjNzPba
	2U8iow0NlzZVXxrsz/fIIhNs1fyiaklKCRsNZPaUKF8bM53V4Dw8jeTH/XiA8FTmiwVGF26Os/3
	gMGG01cgmGVdbqTXvjcq4cyVXwlWr+hr+70eHVD5DiPBpPQHR7s/BjmZfU3a4Uopl7LjART+TOd
	qqLciso1jjipFDzprX4pXurNEzRZYYCaCHB9XjFwI2gUqg=
X-Received: by 2002:a05:6830:6085:b0:7e6:d0ad:5254 with SMTP id 46e09a7af769-7f3de50a311mr489399a34.8.1786653698007;
        Thu, 13 Aug 2026 13:41:38 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f3c9e23b6fsm3087958a34.25.2026.08.13.13.41.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:41:37 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 4/6] NFSv4.1/pnfs: treat an oversized LAYOUTGET reply as -EMSGSIZE
Date: Thu, 13 Aug 2026 16:41:29 -0400
Message-ID: <c883c5d4c08ae3f7ec605e69beebd0145792ab13.1786653456.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653456.git.bcodding@hammerspace.com>
References: <cover.1786653456.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

decode_layoutget() already detects a server that sends a layout body
larger than the reply buffer we provided ("server cheating in
layoutget reply") but maps it to -EINVAL, which pnfs_update_layout()
treats as a transient error: the client falls back to the MDS for
this I/O only and re-sends a doomed LAYOUTGET on every subsequent
pageio attempt.

A server that overruns the reply buffer has ignored loga_maxcount, but
the client can recover the same way it recovers from a conformant
server's NFS4ERR_TOOSMALL: return -EMSGSIZE from exactly this check so
that the layoutget path retries once with a session-sized reply buffer
and otherwise marks the layout mode failed and falls back to the MDS.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c23c2eee1b5c..6b46ed346a77 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6154,7 +6154,7 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 		dprintk("NFS: server cheating in layoutget reply: "
 				"layout len %u > recvd %u\n",
 				res->layoutp->len, recvd);
-		status = -EINVAL;
+		status = -EMSGSIZE;
 		goto out;
 	}
 
-- 
2.53.0

