Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 11E433314B7;
	Mon,  1 Jun 2026 17:54:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780336458; cv=none; b=ltvOSa74UZ3OGnp9J9rgsZGQytrDi/2myauM9fqYwC6jA7+mkiGXLn3kTwTOE6MuiKQD75ba4yea+XRjVooOqc7J/70Ngq1Vn01aUvALRa7fgRLuf+bxwF5/pClRZRHVpcBnnkVus/8ct7OD3SFNTVq6pjqDXAxBKNQMZSuKi3I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780336458; c=relaxed/simple;
	bh=QQN1FIxJSjNkFCqAEgWU5GoFo7bWLjkTBSQbKgOMPc8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=oeU/hI4xUMzRa0nRZIIzCpF0EScRtCg6Up2W3TfEc+35HULTYQprqITUsQafDIJ1c6YOTDmpFTvzUA4+OemmovztBTltt4N7EBA3Mxt3iuAN5CEBcMg0IzAES9SLc5P9q2pf+fEZ9/FCCDHScHlFTZJRHYuSY9Zo/39AGXWZMFg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VKYGIb8I; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VKYGIb8I"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F3F81F00893;
	Mon,  1 Jun 2026 17:54:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780336457;
	bh=e1QcJj45qt5DbLcbp8lWq+XdaIUJ5pHVCoH9Vk6WC8U=;
	h=From:To:Cc:Subject:Date;
	b=VKYGIb8IaG39M67eyLWOGn3YmGvhGnA+7mhTK/0Jw4hbHJw7TSJtWFcpCGdFrSXwS
	 1QUsgGGizY9zG/rBfgnU7QgndlM1SAncPg9z9cIB72lr9gfwwq/jYopVbl34x6slT0
	 5nkjHQMHOattaq44zbYj6NYij2VFsoJDMSrhMFHhulSBObrkYa/aXZrzIInrwEfY3D
	 C3jeyS/JJu6pi5VQIt48jauSBlkx8kBWzRGpdfDQ6e5wiiHnd+ABBUdHxAKeJIpe1i
	 kZNOVM4AfJGFdAACZpJseIBC+LHBvjKkBw4sRJfma9cKUaP+IgqAhPtGkSEemsfDW5
	 Z5SXqacDkYa1A==
From: Chuck Lever <cel@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] follow-up to "Decouple req recycling"
Date: Mon,  1 Jun 2026 13:54:11 -0400
Message-ID: <20260601175413.29544-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

Here are a couple of trivial fixes to the recent "xprtrdma: Decouple
req recycling from RPC completion" series.

Chuck Lever (2):
  xprtrdma: Fix I3 invariant comment in rpcrdma_complete_rqst
  xprtrdma: Remove tautological I2 assertion in rpcrdma_reply_put

 net/sunrpc/xprtrdma/rpc_rdma.c | 4 ++--
 net/sunrpc/xprtrdma/verbs.c    | 4 ----
 2 files changed, 2 insertions(+), 6 deletions(-)

-- 
2.54.0

