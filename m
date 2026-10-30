Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793333180;
	b=GUGhMGxsf57K+8263hELojJH8/10G4aQ1KwsF1Bax1yLrtnqg/VJQTjVHUoVUTVSBXBA
	 mLDakVKJLeQcYzb/YhCyQlFnPY4H7Vl5CwrJVDmLldHnA6Fjd5OGBTLb1bxsZ8CAikbWf
	 k5arYmWMkAz8t01SlcyaW9azhgFoIDOwuo5PDMwCPccuRJC5WRktvRfxraLthsMniwWzQ
	 D+JQ2VdnThwoavVIORQPMliiNpDwH5IbletTsMg72E1dI9a3SL7hTQWGxdvz3luQds8lS
	 dHTW6AkUEirw5DCyVU4mqTEnexU75tvNPqlQJyfAqJvbc7i+WEWzU6vSbVVPqUfI/2w==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793333180;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:X-B4-Tracking:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=7QjOaxnuqQRFLvn1pzdZ2frORY71AqJEELaR81AFzz8=;
	b=sARb6F65JhDOdhjTTEXUdSP0KfJYjEX9HUWcj4rPWIhETnI3BGWYQ2+nuX4UsUHPykKR
	 CbYHDywIqIOh1crzX6YbJpLbO5dV+pEKOkMWY5rn98JS0TXut4RcNl/zYgnWigQbU+NF8
	 ycRZxpVhTMl4WJtecg9zSb61jTOln4UcKu8+Ug1DTohiPMQg5p50lZCw4GUucyIGdLyfN
	 fjg/TzjSGeAZehKmLm/bVuZSYp8CsfLzdZIE5V/q9tX7jAvS02kYDLO1DbdAXQTWiVGi3
	 dEDuglGMuqjHouzVTL9nR1RO5NGQiwRLZhn9kKiZOWPcURorFWVvVgtsmO7KGUtER5w==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K17KlGia;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 976B0606A31A
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 04:06:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K17KlGia
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1793333180;
	b=cJ+BMdeGaqOMIY3zTCnon9sWJeyguydKZYTTt3PG6pcmBtPQo87T60tPxEF6XRzdaJdG
	 JgH4IhzN37tGWAcvKWTfM5SY1LvpLw+AK4otVK/RM7s0XKjfnP72grh4i19G0UEwEV+R0
	 earzCNDq6lU/rd7dZpoQzxmXkVN4kUQhfjjgboD9wZP2hija/gswfp7sNomu0tDhMQg5+
	 kfvGY0owAUon0LivtAVd1F5uOtd73JwDtiLjRxLVXumFIiiz3v7GBUUn9p+jrcJs+dtiR
	 2Z0gWk+sj6WiFv3eleLHFTEvw00q6HRLNEhDB9mMNkveGomqfaWSyuI/tvrpZGxTn3g==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1793333180;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:X-B4-Tracking:To:Cc:X-Mailer:X-Developer-Signature:
	 X-Developer-Key:X-Endpoint-Received:X-Original-From:Reply-To:
	 Content-Transfer-Encoding;
	bh=7QjOaxnuqQRFLvn1pzdZ2frORY71AqJEELaR81AFzz8=;
	b=WXFQHW45kzFov+3BT7AXjr6WvCQ0BMkjKGKAYmRwuWa7F67mp9bBSoP/ECGEauXykSgX
	 gZkLH3Vqjva1reo0MQ+XgKbPNZCvnxyqycWhwwI/GsImvM6Qi8FSgBx7m+TScPIauOQgs
	 MmKi9hWEm1fZrAs4U9zf+2q4JNjBuxUs960cyKZkvMpwAO1oPFwUDFsyLGET4cDF/CO+O
	 P6R9VmYNeqn4E1jDixoJJO5bBRlh9dau/QEWWp8EV+U7V7z1LMW4uSjstb+kpa/ncUTtN
	 2Pd4tlQ/v8Gggurl+XY9twpxIQlIZQwqwVBrLf/werT7Ecc46s5x99YXgpXuSGlrD5w==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id C052D1F000C1;
	Fri, 30 Oct 2026 04:06:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793333180;
	bh=7QjOaxnuqQRFLvn1pzdZ2frORY71AqJEELaR81AFzz8=;
	h=From:Date:Subject:To:Cc:Reply-To;
	b=K17KlGiaVJ/txjcx3ZwWInuJphUCblEzJBj1fVq5pI2iV9k3dSEEarymfeZp/DTo4
	 Zo0D4r5NpItrsLmCPeoHKDlNUAypNXkvUZz+mfb9AkHnalKQDoovnSUSm2+75cs2Xx
	 mFy+03ZS/XIH+30Qyl0jgWaD6GlgeK2KEhzgadZrSihqG6/C/mzEuSJJg9O0tP6iVq
	 436l3uQ6xd6dV/tFFIAgaMzL5d2WKKcU3PD37Ueer6NKvrHoa3VqXkBq0PmduYzlMm
	 gKjWW5xklaEjwrH9KJ6ZE1hfDjF4e5eVKwLdzg1Wn3GIsMgleQAG2E81FIyIyJjKfI
	 cPlNyj3/JJx0A==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 1F79343632;
	Fri, 30 Oct 2026 04:06:19 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Fri, 30 Oct 2026 13:06:19 +0900
