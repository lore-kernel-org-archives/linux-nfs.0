Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CEE78384238
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 20:06:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788897998; cv=none; b=QV+NZh9R60L6kgnogXi31qMbX2xyd412xu1BQ7mXVkiUBJVQjhZlRW8DipRsBuVBsd4Yn5zXGhRO7+XKG32rgiXOsCnybAl58G7Vm0ubtEIop6tOuY1bZ+Ex8Gv3sqfevmwsq+eozID4nIOYQMnKRrqhi2tQGccsglaZiiWRNWM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788897998; c=relaxed/simple;
	bh=/0UhP0OSGhbuDYTQJgOwk86tL8UnKj0BwdIga7AfpJM=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=SFb7Zuh9mXa4ysfESw1EjiPnbCVg7S8MK4uuZaV9/l57O1PXH4KpZJ/sRYYuL62SMrhA+wLtKzksI3I0vccueec2B7rCNJAAFUOYZPFtmIQpksdYjRJ7sG/e/KQduFa3hq8XeWFGtpzbxfKPTsu1uVEj+tumqnN69zxIpBdtdWw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=oLgb6n99; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="oLgb6n99"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 20B431F00A3E;
	Tue,  8 Sep 2026 20:06:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788897996;
	bh=jSC3oIajyQ4PIo/ALkZn1DB77pWCht1BcnyCRJNDCkA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=oLgb6n99NQFZealVGxlGEu44ujmZ/FELARHnhqHiU4W/44/3Z2bhCN3bDFP+HhVL4
	 F79CrQwkAshX/trt3huiBgs+jaTGqa6Ha2v6RtKCNgA2B9kvpFPx4SWpi8Lhk3ZGbl
	 Uf2cGUSY5h/RnNVUj2BRQp24kjOAiRFcx/B+cKc3N9DKWee6QXiXxQHWzo9f2p2uDY
	 anEbnwAGFtWjsAUjzIzal8P5rlxsoyzblLAZSnZSdyXb3la2f+vv6HjkCpiO/5julM
	 zPWdIpDsb0VVe00dvnjXHMnivR0oae7cE8d0iPOQ3m0skrI1GxaJ5xBHGzbq244k1x
	 Nr7wG7vitzzig==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3DE90F40066;
	Tue,  8 Sep 2026 16:06:35 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 08 Sep 2026 16:06:35 -0400
X-ME-Sender: <xms:y2qgauWEJ1NlKroiPM1UZXxQ248dUcr-uzrfEjU3z9iSfQRwHqQE8A>
    <xme:y2qgalYn5N1xQYNBPQUsWKKZphbtWzGw0obu8aVU9Ihx3YRlo0ToKmOlP0M2b-jDr
    oFgb-28Kd_AVuO-RL08eUUo7h77YoIXbjzz1u5gKK3JBVIfzOuEW57r>
X-ME-Proxy-Cause: dmFkZTEg8OR/3jSWCOjNDA+uTZVrhEVp1VUEpyeHsfw+Ad2xUA1YfKCwjieAgRTXarE5mT
    o9WnbOqCWzaQXAhzRN7Fy9wyLsUYdr55wBkDaamWZK5q55Y0g9tp9RiFOgswMV4yMYqYEx
    dhNUCw40cSqxbAKms1vpsKWDOykRzPWkgu35ordlwwSGJ5DxbQ9026MB9sIP/RhWOrPQ4A
    tO/gnreUrcFwz10AT//ygj5ZdyLcp9Mfqo+tBkBBfDtiR1OzUXnTQgVKx8WLG3nhXfxbbR
    gxE0gV4unTomLMazmp8ZVsMpjSJisVLXVKKPM9MOdPPxSn8VW244bBiCL4vjeLwDrLvuak
    IMacHmCnNUQdtghUYfbeHMMT6Nj6dm/qeFn0FY1a/CjPyfuAd5jxsj5ZAPAoheMQF8yyZf
    VlNP5RsK+Va+SY+W/KEi6ajVguEJg9KMkf6m/KfDifcp3pyMt65/R1dw+U9FNvXx2PO0V5
    h1igMdap5Mq1YFfgyjv5YRk+jvDPfHCPhvGnUlxDytj+7bK3w0K8aAtBSI5QQyfkX55I5u
    u5UXOVVBMZf49MBxslu/MKHwpQe2aoxdc0d54vgsMzWpD+km+3f5YinZj/ZvYKjIr0/Nha
    hC6oLbziuYlFOugPzffYkr2i8+v2ygmcN55nBU4k2T5twGqbpIkJzPfXxYuw
