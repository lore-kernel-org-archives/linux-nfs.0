Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86C4F4570F1;
	Tue,  4 Aug 2026 10:55:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785840927; cv=none; b=iIgTPiNCbVOdpMUT5tXb07s92HbQU6/6Ifb7nS+KiVmlVpFdRczWUPYmZl9+L276h8gc3jvmK53vkyLCAPlXNkB+5X5mODMRQmiXthhXretY1ylGPnSnQLVHAUSoxSeSdRAVKS2yEc3+by8Emh7mPBOYUkOmVX0QLQRx8DSRh1s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785840927; c=relaxed/simple;
	bh=hhGrI/mzu3aPM7QOJT92Awih3YCME5wdzbeEt4sTwTE=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=s10uwBlxo3gyZlGEnXjwzdI/hD1Dwkcv/WeXTbBuzGsG0sl+m1o5ZB51/IVub/8qy7f47I6JPAPoc2xtYXvi+x0Eyz3AP4wWI2zZUFEJ0q9VoHOEeGDi9b9yFnroKzAJJJmsY1NxP+Bp0CzNR6xm5CuhkRhd9af2gx+A+rFVlmY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QQOA80Ol; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QQOA80Ol"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 990BAC2BCF4;
	Tue,  4 Aug 2026 10:55:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1785840926;
	bh=hhGrI/mzu3aPM7QOJT92Awih3YCME5wdzbeEt4sTwTE=;
	h=From:Subject:Date:To:Cc:Reply-To:From;
	b=QQOA80OlDZyrZoaO+HuPeEGkqdi+aH/zi6LpxVRBMtLxk7WShdNcM/uZYW+QmkCC6
	 fZiuC3yH1dHEqoRN4+4AkHYMhL5LApSGYPDsCCpNihZbqUHU7gApwYX9sfadLhpGPi
	 oC0JTDQUmYntbnixFt2D+IoFLIliK976NUs/9NBmviErWv0SUMleF2VICmA4/Te6fq
	 lzevpOU5R25CDa1L96WE68x++yCQhHacJHmR/yMMCd/kdLunVKZsJlDPv5eZ2BciMz
	 Snc2NS4bdssepDxjys9H5lOcm6V0NsF6SxoH9/1bwA9MS13Y7xtie5lkLN4lhtmHaK
	 gHlKWP7cynpmg==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7524BC55184;
	Tue,  4 Aug 2026 10:55:26 +0000 (UTC)
From: Junrui Luo via B4 Relay <devnull+moonafterrain.outlook.com@kernel.org>
Subject: [PATCH 0/5] NFSv4/flexfiles: harden LAYOUTGET and GETDEVICEINFO
 decode
Date: Tue, 04 Aug 2026 18:55:00 +0800
Message-Id: <20260804-nfs-fixes-v1-0-1544df970e7c@outlook.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAATFcWoC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDCwMT3by0Yt20zIrUYt0ky0STFOM0k1RTA3MloPqColSwBFB5dGxtLQB
 CNjQkWwAAAA==
X-Change-ID: 20260804-nfs-fixes-b9a4d3f4e507
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jonathan Curley <jcurley@purestorage.com>, 
 Michael Bommarito <michael.bommarito@gmail.com>, 
 Junrui Luo <moonafterrain@outlook.com>, Yuhao Jiang <danisjiang@gmail.com>, 
 stable@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2609;
 i=moonafterrain@outlook.com; h=from:subject:message-id;
 bh=hhGrI/mzu3aPM7QOJT92Awih3YCME5wdzbeEt4sTwTE=;
 b=kA0DAAoWceg4UIuO8EAByyZiAGpxxRehjihg2fa9p7l612YNlk+omlLFaNcayWpISPql/qkaA
 Yh1BAAWCgAdFiEEx3DS9jhNtC20TLRjceg4UIuO8EAFAmpxxRcACgkQceg4UIuO8EA38wD+NFSS
 t2R5KI1Lq9icoRtW7TkkbE/EhQNa6bL+1BrI1igBALxCjQAGVXTYqLYtEphKxM+FZqnPzwaZUbP
 lA0REHCAA
X-Developer-Key: i=moonafterrain@outlook.com; a=openpgp;
 fpr=C770D2F6384DB42DB44CB46371E838508B8EF040
X-Endpoint-Received: by B4 Relay for moonafterrain@outlook.com/default with
 auth_id=909
X-Original-From: Junrui Luo <moonafterrain@outlook.com>
Reply-To: moonafterrain@outlook.com

All five patches fix bugs the flexfiles layout driver hits while decoding
a reply body from the metadata server.

Patches 1-3 are on the GETDEVICEINFO side.

Patch 1 bounds the multipath address count. Once the xdr_stream is
exhausted, nfs4_decode_mp_ds_addr() returns NULL without consuming a
byte, so every remaining iteration re-fails at the same offset. A server
advertising 0xffffffff addresses in a body that holds none of them spins
the loop for roughly 2^32 iterations with no rescheduling point.

Patch 2 fixes a leak of the r_netid string. Both loops in
nfs4_ff_alloc_deviceid_node() that drain the local dsaddrs list free
da_remotestr and the da itself but not da_netid.

Patch 3 checks the sscanf return in nfs4_decode_mp_ds_addr(). Nothing
constrains the characters after the last two dots of r_addr, so an
address such as "192.168.1.1.x.y" leaves the uninitialised tmp[] array
unwritten. The stale stack contents become the data server port and are
rendered into da_remotestr, which can leak client stack memory back to
the metadata server.

Patches 4-5 are on the LAYOUTGET side.

Patch 4 bounds the filehandle version count, which sizes a kzalloc_objs()
of struct nfs_fh. sizeof(struct nfs_fh) is 130, so a count of 32264 or
more pushes get_order() past MAX_PAGE_ORDER and trips the page
allocator's WARN_ON_ONCE_GFP().

Patch 5 rejects a stripe_unit above U32_MAX. It is decoded and validated
as a u64, but ff_layout_pg_test() narrows it to u32 and
nfs4_ff_layout_calc_dss_id() passes it to do_div(), which narrows the
divisor itself. A non-zero multiple of 2^32 therefore passes the
existing zero check and reaches both dividers as a zero divisor.

The five are independent of each other and can be applied in any order.

Signed-off-by: Junrui Luo <moonafterrain@outlook.com>
---
Junrui Luo (5):
      NFSv4/flexfiles: bound the multipath address count
      NFSv4/flexfiles: fix da_netid leak in nfs4_ff_alloc_deviceid_node()
      NFSv4/pNFS: check the sscanf return in nfs4_decode_mp_ds_addr
      NFSv4/flexfiles: bound the filehandle version count
      NFSv4/flexfiles: bound stripe_unit to 32 bits

 fs/nfs/flexfilelayout/flexfilelayout.c    | 6 ++++--
 fs/nfs/flexfilelayout/flexfilelayout.h    | 9 +++++++++
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 7 +++++++
 fs/nfs/pnfs_nfs.c                         | 3 ++-
 4 files changed, 22 insertions(+), 3 deletions(-)
---
base-commit: 075b74841bd0065a3bda3440873c747938e69b68
change-id: 20260804-nfs-fixes-b9a4d3f4e507

Best regards,
-- 
Junrui Luo <moonafterrain@outlook.com>


