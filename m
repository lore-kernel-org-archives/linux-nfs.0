Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5405E3101A6;
	Wed, 12 Aug 2026 19:58:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786564692; cv=none; b=laePMBFQTRqGr5EBfKVIcvUdLiDVu5XL6/9YiasuyX5a0mAvSLfTrsohhAKuokufpfpZb7k9bZRPgjMSiUNr3wqvpUOp1+LmBVr8d3/8cT4rgEp9TJt6H1dqMtWXKIxJfTmYJB+TkF3teHrYrAbcXpgoCL/LuxsinAfGm4sWyOs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786564692; c=relaxed/simple;
	bh=JZriPIKHnwd+O1LzLaSuY4sWtN/OQY8R6zFShcKLBgQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Hi8pffqRf80TrqERhirfHLVb2hDcfdAYSreWO4OzHILL4q7kU5YtUor+Nz7eeoY/27y0oCceGCVamRPG4NbbA+xFt50kY99j9vUSqrUp84L6Iltdtj054bpfxYubHVJJTFiomt5HTkafSldmaG7dccMGXtJXe5ajrKGmS6pBSms=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GYumb/dS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GYumb/dS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9777A1F00A3D;
	Wed, 12 Aug 2026 19:58:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786564690;
	bh=Y1P55mM0dahNIB/Al0oh+EqD8rQyMQvSEpJTZ3dx90A=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=GYumb/dSle5onLQ8y2eLBtJrT50P1L8kgmYZ2O0JzJJbsMiLcZ9bWVqWkEjenD7q4
	 J2VYRXQSEV/HWP5+0+LZI2IqFexU34zmBqBbv/Zo6tFmi49F8oGn4Y0n3CWFGazYZ6
	 3CCBPmnR16CbqwVhMVCreqj7d7f9czdVHuobfoqiFT4LRpTSP+45iLvYh9Ej7FD9tg
	 iAkxf6CWONqY5Zcg6HDp2SySLRa6xrOZ6vgVHdzJwDXYK/4YcIZlGH3oCspztbI9vJ
	 S9UCZmGov1AkF0EtPNaFYRFxz8fqRthzNlw9hVfIDgXt/CKtDgE0MWxeKMXBMauQNA
	 TvLO/fnpcDJFw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 9E729F40066;
	Wed, 12 Aug 2026 15:58:09 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 12 Aug 2026 15:58:09 -0400
X-ME-Sender: <xms:UdB8arYn39IPfesgoXsIoQNjPwVjXlNcMSSSOq4GLAAfzcd_hTtcJg>
    <xme:UdB8alNACJJplvHjJLAF0GTLqqauPPO93IYo40VIz_VUMkyVO_DauPykiiqy8PBbD
    zAdvYCE0qyWnDMxG9bSke5lUdfo-zkYt9SqLJsnEmXJBwddrMYzsJo>
X-ME-Proxy-Cause: dmFkZTEWzyiPOwExbhK5KCTbtWVdpNIqX5qDclII+jkPfrwpXd9yV8SuDk4G1Y42zg4Qul
    cEOs4s2gHwVD8gLshicaNH0w/l2O2N953BVrME6zgTPFbCYsBhuHwJIY+Mr0H86TJLxr4B
    2zPpgoRvZXBNV6XppZjkG8wV/tqj0IjqSU+jt5opp8qlMfgpYxWm03iEPa0DFOqa3Znc1C
    0e2KSW1u2VgRL7ZjFuDJ9pbkSRdxlA3kmYD9Dw/JcDQfKTrUXPVC81D4fJ3HWuWjaYCbM3
    W6r1EqPa/WuQhC9Yi6azguBSYM0cLyor6nw3uGhc3bZpR8ltg92PuavKaXAXmO5ff+jCPj
    VatPHnablbfRnGkjlEDg/ihUWjz88oXKexRkU+9I6yfsr97xGtce28vOPHvW8cjngrR5kw
    eBaZaZ/EyVmJFbM4Ah+yVSAYVu0Mo/euhgE4ZF9Asi/S6h/TtNysQOOCDAytilHOKit1t6
    h7OwTwG0Uhtn9hVZzjFHthWO9eXSzTqxKowDbV4LxURcFl/MnQXqDNsEvbNuam4GW7H1la
    nV6k6bBoq5ubFt7Kwge0XAoxlUcOp7LieGjsHWt7IdpzY07rjIqGk4pPB0ZVr58qfHyBlF
    tSTkYZaSGVaJ6NhEWzPr3n32Rlh7xjdOrntp3sk2oVAXwkcrnAi1b0+CpMlw
