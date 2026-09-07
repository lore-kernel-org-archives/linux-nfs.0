Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4AB5E382F35
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 17:33:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788802391; cv=none; b=VMMBvs2xls2KbaWJfaJEf1u89roaNuKySIQIj2UK0Azpe3+Z315NwuYP30VPkYK0b0myOMFDNuCxTPC+fFcGbaGWfVuTScvLbet8HS08WlHowfvhoYRpJp8owiDhp9E2BqYAKcaV339MiGsUL4gWHvOc53nJiLUK4fA0GZQBfZk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788802391; c=relaxed/simple;
	bh=ql4xasVER74XmdnUzxCMUHlw8bfo2Miwjn954Ajssrw=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=I3s6fudxy3/hTSiB40vY6+SX4nTRjrlm/XDZVNBuLqnsv8HokMuU+xmJuImU7BbhlPFNEPi7s58JATdzDHl3k2s1UsDG2PBzwKIqxRxBcRGKw4iSffWW/BX8lhXXCrn6Qyzh7eNHI7qPAvWeQQhWmLWvPzYypN8/ekVtxjH0iCA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=klENLq5R; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="klENLq5R"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EA20E1F00A3A;
	Mon,  7 Sep 2026 17:33:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788802390;
	bh=XQWY1g9lIO9mEGNw5MFNGZrUA7xWdL6ep3r/5QZGyGM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=klENLq5Reo8fK9aBNnA7oeTbSLIgQlR7C6XHnhFgFesdgUKgJ2glg/px/Lj5oP0SJ
	 F3yjctKosPBGz5a1JMnWmsdxUQRT8s8GnZ4WKtZaqo4lZgaFh4Y8HkQMFKNrp5VyqQ
	 awltFryvjYFbbMoL/HFK54BUJ7+ABCpi2vzJN+Wx9Enqn9h9N016lVcQZiYnFAH7dR
	 TDmfkgWVzyICZQ70JTNbCC9QLfyQDnL9IF/7zxmKw/miKm1Vd2N/b3ZHKP0PU3cjGa
	 tq2swJKPpCgCp4MKEIDnlxDjxehE2uKbadTdTd/xawPYVElDzZP1rEq2NXb1KdZs5V
	 hrrtaoqupCT3g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0F684F40066;
	Mon,  7 Sep 2026 13:33:09 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 07 Sep 2026 13:33:09 -0400
X-ME-Sender: <xms:VPWeaoKqeVp5r6qU_gZHyUVM6U1jYe7sLKckKqOI9qGSWpuknVwbwg>
    <xme:VPWeai85ZZycjyZH6OXaabPx8dVNVGK69YJJFP2t16aKMnJnoWfPBSO294qD-t8Gv
    e-cQvAN2Ar3llh8DsR18NL2ZINik0PbPmbx5a0ZIYt-KnZlLEehcOXS>
X-ME-Proxy-Cause: dmFkZTFdwSik+4bzEbIDFlEEm5PlxFEQy6AZxuh3Vk6QHXmr26JSv3WFWuDE6DAAS7ZNvy
    4wcvVz4HZx3nxYQ2R4oFCKcjsWETXXnT9LXn0Bpma+IC5ES+tqUe7RZxvyxvlmjH/0DTgG
    4UP5Ih7GCqRgRaTWOyg6H8LBqZLq0AnL9q9SxQmjOWro0rR14inedj4WnQtm3b5NPpdrNH
    iB55Ocf+Uweno2aSR/jsyrFLhxvdm6vuZi2Jc2OcJ5cF9fwOQbEXzm/ggTRPrM2z58uMpj
    JGlFDkGV22v1ANK+2yjJuZ4ZgNnDu+goD9VnKS6hSR0gaosYepiqzK5dVkzKS+awxLrADx
    6pOIUMp93vY95Rq+iRLL3q6xMuxID7mtEgIkUMaKZIWBvIb/F2vyQlQE42SDg99bZ9mp6C
    R9/HcHcUIJJspLKCjMlLNcKa7KHxjxzYg4qnUOgjFlqSJG4LSLn/nKAFvWyQsjhVvZoHp1
    z4intXUIgIf/wnWbZQcwmrm92XqBm4HkIMIC9Str45Rj7X4FvvHICWaMo2AnbEB72KpVuE
    OchyUESbnq8A5S4hJXl+lwhy+lgsq1B/P0JT9sZVHXAEV0eGMG2eqjdYqfFM4/CPQZX3fk
    6k4gX9vDeTZqhOu382OYZYgAs1PJ6s/gXRWSvcTBjsHZNRHfGg/096nUu57g
