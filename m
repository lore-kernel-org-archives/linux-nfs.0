Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8AE063C061F;
	Fri, 28 Aug 2026 05:29:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787894955; cv=none; b=AQvoBgjrfWdWuDUUBFpUdB6AkDlst+Zz3tpoBsaKJ9ZYThFlOZcYa0qtu0mSiFvkgEzazeqfekCVZM4pUZny+9J9SKlIl93zW/H6z0HH3oHQ+Sohug8doTMJ8xzgG9kL8frzkSzn1lFLowr5wYLQq9yBNCeciqu+GOuXFMP98Wo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787894955; c=relaxed/simple;
	bh=0k6PkJInVVXv/85VY0NCTXtHaDeumCTk900gNoK0JQc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=V9j2F7MWdyFNU2Nv5pqd8fF+rPFBjJ3wbCzW9Q3fgb8D0M54pCCLG1ejC+vtUTYHIeXJ8SKB+QxwaVl11cGmP+GQFV0pk3yu5I9f2bCfAgSt2MTc3bjAdQ/Mwc37VReIru+P6zRtgWQhCdUX04/QaA7o8hxzg7Y0+FCHbOOHL7g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b=ykyRmVNb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="ykyRmVNb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 869571F000E9;
	Fri, 28 Aug 2026 05:29:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linuxfoundation.org;
	s=korg; t=1787894954;
	bh=Gw8XvP9Oug30eH2z0I3AColYTqEB16CCQilFRfP4eSk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ykyRmVNbU/Yqy6i44TjeayDpIjf1JXQ0zqsWfLkuWpU7sUuFtVn/oyvvvDJDU4gCI
	 WKSByXQ/EXG+Il+Dh/SVwEsCWjZzaLJYspjKGSs+mgK8kkejGTQc1dAjmBE27aU2K3
	 pdvn9clPLJsDZy9PBK7Jn4UbZNz8UpbNqiz4u6sU=
Date: Fri, 28 Aug 2026 07:29:11 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: "Cen Zhang (Microsoft Security FORGE Labs)" <blbllhy@gmail.com>
Cc: cel@kernel.org, jlayton@kernel.org, neil@brown.name,
	okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
	bfields@fieldses.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	AutonomousCodeSecurity@microsoft.com, xmei5@asu.edu,
	tgopinath@linux.microsoft.com, kys@microsoft.com
Subject: Re: [PATCH] nfsd: hold cl_lock in client_has_state()
Message-ID: <2026082828-palpable-dingo-241b@gregkh>
References: <20260828041925.36758-1-blbllhy@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260828041925.36758-1-blbllhy@gmail.com>

On Fri, Aug 28, 2026 at 12:19:25AM -0400, Cen Zhang (Microsoft Security FORGE Labs) wrote:
> client_has_openowners() walks clp->cl_openowners and reads so_stateids
> without clp->cl_lock. nfs4_put_stateowner() unhashes that openowner under
> cl_lock and then frees it, so a concurrent EXCHANGE_ID with mismatched
> creds can use-after-free the nfs4_openowner.
> 
> BUG: KASAN: slab-use-after-free in client_has_state+0x10a/0x140
>   fs/nfsd/nfs4state.c:3718 client_has_openowners()
>   nfsd4_exchange_id
>   nfsd4_proc_compound
>   nfsd_dispatch
>   svc_process
> 
> Take clp->cl_lock while client_has_state() walks the openowner list.
> 
> Fixes: 4eaea1342507 ("nfsd: improve client_has_state to check for unused openowners")
> Reported-by: Xiang Mei (Microsoft) <xmei5@asu.edu>
> Cc: AutonomousCodeSecurity@microsoft.com
> Cc: stable@vger.kernel.org
> Signed-off-by: Cen Zhang (Microsoft Security FORGE Labs) <blbllhy@gmail.com>

Please use your microsoft.com email address, and not a random gmail.com
address.  It's kind of odd that Microsoft would have to rely on Google
to send kernel patches :)

thanks,

greg k-h