X-ME-Proxy: <xmx:UdB8atavH7zdhgok-UMPsDOxqotQTMV24YR0UlUxsw3h1eOfEZcOyQ>
    <xmx:UdB8ajpadmOxf1NiPYvyZwlmCDYZXMGy3v089zstq0C47vRp0H71qA>
    <xmx:UdB8aix7S0JDDMkFePGmIfLQuoitL1_ktO1llBOR2tYhB99whf7t4Q>
    <xmx:UdB8ajLRLjz4876VEznhK1VE0QFk6X610GtOPnH2wOKT3P1e1bHnuQ>
    <xmx:UdB8as5GRhkxr-TEBo0DOUlsVm-Bn8lXQUEPal3qLLgT_rtW9lu62afm>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 79933780C1A; Wed, 12 Aug 2026 15:58:09 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A4afRqWdro9F
Date: Wed, 12 Aug 2026 15:57:52 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "J. Bruce Fields" <bfields@fieldses.org>, "Shuah Khan" <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, "Trond Myklebust" <trondmy@gmail.com>,
 linux-kselftest@vger.kernel.org
Message-Id: <572f0269-9bf4-4a80-8e9c-3c4614d45f7e@app.fastmail.com>
In-Reply-To: <26486c88075a0b1e3c1cb088fe97d39e0051b5d3.camel@kernel.org>
References: <20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org>
 <20260811-nfsd-nl-hang-v2-4-c0c92b3953c3@kernel.org>
 <e1706a70-d9f8-423e-9462-2d77b2e444b1@app.fastmail.com>
 <26486c88075a0b1e3c1cb088fe97d39e0051b5d3.camel@kernel.org>
Subject: Re: [PATCH v2 4/8] SUNRPC: undo partial rpcbind registrations when
 svc_register() fails
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Aug 12, 2026, at 3:38 PM, Jeff Layton wrote:
> On Tue, 2026-08-11 at 15:19 -0400, Chuck Lever wrote:

>> For an IPv4 listener, the port-zero callback falls back through
>> __svc_rpcb_register4() to rpcb_register(). PMAPPROC_UNSET ignores
>> its protocol argument, so unwinding a partially successful TCP
>> registration also removes the mappings for existing listeners on
>> other transports, I would think.
>> 
>> It might be that the best the kernel can do here is tear everything
>> down if one registration fails.
>> 
>
> What I was thinking for NFSv2/3 was to just have the listener set
> netlink call wait for registration to complete before returning to
> userland. That would mean we'd have to block even longer to try and
> unregister things if things fail.
>
> Alternate proposal: let's just declare rpcbind reg errors to be non-
> fatal: do a pr_warn() and just leave it up to the admin to sort it out
> if that happens instead of trying to fail the startup.
>
> The resulting situation for the server is no worse off (it's just
> running instead of being down), and I move that we're better off
> leaving it up to a human to clean up the mess instead of trying to fix
> things up from the kernel.

I was thinking of this in terms of a declarative administrative UI:
If the kernel can't set the requested configuration, it should
fail back to the previous configuration. Maybe that's not possible.

On the other hand, what might be better is to handle the rpcbind
registration from user space instead of the kernel, after the
kernel listener is set up.


-- 
Chuck Lever
