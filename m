Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E55A64A384C;
	Mon,  5 Oct 2026 14:59:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791212354; cv=none; b=An0gVb8E7IVRDfqVoVi5oS0UwoF7Zbwq6nQJ6NaWLpHmgNELSQlI5m1KAmApUKLgQtHnj449XOU9nTvTzpP3PNvxXvPRg6OYEIiIAnDO6ybnZ7Sq0LzWajbOpZbmGkkIsD60oHU2GDkYwb+/1gyrgoCGij9JPKxfRfKTgE+PeLg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791212354; c=relaxed/simple;
	bh=znDke5HFY/BA6R8clC5onR4T86VhHl83wHxMzWOhhB0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=SN8VCJti6+IZPmLf7qKXcJ33lKz+xDtl8sKF6Hpwbz56DaW7gB4Xt0Qi9Pet0n4+V0FlWcOk9pypzUM3O0PY0NTkAZw+bjQ77+hJi2SIhUrEL2N/xqLMqeEE1sA5uTOgtXeDR4O21l4mXzHsaHD8bDnpM1bU9ESKXr0mghM3rZA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AXF+Prk7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AXF+Prk7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CE67A1F000FF;
	Mon,  5 Oct 2026 14:59:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791212352;
	bh=yChXRVF8zlmSR4yRBEYFeg9ujmUpZOAXCnxjIybRe5s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=AXF+Prk7MWHrAkb7MCYM61wp4qkLuFTZfisjhcJgdTYZGv7YnaOgbwl9nm62sBGD4
	 dGlePVLXsDwHYpxwPl65vKzRMQpfbNbkWLHcN1J92fqmG71XabKDcq+o5Pa75qwhUi
	 k5+Ny5jaOvnym35n+Qahe4SulFz77ZQpcehgHuj/r6tPNemFtzOAOa6zw8Jbut/KD7
	 PWi5Hr7+ejgSo0Z+tNEOAjnoJ3ckio2kTO3L/2q7bdTJEy9+dhyCsZOgjYMtm7ilsp
	 pAP+Caki/D45rJTMRJpjDKdSBg8PvJ6pDuPp81WIoWqRQ0741XynBhn58/fhNakcL3
	 6UDCk8Zct2KSw==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Boyan Liu <yymhvert@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	co+7aebac19e62711ff@bugs.sh,
	stable@vger.kernel.org
Subject: Re: [PATCH] nfsd: Fix out-of-bounds read in clientstr_hashval()
Date: Mon,  5 Oct 2026 10:59:07 -0400
Message-ID: <179121233712.30586.16853326888693672488.b4-ty@b4>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260927142319.12054-1-yymhvert@gmail.com>
References: <20260927142319.12054-1-yymhvert@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


On Sun, 27 Sep 2026 22:23:19 +0800, Boyan Liu wrote:
> clientstr_hashval() always hashes 8 bytes of the client name, but
> since commit 6b1891052a3f ("nfsd: make nfs4_client_reclaim use an
> xdr_netobj instead of a fixed char array") the name is a
> kmemdup()'d xdr_netobj of arbitrary length. A 1-7 byte ownerid is
> legal, so the hash reads past the allocation:
> 
>     BUG: KASAN: slab-out-of-bounds in nfsd4_find_reclaim_client
>     Read of size 1 at addr ffff888010acf1a1 by task nfsd/141
>     Call Trace:
>      kasan_report (mm/kasan/report.c:595)
>      nfsd4_find_reclaim_client (fs/nfsd/nfs4state.c:1622)
>      nfsd4_reclaim_complete (fs/nfsd/nfs4state.c:5286)
>      nfsd4_proc_compound (fs/nfsd/nfs4proc.c:3313)
>      nfsd_dispatch (fs/nfsd/nfssvc.c:1038)
>      svc_process_common (net/sunrpc/svc.c:1527)
>      svc_process (net/sunrpc/svc.c:1682)
>      svc_recv (net/sunrpc/svc_xprt.c:886)
>      nfsd (fs/nfsd/nfssvc.c:919)
> 
> [...]

Applied, thanks!

[1/1] nfsd: Fix out-of-bounds read in clientstr_hashval()
      commit: bd3622da433d2f6cecc10a49f559383e0e13654b

Best regards,
-- 
Chuck Lever <cel@kernel.org>
