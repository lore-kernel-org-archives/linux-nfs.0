Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78B8E2F28FF;
	Sat, 29 Aug 2026 05:54:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787982855; cv=none; b=fM9JdeRfZV9a2UxcKTN4ct377hi2iMpAV8AwoS7rGv7j8OiyNpj69PCkaixmMg6tW18AUvAMXD5rvbEv0Dc//PuCsF4Ck/mCFoRbawSX9J7d+y06fdh339gOjo5oRVSQeecTj7JTPIbxSbnyWpTNj5vwoDoi3IjDhOg+EFBEeZs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787982855; c=relaxed/simple;
	bh=6e5twiWPXIosp8OruVrNP6l+Q7LjcOHYdnLno5IGxLE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=o8BlF6JKwrZTrvK5DXZjakjrFXDIphcGulOa8I6dSzeZS7WSbik5gJ+XgoW8qbNc91psVAe8Kyx/T3v1Tk2pAPS6WY8r2KCEFiA1PTtiymjYuym7rAWI1LcQ/gmS+KosikVR4XarrSAxgGBcgrWbg4N4LX0UjHq1dEmwmWc6hS0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b=IVPkMZuT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="IVPkMZuT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F2E71F000E9;
	Sat, 29 Aug 2026 05:54:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linuxfoundation.org;
	s=korg; t=1787982853;
	bh=YFW0XH/PSwQsLKnfNogApnQ0v2KuOhdfFX8Lu9Q6tl8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=IVPkMZuTzs2NFp1xt75PsOBImKyCTij0PhJgof2LrSSbCVrEn0OFNWfQ3JLYVkx6n
	 lwVmFTnc0w4ZRoDJ7SdDDUM8bXY/nTaukoBNFWVgiKhnt3WvgaXOFg34/8SIfGhyZ6
	 sCz4oR/VSU0bXBJYGlefULFTcWBe6JHYPawNz58M=
Date: Sat, 29 Aug 2026 07:52:31 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Chuck Lever <cel@kernel.org>
Cc: "Cen Zhang (Microsoft Security FORGE Labs)" <blbllhy@gmail.com>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	AutonomousCodeSecurity@microsoft.com, xmei5@asu.edu,
	tgopinath@linux.microsoft.com, kys@microsoft.com
Subject: Re: [PATCH] nfsd: hold cl_lock in client_has_state()
Message-ID: <2026082948-sleeve-blaming-b901@gregkh>
References: <20260828041925.36758-1-blbllhy@gmail.com>
 <2026082828-palpable-dingo-241b@gregkh>
 <978293e7-430d-4b11-9a29-1fb479cb0082@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <978293e7-430d-4b11-9a29-1fb479cb0082@app.fastmail.com>

On Fri, Aug 28, 2026 at 09:45:33AM -0400, Chuck Lever wrote:
> 
> 
> On Fri, Aug 28, 2026, at 1:29 AM, Greg KH wrote:
> > On Fri, Aug 28, 2026 at 12:19:25AM -0400, Cen Zhang (Microsoft Security 
> > FORGE Labs) wrote:
> >> client_has_openowners() walks clp->cl_openowners and reads so_stateids
> >> without clp->cl_lock. nfs4_put_stateowner() unhashes that openowner under
> >> cl_lock and then frees it, so a concurrent EXCHANGE_ID with mismatched
> >> creds can use-after-free the nfs4_openowner.
> >> 
> >> BUG: KASAN: slab-use-after-free in client_has_state+0x10a/0x140
> >>   fs/nfsd/nfs4state.c:3718 client_has_openowners()
> >>   nfsd4_exchange_id
> >>   nfsd4_proc_compound
> >>   nfsd_dispatch
> >>   svc_process
> >> 
> >> Take clp->cl_lock while client_has_state() walks the openowner list.
> >> 
> >> Fixes: 4eaea1342507 ("nfsd: improve client_has_state to check for unused openowners")
> >> Reported-by: Xiang Mei (Microsoft) <xmei5@asu.edu>
> >> Cc: AutonomousCodeSecurity@microsoft.com
> >> Cc: stable@vger.kernel.org
> >> Signed-off-by: Cen Zhang (Microsoft Security FORGE Labs) <blbllhy@gmail.com>
> >
> > Please use your microsoft.com email address, and not a random gmail.com
> > address.  It's kind of odd that Microsoft would have to rely on Google
> > to send kernel patches :)
> 
> Greg, would you prefer that I hold off on applying this to nfsd-testing
> until Cen can post this one again?

That's your call.
