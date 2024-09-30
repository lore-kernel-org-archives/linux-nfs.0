Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0684D4C69
	for <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2024 00:50:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1727657429; cv=none; b=dlvFBTp2ben84cxRhq4Caij8+VWDD3tzW8I8syvE367TSW4cpUWaL2lsASc/5gPhQNCvJcE2Le5hLSPbNFj5ILtLFeokDgGyqQeQfTBPa7ZFsclV+ReWDuX2BjYSooXjVJqyB1Pj1ghH1fv2ZEOuJpTtBCUhzwXPGOa7smtXTWA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1727657429; c=relaxed/simple;
	bh=qZTjaS/bTsUQt8x+mZaAFLvOM16uFDTtxcGKjpFDsVk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dS3v9F0Zak1yZA+C8MsnfJWMvxf/KEq+6BLqKxUJe+/WQ//HcODFwbBUA/PrZRrTYOuWMrmL1rNdxMqFJIQccGF5yNzKZR51jJBOHD5N1TuNTtBKPRrCcoKK3xbW5JPZJTit1358cXjAKuhyOo31oYrVy60p5sAmr7WfG/mpp5c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Qc02yTix; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Qc02yTix"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CAA6FC4CEC6;
	Mon, 30 Sep 2024 00:50:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1727657428;
	bh=qZTjaS/bTsUQt8x+mZaAFLvOM16uFDTtxcGKjpFDsVk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Qc02yTixGH4wassYw+QNXcxGEQiGNZhsnVDzgn0oxSypCtXmydPv/sIooHUxNnoNw
	 y8pVrqfzUXm5uRgQtG2MxsRpoMygqv4S8boQDCVH5A/6ZGb1mtpseCOUdMODkceN7C
	 1yBHsj8xwCBDfsqfrn9nprmm/CBoOPdGJhQZZCWbUsQQKF0psLB+oIRdN0N2luj2bt
	 +k788a4OlERMihm8Hfv/X9+R0GprKvF2nFYExWy6GOP926IkyxvFk5GXLPSQ/0XH2d
	 WHxulkYb6MYiOGuHpvHSQ0+B+pMMOnt4/dept+TaW/1OBWFFmPkTSrCCzoTTJ0nj61
	 KBZ6exYudaAsQ==
From: cel@kernel.org
To: Neil Brown <neilb@suse.de>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] xdrgen: Exit status should be zero on success
Date: Sun, 29 Sep 2024 20:50:11 -0400
Message-ID: <20240930005016.13374-3-cel@kernel.org>
X-Mailer: git-send-email 2.46.2
In-Reply-To: <20240930005016.13374-1-cel@kernel.org>
References: <20240930005016.13374-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

To use xdrgen in Makefiles, it needs to exit with a zero status if
the compilation worked. Otherwise the make command fails with an
error.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 tools/net/sunrpc/xdrgen/xdrgen | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/tools/net/sunrpc/xdrgen/xdrgen b/tools/net/sunrpc/xdrgen/xdrgen
index 95f303b2861b..43762be39252 100755
--- a/tools/net/sunrpc/xdrgen/xdrgen
+++ b/tools/net/sunrpc/xdrgen/xdrgen
@@ -128,5 +128,7 @@ There is NO WARRANTY, to the extent permitted by law.""",
 try:
     if __name__ == "__main__":
         sys.exit(main())
-except (SystemExit, KeyboardInterrupt, BrokenPipeError):
+except SystemExit:
+    sys.exit(0)
+except (KeyboardInterrupt, BrokenPipeError):
     sys.exit(1)
-- 
2.46.2

