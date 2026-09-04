Received: from mail-qk1-f181.google.com (mail-qk1-f181.google.com [209.85.222.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3676F490C14
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 12:56:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788526577; cv=none; b=J+/ejAKZL67bBFX/8xzYB+2trng2Q3MCFx/rPYKiEMffzluYhS54idtzfxnf1RZAiDBQXrH1+WViw0lj5hk07h2WDV2HkBORunJmCvYiVTy9i2h46yVU+vCEs2B3d/9z/anoiimBw6jCxfvkoRCdV1s8y7MNuVvMeZ1irY4cx1c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788526577; c=relaxed/simple;
	bh=8Jh0gpDvr2PVpP+ddAMmJnfeyOWg5ZUpivC7u4tbb90=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sggykoFw24DiVJ1N+TMa4jzn5iJQ2pdmND+nYTsA+OWjTw05ip55XbRtW4xiban6GVxd6qr3dPR0/j/vyQYoLgjBFCMsUt6DK5jkM1FuWIfYNmXzSdz8lf1n3EpXPl77Tft86OrZkZh4x0eLTlyqiffWs2mad+G1C2F1iHCkZDk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=bH0Gmeoq; arc=none smtp.client-ip=209.85.222.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="bH0Gmeoq"
Received: by mail-qk1-f181.google.com with SMTP id af79cd13be357-9309d4ea213so100824685a.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 05:56:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788526575; x=1789131375; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=dvmdU8i3mtPssfJfI5cIhNIHS5XMU0TX9nkgPiXlkBw=;
        b=bH0GmeoqfrobfOxZpomZ1M7Z6snWEv96bunFkzVacqu4m8RZ1Fb+N9PrbZ2LG2wn4z
         ytOmvMSfTDOTGrvXoBkaBzTkwlJPu1f6aev8Q7P5nPhn0CUncMS9UndiioUqjTP8mSVb
         0O/xhMT3UybKjiYcrGpCSTkL5QysTX5bGeHouBi9vfgwdNFY3uRBjJvBoNuJW+rXTOl9
         A2zohvPcVGbg+oKuFcNt731LM2ZgelVMzGEfyzy0vE+seIruL7duK/ZNDwQTQnK9glUc
         t2Mee1lvbA6u3+5Ih1ZcvmI1y4fsRRyBynSngXYTWkjgYDASS0ePLcnyJo7IynmBR1z+
         I0vw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788526575; x=1789131375;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=dvmdU8i3mtPssfJfI5cIhNIHS5XMU0TX9nkgPiXlkBw=;
        b=LgwmNls/x/Yy+HRRluT1NOORngJXLH7r9ySC97CpFpwKaB++KqVtm5/h2n8hnE6iv6
         2Qv5Xu1JF1eM7UQhaa7fQ/sujHGua7MM73ZXlV8ciblgZ4BFRs+JCZyHkhzpUQfTwA0L
         ltTmfNTkwTWGmDR+sxzF2V4O9YB4PihmUyWod/dS6sN/3Tf6A2YZ245XFDTEZScir0Ib
         xrBvaLBd2pWALZMrRYtb8elzvFpTJ/FwZ5664GHqi7LJZpVVPr4MXCFKNchZd4G8wNCV
         6tGOmcPgIJbtrQYwJQgMosInYlIxvqQtH4m+a9jkePdWJSIMLy+yIQ50D6LiJlCLXGBy
         pKqA==
X-Gm-Message-State: AFuF++ncWOZ97jSt8yzKxLnRnoXSuHhoE+pVZrxjzzp8yjBSJxlh1g0b
	SZWHJlIkSXWF46vjejEFZsorLtwpYuON5hn7QnVuRFOpOR8Ys3VmEVLLbaufygW8lGg=
X-Gm-Gg: AYBFou3s//o9KDI3Oa0Exz25k9hlAbFnLAX+AlP0s2qrrk4WWzgLWeK5uvmM9TGTTIy
	BmtvgXtSFIoYq+NCOvsp6RNK+pZFEIwBgL5NpzkTHkKyorQ8ptFAK7kJu0mAToOQ8roq0rzuczi
	Pd0bTpPE0wXEI4a3vpkfINoJ8gsWfMn1/yGA6y4OJ8LYOQNf9ieuBG29XIm1JK3Ok9g6Kw9vXvg
	iRZeARaBlFDWxqsFJhaI8UY6A0Ir6RMOyKGQc49h6Qj5Q+QeyMX/sPrpBzXjekki3F3S0IOaNG0
	aDnEum0qG8WQ9odWQ2sNXno2SXZqyn8Ad60nsAZFmKrmNJR3LaXC5693L4nBMmZD7w9gQxhXOCt
	tZJ3IbmEQNjmHhVEvun8OjfhsZvYtro9tldjrmXGP7kwmq76ew0NeajYirfLTpkinpcY5Z4/7tb
	xSowlhitlntH/MGNLQR0A9QvE0uuYhLZRabS8lO8zKEsHBu2lw/YVHQVJX8yTa5XrIf4BrIYK4D
	4ZwYivJG/jRoOBM8cP+usVu
X-Received: by 2002:a05:620a:84c1:b0:915:de68:1802 with SMTP id af79cd13be357-9398072a174mr541267085a.41.1788526574989;
        Fri, 04 Sep 2026 05:56:14 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fb2fd82sm203324985a.17.2026.09.04.05.56.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 05:56:14 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 1/6] NFSv4.1/pnfs: suspend pNFS on NFS4ERR_TOOSMALL from LAYOUTGET
Date: Fri,  4 Sep 2026 08:56:02 -0400
Message-ID: <a906e6ed5bd3fd560ace313a6b64491e1da835ab.1788453839.git.bcodding@hammerspace.com>
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

If the layout for the requested range is larger than the size the
client advertised in loga_maxcount, RFC 8881 Section 18.43.3 has the
metadata server return NFS4ERR_TOOSMALL.  The client caps
loga_maxcount at a single page, so a flexfiles server that stripes a
layout segment across several dozen data servers produces this error
today.

The client has no handling for it: nfs4_stat_to_errno() maps the
error to -ETOOSMALL during decode, which nothing in the layoutget
path recognizes and nfs_error_is_fatal() does not consider fatal, so
pnfs_update_layout() clears the layout fail bit and returns no
segment.  The I/O falls back to the MDS, but because no fail bit was
set, every subsequent pageio attempt sends another LAYOUTGET that is
doomed to the same NFS4ERR_TOOSMALL.  Files whose layouts do not fit
the reply buffer never use pNFS and pay an extra round trip on every
pageio.

Map -ETOOSMALL to -EMSGSIZE in the layoutget exception handler and
have pnfs_update_layout() treat it like NFS4ERR_LAYOUTUNAVAILABLE:
mark the layout mode as failed and fall back to I/O through the MDS.

Fixes: d600ad1f2bdb ("NFS41: pop some layoutget errors to application")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/nfs4proc.c | 8 ++++++++
 fs/nfs/pnfs.c     | 2 ++
 2 files changed, 10 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 04b1987115d5..e41c792a2725 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9680,6 +9680,14 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 	case -NFS4ERR_BADLAYOUT:
 		status = -EOVERFLOW;
 		goto out;
+	/*
+	 * NFS4ERR_TOOSMALL means the layout for the requested range
+	 * exceeds what the client advertised in loga_maxcount (see
+	 * RFC8881 section 18.43.3).
+	 */
+	case -ETOOSMALL:
+		status = -EMSGSIZE;
+		goto out;
 	/*
 	 * NFS4ERR_LAYOUTTRYLATER is a conflict with another client
 	 * (or clients) writing to the same RAID stripe except when
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4f9c0f639014..c5d1951d5400 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2331,6 +2331,8 @@ pnfs_update_layout(struct inode *ino,
 			break;
 		case -ENODATA:
 			/* The server returned NFS4ERR_LAYOUTUNAVAILABLE */
+		case -EMSGSIZE:
+			/* The layout exceeded loga_maxcount (NFS4ERR_TOOSMALL) */
 			pnfs_layout_set_fail_bit(
 				lo, pnfs_iomode_to_fail_bit(iomode));
 			lseg = NULL;
-- 
2.53.0

