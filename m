Received: from mail-ot1-f49.google.com (mail-ot1-f49.google.com [209.85.210.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C14AF42C508
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:41:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653698; cv=none; b=pwHUVtiihC7SAqvvECnLb09UXjw7KX86UeF+50V8D+KK3mOF9JpO2r72KVVmvnlhG12Se9trQgFYHFIAtfIX5CLX3jrjyLpfYhVyShRyTzk2tgi8yvm1WsISfythwASRyP2lgoeeVhbfKEtBEm4Sg0H9xOWNBwKgAkf8MaNX6HI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653698; c=relaxed/simple;
	bh=N5JDZtbP1oVQQsjMPbNmcHJ5TqCW5ho6wka/grv4FzE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=odcfY2G3M5PeQ6CH9TBGnl3q7Hy1noXjEp9JnRJGQtUMcS1F5bs6yMh1NUYMSFNakqWqm+Sus3fpHm39njaK1ZeDULnSHtyUZ0LBSSYUAJaqfl4+/5m668hR3YwMgAW0cuDvOyAseC5BXdiIzrPrVvUjPvU7EiAFB/nZEIwwX6w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=NsJaHRrd; arc=none smtp.client-ip=209.85.210.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="NsJaHRrd"
Received: by mail-ot1-f49.google.com with SMTP id 46e09a7af769-7ebd88be784so251239a34.2
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:41:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653695; x=1787258495; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Fx+DSzvMV7xbckhhOTBdms1ca/lfgUKsq/ZcBMJSVss=;
        b=NsJaHRrdeEnm0huoqTM7edEJHO+0O8tXBeoy40GEsCMqWhoZ66EhQ+0MLz7KwR18mJ
         pqS4eIh8mbOF3tkJzOS2U4xrcJNG0gbwP04DPWaTvDIpRjf1yN+lvuUC9Aw+6VjuYCxM
         cpF8rkHySXiVpaqNnoHA6pD2SYVOSgB2jdC0qN/OSpA+ZcUtAXz+9dB3sqzCZEdMcWk8
         xwRBw199IztOIs3Qm3jYgTR3AmAI/05g6MDxcOcX0hL+GllQC3NQT+6dSdm9lhwZxBd2
         zOypCUT88xjpnrXt+1HzkdUn3DxBJSbZhxbjNOXBc0kxPdNB+KOky8TdbWQJLNxKetaU
         9EUQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653695; x=1787258495;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Fx+DSzvMV7xbckhhOTBdms1ca/lfgUKsq/ZcBMJSVss=;
        b=YXDAhNeGrLwRI1uYsOVWUciY/s+zE/cYdK5qzm7C2NooYo8fqTzjGYxEy5zwAZrhDx
         TP+5MXfvdYk6ov09SVoCJ+C91C7s3Lkw1WECyahSkhKpqX0sG3GrwwAP8OyxnqaefeLJ
         dTC/2EcfNjZSg9n0yw5+fDS5xSfMHEyfHPHlBSvn7INNGATxTN29rS13k7pygx5P5Y6W
         Uxdh0XZxtH9qmKxzJhs3JjK91DDk4ZzxAYlQjOZLAN5BpEGDj3NPYI7p9+lqE6S8sYSt
         B3yuZip0L0XE+LxtXxyVUCpRZ6NJsRfjZYQIwKqlpkNplYnEWOEiiV1BzRtGNds14ITq
         grLw==
X-Gm-Message-State: AOJu0YzBfBfucvTvl1V8qJVQl26hVfpVgCUQdfddnLlLuO/em/Szh8lJ
	u7ZJDlaa4nvabC0QErKDfjek4knn0jvaVichyBjvzaEoBe/iDn9lEVmO6HGyrg/Vv9w=
X-Gm-Gg: AR+sD13Ra+kVLpCQoSh5PFBNju/ZUY2aC0/1COiAkAJL6F9b2zhRV2nzCHSz/aDhjxy
	fl+flTV3n+nbVyzgYoRobq5xEUDW9j2LDMSxYCQs5IbXwvtaUfaLcqUrOgbfR1I/kBBkR4zpGIW
	1FWYG6LPfESn3sXkNGS4HuT++HzA1SSPud5F6Od2cQgxcmc9QYVYF93RMHz9vnWNiUDmOk74Sft
	laB8DKmlkOm5wctcBadGoejmgdJnyU9Wmo6jPkXN3GgOzwLaI4cdZ95AqoNhMzOxOqXcB7H1H20
	OowBfTI0lg7Wgg5ZnIabgJXc35jM/MeL1N6LqGIzf56qQCmY0eHWRl5u3xI9jxaGyKAvKJb0+7d
	N8+7jKcgIjEoRKXi+gBbJOHG6TvnQObFcdtHz0tEcD9jw8gPAQItT4Oir7ABdSFdTgLMQaDTKVI
	RqKkrGpYYKnqS9G4ACCAD2fdy0OMpPds+vQyBoJXA2NYkmMZAs7sfelGviH46wdTrXc+U1uqqmQ
	mjCOA/uroonnkDLxfMqe8im
X-Received: by 2002:a05:6830:2b0e:b0:7dc:4a43:fb5c with SMTP id 46e09a7af769-7f3de64c451mr480008a34.11.1786653695504;
        Thu, 13 Aug 2026 13:41:35 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f3c9e23b6fsm3087958a34.25.2026.08.13.13.41.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:41:35 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 2/6] NFSv4.1/pnfs: derive loga_maxcount from the LAYOUTGET reply buffer
Date: Thu, 13 Aug 2026 16:41:27 -0400
Message-ID: <0653ae1c2d2565701982bd8887fbce987e406308.1786653456.git.bcodding@hammerspace.com>
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
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 10102bda6a38..88deefd45202 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1209,7 +1209,7 @@ pnfs_alloc_init_layoutget_args(struct inode *ino,
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

