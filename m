Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7798F5304CE
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:21:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790169711; cv=none; b=VR04YSIVCXqGG1AEBJ4MJhCLWT97gUZhEJFT+pzPTOFGs8s+BGUh2bwkDDM7khwHiBAF1eYPZdavCYJlo79Fo2qu5ai0ykby5tu78e7k3ry3mJL5eq/C5n2/visL84bVzrDMNW83NHqYuQ6AP+McmWl5oHJFg91WZiyyGgXZRKs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790169711; c=relaxed/simple;
	bh=cMAl89TaM3jt9M1kvyx5O2FPHIx7La0GATVHQQvrBbo=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=MUhCGXCf/JDH7evmvcOilWEEPVHohcRW1Oo5D8ocvLfWrOytihw8UGubti5u724vRIcNaqDf5SWsnSiQsikSUJwHaelIZHlwAZuWHKUPkc341yOUcWeO5NfuTw7XgC6tFvEOfLoivQjyDZxn8HbJdoJEsKgFPlc4IJvX9FYOcPQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SR8xsPvu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SR8xsPvu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2B9431F000FF;
	Wed, 23 Sep 2026 13:21:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790169704;
	bh=ZEuYR1K5jN9R2X5b7YIQPk8BMTNV7WrwF/2WnqsjoLk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=SR8xsPvu80rVSsKgrbVMcr4IMAuom02Lc94cFhYZdl0kjAdbyJ6Y3yz36NsNmMM/J
	 8P+jO6h2KiYzo7LYjOPPPDb/nkpi/UVpaLpqOTnNYUhPhCWZcvnHTYCu20gssyv4un
	 dGFnQxXl0dbfk6OnHGV5h5W0HH7UvHHI4uIBpiNjzVz9yi2uU3yu1SAfYCqJF5coI/
	 BOHib7nwks2b2ZWsA99eBEucr9zeLus3NfBotX+9LurMXxJjqkTVPAqPvVrjuuToLq
	 vQLrK+Pps9YY0CZzxXSAomRsZfud8uCHSyLUTGyJWuXgbOX+6x2SQX20CPU8GvgUBi
	 FfsBbtyQHvjhw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 458A7F40067;
	Wed, 23 Sep 2026 09:21:43 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 23 Sep 2026 09:21:43 -0400
X-ME-Sender: <xms:Z9Kzakziks9CMb0u3c_wn_0fNCByXcWZvMYilcxvDmwqUb7qFyhg-g>
    <xme:Z9KzajF2ebqxBKp0pu-Rc-E4Ftp1pFcDKGhd4DPg90dUU15DnLOfvYpd0jBV5OWF7
    bQJh74fE-0_YLQ65mVEd-A_x7NXgKVJZwbCjETPudIwWLgmbbt4sQ_s>
X-ME-Proxy-Cause: dmFkZTFYH3QZwqOhd/Q9OTbun6tIB0QMI51sU9X2O5EP1pgGyuvNf+GN7iIkNUG168hXHM
    VTWzAgVWutlo6Tpq5e7AR8jdPElKz4tCmHM454qu00XOrIYh2leu3lqsyde3LHrEFcn2A0
    pMkHR9KgSuYnDYrq2vIKoqbH99e8Tw/I368Pyknnbg4TGgbCu7O/VpJGs+y75UEwBBgyGq
    iUfhzy0sLsW8sVarq/t2JJWuP8a8GzThJ0k2kKiD/PPFzd7aRB6wjzBP2GGkVnq0/3qZHf
    VlaCx/TBoaIt6aUhBWxpdf8atj0/l8ZgDHVeNNOCgkkc9SIl/yT8/Y2VQb3EdeJPAI+DZU
    7d5W0GvECLR/8ifkRBHZd2Avrh22gM9bhiesaUvX2NqYHfxuPRcXakac1orGJHy0eF70kI
    kinG5e5qRCaUNz9r/iVravD9oIcwGlx6mLYFkB/HxvDPoCkxQnOyK+NntzWBRmXBP96Bel
    vSGQCfhrYYR6ZOj2XSJ9W6e8hMlIr9NcmquxBBxXJi+aITXl0UnM2dICL/4jSrReh8TmIH
    m7GrcTUnpiKtcij90Y4foQGrECpbKra1YDwhC5elcn+YJeq6V1CUlq8YO0eGtaSsMDeqXh
    KjF6D9kq0xd0Y0sKNMGdGWF1mO3Ll4VaQ2DL3iXph3duPlP/NUTFBWHifDTg
