Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABC7B46D543;
	Fri, 28 Aug 2026 13:50:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787925039; cv=none; b=qLkN3u190Zm09gz2D4hDhhbZjkrkopgVgBp5iYGAmSJSkUIKzVzEh1mpcqGx+xC1snYZb19+V5azj8DhzbSVjDwc5WR4QN9DfndTzOx0brEZocfEdEJQiM/9JaU8vUxFv0lO2tIYSQsupaUA7A7YC8NoaSGuuPYE1l23Vb25HbI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787925039; c=relaxed/simple;
	bh=zSITZ+sDBVwfMVJL6DfXexhqM2yjjr4I99sW59+6T4M=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=MePTtcjdl0rL0Pl00WgbrOUlyrz+d0LsWVVTdpXv4j1Y0y5VMYewiBG1acbOPXGvdijsHkP4iVnxwMajX2qsEuEGepfpNouFnte4RLhk05c7U01tAY5Y1I0r2+MSjY3rElkN/P/PNzdyVWVpMb/Te+0RhuJWSgZ4xlpTThptCrA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ijtSTARa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ijtSTARa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4FD901F00A3D;
	Fri, 28 Aug 2026 13:50:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787925038;
	bh=I1itcvWvI5v6xHrt95PdL6sm4ktfl/GDz+05F7LSid0=;
	h=From:To:Cc:Subject:Date;
	b=ijtSTARaK8nfN92wf3LtBCcU4dRnV7ysaArZO9kkLH/tbgDdEnMSWfI9kvZyhLzIG
	 gYZhOCIFTXYo4bodJTkTl76JQspTbMT32IC6Lx6Tf5IBiln8Y5MhYM4cLctuup8ZLn
	 B7eNmi14m0XlGe0gvV2Gtdk2TdtDw+qXqVskDokrl4S6NtPEb35OUINzbNR+CjFOxL
	 SZbCYMRKMgQGoSo/8KJc8bTGV9JqMEpLt2Wa0sUJDi+CoRKca8MyHccYvut+4i/NF0
	 3k1oXibct/0lghsStUp9Ao6KC/1s4jW98Aq5jzSO+k0saGPoY+Aa3h7BLX2syxAfjc
	 ZbGWNHUPGPPZw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>
Subject: [PATCH 0/3] Minor fixes for svcrdma
Date: Fri, 28 Aug 2026 09:50:33 -0400
Message-ID: <20260828135036.796842-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Rediscovered these while cleaning out old development branches.
All minor fixes.

Chuck Lever (3):
  svcrdma: Grant credits from the clamped sc_max_requests
  svcrdma: Clear XPT_DATA when the last receive context is consumed
  SUNRPC: Skip xpt_reserved accounting for non-UDP transports

 include/linux/sunrpc/svc_xprt.h          |  5 +++-
 net/sunrpc/svc_xprt.c                    | 30 +++++++++++++++---------
 net/sunrpc/svcsock.c                     |  1 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  | 18 ++++++++++----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  3 ++-
 5 files changed, 40 insertions(+), 17 deletions(-)

-- 
2.54.0