X-ME-Proxy: <xmx:y2qgasCn4P3g8xQfijY6nFeqlKG-4C01vkQI9u123dWmBBfECdnFsA>
    <xmx:y2qgan1cS_huQ3RMyhreZBTDlVzPUGtLJbOK0Lg2-O4SRYYEy2BuCQ>
    <xmx:y2qgam1-4Hx5dydYMwPZyu50uOD99JiRoYKzV4MTecrqzq850ySbUw>
    <xmx:y2qgakDh136B0VPuZJgAE50T6XaQfBt5jMKCgyyRYgOydqXIfp79KQ>
    <xmx:y2qgat7eUiuRh8XqA96xf_3T_uL3cwhOzHhhO17-vjHnuQZY_X3Tzrdf>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 1E58BB6006E; Tue,  8 Sep 2026 16:06:35 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AEpWtzEVLx4J
Date: Tue, 08 Sep 2026 16:06:14 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
 "Jonathan Curley" <jcurley@purestorage.com>,
 "Mike Snitzer" <snitzer@kernel.org>, "Jeff Layton" <jlayton@kernel.org>
Message-Id: <6f72685d-26c6-4b50-9784-42d6f30b3646@app.fastmail.com>
In-Reply-To: <3AE72914-37A0-4ACC-AFAA-57BE5052F5BD@hammerspace.com>
References: <cover.1788453839.git.bcodding@hammerspace.com>
 <a906e6ed5bd3fd560ace313a6b64491e1da835ab.1788453839.git.bcodding@hammerspace.com>
 <15ea408a-5e87-4a65-ac94-10e357683a8d@app.fastmail.com>
 <3AE72914-37A0-4ACC-AFAA-57BE5052F5BD@hammerspace.com>
Subject: Re: [PATCH v2 1/6] NFSv4.1/pnfs: suspend pNFS on NFS4ERR_TOOSMALL from
 LAYOUTGET
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Sep 8, 2026, at 2:58 PM, Benjamin Coddington wrote:
> On 8 Sep 2026, at 13:35, Anna Schumaker wrote:
>
>> Hi Ben,
>>
>> On Fri, Sep 4, 2026, at 8:56 AM, Benjamin Coddington wrote:
>>> If the layout for the requested range is larger than the size the
>>> client advertised in loga_maxcount, RFC 8881 Section 18.43.3 has the
>>> metadata server return NFS4ERR_TOOSMALL.  The client caps
>>> loga_maxcount at a single page, so a flexfiles server that stripes a
>>> layout segment across several dozen data servers produces this error
>>> today.
>>>
>>> The client has no handling for it: nfs4_stat_to_errno() maps the
>>> error to -ETOOSMALL during decode, which nothing in the layoutget
>>> path recognizes and nfs_error_is_fatal() does not consider fatal, so
>>> pnfs_update_layout() clears the layout fail bit and returns no
>>> segment.  The I/O falls back to the MDS, but because no fail bit was
>>> set, every subsequent pageio attempt sends another LAYOUTGET that is
>>> doomed to the same NFS4ERR_TOOSMALL.  Files whose layouts do not fit
>>> the reply buffer never use pNFS and pay an extra round trip on every
>>> pageio.
>>>
>>> Map -ETOOSMALL to -EMSGSIZE in the layoutget exception handler and
>>> have pnfs_update_layout() treat it like NFS4ERR_LAYOUTUNAVAILABLE:
>>> mark the layout mode as failed and fall back to I/O through the MDS.
>>>
>>> Fixes: d600ad1f2bdb ("NFS41: pop some layoutget errors to application")
>>> Cc: stable@vger.kernel.org
>>> Assisted-by: Claude:claude-opus-4-8
>>> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
>>> Reviewed-by: Jeff Layton <jlayton@kernel.org>
>>> ---
>>>  fs/nfs/nfs4proc.c | 8 ++++++++
>>>  fs/nfs/pnfs.c     | 2 ++
>>>  2 files changed, 10 insertions(+)
>>>
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 04b1987115d5..e41c792a2725 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -9680,6 +9680,14 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
>>>  	case -NFS4ERR_BADLAYOUT:
>>>  		status = -EOVERFLOW;
>>>  		goto out;
>>> +	/*
>>> +	 * NFS4ERR_TOOSMALL means the layout for the requested range
>>> +	 * exceeds what the client advertised in loga_maxcount (see
>>> +	 * RFC8881 section 18.43.3).
>
> ^^ gah - Jeff asked me to drop this comment and I forgot.  I agree its
> better without the comment.
>
>>> +	 */
>>> +	case -ETOOSMALL:
>>
>> Should this be NFS4ERR_TOOSMALL instead of ETOOSMALL?
>
> At this point, its already gone through nfs4_stat_to_errno():

Oh, I see. I was looking for for the call to nfs4_stat_to_errno() in
nfs4proc.c, but didn't think to check nfs4xdr.c too. I think that's
cleared up my confusion!

Anna

>
> { NFS4ERR_TOOSMALL, -ETOOSMALL }
>
> I definitely tested this case thoroughly..
>
> .. but yeah - the mixed error types and the comment in there don't make it
> clear.
>
> Ben
