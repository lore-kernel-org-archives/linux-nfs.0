Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2042046E010
	for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2026 13:06:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787836011; cv=none; b=n/+1UeiqYJQ/gjtd5W6sykh57xkkKEA1NwzIoX9My0jDoNk6IoX+VvvyK3AT1PL7Tq4zYq+9faSJRn3d76z0GmJ0f8g03zWxnmh96Ti75ZK07OwyqvLr+aJFEnIlUDJ+3HZ71/24wHBSKgDeNgcW8fxU3Nnt2sQUfI2emJAiUHY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787836011; c=relaxed/simple;
	bh=D0HBwAIvzJNMhfik4eK7FAFYtPWgdl8TcYYSAC6k9y4=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Ohpz1p4ccjoS6/rQn0bYMcU8B1rpGILzEEBTN+q9e6FlrlzeebM5AOY6bM++gL4VUtzF3JxhFBbzXgmXgqaen/ik6+9jW4T5MwFSIA6jVhPb+vq6HzCYGQtfrrRDr9rSOzey/Kpx6H21yzIQltaPjxpgxJhvqNB6p8grMl2cdS0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hRtn/HQc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hRtn/HQc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4EAFA1F00A3D;
	Thu, 27 Aug 2026 13:06:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787835993;
	bh=cJTSlEd68RZuGL06M3/Lyd/r+uxyOtiVJOKCOkVdyrM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=hRtn/HQc7WBAfrSiwvoiPVfQLcHIPVDgzuajduCSlNfjzVYIjqoI867rH3BEqbn2m
	 avD5LSfiyAHM7d30P0PLA5EiLlQogePWUlATtiOwJgKE364R1ogA5OHyzQo+Gg0Jtt
	 t4UzmLtnhZZmqghArpDdMwZdx+bdaAJ6cYVgnJ0FW2o0ox8xQugDE1x16unFfHBOGI
	 3D9oVsGLpUdSY75gW8Z3r9tGxACRX7NWtJi7A77qaPTNIlTiR/zbgDs/MQjWAfe36Y
	 y5HXIUyekEEy7IF2oHPuwhn/bPKp5R4wS2VjXGNXUaAeazTOtIcr5CdnWqIeQO7Mw0
	 FkGfzY5Z0Awvg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3B45BF40066;
	Thu, 27 Aug 2026 09:06:32 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 27 Aug 2026 09:06:32 -0400
X-ME-Sender: <xms:WDaQarG5hoYYQLBRNaBeNq6jqahLWHyBWSGuRIfVgwM-jBcqTnfIGQ>
    <xme:WDaQajLq7NpwhG4peRInKs29aXOLFREdeatRWSipYvTUi95TLEeXnzFgfaWs2DA2C
    d_XXUD25dSLif17Ak73ndWAKnLRfL1XW85JbUlSG8QxTgwtYscSQw>
X-ME-Proxy-Cause: dmFkZTFV6UjLByR+IHaYGJ2LqCsZhmTmv9hYxnrT+FBBtmogQP5ZID/Ow/TX+AWKibHNdv
    o9KTcq7NOn0bJfxy7jxZhcYQR32aHz1Q7ySDS12L5fkj2TmkbqjSWmK64ViLDcOf77yeWy
    hPWeKtAuSZ1Iw/3mU3EnB8DJZjrQcqpIgVpkiux5uDt8McEPZcjJ8Dz1ZbSoOGVO23HeJr
    ZABVBZyh1KC3FtvsBSrIBR54Qpurl3HXbAzJeZnHVP5gTfbUK5icQZFQWqj+e4f67sxRY7
    F/nMoIOPcHnjENN52CmHYK/ulxrCMBN4WsCczUOm6lZDsc4CEpGqNDvMQx7ljPCxfS6GU5
    6pAeheTngMhXCJj+hxQ5krjp5vJACzB2ByRD8LIgVV8HCM1Bh4zYLl4BpLp2vfQIhxf0Ne
    IH/KkaIVTN7U9JNAFOmR+SZXvZYPZiNpryLjBIVLM68FgnIggcHzQsak0doP/LLYnVgINn
    V8AM9Ywa89tJld2alik0jA0dz30xj+5DIeDQj19k2BzJLjT6nrPFB2WNKC6X0eKvuh85Zr
    FEYDvl3fJJp0614f/ccekjhXn/UH35EJGAQcF7Kcu1PReqt7hX6QIaUUmYmwTnzu0VRCdu
    jWV1dIWwA1zQ/M7A0l3iPezcJ7Z9whOXFhHGfuciP4RCdcHnhdlvU4IlnDdw
