Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B3A343921DB
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2026 16:59:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785257955; cv=none; b=cij5hamwR2NX/0KmXyZa31O43i3I6OcZaJfuFz3an4jxMJthmmjrJb2ZXhqwrTQV2JK8UI/KOk8FLyJpQr2ovMLJhHWIoU+7msGDk4GR+UBSsb8WK/NrGJzyfo+MFM0OgRaPvVNbDXxXnxlKRZkedEZz9n0zFe/ZjQd4gsl8xi0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785257955; c=relaxed/simple;
	bh=LlMgsLAUkklC+Klm0fA1eJHalOo5NSNtT9f8mQVBCxA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ptkEus0KYMwmFaYbi22HvL0yXKOFWQGGAyNlc3kSUVFjXaZQfcPwcw9JKzKyw4sE7XT8X16RHKJu76dZ7RwhmxE/eR1ik5AsiZHm2JK8eAgBBAO3VYdDwDCAvgk3t+T+f2LT7RgJBIEGJrZC+xJImOwzPxAzaaTo14YucehsE2A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OZk7DlLw; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OZk7DlLw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B90751F000E9;
	Tue, 28 Jul 2026 16:59:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785257953;
	bh=Kv+QaDB/7GR0IqkL9RRE/qgAp6ij4PzKZ+huUjrk8Bg=;
	h=From:To:Cc:Subject:Date;
	b=OZk7DlLwLt275SIlhgncuNYwnUp0kfilj9LxwcUbEth/cOBfp5UYXuwrzeKnbnQYG
	 7NsSc+ZJXNDX1EF9xh+RusLy+JNx/5FF0VTn/pXTQN8+UTeNzV0f95v2Cr1poB+bqP
	 9RjTSSbh3rQDNFZZprQ0vGv0W9KHvLlUg44mx4OUmhPkWbyp8NAQRPRCFBcGKZs5A4
	 YsCGiQY7eTb2RlRy/BIqn4d7lXYKfF8gp6cQyKqkvIoifltechELwbuoU3/e8Czbfc
	 E2WNYIS9734EBteYEfLfiQbBfUibAWFYV+A1y4tUUFf4+wcSNj2EeLl9H4oEorJFC1
	 uvrtQ/z8UNI9g==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 0/5] Remove NFS client header dependencies from LOCALIO
Date: Tue, 28 Jul 2026 12:59:06 -0400
Message-ID: <20260728165911.462534-1-cel@kernel.org>
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

---
Changes in v2:
- Including <linux/nfs4.h> is also no longer needed (Neil Brown)

Chuck Lever (5):
  NFSD: Move the RPC program definition for LOCALIO
  nfs_common: Remove "#include <linux/nfs.h>" from linux/nfslocalio.h
  NFSD: Tighten header includes in localio.c
  NFSD: Name the fh_maxsize value that carries no NFS version
  NFSD: Don't apply NFS version-specific behavior to LOCALIO requests

 fs/nfsd/localio.c          | 10 ++++------
 fs/nfsd/lockd.c            |  3 +--
 fs/nfsd/nfsfh.c            |  2 ++
 fs/nfsd/nfsfh.h            | 14 ++++++++++++++
 include/linux/nfs.h        |  7 -------
 include/linux/nfslocalio.h | 11 ++++++++++-
 6 files changed, 31 insertions(+), 16 deletions(-)

-- 
2.54.0

