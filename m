Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192823;
	b=IVmFiWLOQg6pBG4+j8YLrZvoJaa89Umxi04cXz7Bny1NtJyDqp/igJ8lVly9w7SwBuev
	 Vo/4LkxOdovGnqahlIjLA5gyyWI0E/nC8Svr1hwxHhNw4+jS5Fo2xyo8xdL3I4U9yIFZ8
	 4un+H+u7NnCTN5qCs77SwUc3qEu2WIniDe/4xh88MxuGisXlwYupM7KuEF4WDcyQuiiZY
	 Z10FkJfACW2ED1N9j8F6UAZ6WItwoB8dWfuI49/uj1IMQ02tVqgllpPYVDx0R+DnIGKGu
	 d9WbNP1bb7c+5oX6grJPcr8U5jbzAbjrpJdTU+CyXNS7bbcaYZw0R+6V9oGIXPJ7SIA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192823;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gyxgT4IX7LtruGkky0Oi3Cw70BiD7ZNrDBoJFZzuNIg=;
	b=kRn8LkWPsZfE+g19AnVl7P24kfdmoqq5cdDtEOAqELR+hHKUkN4y+NxwYEehTVdM4fbT
	 3A677WTsbvd+mR4kLKr9SBC90F2Y0a27KEKMSfng+h/y/aTcM58KeNT5/8THQw+G4JkcS
	 1kyjqe2gufdfc55bVbsznijbzwWaxeP7wZKQd+PFS4+GuuSJSGiQ1G+GG3gqsL7Q3GIum
	 oWg9YhOhS+mKgTIQ7COhljVH+iyOTJCrOGvtsuuxlFhBiSALnm06PzmmpisCKlfddR9cB
	 dald989cR1cNUXVfz1ZBQpitnTGGhzBNIiEFTfDPI7UfTuQjV3Pdx7zZj2wew+66Fmg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z40xSSaC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF99660A3820;
	Fri, 20 Nov 2026 16:40:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z40xSSaC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0955D1F000D3;
	Fri, 20 Nov 2026 16:40:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192823;
	bh=gyxgT4IX7LtruGkky0Oi3Cw70BiD7ZNrDBoJFZzuNIg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Z40xSSaCCo6dpAp0HVW/cuP4aAGBQpOGge8pABL9B6vh28loO95Yg51WetUZcTnql
	 e0DSnxf2HZiOxHJEioa0YVtNBcmxCNRF8KLx4kGulqIzSQSwiENPsexz/b+L5A5VzR
	 796oxZ0k+/FWFS+gY4lEg7liTZZUeQp3fLd8AcRTwwlQMMfrVVCSOaLZVtrNQoRKgV
	 UVogqTpcqPz6IEnw1EBCXUpYe4I1AJPx3cBI4H3tjt75yxqonNMEz363V8BffytqYT
	 A8vtmKlS2b8yJZVpvrAJ/oSz3wfO4I/IBBF57T7LQkPQinPWFnQW18u0fR8cBTSfTT
	 P1CvNoKkYSPWA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 08:40:11 -0800
Subject: [PATCH 05/11] nfsd: set ctime when a SETATTR with delegated times
 changes other attributes
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261120-delegts-fixes-v1-5-c89b37d2d462@kernel.org>
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1576; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Zlz32Gc29QNIG3vpAmd+auU1FO64+bJJZ8eozOi+X4w=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfxqpLPnam5Lb1vW/EvzAyGVXOM/KDr0DR6H
 QgsMojmIOSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB38QAKCRAADmhBGVaC
 FYj3D/9ViS+WhQyaAArHFyLUOTBWGlkJiYu/CfuLy8an9zqSFR4IB0oSlmb6TrLbZH0Lg1/8oR5
 Tv+35sXsNJZE6/10CX1coRf1l9lYDjnz0hGralG3Hbz7KfuTeTBb56QKbVvMvODOwGbpuMohkyC
 SRNTs6CDSip4BFqRgt4ims8iPkXcWcAty3zAPGbkBKFcPIysEgPvNVpPxMJancOHi9kJiqBx34p
 +ztQnhaDVbFnYwB3LOM/bq1K0oa+l8cjBx0ypKIjFp09tq2To/rQImQFvjEiPg0zMbUDzc0TY0z
 TGQUHs4d/FyQtr99P8bZBpd4aX4LTmbMjRvMySI9Rzsy0kAmHqaoI/Qe5qU7O9usbWGt916cY/9
 A8dlXnkrqiO74bgg1b9Duu/YB4HRhJ4g2vGBaRCiQ/kF4qNwjhExUG2uKOyxybtD0hGd0gBUTSV
 EXqaKzfGy6eZ3CI2+ANfkZfUDFA2oTeNWLcRzV9dr7l8VmjNGKH1ixSJ1I3xWNoq004XlTh5Ao7
 VeVADazackgUsAarf5QiXK3S5FiMDu3safqA2kKCETbp1NFHuGwjQ47PdTfT2FdEj7Z9szwnoO2
 0NtwED2iwn3fvZ4UXd3WNgDdRPkUTc9YjQCpCEqdT0h6DJUv5hmymn5B4plxC3k8BCH4bWxm7dj
 0rthbh1nA23JEGQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

__nfsd_setattr() adds ATTR_CTIME only when ATTR_DELEG is clear, to keep a
delegated atime-only update from moving ctime. But ATTR_DELEG is set for
the whole iattr, so a holder's chmod or chown sent along with a delegated
atime changes the mode or owner without updating ctime.

Add ATTR_CTIME unless the request is a delegated atime-only update. A
delegated mtime whose ctime failed vetting now gets ctime = now instead
of no ctime update.

Fixes: f9a348e0de19 ("nfsd: don't set the ctime on delegated atime updates")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/vfs.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 4f3e480a3981..c0d10c263a93 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -514,10 +514,12 @@ static int __nfsd_setattr(struct dentry *dentry, struct iattr *iap)
 	/*
 	 * If ATTR_DELEG is set, then this is an update from a client that
 	 * holds a delegation. If this is an update for only the atime, the
-	 * ctime should not be changed. If the update contains the mtime
-	 * too, then ATTR_CTIME should already be set.
+	 * ctime should not be changed. Any other attribute change, such as
+	 * a mode or owner change sent along with a delegated atime, must
+	 * update the ctime.
 	 */
-	if (!(iap->ia_valid & ATTR_DELEG))
+	if (!(iap->ia_valid & ATTR_DELEG) ||
+	    (iap->ia_valid & ~(ATTR_DELEG | ATTR_ATIME | ATTR_ATIME_SET)))
 		iap->ia_valid |= ATTR_CTIME;
 
 	return notify_change(&nop_mnt_idmap, dentry, iap, NULL);

-- 
2.56.1

