Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 638DB47DD5C;
	Wed, 23 Sep 2026 10:59:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790161169; cv=none; b=TlIV9NYtf+vk+eTuKcw3WGGnYvyPye1O1Tr6BC6f+UxJtVDPl0tCUPlWTl3QHhzCXD1pLlYZiyafg/H/FwvAUVr0uV8DtPFXOKpGCmxs3b59Cy9YanypJcr+8T6ru1yIuB44nlpXx2OkAWYDsHZUvlcev2giNktdfqjXrLTtvpI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790161169; c=relaxed/simple;
	bh=G5oO/+RhBLTrz3cAjisoExQ9dTpAdQbN9ADtYijVQ20=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=r5am8pQW5ZQpg2KSMPd3u0S3pLPOax3LEeo5Nmy7JX+yp+jbwAZPXensOcL4dmR+53IG1FMK6B0QEeZaCllG9WW9h1VVTqMKZr0t9g7nhRdv965dw4cGyoPOxduy7zGQjZPg5ol0+C7nLkf5ahZ3faZ3bI/zbFRcx/WGTLl5/GY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Cxm2SRBB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Cxm2SRBB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A566A1F00893;
	Wed, 23 Sep 2026 10:59:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790161162;
	bh=D6U8HY7mBNbIPoapivmiB8AdBKml6Hnm2Fkjlzw9aj4=;
	h=From:Subject:Date:To:Cc;
	b=Cxm2SRBB5p4nl+alZDrzO+TrRWvql4V39l2WGNSRn0ym9sRba6WihezRBpA8DK+C+
	 eO64NwwKTgQ4RX8r0fdkzzRLCjuJ/9sBdNDzoY+fJKHUnPY/TmI+klkZhGLC45js8F
	 rqgdgSSE309Ax5e4EWHq/OEkaXLJMwzUxMIUplGE4qYfikOojnk9M3Ehfblze7Y4Cr
	 tY86R787J2i9O2APK/6RDkTb8RpJi8O1VXji+yioIHUNND2xQo+METcrtXj+fZXxBd
	 AazHoF3xGc+SgKYWF+hzQNeWCqGch1iSnAj8TvmLzPECi9klP4SnhI5KErsRT6+bzr
	 Fzvspp+MZEjcw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/2] lockd: allow setting ports without setting gracetime
Date: Wed, 23 Sep 2026 06:58:55 -0400
Message-Id: <20260923-nfsd-testing-v1-0-a793f54a4dd1@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDSyMj3by04hTdktTiksy8dF0Dg2RDI2NjUwMT8xQloJaCotS0zAqwcdG
 xtbUAHIgMUV4AAAA=
X-Change-ID: 20260922-nfsd-testing-00c12335047d
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1024; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=G5oO/+RhBLTrz3cAjisoExQ9dTpAdQbN9ADtYijVQ20=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqs7D/R827ZDFgbncLCefDfcKGfZUKqwkXNsfhq
 kt9eKhp/3eJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarOw/wAKCRAADmhBGVaC
 FQ+BEACjoYvSorWriDKfUUAGutR0+ux5CVtdBsZAhtMoIHo3JF3s5ObH1SwnRa9gSDOrSRqBrDl
 gBKBHW8ZMrUge0PWkAnxFs110JUcTHFZrWUyx8ckiINDNefFtiF5xbZBF0+JqgyDyshv3rZYcKJ
 gIXO/IxgNT6uBSOv2vvwg0ZiNB031ro+2jgSjce01W8+HLDwpuOszZ/fdWNWs5HEf+JLeZW38vT
 qLGiNdqapO4EpObwdjzaeUufMtAA8jy0BgFI4VETv1zYPo+MvKJbmEAWIlKAS70e/8UC6wjKUmL
 D9bMV+ZK9BoeFSMWAauDY3o4M1lf/aFtF5Sv0FAGboilQ6bO2y6xnJj1XKXDXZVB5UUb7kk4+aW
 n96qfE3vzjyeXLdOKLmf6VnSCvfP6HHHTlb+5z3VkUMoLepZyOqWYESm6AQw1WODlkSA1DxHsK7
 6DifekYUNkpT/8q/bPe/QhRb29Qd08Su0eH3BG0lrukfh48a7agu4ebN/oxi8BBB+ikRDy1gdMk
 fM5w2orloj3zdsYqgTzKAUqAOMWvT6cWKxfWqCGlysnTdnBYColTmkr4Xr5Gt2N8cOVyMcx1Wah
 rUUWJHMW2MccxKQ+8KX73Ht07xdASByYIkBv4knUdHZriPf0ogLv1B1dbbP6a8F/SCJ8inW6ILy
 KUvEbOqUXY1Qhag==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This fixes a rather silly bug that Scott pointed out to me in a meeting
recently. You currently can't set the ports in lockd via the netlink
interface unless you also set the gracetime. This patch makes them all
properly optional.

We probably want this to go to stable.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (2):
      lockd: allow SERVER_SET without a gracetime attribute
      selftests/nfsd: add lockd netlink configuration tests

 fs/lockd/svc.c                                    |  50 ++---
 tools/testing/selftests/nfsd/.gitignore           |   1 +
 tools/testing/selftests/nfsd/Makefile             |   1 +
 tools/testing/selftests/nfsd/nfsd_lockd_netlink.c | 249 ++++++++++++++++++++++
 tools/testing/selftests/nfsd/nfsd_netlink.h       |  90 ++++++--
 5 files changed, 348 insertions(+), 43 deletions(-)
---
base-commit: cab95e6be3ba82bcf4c8be27c2eb20e55238aa41
change-id: 20260922-nfsd-testing-00c12335047d

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