X-ME-Proxy: <xmx:Z9Kzaqt_2UErHz8_GhNmOae6LKcuOdnRJnDpUC09Af9ls2V7OkzJQw>
    <xmx:Z9Kzakazf3szCm0aK_TtlKph2f9SV2wp6vMnAPcqDW57KxJ3XUVDVw>
    <xmx:Z9KzaqBoeMr5PbYmIhl6Q9ED_w1f0-AJ-zg3EtFZ-Nd-EKGLYjPhRQ>
    <xmx:Z9Kzak8CZqjXvB00bOpRgntlVlOVZ8ILyLzHzd0mTaDvgUwflOgHIA>
    <xmx:Z9KzauTxXMUown53VtHzwEuzIQAkZhLGYoP3qpEhNKnhalCKrwO6kvd6>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 259C9780070; Wed, 23 Sep 2026 09:21:43 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AQuifJQH4ySF
Date: Wed, 23 Sep 2026 09:21:12 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Piyush Sachdeva" <s.piyush1024@gmail.com>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Anna Schumaker" <anna@nowheycreamery.com>,
 "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>,
 "Shyam Prasad N" <nspmangalore@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>,
 "Shyam Prasad N" <sprasad@microsoft.com>, vaibsharma@microsoft.com
Message-Id: <0bfc0362-096a-40c0-b6f9-a1a0c0edbf46@app.fastmail.com>
In-Reply-To: <m2wlsc88by.fsf@gmail.com>
References: <m2qzlx7eye.fsf@gmail.com>
 <0b39c1e01a92f99fe456c76523ec7f3aa5dc1a81.camel@kernel.org>
 <455619640.1622514.1782212671358.JavaMail.zimbra@desy.de>
 <a9885b28-a3fb-4ec6-b6fb-1be78ef16b2e@app.fastmail.com>
 <m2a4pqwx98.fsf@gmail.com>
 <6b4764058582acb5a71d83fa9639df10b4c2f717.camel@kernel.org>
 <m2wlsc88by.fsf@gmail.com>
Subject: Re: NFS delegations behavior analysis
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Sep 23, 2026, at 8:23 AM, Piyush Sachdeva wrote:
> Jeff Layton <jlayton@kernel.org> writes:
>
>> On Wed, 2026-09-09 at 15:40 +0530, Piyush Sachdeva wrote:

>>> With that as evidence, I'd like to propose exploring two in-kernel
>>> directions and get your opinion on feasibility and desirability:
>>> 1. Extend the existing getattr miss-tracking: when cache_misses on a
>>>    directory cross a threshold, trigger a deferred, background
>>>    READDIRPLUS to refresh that directory's child attributes. This gives
>>>    the find / du case a consumer for the miss signal it already
>>>    generates.
>>
>> Tough call. This adds load to the server for attributes that will never
>> be used. My gut feeling is that that might help some workloads, but
>> hurt others.
>
> I understand the hesitation Jeff, however, based on the numbers above,
> it is clear that despite the higher number of READDIR(PLUS)s its still
> significantly beneficial compared to the sustained GETATTR storm.
> READDIR(PLUS)s may have doubled, but they save us both time and GETATTRs
> by close to 50-80x which is tremendous.
>
> Currently cache_miss increments happen for stat() calls anyway, right?
> So, the heuristics are updated even today. All we are proposing here is
> to trigger a batched pre-fetch of those attributes to the cache using
> READDIR(PLUS).
>
> Doing a READDIR(PLUS) during find / du - It might seem wasteful fetching
> those attributes, especially if the directory size is large enough for
> the enumeration to take longer than actimeo (acregmin). With the patch,
> although the first fetch would still be wasteful, but we would end up
> offering better performance with subsequent background getdents() called
> from stat().

I'd like to underscore what Jeff mentioned above: "This adds load to the
server". On some server implementations and in particular with large
directories, it's quite significant. This will impact server scalability.

So any work that's done in this area needs to show the server-side cost
in terms of CPU and disk activity and READDIRPLUS latency deltas.

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
