Received: from smtpout-03.galae.net (smtpout-03.galae.net [185.246.85.4])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E156B4A1E1D;
	Thu, 24 Sep 2026 16:08:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.246.85.4
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790266112; cv=none; b=D2m/C07VO+HgVKfkzbKP1pmg2h5uKWLYSn4bOoUkxUXsOc9WCvRcjFpU4B+WZ+PLTpwmtxBCuK+THYHT6vIrX5+RO8k97xZ3QreT04kG3RQXO4lkXbQXlkkZhrsysT4lUv+t+pazhLY/T8N4IgXvRjqj4KIsp39TXfSUdeMBvYM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790266112; c=relaxed/simple;
	bh=PdOrdhPdZuZhrlxEVnCGfBAZmrpdFXAr/Fx0uRSk2gY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=gY5lnNzIxROe8HJBZrkuED68VxPOeeqvO3Z1xRPURmML7WHT4BjcYrVmygQjcWCXItKB+4b6WHuCf7Fq96/JVlmnLYEiPmydI+9OOoRSPeZglvt/BApWghwBOY1kNB9hj2Zkn1VMLRLUfwCYspDRYYZiMUaiVIN4WHKr9XTgBA0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=bootlin.com; spf=pass smtp.mailfrom=bootlin.com; dkim=pass (2048-bit key) header.d=bootlin.com header.i=@bootlin.com header.b=ONsXbOcr; arc=none smtp.client-ip=185.246.85.4
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=bootlin.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=bootlin.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=bootlin.com header.i=@bootlin.com header.b="ONsXbOcr"
Received: from smtpout-01.galae.net (smtpout-01.galae.net [212.83.139.233])
	by smtpout-03.galae.net (Postfix) with ESMTPS id 3342B4E4105F;
	Thu, 24 Sep 2026 16:08:27 +0000 (UTC)
Received: from mail.galae.net (mail.galae.net [212.83.136.155])
	by smtpout-01.galae.net (Postfix) with ESMTPS id 00C3760738;
	Thu, 24 Sep 2026 16:08:27 +0000 (UTC)
Received: from [127.0.0.1] (localhost [127.0.0.1]) by localhost (Mailerdaemon) with ESMTPSA id 0105010329450;
	Thu, 24 Sep 2026 18:06:38 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=bootlin.com; s=dkim;
	t=1790266041; h=from:subject:date:message-id:to:cc:mime-version:content-type:
	 content-transfer-encoding; bh=BH+arErWIBY7hpZKpPthQMU4Dv/fEL3yycrYdB+7SAY=;
	b=ONsXbOcr23MBp97WH0svxjX/qajC1P03GDotsG32pqiLLyxtrTG9i/nFxLh60PPtt6ib8B
	KpwGfgCIAwOe7tqrY2Dr+yZGfVzW92Q/qGCRLH12Zq2Z+wkPwECFoEWvCnx7LufxoQmNdg
	WJ38Cg8+yZ30XQiNT8mAwHbSzwvtFH3WA1zvLte7l0Hovu7kidqd16A6YZg6XsdpHqCF84
	NeFQDNgfTJzmgMmEB3SwdUbUw3tntTqszPGEZrO2bTGHan5QGUo5jUepD2J8Oh1oP19ybF
	hrPgZgr2bEWcYpEAMR3ve3Agm7LWsRG1dKDyFtfL681JTjL1Biw6uMGRLV74FQ==
From: "Miguel Gazquez (Schneider Electric)" <miguel.gazquez@bootlin.com>
Date: Thu, 24 Sep 2026 18:06:25 +0200
Subject: [PATCH 5.10.y] SUNRPC: lock against ->sock changing during sysfs
 read
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260924-cve-2022-48816-v1-1-b44c7e4dd493@bootlin.com>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yXMQQ7CMAxE0atUs8ZVHNqq4SqIRTAOmEVBCVSgq
 ncnwPKNNH9B0WxasGsWZJ2t2G2q4E0DucTprGSnanjnBxd8RzIrVXjqxpEHYg59SCmKxC3q6Z4
 12esX3KNv2bVvHP57eR6vKo9vDev6AQqjEkB6AAAA