X-ME-Proxy: <xmx:VfWean3mYBfgTHLzLSOBYBIAIsDCax7YDRSY2g7QBIdd_alZ6-Xv3Q>
    <xmx:VfWeavbgf8iZzq1TCkSjHp9bl8R8Yn5MBo2dQsK7ct239fPSxb1cwA>
    <xmx:VfWeavKbzV90PXWWdMfHWGMZmKZud72zKelYXv5owThrHTcWcXi_4Q>
    <xmx:VfWeauHw7rIxWv6x1i4QHc3DDzG_NpTWdSJc8DQihtgneeH_8eKaNw>
    <xmx:VfWeamssmxdJlO1HDLXY7Yzlk5KUiXbbOU7j375c2gTQQ2AK42w3482d>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E59317811F0; Mon,  7 Sep 2026 13:33:08 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AxchwvwWr9Mk
Date: Mon, 07 Sep 2026 13:32:45 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Message-Id: <c0c96e2f-ba29-4b46-915b-23399810d384@app.fastmail.com>
In-Reply-To: <178876623368.207413.16768374723232216468@noble.neil.brown.name>
References: <178876623368.207413.16768374723232216468@noble.neil.brown.name>
Subject: Re: [PATCH] NFSD: return NFS4ERR_EXIST for a guarded OPEN of a non-regular
 object
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Sep 7, 2026, at 3:30 AM, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
>
> Commit db8b567ffa98 ("nfsd: (almost) always open file in
> nfsd4_create_file()") moved the regular-file type check ahead of the
> createmode logic.  A GUARDED4, EXCLUSIVE4, or EXCLUSIVE4_1 OPEN that
> finds a directory or symbolic link under the requested name now fails
> with NFS4ERR_ISDIR or NFS4ERR_SYMLINK instead of NFS4ERR_EXIST.
>
> RFC 8881 Section 18.16.3 requires NFS4ERR_EXIST when a guarded create
> finds any object under that name, or when an exclusive create's
> verifier does not match. The type-specific errors in Section 18.16.4
> apply to opening an existing file, which only UNCHECKED4 does.
>
> do_lookup_open() is passed O_EXCL precisely when UNCHECKED4 is
> requested, so it can choose whether to return NFS4ERR_EXIST or
> one of the other errors.
>
> Fixes: db8b567ffa98 ("nfsd: (almost) always open file in nfsd4_create_file()")
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/nfsd/nfs4proc.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> Hi Chuck,
>  I took the liberty of reusing your commit message - thanks!
>
> NeilBrown
>
>
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 33dc92d48ce0..067e24514dad 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -240,7 +240,9 @@ static struct file *do_lookup_open(struct path *parent,
>  		 */
>  		int err = nfsd_check_obj_isreg(child);
> 
> -		if (err)
> +		if (oflags & O_EXCL)
> +			filp = ERR_PTR(-EEXIST);
> +		else if (err)
>  			filp = ERR_PTR(err);
>  		else
>  			filp = dentry_open(&path, oflags, current_cred());
>
> -- 
> 2.50.0.107.gf914562f5916.dirty

Hi Neil -

O_EXCL is set for GUARDED4 only, so this logic leaves EXCLUSIVE4 and
EXCLUSIVE4_1 still returning the incorrect type-specific errors.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
