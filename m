Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F23E3274B37
	for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2026 23:57:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771545450; cv=none; b=ddCyCTurGsyuWHff1puXNk1ZVYD7Qe5j6sk2VnrDKH1bVGtfFqPk72CAmKvaERinlO2342Tx+WQPRy7JodVwU5ElLYp82pbr4y90JbXsmPIrbD4MLy7SF/UNcFYSTrmotlwD3GG78KG+4kmdGM1vWBZFiNG4lyHhmPZ/lvxhuDE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771545450; c=relaxed/simple;
	bh=TLwkLwyTVxIMt4gAW+uGQOI19DPnhVbMngx1XsO+PpU=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=eYCr7YCK4FTCfzfrjeITpLIfTVbO4Q58dKjDl0Caq3swx5S1pMJfFaKNrBhsbfUMyBraUekWr4q8WKZQLzwFZ0/WPGr03Y6quN/HwM5KxIoLl1ptvbSTv+fHsaBNPkwj6F/9HLOLU99savgvBswBTSXWvj7nXB78AAiIjGBbFV4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=b0Y/P/oh; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="b0Y/P/oh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2A54AC4CEF7;
	Thu, 19 Feb 2026 23:57:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771545449;
	bh=TLwkLwyTVxIMt4gAW+uGQOI19DPnhVbMngx1XsO+PpU=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=b0Y/P/ohIxMq52wb3Osq2CrPq1cLvf5JkBT1ON6n+ZjQlnWs8kEagjz+2gFdbMOJd
	 LV4VcbpB5tIPdvtmmtZnbb1pFv4bvQxBjD4umrGYvRfPEmILYRgbJsB1oUDG7AFQhg
	 +0yf/IeN6IDZvI79a572cwvG9aCg91VqsxsmP3qDCXfAy+ZOAMuYWJXyU/UDVHlf6h
	 IqJ2CQIF4ddpfQKI+6cQbZuCA2jFdxH3i9Sc4PZz2UAHrtdUUy46HXyqDouYtM5Rib
	 rDpWJBcRXCU0x08irGoTfXFNggQXnsP6MpOT8Pn3QrRxaAl/fbSVM01I9JdIyXynud
	 NwbDyTiYhlNNg==
Message-ID: <4d1a2b195f0d2ece9d0db5524e69462d71d3b626.camel@kernel.org>
Subject: Re: [RFC PATCH 00/11] NFS/NFSD: nfs4_acl passthru for NFSv4 reexport
From: Trond Myklebust <trondmy@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>, Mike Snitzer <snitzer@kernel.org>,
  Jeff Layton <jlayton@kernel.org>, Anna Schumaker
 <anna.schumaker@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 19 Feb 2026 18:57:28 -0500
In-Reply-To: <098b9502-8868-47c9-b164-be80bb11ae74@oracle.com>
References: <20260219221352.40554-1-snitzer@kernel.org>
	 <098b9502-8868-47c9-b164-be80bb11ae74@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.3 (3.58.3-1.fc43) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Thu, 2026-02-19 at 17:21 -0500, Chuck Lever wrote:
>=20
> 2. Do you have a plan for similar passthru support for the NFSv4.2
> POSIX
> draft ACL extension?
>=20

Why would we need that?

The current need for a passthrough mechanism is being driven by the
fact that knfsd unconditionally imposes it's own lossy mapping onto the
NFSv4 ACLs.

I'm assuming that for POSIX ACLs, knfsd will just pass them through
unmolested to the VFS layer. Subsequently, they will get passed to the
NFS client via the POSIX ACL interface, which pass them on to any
server that does support that kind of ACL, and fail if not.

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
