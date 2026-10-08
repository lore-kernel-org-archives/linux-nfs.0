Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B413035FF6C
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:47:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791474454; cv=none; b=GbvIbQbQgW0mc7jwxe0dwi1CWRklrX/apoa2QqW8oQMa/gZL0K+Kk/JCKvwXHvBQtM9ml8EREysDPk7L8SkzdhYXs310hqYDbQU9EF80iB4Gy3uyzc1/WLvsWw8v9EE0g39i65VWQVm9nnMgJqHHFzSpqYnmCZI3iEkWtFdA+Ks=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791474454; c=relaxed/simple;
	bh=PqpoV0t3CNYCBQDu0BdRdXK48DLu5bsz7I+calhBxIs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=tgQ7ytcWTR/ZFoV5RZMnbtPMHgN4mmOQaTxAA/by/2DG11v3W5BSn9U9BUm1aw1f5empNl6FzKOTRF2Z0Mm24kwZjeTdxDvyR+D5z2gIVjREB0r4YeG2j+PYjia0iRUEsXdnaO7X4QzK7IIbphyjtI7CpUeTumwjOwKRiHgoPfM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MhfzeSfW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MhfzeSfW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 907581F000FF;
	Thu,  8 Oct 2026 15:47:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791474450;
	bh=kMu5YlxNKz3sbyTwpACaa1GzKksesr8YbBmTu78Rk3M=;
	h=From:To:Cc:Subject:Date;
	b=MhfzeSfWOhRcFf+UXoFCPobNJiwRN28XNdUsZvLfbYEXfl4BYaKKOU6B1aWhbF1NB
	 MXK0Ps4At3/Q/JD167wTd5mLdDkwiZ+VbCIjo7UKlL/B0esXyIe9poEZyd4q+8Ttqd
	 WiWlqOpL/yL86ElswFdPy4dxe5wMVZ4HtoRPWKh4ktrBmGN5HM5RgrO1f96E8qLjFg
	 XctLz13axVRGI6g9UkG8a/P2q8CrO2h/nAn8AH8EALym0TFhpmofJss5c+VeUC4Izn
	 PU2WfXnvCDiR5YWnJjFX1njEceENZzXZDfs3jWal8bJx8Li2mHexhqCDq7OLWsd2XD
	 2cP/WYjN5Uzww==
From: Chuck Lever <cel@kernel.org>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 0/8] Test the WANT_*_DELEG OPEN flags
Date: Thu,  8 Oct 2026 11:47:21 -0400
Message-ID: <20261008154729.77787-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Add specific compliance tests for requesting delegations on
already-open files, as a pre-requisite to finishing the Linux
NFSD implementation of this feature.

Chuck Lever (8):
  pynfs: add test for OPEN(CLAIM_FH) with WANT_READ_DELEG
  pynfs: add test for OPEN(CLAIM_FH) delegation request on an open file
  pynfs: add test for a delegation request after a recall
  pynfs: add tests for SETATTR by a delegation holder
  pynfs: add test for WANT_OPEN_XOR_DELEGATION through CLAIM_FH
  pynfs: add test for a CLAIM_FH delegation that outlives its open
  pynfs: add tests for delegation upgrade and downgrade wants
  pynfs: add test for OPEN with WANT_CANCEL

 nfs4.1/server41tests/st_delegation.py | 405 ++++++++++++++++++++++++++
 1 file changed, 405 insertions(+)

-- 
2.55.0

