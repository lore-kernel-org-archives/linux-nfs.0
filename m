Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8A60322DAF;
	Thu, 21 May 2026 15:41:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779378092; cv=none; b=tc0fKDGk/NMie6p65miudDM9n+G4tbAmkbg3+uB2BWn4RUF4r0klyXdrsq9uFJG9TYNyMMdRMFfb6IrtPXwFsNGicCInA7PzQdfJncXIsFMrtLGeDD5x3ziOfl0zyenGutLoVPlTp6MEvfngehFJI5SpoMM6caIDDD4sMqG8Xlw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779378092; c=relaxed/simple;
	bh=IJisraa7qvWRueWTdzA2itQcAkFZbWgmUpPhIiTEOWc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Efnt3QERIE7C6kaadUc9CSyzFACVmXHHWNqZ9lTYt4YSvsxOedmsJoLY7H8IF+auhovKOeVuWTzE+OjKB1lesTZDwFGJP2Nvdy2IUVAzlvEPx3ullARC/9EUWbvqmsWLxCGwKL/vKxalCRjsosBDgBirOkySO+j54bY5RY6Mp6k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mIiLCCOY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mIiLCCOY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B3F901F000E9;
	Thu, 21 May 2026 15:41:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779378091;
	bh=tGf//NNpZo5d9V+clStXjH6F0OQpZul8aHOJVk+yu2k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mIiLCCOYbv6Gnum27P8Slhxec6LRBCQuLTZsUIbpJ8ONAkrJawBD8dq1OWgzHl6Ma
	 wFK5h+TLAh67ervkZXR/cR1y9lVFjPh2QGrs594wE1yXlk6508oaw9jWA4QV7YRV0m
	 uQvO0yqepTgoEGOS7WlA2BRCPy6DbboXUU39ZQ8fuq3L4yfmQsurIUpsquliMpKGXL
	 9dAZFI72eDCSPZP0Owh0U2H9/b0OjPnUEXV3kCGPhoxsuXLoXM2SmbzEnGoHpOJHL9
	 m/BInDbdX1Nbqsii9skHezdHuYxa7mR3nqaE2QyUp7FRaUTcax17KvNcLUr7NXMwod
	 dnv7JxMnvUaCQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Rick Macklem <rmacklem@uoguelph.ca>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Chris Mason <clm@meta.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix dead ACL conflict guard in nfsd4_create
Date: Thu, 21 May 2026 11:41:27 -0400
Message-ID: <177937807664.146125.12699537327417112468.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260521-nfsd4_create_acl_posix_acl_overwrite_leak-v1-1-850fc0a7157e@kernel.org>
References: <20260521-nfsd4_create_acl_posix_acl_overwrite_leak-v1-1-850fc0a7157e@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Thu, 21 May 2026 07:50:21 -0400, Jeff Layton wrote:
> nfsd4_create() steals create->cr_dpacl/cr_pacl into the local
> nfsd_attrs via the designated initializer, then immediately sets the
> source pointers to NULL. The subsequent conflict guard tests the
> already-nilled source fields, making it permanently dead code:
> 
>     if (create->cr_acl) {
>         if (create->cr_dpacl || create->cr_pacl)  /* always false */
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: fix dead ACL conflict guard in nfsd4_create
      commit: e18fa5137111b7d2ab7002d041c05ee7c52694ef

--
Chuck Lever <chuck.lever@oracle.com>
