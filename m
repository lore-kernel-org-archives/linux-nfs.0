Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793587421;
	b=ezRNLoNpPPJ6dtqKTCuEBVsQMw4h0Ar/7tTzzZy5tKxmjZshGB6tYdfjL2D8awIS/mQv
	 Dfd+iRiv96/PYrYztILNICUJom5uruf8ZfGqhtpy4Yw0HNT5qz4pkkkgrKqBxKJITh/3z
	 g+JMY0JMqa8SdMrC+tjXEvECFN3qvndMxuCgVWmGmg7tWnfpYjEPifAhGq/Qr2zbGQG1o
	 zd1E2lcGid9YIW6fTh1iImpdWN8J/ouh5YrOzHr8b69JZhjchZFHQyKQMDyOO1LDUX7bW
	 IrbRjH9LbDgANDO2H5CdNdiQkT2XKCOS/GUydfFq5C/GEWreBMv0D27uXpa1HVmNCUQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793587421;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=m3N8za2L/figfCzBPj4RCyQmLOipGBFMthCmsU6stDE=;
	b=yT4/t0yDPgVzasOdIYPl7od0bly3ySaETodX3jNnEJAdCJ6KSP0dY4E063E2qS4y8k+I
	 gop3eDiU5MdEHLf35nYbWpd+8wkCJ9M9fTGypP3e0qNjACtEJ75P4JQLMYqCZOPsl2zxL
	 hEVx6k4W3gd6Xt/n5YVouFbP8RdBaE+FQHssPSZ8sCd6eW4O3P33ZZXzaKuM1QGzlhFcD
	 DCMV3E4s0Yd7gGD34e+1Xxb07D30Rft9/ZYJWZSQCkPP66KYLe+a2xX4aeMdIB8mB18gK
	 oki7cv4Rt87B5VJOY6Cd/kyPNNwALKJBSB8trUlyqQdbLBAJ8basALAotvIbhuICuhg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HKH+OZBZ;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 741E3606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 02:43:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HKH+OZBZ
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1793587421;
	b=0EQflumglgo4iGhVBs3qmagabubjg5Xo1p/RJFN3uzTwp+r2L7h6pRtO0R84NwZ2hP6b
	 taEfCUJCslnjMIx0E+C4kQqyfGg6TKzz5zHFlR0E401JiduTnz6nR9HjAn3CkeikVD9LK
	 g+iIFrLYU3FmTDGuU4pPM2VJbcu+kf6BZGy9jeV/RCqzPPr07Qdb9phM7kapHkUbXfAc0
	 wXIKzmTQIBuc+dZS3RR5AI8J1elE863D73WzBtsrKyzT+bkhyw415lcJ4BYCzke/7uRkR
	 gVvFYMdTanX3TdqPJjvjIptguU4tboi1YZlig/RqqRtxj+SdZxR5c+kx34DWStj4wrw==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1793587421;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=m3N8za2L/figfCzBPj4RCyQmLOipGBFMthCmsU6stDE=;
	b=hfog0u2bbdOYCCjR7cGvC2SaQTS4G7zZsSiFapIWxe6yJVuDO0ih00pYk7md6mVrkl93
	 qksIGej52hw5qJqbUkT8pCgrB7j5ojm9W0ffkULyEOXP0UEk+VvXtObaB4mDFGG5SerMc
	 MbsST9S9Mmlv6PNT0e6x2szYMtWN+9qz+qCvBTdgLuwqZ2AQYd3DLdMUOTLnNRL3kpO88
	 M8EA9GY3Fk/h+j4STMsKBQ1Oa0ssdKU+X+/0+TxhWibNUtKsRJkfeonbkiCAKSHPIEMEu
	 4AC/Z+zGOGjejg53FY/LwaaZBLHLMJThGl032abI5xhuErxa28ybH02s/domN7zAdiA==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 746FB1F000C1;
	Mon,  2 Nov 2026 02:43:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793587420;
	bh=m3N8za2L/figfCzBPj4RCyQmLOipGBFMthCmsU6stDE=;
	h=From:Date:Subject:To:Cc:Reply-To;
	b=HKH+OZBZdp7zRlKYAp0Hiyebmj7lDk93T+skSlRmj/kCSwq6JxXGh1GD6LisNwRfz
	 yh3KB2n6IlFIBKylyXl0WF6As/Id1o3L7ORxmL+lba+u4weVldvZgNOcY5lMtNtO5o
	 R9x4c75NbM/53rCnIQ/wQD1cOCYcsDFtDwWH5/1qioB+/bZ6oWxdajVAgnnJJGIicG
	 HG/+LAdxNPhm3EwyXGs24ZILw8e2LhtU1ZfjFrw0SpiWcgzspUZ5KtzXNsC/jNB47S
	 3T+pcHuNuuRxiM2cTnZbg/RHVERe5rYt/rSMf7/vmoGXmSf58JRUUBEpHIP+LUHn18
	 rmQLb8IjdWfdg==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id C35A4462BF;
	Mon,  2 Nov 2026 02:43:39 +0000 (UTC)
