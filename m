Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5F48361DB0;
	Tue, 14 Apr 2026 21:13:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776201192; cv=none; b=XSnaQnCapZkCIE/HMPP5tyLsogCLGSu3NDC4YUR0RG6U79hf5zmeBNQauMuOAgD7fyVgp5uTiKmfrAO6lSFPefIjc0KwjODcrCmJvbOkzWa+4WJDRPAzj5vLAuqWN6DQFy0MfRLMxBKkxIKlrsJAaP3IgxW93wgIf+8GLiJupqo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776201192; c=relaxed/simple;
	bh=/Eu1JwmYu8hOqYW5w2VqiGpYiOWUGK53RuJBNR+i+Ok=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=F1zHJHytOG3yrMFTsQcUO28y7LoAuHdISZWywB/nu4Q4yDUdAg7otQbNm+vmvfk4CYhRRsFWUrD5bXaraYnlRePYNOaeYreRMXj2dqtJBDlavMhTDJQgo34IG8D5Rs/iHhcb8RaqOUVqpaNTmwSHdGyWmJQSbfkUMnSBDVcVtYs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UUYxnxKW; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UUYxnxKW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 237AFC19425;
	Tue, 14 Apr 2026 21:13:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776201192;
	bh=/Eu1JwmYu8hOqYW5w2VqiGpYiOWUGK53RuJBNR+i+Ok=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=UUYxnxKWM2+ZXHfwhpMp3Rp2Eu/7d4U/+ia6MCMEiJ36lVvttkEdhAwFGozDiYjvs
	 KFYGpxmv3MctUc5XWAhzldNJ425xl5yrB6cxKCUiKqCYzcFO/bpVZcYjyYI6H2f9qt
	 gYrdcmwatDVgU3VchR6KhuVs2BS5RS/1sU2RXiOvaK/WUc8B7p7xw7KZ/RZz1PJwg5
	 8B0dPTmr97k1tF/xnwefTiKSkopk/ciDWz4AW5lOY6frzxR3PIZzp0yQunufLCg4UD
	 pogoWRdwNyl3SjMDLpH9WV/QZ9/f5ixoRFGyM4Zt7DeCxZsG80ipo/SSIbYJZa8+9L
	 VJxgtmSkyGYVw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] nfsd: fix handling of NFSEXP_PNFS in the netlink codepath
Date: Tue, 14 Apr 2026 17:13:09 -0400
Message-ID: <177620113346.1860.6728402715692161684.b4-ty@oracle.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260414-pnfs-exp-fix-v1-1-9face14c16c2@kernel.org>
References: <20260414-pnfs-exp-fix-v1-1-9face14c16c2@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Tue, 14 Apr 2026 07:18:05 -0700, Jeff Layton wrote:
> The rework of how block layouts were checked moved the check for
> NFSEXP_PNFS out of nfsd4_setup_layout_type() and into the callers. That
> patch didn't account for the new call in nfsd4_setup_layout_type().
> 
> 

Applied to nfsd-testing, thanks!

For the moment Christoph's series is still in my tree.

[1/1] nfsd: fix handling of NFSEXP_PNFS in the netlink codepath
      commit: b8cefe5d302f351c252a833dd8c7e8f4a0cd5028

--
Chuck Lever <chuck.lever@oracle.com>
