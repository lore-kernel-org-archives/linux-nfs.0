Received: from mail-ot1-f51.google.com (mail-ot1-f51.google.com [209.85.210.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B872B3314AC
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:41:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653697; cv=none; b=F5ogFveoil70i+4J12AfYdBHtD8W6LZX1CIvycEbbCDtvLVn5Jwms0mqcSg950nEIPrQzu5wb3bp6k+Pcma66IeNlq1o6diqDzy1QoPHTajCtAikWKhNb6tiwYgFOSICuPBVA6qGH7kTQMmAmZ9Dte5wwcTbuk9NxerW1n7VlCM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653697; c=relaxed/simple;
	bh=jQwsp+kD+7yDIcD+8A5wa2tQDC70Cbbjz6pndDIFHrk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Sbws/wMAmDRI7+fITsDlj9oOOXKM51dINihOs2fK5UC1NraeLAgOx33+f3D21LXLOjUegxZmzCmfQWZVqm1RTKpcqD8hfk+3rbXrzPOmZ6dGWSsX5ORsRGV7erDLuMoYv97XyuIKLMgXHCTo0HY3lP/+At+G48z5hb4lBEP8BgI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=dfAFUuo7; arc=none smtp.client-ip=209.85.210.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="dfAFUuo7"
Received: by mail-ot1-f51.google.com with SMTP id 46e09a7af769-7eb5bdb50fcso250623a34.1
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:41:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653695; x=1787258495; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=EB51Ju9QPfx0ISg4yMNUT+Y+r7FvuyZkraj30KlCQFo=;
        b=dfAFUuo7wIeTOIrh9Duz+ZcZmXhoxwA1WnTMMSb3pMn4Px6FA847Zvi+1WibjeodLV
         7mG/uWF/gd12zLxUETh858DMdmhl87c/ccyhoLLaPUDgoqZT1JtoU1wl73bJ/qQuPMHj
         9mKzOQmVUJrsSDgO2oFf8VZYo0j6HyT9WiYP9wP6VQIqC1lPirR1IPGGjk4jMukiZ/5Q
         tp+frYhxRhW74DAlIKyPkuUT3n9vqN+KDGs+9B44FIDQmUVwVzrmDLjw584lN2NM1r8q
         eS8hPPbV0SwFO0dxwNX/Fv3NVdH6UC23clSoCpjK3e50LsQsE8rWi4npE7dvruDl6mwH
         Jvbg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653695; x=1787258495;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=EB51Ju9QPfx0ISg4yMNUT+Y+r7FvuyZkraj30KlCQFo=;
        b=Own/Jp5y+bftbvVmLWZ9kqMkw5EjLsk8RXxKwb5d4+jXyXOqwpZit0denW4x5MWcCe
         yvrFyPZnK5zo6VuwnBe17IzpU+LXh/c6RLe7WnW2hPBAHoiuWeO8tCs4Yikwe8KXGFYD
         HLm3jQrril9BK+POecDQwi0TWQRqExS9d5/NibWSrfE1cC5cVA2FK04PAmIPZeVwHy9b
         IhdIz9QZ8JUQpAr6DfpdWCzMSGKEzOy+8XpwV2KhRanyXRpotUqjd/JPmRYGGQhRsHl6
         uM83zAgPP9zlJEunzMKznrChyK0MvIncVcT2GXPu1exaFhO66VnjF9RnQSGsZbWZXqjf
         agtA==
X-Gm-Message-State: AOJu0YzKyTWC6jHqRp7tOsxiJ/RDcmEFIXlAI7/Raeg9zjBEdICRIGny
	QPLZlupHZ6MXrgEXbPMe6K4Ui54GCPncxIHYMNwcIibNvWubXhyZDAcuRV/GSeL5FT8=
X-Gm-Gg: AR+sD11woAwAuR+B10lAmYUW4aOD44MyOs7vCwmETGZN0lbi3229k9SxmNiGi8tsDfW
	IEgSfbhpePbzAdvSpLC/MZTz0RufYRktHa30oFrr1sbd/fgPz6+3W7xfdVpzICbNZQZeKCJUUJ+
	S/6SuhFAXxD8D59nEEkpOrKtiywdr5FO45X26InBt+JSJx+v3062A4HV5HcsCdN+1bSMLz3vH0j
	LjvcCLvk4uph855VDvI8crTnDviAM/FW5w8knOROnT/52nnwy9kxDyTN9xsg7JMyfvhK2Df9+RW
	hQsRAw7qdfDVTvrdpEFSRwTGHw+nBWHDpThnQ4pqh4CnSFbw1L5SQUYxWgwr9zTwTRKo5NnGrgG
	jC3aSEo0LY8s/C+YE1aDTyPnl3EHfH+e8G/gWm7pR012cOMyTWh4kphR7UY/u34dJEf17QDfoQ3
	1S88AvuULns3bHa5BDmT/0WYPBqkoK7C70glS61n1xbgHvI1KEpbB6n7UvaRuNA9mdK9REGnTFf
	zpPy1LQUZ9y9VvRxRF6SPF2
X-Received: by 2002:a05:6830:6b03:b0:7e9:cd7a:7c34 with SMTP id 46e09a7af769-7f3de5b33f3mr566825a34.10.1786653694625;
        Thu, 13 Aug 2026 13:41:34 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f3c9e23b6fsm3087958a34.25.2026.08.13.13.41.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:41:34 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 1/6] NFSv4.1/pnfs: suspend pNFS on NFS4ERR_TOOSMALL from LAYOUTGET
Date: Thu, 13 Aug 2026 16:41:26 -0400
Message-ID: <57c201555a87e999cd2de1747901f3b6cc3d5792.1786653456.git.bcodding@hammerspace.com>
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
---
 fs/nfs/nfs4proc.c | 9 +++++++++
 fs/nfs/pnfs.c     | 2 ++
 2 files changed, 11 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5709c6fea85b..016e8b38b87b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9623,6 +9623,15 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 	case -NFS4ERR_BADLAYOUT:
 		status = -EOVERFLOW;
 		goto out;
+	/*
+	 * NFS4ERR_TOOSMALL means the layout for the requested range
+	 * exceeds what the client advertised in loga_maxcount (see
+	 * RFC8881 section 18.43.3).  Note nfs4_stat_to_errno() has
+	 * already mapped it to -ETOOSMALL during decode.
+	 */
+	case -ETOOSMALL:
+		status = -EMSGSIZE;
+		goto out;
 	/*
 	 * NFS4ERR_LAYOUTTRYLATER is a conflict with another client
 	 * (or clients) writing to the same RAID stripe except when
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7715e2bd5871..10102bda6a38 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2338,6 +2338,8 @@ pnfs_update_layout(struct inode *ino,
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