Subject: [PATCH pynfs] BLOCK3: send an empty extent list in the second
 LAYOUTCOMMIT
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
Message-Id: <20261030-pynfs-block-empty-commit-v1-1-a1dcc3473ac1@samsung.com>
X-B4-Tracking: v=1; b=H4sIALoX5GoC/x3MSQqEMBBA0atIrbtASxyv0rjQWGrRnYFExCDe3
 eDyL96/ILAXDtBnF3g+JIg1KYpPBmobzcooc2qgnOoipw5dNEvA6W/VD1m7PaKyWsuOzdy0JU3
 VSFRB4s7zIue7/sKrYLjvB9yJxclxAAAA
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, Christoph Hellwig <hch@lst.de>, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1793333178; l=1862;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=HzkblooUr65z9Ok3LlhdDkT+TzEVEd2JnZC43XXWaos=;
 b=7alkc8rE+OY9hqxCuyFtqq8z9HIYa6If7Vedb3OK1vsdfY2wGAq1ET5Id+Hk68fpgyYTGKm0J
 lzPsfxhOQgHBiodrADuN9I7lTnmgpQpnBODZhYND/df3NgIpijrC/Xt
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com
Content-Transfer-Encoding: 7bit

From: Daejun Park <daejun7.park@samsung.com>

Under Python 3, BLOCK3 fails on every server with a TypeError: its
second LAYOUTCOMMIT passes the str "" as the layout body. Send an
empty pnfs_block_layoutupdate4 (RFC 5663, section 2.3.2) instead.
It holds an extent count of zero.

Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
With b"" (the zero-length body BLOCK3 was written to send), nfsd
answers NFS4ERR_BADXDR. With this patch, BLOCK3 passes on Linux
nfsd over XFS (mainline 65ba8f34ec88).
---
 nfs4.1/server41tests/st_block.py | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/nfs4.1/server41tests/st_block.py b/nfs4.1/server41tests/st_block.py
index 3cfc1c6..d43b7d5 100644
--- a/nfs4.1/server41tests/st_block.py
+++ b/nfs4.1/server41tests/st_block.py
@@ -158,7 +158,9 @@ def testEmptyCommit(t, env):
                            layoutupdate4(LAYOUT4_BLOCK_VOLUME, p.get_buffer()))]
     res = sess.compound(ops)
     check(res)
-    # Send another LAYOUTCOMMIT, with an empty opaque
+    # Send another LAYOUTCOMMIT, with an empty extent list
+    p = BlockPacker()
+    p.pack_pnfs_block_layoutupdate4(pnfs_block_layoutupdate4([]))
     time = newtime4(True, get_nfstime())
     ops = [op.putfh(fh),
            op.layoutcommit(extent.bex_file_offset,
@@ -166,7 +168,7 @@ def testEmptyCommit(t, env):
                            False, lo_stateid2,
                            newoffset4(True, 2 * 8192 - 1),
                            time,
-                           layoutupdate4(LAYOUT4_BLOCK_VOLUME, ""))]
+                           layoutupdate4(LAYOUT4_BLOCK_VOLUME, p.get_buffer()))]
     res = sess.compound(ops)
     check(res)
 

---
base-commit: cd4701827a8261fedbfb4c6e39029fb9671321a6
change-id: 20261029-pynfs-block-empty-commit-7d7832b5a225

Best regards,
-- 
Daejun Park <daejun7.park@samsung.com>


