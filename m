Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40DF237FF79;
	Wed,  4 Mar 2026 10:28:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.195.75.108
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772620134; cv=none; b=sOSnTR26aJxDKyo3Llf34JulPrHopuJtSEhAsl396TXltugdZ4PKr2JcYqgkv05pIGeva/spuHxd1RM8MeVzw86t7T67wwgcymG4scvlb4Xk0nlRxiWwCPwsdSdS0IqAMOUp1ZCmRX6/iqtHUNLevuUGAuazkCH5NT7X7bMfwUk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772620134; c=relaxed/simple;
	bh=d4bNtrNjDih07VzPz9I8qEt+Qp9zR9VO2epfFefT+lo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=IAApl2IjA27xo8uY8qHnyWBwFEBLOUbZGLOYxBKyenJDM977COpeROkq/dRMgPfINLGKno/G9GZfLjjUvB/zcvFh9iPDIgjjCDZyPwX4y1riOQui72Dn3Uz8Z3/pDpGQRFrvB2hzYbsjuk9iXapmW8lGXgwaFfYjBwY3/uMJHRg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org; spf=none smtp.mailfrom=debian.org; dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b=g9dMXaMz; arc=none smtp.client-ip=82.195.75.108
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.b="g9dMXaMz"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:In-Reply-To:Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Reply-To:Content-ID:Content-Description;
	bh=SNgwkX+bdpfdCJLmm7Ie55CAyRvvJujoCIUdEwsAyDY=; b=g9dMXaMznW8gQ4qICcT2K2H09Q
	mqFyFr6LItWW8Qv15k/hBtWnIFd4u9xF63T41ugmehACeavXx+206h3+/x2bwVdISX9QqhAy7iqGr
	uBIXfHMgdxFsFr66VaQCGUyNvgjyeGHtIdzdaej/i1d1S+tBB4WqBX/rm/54ObD2al991GitPYu8m
	Nii0XOmjbD6x4iBAoXM4BX8BOZYoljQtJnRDob711E2f7kdF071pd4LCS2wu9x975YGLa1NuAVZyC
	hXGsmuHK4sxUnCM79ke35Qn0elUz36LFO+01t6guG17LFEWGqannhE6PR7q3xHOfwM5fZPgJZuQm3
	rPi8vE1A==;
Received: from authenticated user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.94.2)
	(envelope-from <carnil@debian.org>)
	id 1vxjT1-00FtEt-Gm; Wed, 04 Mar 2026 10:28:35 +0000
Received: by eldamar.lan (Postfix, from userid 1000)
	id 3E297BE2DE0; Wed, 04 Mar 2026 11:28:34 +0100 (CET)
Date: Wed, 4 Mar 2026 11:28:34 +0100
From: Salvatore Bonaccorso <carnil@debian.org>
To: Thorsten Leemhuis <regressions@leemhuis.info>, 1128861@bugs.debian.org
Cc: Tj <tj.iam.tj@proton.me>, Neil Brown <neilb@suse.de>,
	linux-nfs@vger.kernel.org, Olga Kornievskaia <okorniev@redhat.com>,
	stable@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Subject: Re: Bug#1128861: Regression: Missing check in nfsd_permission()
 causes -ENOLCK No locks available
Message-ID: <aagJUlFIJkjgbEHQ@eldamar.lan>
References: <c0f15088-3fc0-487a-9f24-cf89c158420d@proton.me>
 <177187492815.425331.14320091315652332093.reportbug@nimble>
 <418f30b5-06ae-471f-bf5f-f14f3f75deff@leemhuis.info>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <418f30b5-06ae-471f-bf5f-f14f3f75deff@leemhuis.info>
X-Debian-User: carnil

Control: found -1 6.19.5-1~exp1
Hi,

On Fri, Feb 27, 2026 at 10:54:13AM +0100, Thorsten Leemhuis wrote:
> [CCing a few people and lists]
> 
> On 2/24/26 03:09, Tj wrote:
> > Upstream commit 4cc9b9f2bf4dfe13fe573 "nfsd: refine and rename 
> > NFSD_MAY_LOCK" and
> >   stable v6.12.54 commit 18744bc56b0ec
> 
> In case anyone just like me is wondering: the latter is a backport of
> the former.
> 
> >  (re)moves checks from  fs/nfsd/vfs.c::nfsd_permission().>   This causes NFS clients to see
> > 
> > $ flock -e -w 4 /srv/NAS/test/debian-13.3.0-amd64-netinst.iso sleep 1
> > flock: /srv/NAS/test/debian-13.3.0-amd64-netinst.iso: No locks available
> 
> Does this happen on mainline (e.g. 7.0-rc1) as well?

Not tested 7.0-rc2, but the issue is reproducible still in 6.19.5.

Regards,
Salvatore
