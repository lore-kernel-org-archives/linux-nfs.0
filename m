Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C73D630566F;
	Tue, 15 Sep 2026 14:20:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789482060; cv=none; b=onljl2Pqygmhl2PyBdsfk5gEXWC48EehS2Cb74ZIhv83ctbwj6n3eo1vYQuQNNc/xX96UXgnjTzJYteSL4xm+dg4LTeW8OTthIAF1wH/oyXry7YHX7fUnlFUUdKZdc/DpdVNiDuMf7XlSDeDxH96CJAzv4OPgEgtsdalzjrCmtw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789482060; c=relaxed/simple;
	bh=oa5dEyn9Zsa38Ku+33+tf3H2bkwRDudrZYcsIqPtcXc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=USj2pKGXn2krz4nwP66oIl2lXIKekPHizJgnTCtGAPCgtz6mmEWElo87752oKw49rse3/SUxCWgBQHE/k/z9RS7h3f5VmbE1cXq95zEu3S0dwNMIeBRYthcL1/D0sOhL8Z8/3Vv4CGvZv93JnySG1K8MKILIpl4BL2dXf+r1pQg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Pqa2FD/H; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Pqa2FD/H"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 161361F00893;
	Tue, 15 Sep 2026 14:20:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789482058;
	bh=u3d1LqkKFumaGM48TyrGDB6bAw4mkY3a4wCUIMlrbQw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Pqa2FD/HWBn+vYm2bueBmQ01QSVFAY5GeT9OG3H72xc+O78I0e5EK2ZCm42XpYcfU
	 xCKlWUjVxBtgPs7sJptTV14EnCxjHzOUeZvI2ev3DI1X9ACSErnYa0yG6xmDqraKht
	 YpyN1Hd64TH4wfQdb7xhq/Oeq84Qf9NKeaBrzPnBrHqNbLZ7d7PTCSukWZhu0IsBCM
	 GNKY3+dy+5BueUNI38nHHJA7ZtHwm0UDlpM+uZXk/dGXkwj5nzkX7xdSUKov+QwbHK
	 t+xWjB0rBt2ViMZdCqFtxU5kEetqREbflOk7WaR3FNcw0vki6NB8+5/lHg+QRthoaD
	 CKd8W2/r1zVYQ==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 15 Sep 2026 10:20:44 -0400
Subject: [PATCH v3 4/4] NFS: Set WQ_SYSFS on nfsiod
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260915-performance-v3-4-ae26d460bfd3@kernel.org>
References: <20260915-performance-v3-0-ae26d460bfd3@kernel.org>
In-Reply-To: <20260915-performance-v3-0-ae26d460bfd3@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Tim Menninger <tmenninger@purestorage.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1001; i=cel@kernel.org;
 h=from:subject:message-id; bh=oa5dEyn9Zsa38Ku+33+tf3H2bkwRDudrZYcsIqPtcXc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqVRGivV37ULv2+5zcW1uIWejGnkKzI0uQAKQx
 DljsowLsomJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqlURgAKCRAzarMzb2Z/
 l9leD/4mBER0/xhNXqQ3QdyYXNH20NOLhnGQHH7LdsZj+zNBxrlEZLDNKqs2pvhWkHJdzBNegdy
 m3rAHy2VngPBv3u5qOlyzMoInrgbH8qIGo/Mp3SbuwVvT+XlzLrdtO+WaQZ1C5D/DErSz9Xjbnh
 sz/skBlHYonU/pkr2N/QBx9jDX9HkQspd6E2eZechQ26YaBCOGEiotJWQ+wzpKhoNoeJkKbdBL7
 WLSQHMX0Wb6Kg0vMABgZQO6ni2dhj1/Uy7sVyLderIxcBfqy66rSYt6iMw1KZ8X2Me1ppBIw7vX
 7At32tZLdVxpJbaBYu76gfnRkR+QpVBvGvVliflhhJaI/Q+kweEe2GDdpch8niE9H3oCvol/nQx
 tAwVMpDRHVAiAOlOv/IV0ucFYmc3xW7Cc4zttb0u/yy3iZ/3WjFMkmiDrYIuxhizvP5T5w5O1K9
 N5ZhuJeVVLG2O0k6z9UK4mg/VHyOvivQtU46cJAVkSMs1SrgFYzoJZo3Qt7hPIW/T5jYKB7V4TA
 KY0UL1ulOe+/TCgbnEBnYySCaZTSDoAuH5lysB8Bar+YEt3KRh9s1wL0evt38ZaeMWGfsuu+3Yb
 fuD+7MwVjKi5SjkMyeoQwOzj+AseuJcgZZqhNEvR8XqEK0O3phmy8X+pjuUhNQOkpgNUzJPnT+m
 VsrcqG4DuH3Tlig==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

An unbound workqueue's attributes can be changed at run time only
through /sys/devices/virtual/workqueue/, and a workqueue appears
there only when it is created with WQ_SYSFS. nfsiod is created
without it, so its affinity scope cannot be tuned without reloading
the nfs module.

Create nfsiod with WQ_SYSFS.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/inode.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3022454f7698..107a2135029d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2619,7 +2619,8 @@ static void nfsiod_stop(void)
 static int nfsiod_start(void)
 {
 	dprintk("RPC:       creating workqueue nfsiod\n");
-	nfsiod_workqueue = alloc_workqueue("nfsiod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
+	nfsiod_workqueue = alloc_workqueue("nfsiod",
+				WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS, 0);
 	if (nfsiod_workqueue == NULL)
 		return -ENOMEM;
 #if IS_ENABLED(CONFIG_NFS_LOCALIO)

-- 
2.54.0

