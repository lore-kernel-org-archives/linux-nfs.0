Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFF0340B0FA
	for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2026 13:04:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785157453; cv=none; b=aCvcTPcu5rFwiIQlcYgCLA99cFFvz9CzwOYZ8yBr7mghQ34v0oiwulWwP9mHghQwCSfFUmRmp48M64j5m5HH5aoSG6dL3kVltnrlS9WhgoqOxRO0ps4YDfoHF6iSmpOt+hTF4l/dqTrWc4xZ/1MKv+XsMqRAavMRb9qT66fNQf0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785157453; c=relaxed/simple;
	bh=c0BOrlhF0Cb26mGlMnSZgRAIOJvLyk1bEAbI3o9z/vw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=W6VAmBs7xRnq+7wRv909DlS+MtZyvAnt75QRd+hMvDlARvOZOGjTaztG6sJ0BWKDrc3cLhAtyu32h5ICQ3sf9uR6tcS8H3j+4lqLwFT8/6wMqUr1q0dj30XGybS4Og0LOzTaRTQYHRBXSgjXYy0y5pwnimiCerJd9RYM1OfRBaQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YUYtMpl9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YUYtMpl9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D29FD1F000E9;
	Mon, 27 Jul 2026 13:04:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785157452;
	bh=LSaVQzbOfVeI8uBm/EMdojBNdMkwwOnLcDaYbnFpCKg=;
	h=From:To:Cc:Subject:Date;
	b=YUYtMpl9k6gsAxXZIzXgvkQv4ejBmKkVD745rt+LOOt7mb7F7XlP18n1BtZX61ihg
	 COCBq+n3g1B4taD6dAXqWsoDRv0IqdXqVWbg7F6ShnxIGn8GG/gZSBxzNwcHnJVIXC
	 C32uWMwCyPQp3PtufLLByGK6jvMHkPu/Y2nYigukCe3OZQFxupWFPlmNFuSHurLdDg
	 xnUOKeWe2XGrIi+/TI/yp4gHI4oS7Kb9Ged+jlwCkVE4V+hxkMdOXoCFq4mE2O2D3d
	 yKfXv6vi609IPOUyyRxmotGtSLilZPys2L1fFywMfPuAkvH8OwPPTqJq0JDjwIMD25
	 UG4XBd8Z+AlFQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] Remove NFS client header dependencies from LOCALIO
Date: Mon, 27 Jul 2026 09:04:07 -0400
Message-ID: <20260727130410.14887-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clean up: fs/nfsd/localio.c is a server-side component, so it should
avoid dependency on client-specific headers and XDR utilities.

No change in behavior is expected.

Chuck Lever (3):
  NFSD: Move the RPC program definition for LOCALIO
  nfs_common: Remove "#include <linux/nfs.h>" from linux/nfslocalio.h
  NFSD: Tighten header includes in localio.c

 fs/nfsd/localio.c          |  7 +++----
 include/linux/nfs.h        |  7 -------
 include/linux/nfslocalio.h | 11 ++++++++++-
 3 files changed, 13 insertions(+), 12 deletions(-)

-- 
2.54.0

