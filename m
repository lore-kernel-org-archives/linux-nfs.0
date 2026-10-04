Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6B4A39DBCB
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 19:40:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791142832; cv=none; b=mPDYKcPg3sgxKbwD7GdxYDfDQpyR/8D89kOIp4ajtO3RHpWDXs2NV7edN98VyGuDmtIm9ACfprqhYdnFEtR7+rpEHLp4abwsz2HOjZRmukZgX31RpXeetrPvAiHIW438TcZa23Gvhl8m35jX7F6DIoGrPHISxYA5qBmO7Pkqcrk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791142832; c=relaxed/simple;
	bh=INVGyAGaiKSOGTZmn0juB5na7hRkP1ClhI8kOyYCKc0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=t6wGZyDCse6ppox7rdPddqIKPcpPgk8SxA2m6msKjEQixdEXxx6tDIDsWgRORfA7pBLplFqkfphI8Ltpq7AQKFtBapewuPnJvVycRT043+u9L/ajXKMKGY0X2y3S9VgNEcWpYWI/eikeOS9Wmcfrc6ShVDecXkLrgaXuBw83LNE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=L63kiK5e; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="L63kiK5e"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C88E71F000FF;
	Sun,  4 Oct 2026 19:40:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791142831;
	bh=73dOVR/80d+YgoK77D40IzsbP3kOqxzDTm8NToJo6NE=;
	h=From:To:Cc:Subject:Date;
	b=L63kiK5ek1FjUoPY4TZEw9IeyAZRR/wT6sDyhurAyxeaLzgVcikuaTKBBuIxmh9Ed
	 mjd5RmeNjLC41rjmskjHSZInTPvXg/Xb5W09lGzyB9jbyksvj9y7fWuX9fjxklV+DK
	 lVJT8aOkYu0Py7syYZ1XWj606dNke3HPK9KppW9/QnFtI3hJzfefSD4p0ogdqywgdl
	 1kXmZGJ6OX+of1EmjDXc12Rjyc/5JoBg1V/vSbBNJNfekNYie5Z2RDYh/xjTcYIeX6
	 fzGYztP7PfGAwgfcNcR16Narg6rVIUi6hTzm59cbZinFhcu8NaPcM0JFZp24SKMR5o
	 sKTS1IVtT4oLw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 0/7] NFSD short subjects
Date: Sun,  4 Oct 2026 15:40:22 -0400
Message-ID: <20261004194029.10714-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This series of patches addresses several minor issues discovered
while reviewing recent on-list bug reports and fixes.

Chuck Lever (7):
  nfsd: use direct I/O only for the last operation in a COMPOUND
  nfsd: account for page_base when advancing rq_next_page
  nfsd: locate the READ sink page from the reply buffer
  nfsd: keep spliced pages below rq_next_page when a READ fails
  nfsd: remove unreachable cancel of the layout fence work
  sunrpc: preserve rq_daddrlen across request deferral
  sunrpc: assign RQ_LOCAL from the transport on every receive

 fs/nfsd/nfs4layouts.c |  7 -----
 fs/nfsd/nfs4xdr.c     | 26 +++++++++++------
 fs/nfsd/vfs.c         | 67 ++++++++++++++++++++++++++++---------------
 fs/nfsd/vfs.h         |  3 +-
 net/sunrpc/svc_xprt.c |  4 +++
 net/sunrpc/svcsock.c  |  2 --
 6 files changed, 66 insertions(+), 43 deletions(-)

-- 
2.55.0

