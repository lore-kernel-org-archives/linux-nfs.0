Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3C103D566F;
	Fri,  4 Sep 2026 16:11:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788538320; cv=none; b=KGRm1EG/h7cbtdulHvnOtujkqwK1qcRKeExb3pxiEmGFEs8Th/Pm5BO2spntQ1nGSrPHSNbD0QROzIJisEBTy/lQ9puyQw5HsuRQz29DHPB3J/9+hWr/jjwsDHn7Inc2j2ZzuoLjD+9i6yMIMAe/Iz77JS4H1CQQG+M6KjOoB2I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788538320; c=relaxed/simple;
	bh=sYNNdCHqE/KN9Zct2AmlwOjDOopxznmk/J1MPYmUFFM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=WULdINrCCRQfXsPfvwWna69vnN6s6WTy3hIYpARu9ZdvN/BjDEDpjyAxzL0YpMAbMaV0t8jUNOvqeoVuvFJjKOUW4ekM5wNYJDFM5R40If0InqQIU6IOE0KVpdjjBklt8I/a+Z4hOBz+XjPW6N7Fgibo62Dcc+SYG62RqLnLV6g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lV5XIzPf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lV5XIzPf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B4C201F00A3D;
	Fri,  4 Sep 2026 16:11:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788538317;
	bh=NxayeQiMWpufbOlI8EzHLrjPXhtjAb/N6rQV0bh54j8=;
	h=From:Date:Subject:To:Cc;
	b=lV5XIzPf7W/sJj4zYDfoT+vOZnxLlRPjXMZIwvPkBKp8riKTYOei6oq1R1oa7D7qB
	 ynTOpMWiDtsdB1nz7W4EtKbOWLe9AhapqpCCTlxzEyAPap0K7gQjPLVmSq0Yn0bmj8
	 J7I6HrTz5UmGHLb5o1yoWukYI+11sYLMJ4GmuNOkD6qwjVpkDbiywvjgz3z/b6ftgZ
	 MCwqHNvHU7TBfuosmJJ6rFdLEz39ooqNwi0Jf62+M0U4ipkIMLfLqS0OwZTq3LXFr+
	 HivOtkYm3pScWFCz7izs3uAo+O9179XZZ2BAxB6NhCw8JKI7N32AqgyXM2JU/+Ez4q
	 P8cqIMIFWtoBA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 04 Sep 2026 12:11:37 -0400
Subject: [PATCH] nfsd: don't offer flexfiles layouts when NFSv3 isn't being
 served
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260904-pnfs-ff-v1-1-5f502cf25401@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDSwMT3YK8tGLdtDRdEwvTxGQjQwMTo0QzJaDqgqLUtMwKsEnRsbW1AKc
 eGxVZAAAA
X-Change-ID: 20260904-pnfs-ff-485ac21042a6
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Tom Haynes <thomas.haynes@hammerspace.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Benji Wiebe <itsme@benjiwiebe.com>, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1689; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=sYNNdCHqE/KN9Zct2AmlwOjDOopxznmk/J1MPYmUFFM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqmu3GGMrK2pHBWo3zEj4dflJ0o1XOnR+Nr9/Ib
 rdUGFYzp1OJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaprtxgAKCRAADmhBGVaC
 FQ6aD/0ZsbjMT6Ztf71kQV2TKnp/S2D9ZoJBODti9QxnOY+KcPmjFUceueMAT34IHy0hvFq6GOS
 MgPFvqffE9o3G23Z903nadKSwLiMyL9sniwzONfM5p4vhVeh+e74zOfEPYo8KmXeWqJMAAeZC7w
 mb9fbhMzr29bOKAqJSUt16Hk3mFFfvaS/TQQC+a1QZMLwykn0KuPIUFQ2+viVKp2L1w8gb6xXtL
 80KOSNboMn7pihQE79APOFnkeAIxVkRLHD2hw2HEhJQDHej42AKxSwaOlMmy/X3G6bjSISChsIs
 zfwicKUaISGP/qZVZRbOOLXIZ8TqUSUW+B+1KI1aki13XLCtGFYXoaCvDRlQt03Bjf/PyMAzAz3
 m53cF1l8ca9eiFeqSiFDtOyRIqVyp1F0oVY0TRFenA4BoF8WmagPPu+QGEeE4lRQQUQzK5jhVJz
 hRHSErk5agFN6M/dKxwU2NOC/73kY6nCVdV/LwVeOpU77s6kAkYuZrpKiWfljNN7J9hImgRJNJa
 LupjCWyjYI7gj8s+Hj5pt5T5lUvAFASLqGKG2h5xwnSMQLqlwSkzfc35Zj+iiPRSWLhITpPS7+p
 35osSv1IqwGcAPjlRvTeIMFuAe7gwBgnIzJFDlqjk4Meti7dQ+n5x1sJPAfFniyVVwEhxjLnFmM
 IdTxhggLbjkLHIQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The flexfiles layout driver hands out a deviceinfo that names this server
as an NFSv3 DS (flexfilelayout.c hardcodes da->version = 3). With v3
disabled, the client can't talk to the DS: it loops on v3 NULL calls that
the server answers with PROG_MISMATCH, and I/O hangs in D state.

Skip LAYOUT_FLEX_FILES in nfsd4_setup_layout_type() unless v3 is enabled.

Reported-by: Benji Wiebe <itsme@benjiwiebe.com>
Closes: https://lore.kernel.org/linux-nfs/c734eeb8-8486-4491-bb4d-b9656cbaffbe@app.fastmail.com/
Fixes: 9b9960a0ca47 ("nfsd: Add a super simple flex file server")
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4layouts.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 22bcb6d09f70..cef4d40c89a2 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -127,10 +127,12 @@ nfsd4_set_deviceid(struct nfsd4_deviceid *id, const struct svc_fh *fhp,
 
 void nfsd4_setup_layout_type(struct svc_export *exp)
 {
+	struct nfsd_net *nn = net_generic(exp->cd->net, nfsd_net_id);
 	struct super_block *sb = exp->ex_path.mnt->mnt_sb;
 	expfs_block_layouts_t block_supported = exportfs_layouts_supported(sb);
 
-	if (IS_ENABLED(CONFIG_NFSD_FLEXFILELAYOUT))
+	if (IS_ENABLED(CONFIG_NFSD_FLEXFILELAYOUT) &&
+	    nfsd_vers(nn, 3, NFSD_TEST))
 		exp->ex_layout_types |= 1 << LAYOUT_FLEX_FILES;
 	if (IS_ENABLED(CONFIG_NFSD_BLOCKLAYOUT) &&
 	    (block_supported & EXPFS_BLOCK_IN_BAND_ID))

---
base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
change-id: 20260904-pnfs-ff-485ac21042a6

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

