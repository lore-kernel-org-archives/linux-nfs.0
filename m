Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F0541424D48;
	Wed,  9 Sep 2026 14:12:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788963127; cv=none; b=Am+iiW7PCQ8qfbheSEY3zdqyK/euI+4oykchaj23LHomuZtgL0Vsp3lI1Zu5zsjM7mksmhcbF1Zqkj/pr4tGx/LwOkS+Zl+g8JcYLREvGsdV7clC/SYrMkOdhQSTxT/4NqajWbwPHFVwaBGOWBWi6x1Z0mYNMqMC/Iw99aoxjjE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788963127; c=relaxed/simple;
	bh=pf91o4e5Dn4A7902LfUiY3zXyRT6Ww66qXPAuHyLIBA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=GuvbsaBrZTDTsJjdYmccGRd/qict1WR8OJHiLFiMpoLlFKmGd8HxA5iEJ2K5cKqLJrNtAK3LgWWU/0evHGL/MrbqKWmgtP3RJKhAOHTmLQAR4dghXo7bEAb387cHU/nepTfHh7wP+fLw44i9kHHyPr4IvgATWAJ8mc4NDVM0zrc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=H2OaCIMH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="H2OaCIMH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0A0F61F00A3E;
	Wed,  9 Sep 2026 14:12:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788963125;
	bh=EP8eMN7GZtt9E2RjYW7ghfREkdRA84DrQeFmz1/7vHA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=H2OaCIMHxv4FbemUiAtd0de7toL2/JcQnF3gg0ryUddz5PuSHlUllQg3T13pkCg8n
	 hU2ilYDdEl+eVDzch2OabvvkY11v2pN9KQ9rZE0LbcazYgv3wfQOL2aRMQ2wIJ2Gl8
	 6nRF2KfHna72ZiGk9CgHUmFsJBk6AaSox6e1Yar+N/KKlWF8s5f/t1uwXELnYSlWIz
	 p86hckprDCfV7TBsF4S9dSN/+cj24EWCrQog1pDn9LYSWXX8evNsUmwwi6E2Tzi1qD
	 yeHBdfFvPGZ90hhzqd/2gEtSj0n4VaKQXm+KiGP4HP59+xTW3kefywe6DissZoyEHg
	 Bk53sKypd18Gw==
From: Chuck Lever <cel@kernel.org>
To: Karl Mehltretter <kmehltretter@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] svcrdma: Fix svc_rdma_recv_cid_init() kernel-doc
Date: Wed,  9 Sep 2026 10:12:01 -0400
Message-ID: <178896311384.26504.12567759404043090829.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260909064343.90437-1-kmehltretter@gmail.com>
References: <20260909064343.90437-1-kmehltretter@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Wed, 09 Sep 2026 08:43:43 +0200, Karl Mehltretter wrote:
> svc_rdma_recv_cid_init() initializes a Receive Queue completion ID,
> but its kernel-doc heading names svc_rdma_send_cid_init(). The latter is
> a separate helper immediately below it, so kernel-doc cannot match this
> comment to the receive helper.
> 
> Fix the copied function name.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] svcrdma: Fix svc_rdma_recv_cid_init() kernel-doc
      (no commit info)

--
Chuck Lever