X-ME-Proxy: <xmx:WDaQavQLtp0iJBgyfoBr4-5AnF0SJ7YUwJqlH1L0oSPy9BlF5aVKBA>
    <xmx:WDaQamzGMitFRZ1NQwNbh6e_SdVY8LDniQkssfKJSJ7YEcYGYJWOTg>
    <xmx:WDaQavrsMyo3rCpnKMTO6-l_xS1WBCsUy-aWe6IgaVkLI7UYiewQKQ>
    <xmx:WDaQah2T7qNfCutUEpwuP4zHnEJfPjzri6GzuSPfJWS9NWx8OHa62A>
    <xmx:WDaQanxz93IWRNTi7zChd6OQsmV3NZXZTj-Iuo21EKK1zvzYGRuFIJwc>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0AC7D7811F3; Thu, 27 Aug 2026 09:06:32 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A0AurJh4UZM-
Date: Thu, 27 Aug 2026 09:06:13 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Prabhakar Pujeri" <prabhakar.pujeri@dell.com>,
 "Jeff Layton" <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Donald Hunter" <donald.hunter@gmail.com>,
 "Jakub Kicinski" <kuba@kernel.org>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <1c53950d-66ba-490a-872f-b2318c584d3c@app.fastmail.com>
In-Reply-To: <20260827045139.4353-1-prabhakar.pujeri@dell.com>
References: 
 <3fd25e2178458fbb44f57f1b0e068c12a6503d17.1787638668.git.prabhakar.pujeri@dell.com>
 <1046756851d9d7d688ac612a7f175e48745d2b84.camel@kernel.org>
 <20260827045139.4353-1-prabhakar.pujeri@dell.com>
Subject: Re: [PATCH v1 1/3] nfsd: report NFSv4 grace state through Netlink
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Aug 27, 2026, at 12:51 AM, Prabhakar Pujeri wrote:
> On Tue, 2026-08-25 at 08:10 -0400, Jeff Layton wrote:
>> What's your interest in reporting this info?
>
> My interest is in making nfsd's operational state observable to
> monitoring and validation tooling without parsing nfsdfs.
>
> Concretely, I'm building a validation harness for NFS server
> restart and failover behaviour: bounce the server, drive reclaim from a
> set of clients, and check that state comes back the way it should. That
> kind of test has to know when the grace period has actually lifted
> before it can move on to the next phase. Polling
> /proc/fs/nfsd/v4_end_grace works, but it is a text interface, it only
> answers for nfsd's v4 lock manager, and new nfsd control and
> observability interfaces are going to the netlink family instead.
>
> So I would rather frame this as parity than as new information: grace
> state is already exported, this puts it on the interface that is
> replacing the one exporting it, and -- per your point below -- fixes
> the semantics on the way over.
>
>> Just because the v4 recovery is done does not mean that you will be
>> able to access files. The overall system grace period is a union of
>> both the NLM and v4 grace periods.
>>
>> This patch is reporting just the v4 one. If the goal is for the admin
>> to reliably tell when the grace period has been lifted, then this
>> won't tell us that.
>
> Agreed, and "has the grace period lifted" is the question I actually
> care about. I mirrored the semantics of /proc/fs/nfsd/v4_end_grace
> without stopping to ask whether those were the useful semantics to
> expose in a new interface. They aren't.
>
>> Maybe this should just return the result of locks_in_grace() instead?
>>
>> Or, do you plan to add similar functionality to lockd? Then you can
>> just do the union in userland to figure out if it has been lifted.
>
> I don't think lockd needs to grow anything -- fs/nfs_common/grace.c
> already gives us both halves, and nfsd calls into both helpers today:
>
>   - locks_in_grace() is the union you describe: true while any lock
>     manager in the net ns is still in grace.
>
>   - opens_in_grace() is true only while a manager with ->block_opens
>     is in grace, which per the comment on struct lock_manager is the
>     NFSv4-and-up case; NLM doesn't set it.
>
> So for v2 I'll report locks_in_grace(), which answers "can this server
> hand out normal locks and opens yet" rather than "is nfsd's v4 lock
> manager done". If it's ever worth distinguishing the two, a second
> attribute carrying opens_in_grace() gets there without touching lockd,
> and userland can derive the NLM-only case as (locks && !opens). I'd
> rather not add that speculatively, but say the word if you'd like both
> in v2.

Although NFSD does not yet support putting individual exports in
grace, that is an open possibility for handling things like the
reboot of a backend NFS server for a re-exported NFS client. I'd
like any new API to avoid foreclosing the ability to move exports
in and out of grace individually rather than as a single unit.


-- 
Chuck Lever