X-Change-ID: 20260924-cve-2022-48816-11959ffacca3
To: stable@vger.kernel.org, 
 Trond Myklebust <trond.myklebust@hammerspace.com>, 
 Anna Schumaker <anna.schumaker@netapp.com>, 
 "J. Bruce Fields" <bfields@fieldses.org>, 
 Chuck Lever <chuck.lever@oracle.com>, 
 "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, 
 Olga Kornievskaia <kolga@netapp.com>
Cc: Benjamin Robin <benjamin.robin@bootlin.com>, 
 Anna Schumaker <Anna.Schumaker@Netapp.com>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Thomas Petazzoni <thomas.petazzoni@bootlin.com>, NeilBrown <neilb@suse.de>, 
 Robert Garcia <rob_garcia@163.com>, 
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
 "Miguel Gazquez (Schneider Electric)" <miguel.gazquez@bootlin.com>
X-Mailer: b4 0.15.2
X-Developer-Signature: v=1; a=ed25519-sha256; t=1790265996; l=1838;
 i=miguel.gazquez@bootlin.com; s=20250708; h=from:subject:message-id;
 bh=liulsZ/coQfT07R5JtzG+PjFTbjUtiJrY8ERm44fUGw=;
 b=hvuAFoVF4j+paPwTWzFrf8A5Zvpgx03sXgeYvPovb8Fl/DD4+3oPfzYGOZU2WXVBh2AVlco3N
 vH+l07ieePVCOtgTy7kARTUQVdDf8YorRQLKWt+tC9Bhkqw27kHEwg0
X-Developer-Key: i=miguel.gazquez@bootlin.com; a=ed25519;
 pk=k/2KI9jkmayaF0ghZ8QYUH9Wm/kFHDhl8QoZ0RHbr4w=
X-Last-TLS-Session-Version: TLSv1.3

From: NeilBrown <neilb@suse.de>

[ Upstream commit b49ea673e119f59c71645e2f65b3ccad857c90ee ]

->sock can be set to NULL asynchronously unless ->recv_mutex is held.
So it is important to hold that mutex.  Otherwise a sysfs read can
trigger an oops.
Commit 17f09d3f619a ("SUNRPC: Check if the xprt is connected before
handling sysfs reads") appears to attempt to fix this problem, but it
only narrows the race window.

[ Removed the changes about net/sunrpc/sysfs.c, as this file doesn't
exist in 5.10 ]

Fixes: 17f09d3f619a ("SUNRPC: Check if the xprt is connected before handling sysfs reads")
Fixes: a8482488a7d6 ("SUNRPC query transport's source port")
Signed-off-by: NeilBrown <neilb@suse.de>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Robert Garcia <rob_garcia@163.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Miguel Gazquez (Schneider Electric) <miguel.gazquez@bootlin.com>
---
 net/sunrpc/xprtsock.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5dccad3271fe..4ec6516a53e0 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1666,7 +1666,12 @@ static int xs_get_srcport(struct sock_xprt *transport)
 unsigned short get_srcport(struct rpc_xprt *xprt)
 {
 	struct sock_xprt *sock = container_of(xprt, struct sock_xprt, xprt);
-	return xs_sock_getport(sock->sock);
+	unsigned short ret = 0;
+	mutex_lock(&sock->recv_mutex);
+	if (sock->sock)
+		ret = xs_sock_getport(sock->sock);
+	mutex_unlock(&sock->recv_mutex);
+	return ret;
 }
 EXPORT_SYMBOL(get_srcport);
 

---
base-commit: 1797d8bf8d0c2e74defad605d14e3553d43a3caf
change-id: 20260924-cve-2022-48816-11959ffacca3

Best regards,
--  
Miguel Gazquez (Schneider Electric) <miguel.gazquez@bootlin.com>