From: Nayeon Kim via B4 Relay <devnull+nayeoni.kim.samsung.com@kernel.org>
Date: Mon, 02 Nov 2026 11:43:40 +0900
Subject: [PATCH nfstest] NFSUtil: find OPEN when a later operation fails
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
Message-Id: <20261102-b4-fs19-open-partial-success-v1-1-5e0f55385d27@samsung.com>
X-B4-Tracking: v=1; b=H4sIANv452oC/yWM3Q6CMAxGX8X02kZGFhJ8FeNFV4rMyFjaYUwI7
 +7Qy/P9nA1MNIrB9bSByjtaXFIFdz4BT5QegnGoDG3Tds41LQaPo7kelywJM2mJ9EJbmcUM2Te
 Dd71n6RxURVYZ4+env0EarYgVuP8LW8NTuBzyYxrIBINS4umI1mxFhebLTPWlsO9fkuoV5asAA
 AA=
X-Change-ID: 20261102-b4-fs19-open-partial-success-c40d4194ce61
To: Jorge.Mora@netapp.com
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.16.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1793587419; l=2619;
 i=nayeoni.kim@samsung.com; s=20261102; h=from:subject:message-id;
 bh=kM+8j/vfKTA/FNbh1boUK6kqOiP9hAPClcoKGunMq5Q=;
 b=i4/GZfSnlp4aIqrZl96mMEntMk+JYSePdSBReFgdPJZJY9dvKiNGKS7kZtQ8KiwEzJkWVU/sV
 wvL6DP/w92UCkbOHfME0DGxXthUk+6YXeFxET6k2AC6vvGxEQg6jJvW
X-Developer-Key: i=nayeoni.kim@samsung.com; a=ed25519;
 pk=6rdU/EioX/vzm132vDyAq+TUk6SqpWqob+mz30+/n5E=
X-Endpoint-Received: by B4 Relay for nayeoni.kim@samsung.com/20261102 with
 auth_id=1381
X-Original-From: Nayeon Kim <nayeoni.kim@samsung.com>
Reply-To: nayeoni.kim@samsung.com
Content-Transfer-Encoding: 7bit

From: Nayeon Kim <nayeoni.kim@samsung.com>

When the client sends LAYOUTGET in the OPEN compound and only the
LAYOUTGET fails, e.g., with NFS4ERR_BAD_STATEID, the OPEN and GETFH
still succeed but the compound status is the LAYOUTGET error.
find_open() looks for the OPEN reply with "NFS.status == 0", which is
the compound status, so it misses this OPEN and either returns
(None, None, None) or picks a later OPEN of the same file.

Fix this by matching on the status of the OPEN operation instead.

After this change, the matched OPEN reply may contain a failed
LAYOUTGET, and find_layoutget() then looks at the same OPEN compound
repeatedly until it hits the recursion limit. In that case, ignore the
failed LAYOUTGET and look for the retried one.

Signed-off-by: Nayeon Kim <nayeoni.kim@samsung.com>
---
This conflicts with the pending "nfstest: DELEG: accept the attribute
delegation" patch, which changes the line right after the open_str
line in find_open(). I can rebase on top of it if that goes in first.

Tested by replaying packet traces with the failed LAYOUTGET through
find_open() and find_layoutget().
---
 nfstest/nfs_util.py | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/nfstest/nfs_util.py b/nfstest/nfs_util.py
index cf8d6aecc6ae..e6a2dd21ae1a 100644
--- a/nfstest/nfs_util.py
+++ b/nfstest/nfs_util.py
@@ -566,7 +566,7 @@ class NFSUtil(Host):
                 return (None, None, None)
             save_pktcall = pktcall
             xid = pktcall.rpc.xid
-            open_str = "RPC.xid == %d and NFS.status == 0 and NFS.resop == %d" % (xid, OP_OPEN)
+            open_str = "RPC.xid == %d and NFS.opopen.status == 0 and NFS.resop == %d" % (xid, OP_OPEN)
             if deleg_type is not None:
                 open_str += " and NFS.delegation.deleg_type == %d" % deleg_type
 
@@ -625,6 +625,12 @@ class NFSUtil(Host):
                 self.layoutget_on_open = True
                 if self.openreply:
                     layoutget_res = self.getop(self.openreply, OP_LAYOUTGET)
+                    if layoutget_res is not None and status != layoutget_res.status:
+                        # The LAYOUTGET in the OPEN compound did not return
+                        # the expected status, look for another LAYOUTGET
+                        layoutget = None
+                        layoutget_res = None
+                        self.layoutget_on_open = False
 
         if layoutget is None:
             # Find LAYOUTGET request

---
base-commit: 94089545caa18bbe4be1b055125d0721fe8dee80
change-id: 20261102-b4-fs19-open-partial-success-c40d4194ce61


