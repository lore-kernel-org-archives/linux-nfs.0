Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A08BC3BFE4F
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 04:10:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791951026; cv=none; b=rkae8/BFm8Y0PKsqBwblgriWgwnX8uUVIacq47/HXVDxiAOloLk+nHsqbFPNgno2+Rji+OGA5AyPEjRUTk1YvrZv1aKwVCB3GxxwTASo2Ws+ST7H+dH7YzuxTXerjNPrMuwCBG5cDKTKuk5Wgg5dUAU3gRvo+LoTdFxskxU3DIo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791951026; c=relaxed/simple;
	bh=3Fp8P4HKTqbNbg3T2GfmaG47HIdB9kMIe1WJy9U0SW4=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=AMiafNbCNsmPvL4/1EnOCQW1ZhP1c9KuApi/XeAcr4Wrii5GN5ZQcvSQkhYKdrM6MlakX4VlFP5AI0rYa6ppJzApmB7gfD07R9YsAiuaNblmuCWYlKyRG4HKswG1P9nsZegP+FlDpfOfVtonhmCFlQZ6JA09cONwP/JF9pm2fiU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cmghC6HF; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cmghC6HF"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 42587C2BCC7;
	Wed, 14 Oct 2026 04:10:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1791951026;
	bh=3Fp8P4HKTqbNbg3T2GfmaG47HIdB9kMIe1WJy9U0SW4=;
	h=From:Subject:Date:To:Cc:Reply-To:From;
	b=cmghC6HFl28TFHU2VGmyj6XoGZ166xWqumQLUWSAqK0Juqz5ERChXSNt3KjuN/SA6
	 HLApQU6zg+VREWgcpwd2/JAMRv9yg5F0eVmc5eki0JBsbtk1nPudidFpIJ+CXwT2al
	 vfAdutCh2FHjVDiqmT0ZNTKi7svymWg4IjegATYkHyB+NO2HeV79RqGtl/T6+TDXSH
	 dvFc0vqbabVCv/1PW0SURiPh7fI6GqSLjeCNADsNFr08v9PElM57b/pSvtwYGNE36d
	 A1p80JHOR8KbFikQxlZAg44SpG7Q7OjvIRarlgkMMd5RKx4Ft2k5TGyRw2mlF+TKU2
	 ghKRNNOheAhmA==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EC9DCC6B19;
	Wed, 14 Oct 2026 04:10:26 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Subject: [PATCH pynfs 0/3] Block layout tests for LAYOUTCOMMITs of ranges
 without blocks
Date: Wed, 14 Oct 2026 13:10:25 +0900
Message-Id: <20261014-pynfs-block-commit-v1-0-1723979f495f@samsung.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIALEAz2oC/x2M0QpAMBRAf0X32a0NjfyKPDB33LBpk0j+3drjq
 XPOC4E8U4A2e8HTxYGdjSDzDPQy2JmQp8hQiEJJISs8HmsCjpvTK2q373yiroWhsqxH1VQQw8O
 T4TtNO0g+9N/3A2H/OH9rAAAA
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, Christoph Hellwig <hch@lst.de>, 
 Dai Ngo <dai.ngo@oracle.com>, Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1791951025; l=1794;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=3Fp8P4HKTqbNbg3T2GfmaG47HIdB9kMIe1WJy9U0SW4=;
 b=pJwOE5elA4qDNMpNft7wX+SjhuUYZZG2TfK2shhALNt73Qz+ItwlrkZ85H8pJhYauI+XrUgnh
 0R2YaBlZ7csBPcF4Wsc3vrZFZ2GgKc2tamcdvz2rjgMa+Beb1abbTJn
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com

Patch 1 is "Add a test for contiguous writable extents in a block
layout", posted on October 6 [1] and unchanged. Patch 2 adds tests for
LAYOUTCOMMITs of ranges that no layout covered, which shut XFS down or
committed a block that nobody wrote before the XFS series in [2].
Patch 3 describes how the block layout tests are run against Linux
nfsd, as Christoph asked [3].

Tested with Linux nfsd on nfsd-testing d918c664efd5, XFS on an
NVMe/TCP namespace exported by nvmet, in QEMU guests with KASAN and
lockdep:

 - Without [2], BLOCK7 fails at the GETATTR after the LAYOUTCOMMIT, as
   XFS has shut down, and the tests after it fail for the same reason.
   With BLOCK7 and BLOCK8 left out, BLOCK9 fails because the server
   commits the hole. BLOCK10 passes; the server only logs a
   "non-standard errno" warning for it.
 - With [2], BLOCK6 to BLOCK10 pass in 5 runs, and also on an
   XFS_DEBUG kernel.
 - BLOCK3 fails with and without [2], on a bug in the test.

[1] https://lore.kernel.org/r/20261006002622epcms2p38e492aef17fdf79e48b05c9aada2918d@epcms2p3
[2] https://lore.kernel.org/r/20261014-xfs-pnfs-commit-hole-v2-0-d3a02a79ab6c@samsung.com
[3] https://lore.kernel.org/r/20261013120359.GB2944@lst.de

---
Daejun Park (3):
      Add a test for contiguous writable extents in a block layout
      Add tests for LAYOUTCOMMITs of ranges without blocks in a block layout
      Add README-blocklayout

 nfs4.1/README-blocklayout        |  41 +++++++
 nfs4.1/server41tests/st_block.py | 230 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 268 insertions(+), 3 deletions(-)
---
base-commit: cd4701827a8261fedbfb4c6e39029fb9671321a6
change-id: 20261014-pynfs-block-commit-c70fe337b684

Best regards,
-- 
Daejun Park <daejun7.park@samsung.com>


