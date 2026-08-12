Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 11E4334E74B
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 20:19:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786565982; cv=none; b=dw7EyB1p0Xea8poX+DEcqR+HlnFpafx+R4vaLM0hgBN/dwjmnXPsq2fCZD5JsGITFhD2X31bp7HE70KyK6iwUAdDt4s5iGaQceYfJRntQcgfhcmKPFFBzkQvYTEMgejxnusksDku4Gi3ieP822W/WHLBK6nGVKyAculWqRY3twg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786565982; c=relaxed/simple;
	bh=E7b/G6RNZM03UEqbzZTwHfHY5wF7ThjeX0iZXMqLIRk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=HPFtmZ2mBuA5NW4z5eKFqRH72PN1XhbpCj/UEqxpLCdTjqEdOpNtSW7YwCwsHoPa7TKbrEyqRN5Tbk2f3mrGHYsWqyHvFkY7WhzfPi4tsglx9AsazurarNPkWSdNAwjx6gPoom7wFuyAZvE53iWQuqDR63sYdI2BzFKlYq/dMlA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=muK7ZUZu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="muK7ZUZu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7D92D1F00A3A;
	Wed, 12 Aug 2026 20:19:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786565980;
	bh=WzLZYtdL/O2szqwY9PXLqC7x/2wmFj73CwCO6ULszSw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=muK7ZUZu7DpwEYYVfP1a2EILVySzua8To+0nMIM94mxWTE5RNdftGTDap6Q1sSCcU
	 dVQqDawbpxYahMMtNrBT/SSEUruhGQBIbJOQOmHhTK/Fwu4ufmw/bwPZeCdVvZccpH
	 mFSqngDjFVELp0irM4FPX3X/j1NRyrqZLtT3Oz9PP4nkzdvY4f9Ps5JogsBByUsKT9
	 oVVwuZfnkqSsbK43BFD8KP2E8ddFQGDGwJKETzDTdowMS5q35ecSb4cmAhCoyXZdp1
	 qxm/BNYwurYMNymz8rDujIfGjrjRTUR80E3dAMXVr91rPXoKKyPd5o0BuL+La8OvBg
	 Bcb8g13BFqwAA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id B56D2F40067;
	Wed, 12 Aug 2026 16:19:39 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 12 Aug 2026 16:19:39 -0400
X-ME-Sender: <xms:W9V8as_zmlEDAAXWW79jDbrQjzlFTHNSQj04rxHFAAuMGxs46uVQ4w>
    <xme:W9V8avicaBZwmdL0oU2KFYOYXUGt8HMnB1ryMWxwyvaffp2s0p5LaZdxPt3rZrY-T
    R6AQKDDeXrLH_VyiyFlxh3LWb0nTbki13NYOh9UN-E3r2hqWP9LpNZb>
X-ME-Proxy-Cause: dmFkZTEzdax6BSqdb0oTnqv78VH1HD64QKhrtGsKyHAMS3oI+j6xQaW+Acl+a6Mdi7NyWp
    HAVX6C6o0DhmEvX5+Ynl3VN/8eqEM6tYVE2+gl8/NlE9PCVcpT4MTxdcczX7Ilf64ia8fj
    x0ix91vUGVy0VEh5enDkXg3CRpHou5UA+Iz7FnCxUX9JYAIPu7miaZjlIJLdK4LLMTmQyi
    MNWQ5scF8wUN0OBk1aTCm2RjuwOOLEVlDUOfAbE61UNGpSjHp0uTIPW0/3XXduIN8tPwu/
    uiaSrJlQZyC3QZ3Vj+F4aAX3w6gNsgG1ufTCLwkHhs5Ci7pYebxAF5gAJY6MnO538WTuVs
    xhBQuT7tK+fKRfViF6f/8+wAaS70qnTP1Ae1gqRST/BegBED4NKr3FKPbslsNmkAsWbF3E
    DBD3q6qqoPK/uQ8hTIdgL8tGm1OILAOvrgaCH0kI2IjTHQMPALkPfPRVogAgNx92I/MTFZ
    xgtFQaN3VvkL9R3yOECQwCVjxMYrlPLKau0nChZnP4/821WKXE89xz3A9tyuCkJY6hDgLh
    LzYMwfRj2IiBl6XTRMcWGCwoJ68hWxTuI77nYSOl9BoTtn5gprYBSVOpg7Zen5WZYxDLsv
    46b3H3kHCWnIOMJ+JKZouN7I4iASq0pO6+CHwNjnnDqwVZXvDE1QC6WeOSvA
