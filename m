Received: from mail-oo1-f53.google.com (mail-oo1-f53.google.com [209.85.161.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1454360EE5
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 17:11:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788973916; cv=none; b=FFlRrCPJQhzUnASDKnwxSkgYGNQxjvO79Lk16Ap8pQoOhmI69pEpthdtDHBokZrOBqZSQYkLSoXJaVTfpCV+/eqRVJksuZt9YgnpdwyTbrdKrXqWwJEvUXXKr3b7uFcjZws+m/xRyGgdnY3U7SjgCTw6ix49WIXl5FptFbWgeF8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788973916; c=relaxed/simple;
	bh=x2+O/OlDokAoUVWzq1RfJQsiTPDg2TbUXpPEN5uUEEA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=kbKb85MNVZ2Ld6OfEfhKhPlG8YktdEwaUDuTnJQob3i93KUdkYrTdymF/TtOZAqkQwe672guuseL0dbuRuSZRHfQGRO5CbvjHi5MXeIrYCOHOPosSqywiu0MN0Rt/SASot3MrtMwTKqckB3h398OEvl4QA5xe0st+RENhSOuim0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=pz8TQImM; arc=none smtp.client-ip=209.85.161.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="pz8TQImM"
Received: by mail-oo1-f53.google.com with SMTP id 006d021491bc7-6b1b766bf01so2718771eaf.0
        for <linux-nfs@vger.kernel.org>; Wed, 09 Sep 2026 10:11:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788973913; x=1789578713; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=SoZ12e/LONidPB5ehGb6hwY5fqRMiIp4jjp4PAL6aZM=;
        b=pz8TQImMdMW17mBVBqNG0/kKP6bLqc+BYj5+iciKOHP6XLlRfLmPZEHDRnt0IkqKXS
         uOJJteBHylkZSn7tDPIIwOLF5ap+6fwg9ZzeOC0SPq0FwcSY1mMgrT/uTA4gybcRtT6Q
         7i2l7aN0ngh7aFUTLzi/Etk+bCF74EAAr75X1Uuq4VDHxXqWHthw9zq4qyA5RuumnUG1
         XEehrdaz5RoWk5U5UjzWpg1CxUCdFblK6NDrsl0ydNyZRXMEGJw1rKq4UpeftJ1dNX+B
         xrhcvqb5zu08QN93WhAAiZMYTHJM7S/2ETIz7BOGqe+pgv05vvYYM4M7Vl22d52Rbp0S
         J9Yw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788973913; x=1789578713;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=SoZ12e/LONidPB5ehGb6hwY5fqRMiIp4jjp4PAL6aZM=;
        b=OVPgKt03CO9BBvABB8Ga8JJckDs4lAjVUGhjKo9lx79wxsssFUVZ3NNeijHE/UmSlG
         q9J/wHbNpBhkxb1qD88kD1EWwoHdcy7HrWYRCIVoWIxkXHyA43reT4pZhcklN0KQpF3I
         Mn0j7Ha7cMxr7Ux0fB3BYhxHnRDqjj3PCmsL4H7sOTD+RR9yWfyFCXvHGY7snhg9ESGl
         XnZaQzjNn0z4AyPs8wBca+Nd/JmNBAVNxU5J0OBl2CvTN5asRJ0B+yXj0TmxdCm8DQ62
         qwzrEBZg/+xLXU5TXZFnQip2m6lOleoP35gMUUxEdj9JNfG909tR8oXEMOt/cN9lQuwm
         hF5g==
X-Gm-Message-State: AFuF++mXPG05BU7G0mbwMTLSt36TLPKTcJC/h4ixh9xGQ21FmtIsveYV
	ZpZCLCGlpQW8dSAIw2W1BqmHMfHHgD9PWq/b/CzOt8qbK8gy6kf8XFTRjVqUNNV9xqg=
X-Gm-Gg: AYBFou13jqGjT8187us7TOZA+D9DMYVZlh2O+zYtv+ygW/ot/X6Iya2WBJcjhDqFhNx
	fAp27YgJ/dZZ6G2qIcrgeCukNS5lIenqoCJvp1LCkSEdiruLLTBG2rpcj5m1jIAl+CxdrrhReV5
	pBLjGne3tzNSyHZApIwitqMvRYeArhmr49aS1fBHSn6r+4ImKz4JohAAD3YiKekknJEgC+E2NPY
	m8pZY2ypP2tqnNvjPW4EgZQ38LRg+mA8LhlJAtkgQAzy2xOlm0fYA31VRdPK1YEIsfS0b56tuXA
	GAsmq3AFxkTdTjT3RMvebGAx6e7FtZIrHfS2/KIbN7QyncHB7tEAi8hxDVlyiZU8XVQ1FVAO7Cv
	k8wFzQlJgstbXFzOkZfSvHiPN7p4gE3HEBSGCz3OjP7g7j+tKgZX7yCoc/QJg2JL8e9byo66/LS
	SLQa4f+kMGX0dN6VwkwO5frcY7y4gZcFk5OBk+saoVQc/PXbkW6p9f1q3H2m2zvbLK2Vq/tcqIF
	mPLt1nnMxKwI85JqP9Zstbz0uKqJX8At8s=
X-Received: by 2002:a05:6820:80c4:b0:6b1:9f02:e2da with SMTP id 006d021491bc7-6b6fd2d0770mr18983207eaf.20.1788973912757;
        Wed, 09 Sep 2026 10:11:52 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-6b6dd57198esm20616428eaf.11.2026.09.09.10.11.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 09 Sep 2026 10:11:52 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH v2 0/3] pNFS/flexfiles: mirror instance error handling
Date: Wed,  9 Sep 2026 13:11:46 -0400
Message-ID: <cover.1788973535.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a flexfiles data server fails, the client marks the layout for return
and cancels the layout segment's in-flight I/O.  ff_layout_cancel_io()
cancels I/O to every mirror instance rather than just the failed one, and
cancelling a request that has already been transmitted does not stop the
data server from executing it.  Those writes may complete after the client
has sent its LAYOUTRETURN, and the metadata server will see writes to a file
for which no write layout is outstanding.

Patch 1 reports the operation the client was preparing to send when a
data server connection fails, instead of OP_ILLEGAL.

Patches 2 and 3 let a layout driver cancel I/O to a single device, and
pass the failed device down from the flexfiles error paths, so that I/O
to the remaining mirrors drains before the LAYOUTRETURN is sent.

Layout recalls that set clora_changed, bulk returns and revocations are
unchanged: they continue to cancel I/O to every device.

This version applies on top of the flexfiles device-notification and
caching series [1], which rewrites the data-server setup and
I/O-cancellation paths these patches touch.

v1 posting:
  https://lore.kernel.org/linux-nfs/cover.1786636529.git.bcodding@hammerspace.com/

Changes since v1:

 - Rebase onto [1].  No functional change from v1; every conflict was
   in context that series rewrites:

   - nfs4_ff_layout_prepare_ds() now takes the device node the caller
     has already resolved and referenced, so patch 1 replaces the
     trailing fail_return argument of a five-argument signature, and
     three of the five call sites wrap to stay inside 80 columns.

   - ff_layout_cancel_io() now walks mirror->dss[].mirror_ds under RCU
     and takes a reference on the node, so patch 2 applies its
     device-ID filter ahead of the RCU dereference rather than in
     place of a plain pointer read.  The filter still compares the raw
     device ID from the layout, which is immutable across the in-place
     device re-resolve that series adds.

   - ff_layout_resend_pnfs_read() now yields a device node rather than
     a data server and puts it on the success path, so patch 2's NULL
     device-ID argument moves into the braced error arm.

[1] https://lore.kernel.org/linux-nfs/cover.1788530385.git.bcodding@hammerspace.com/

Benjamin Coddington (3):
  NFSv4/flexfiles: report the intended opnum when DS connection setup
    fails
  pNFS: allow layout drivers to cancel I/O to a single device
  NFSv4/flexfiles: only cancel I/O to a failed mirror instance

 fs/nfs/blocklayout/blocklayout.c          |  6 +++--
 fs/nfs/callback_proc.c                    |  2 +-
 fs/nfs/filelayout/filelayout.c            |  4 +--
 fs/nfs/flexfilelayout/flexfilelayout.c    | 32 +++++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 17 +++++++-----
 fs/nfs/pnfs.c                             | 32 ++++++++++++++---------
 fs/nfs/pnfs.h                             | 14 ++++++----
 8 files changed, 67 insertions(+), 42 deletions(-)

-- 
2.53.0

