Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 996D632B9A5
	for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2026 22:14:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771539250; cv=none; b=QDj3AqKYyI/rY8b8qLIqMwtf0zAyqMbEledkAU7dKIDy40Dr8JP5xXIp39quTZImAVCPrVCfRyiALA3Yhe78EcgT1lebXxO98n+avyJmMJf0xrD3h1jY6dl5deWK07iWvJXnAiZaQ9I9qLJi9uKR3GvKVeEhz995gps2tB4Qo9Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771539250; c=relaxed/simple;
	bh=L0M1O+IQpPCjYtFi5eba39+XclJZ/jeswoVOenqUHLc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gPNUMQvSrLPatg/RFx4ymfMiw16P+jK1mHtyYLwNYKpmzubI3yvFdkiJY28hth4J8Cw32sSXhERu4iC7yn3qOnj5NLgWJUiGbdVC+bCM3zP6FnixOSrRoL6sFCRUfBM6M3gKFgx2t4y8qLgwfwFOmphrkeZlBfKvLd4MDcJJv+Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OniHUxzB; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OniHUxzB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 10A3DC19424;
	Thu, 19 Feb 2026 22:14:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771539250;
	bh=L0M1O+IQpPCjYtFi5eba39+XclJZ/jeswoVOenqUHLc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=OniHUxzBn86zqxTTx11Oj+zou2TizHCwosT+XrzyI8L62Ek7z7BoV6sAGdts/qKoQ
	 HbT/APXp5D5xnf2QEIIdhPGn88641y3P66UlGIWgfKd4L04hqetfZRyVUmh9DzLyaW
	 EcAF2PF9NDpeg0hs3LYr4tUi01s4ee6l4293x2J+g//SBr8+PFeUQ5Mb0m0ncNf2fX
	 Yuw2zz3xHGI/6ox+FU81jwP+MWe0O5rVxZTYfrV9vDcueOtugF3Hh/1tov8+cIsMBo
	 QXv5pDOnVN/tOmrNkJ2smpH9S1Girgh5xyDPgjKNETY5Btlgp9Ej7Biv/MA7+idFwZ
	 RDuQ9aoKqPaqQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 11/11] NFSv4: set EXPORT_OP_NFSV4_ACL_PASSTHRU flag
Date: Thu, 19 Feb 2026 17:13:52 -0500
Message-ID: <20260219221352.40554-12-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260219221352.40554-1-snitzer@kernel.org>
References: <20260219221352.40554-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Mike Snitzer <snitzer@hammerspace.com>

NFSv4 implements both .setacl and .getacl and so it is appropriate to
enable nfs4_acl passthru.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/export.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index 6623eb13f4e6..f59839b48721 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -182,5 +182,6 @@ const struct export_operations nfs_export_ops = {
 		 EXPORT_OP_REMOTE_FS		|
 		 EXPORT_OP_NOATOMIC_ATTR	|
 		 EXPORT_OP_FLUSH_ON_CLOSE	|
-		 EXPORT_OP_NOLOCKS,
+		 EXPORT_OP_NOLOCKS              |
+		 EXPORT_OP_NFSV4_ACL_PASSTHRU,
 };
-- 
2.44.0