X-ME-Proxy: <xmx:W9V8as4dLSvmXkQOhHfYzY9mS8pY19zHzLP1mplFWZ40Xp9DdLNSiQ>
    <xmx:W9V8akRDT1uZsctcXtU49s7JIRewQoSRPIiPzeX74vhfQbUySLVAFg>
    <xmx:W9V8anvdzo5uZZ3xIh2znOOd8BJPGshYnXGUmV7qqNkhnG3B2OylCg>
    <xmx:W9V8au9u4uWdTGkykpvLrN-YlikqHrgO_arsRMqUupKaYnYcMj_D9w>
    <xmx:W9V8aowAUnDruzdv-KMASGYBdyYpibOSLj_EOV9KMRcZkpMf7wwZhwyq>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8E432780CC1; Wed, 12 Aug 2026 16:19:39 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ANRTDGv-SKPo
Date: Wed, 12 Aug 2026 16:19:22 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "David Laight" <david.laight.linux@gmail.com>,
 "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Greg Banks" <gnb@melbourne.sgi.com>
Cc: "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Andrew Morton" <akpm@osdl.org>,
 "Linus Torvalds" <torvalds@osdl.org>
Message-Id: <35a12022-518b-4c66-b3d5-c850376bfca7@app.fastmail.com>
In-Reply-To: <20260812193349.13347-1-david.laight.linux@gmail.com>
References: <20260812193349.13347-1-david.laight.linux@gmail.com>
Subject: Re: [PATCH net-next] fs: nfsd: Fix buffer overflow in write_pool_threads()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Aug 12, 2026, at 3:33 PM, David Laight wrote:
> write_pool_threads() writes the number of threads in each pool into a
> caller-supplied 'almost PAGE_SIZE' buffer.
> If there are enough pools to overflow the buffer the code continues
> writing beynd its end.
>
> Fix the overflow check so that it actually works.
>
> Fixes: eed2965af1bae "knfsd: allow admin to set nthreads per node"
> Signed-off-by: David Laight <david.laight.linux@gmail.com>
> ---
>
> I'm pretty sure this is 'root only' code.
> So you'd have to try very hard to actually get the overflow.
>
>  fs/nfsd/nfsctl.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 39e7012a60d8..b74048aa2402 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -483,8 +483,7 @@ static ssize_t write_pool_threads(struct file 
> *file, char *buf, size_t size)
>  		 * file, sorry.  Report zero threads.
>  		 */
>  		mutex_unlock(&nfsd_mutex);
> -		strcpy(buf, "0\n");
> -		return strlen(buf);
> +		return strscpy(buf, "0\n", SIMPLE_TRANSACTION_LIMIT);
>  	}
> 
>  	nthreads = kzalloc_objs(int, npools);
> @@ -523,13 +522,14 @@ static ssize_t write_pool_threads(struct file 
> *file, char *buf, size_t size)
> 
>  	mesg = buf;
>  	size = SIMPLE_TRANSACTION_LIMIT;
> -	for (i = 0; i < npools && size > 0; i++) {
> -		snprintf(mesg, size, "%d%c", nthreads[i], (i == npools-1 ? '\n' : ' '));
> -		len = strlen(mesg);
> +	for (i = 0; i < npools; i++) {
> +		len = scnprintf(mesg, size, "%d ", nthreads[i]);
>  		size -= len;
>  		mesg += len;
>  	}
>  	rv = mesg - buf;
> +	if (rv != SIMPLE_TRANSACTION_LIMIT - 1)
> +		msg[-1] = '\n';

Did you mean "mesg[-1] = '\n';" here?


>  out_free:
>  	kfree(nthreads);
>  	mutex_unlock(&nfsd_mutex);
> -- 
> 2.39.5

-- 
Chuck Lever
