Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD37C49DBB1;
	Mon, 21 Sep 2026 13:25:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789997129; cv=none; b=cp86lxz6jlVePv3yadfDHUe1Dyi1abm2hMQuH4DsvxkZVJT1XoBB9fJ561Uro/rRkm8kktmf7SqBVlLADbGzQvcR9c51/tXdURuFRtOLJ/TT2XSM6wRZuMdQervLJzy5Ehz7RRjGs6A7ZevnGZrs6P8k2Hms1dm8Rz6lFQ9jAQ4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789997129; c=relaxed/simple;
	bh=xYCV9phbnlvr/0RbhoT13i7JK7aS5KJeZrJBgCDDphY=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=EFe5A/02JV38G3YiLfN4ZtwthF0V9bhwANvwqbj3/w+GQrC9WzsNEah04ruZIUaTbgm9xHAbf9GsCwMDv88sJ/G02WRyGzw4Z2tlHCJD1p3cwW8zALt9lQ7rvKVqeh5cM5x0+6Z24Txge8ZAaBgeTL1z4h4Ajuhb7g7XGCC3EWQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YAysZ80G; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YAysZ80G"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C28A91F000FF;
	Mon, 21 Sep 2026 13:25:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789997127;
	bh=M5oDiAOnMaNY9o9gZBHcIp39xYWkoqvS23b/muDgRDk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=YAysZ80GGY8HrTfZgZxkLKTyMtUkedjuankrXPurtWrPEf7G108Gh65GNxThOcjBw
	 iNOhNqXHFF8jmZ3llq1aQp2o6AwAACJlyJiiaMZpEmP+INQwcPAQW4H1P/tIthpyJa
	 S+/UQ7K5CkvWUK6+p/Xl2aCtp+h5cBKi2t+jEs5jTSrFxphT4Imif44/A9gf63WuGK
	 LJ+iA2o1XJqCddAd6HE1dqCgbELHna80cQlILIiZO/f/88kiSFB0ReQQJVW6Od7HZY
	 ILmuQ0osv9ZioFrW28wo4bBye8/iZNSLi0K0oQOUewjMjiqlBe6e4jCpAdrT2XwMxl
	 OhbruLuUYVMag==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E6143F4006A;
	Mon, 21 Sep 2026 09:25:25 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 21 Sep 2026 09:25:25 -0400
X-ME-Sender: <xms:RTCxarYLhx7WOX4ULzwnVuYbYraVJsabJWrLRc2byqMvEnhj3eTkNQ>
    <xme:RTCxalNUXM-lO9HZJn1q51HexVbew3_Q2-E3DcOxbrqGyYmNXRkXBuVS52Z3KF9z6
    KjdX4tuMcYWDgAT0uuNFiDJhHp3YJBiAZrz97pr92ig5uR00L2FqnA>
X-ME-Proxy-Cause: dmFkZTFTghwdCTVE7krZqSerSRoShUBKmlNU07x1ACHTfcSgbqttKRHqveL+zBZ/WQacFv
    zzNfajRXFgkQB1Df2r9By94JsuXNjiGws2qD7z0jvKfZqRN1fwTyE6pV7xpo/7548sq1pP
    SooyRGc1IKlRkQ2o83JzRBjyCHnT/647VTD8mYfG6z4T01+nmAq0OYFMM0SvUPhuYxn9TN
    ttPhbfGhs6JcfjiGn2LxvrIwWcxXQcL2t5WqgmmOAEPcDe9sSqTLW56uc+ysg81GcLS/Df
    iaRmQqmafkdccnHkZZoIIU2TgWKXLAjVKyAYuMHjXDu4veISo4KoXLIvkwnuNfUmTbogjD
    3yMkjqg1qexd/jIcFlJTuv3EBVegB11kyRkeuYCG6cj1MqmJGlcaSk6X3431/cLLX6ioy1
    J14hAzFLYJOJxUTmMxLfOk0AQTp9xk9vWCIln3RPtKxiMLPeZ2VprncYugJy6gGKJmrLC5
    G49rDl0qzMlLjjez8chHbkox+h58QoYplncMNqxfsPX0VIoxQ6TNT1vBxfwTUZgYsLYiIC
    +kQOVUz7vehLMRT9mUXCOrx5jyt6ss24gkXaGsdjnF4BIGDjaQzdCl5Pq7BDB+kELxpnL3
    rjLt1J/JGV7UlXECNgjdPtgvdKPm61/HL+1bS0rtvcqAjDPtQKzW5ih1Q5Hw
X-ME-Proxy: <xmx:RTCxanl7l27lBot6dJBcGBnbDmguZlxsFPOk5q4rhcp32VKrxyGFHg>
    <xmx:RTCxamwHPzp679FKoNTk7PeEYBzadTZt5fqWaJwfCIfZM_UHwn7QDQ>
    <xmx:RTCxajzN8q_QGCIcyz1JdmpfqtujPGmCIhUHtN3hmShIKlX48xK9oQ>
    <xmx:RTCxal8ju2ybe6rbniFAy-DdTjPlG_DG1FJbsFzp9Dse54pSWgDYwg>
    <xmx:RTCxaj8cyXe5RDDFSdeXi0Y2ideS0UbiXfpUZEt_FkEc1QvZSgZhIZVN>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id BEDBF780076; Mon, 21 Sep 2026 09:25:25 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AFQlgKekMDrg
Date: Mon, 21 Sep 2026 09:24:56 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Peng Fan (OSS)" <peng.fan@oss.nxp.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 linux-kernel@vger.kernel.org, "Peng Fan" <peng.fan@nxp.com>,
 linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Message-Id: <2df127da-42fe-4b35-8199-5953f6dd01d3@app.fastmail.com>
In-Reply-To: <arB/ixTLqjuyrSUr@shlinux89>
References: <20260920022714.3145751-1-peng.fan@oss.nxp.com>
 <7c7d7b6a-38a9-477e-9bcd-1f9c53a160c5@app.fastmail.com>
 <arB/ixTLqjuyrSUr@shlinux89>
Subject: Re: [PATCH] SUNRPC: use assign_bit() where applicable
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sun, Sep 20, 2026, at 8:51 PM, Peng Fan wrote:
> On Sun, Sep 20, 2026 at 01:22:00PM -0400, Chuck Lever wrote:
>>
>>
>>On Sat, Sep 19, 2026, at 10:27 PM, Peng Fan (OSS) wrote:
>>> From: Peng Fan <peng.fan@nxp.com>
>>>
>>> Convert open-coded if/else with set_bit/clear_bit the assign_bit API.
>>
>>The above sentence explains the same thing that the diff body shows me,
>>so it does not add value.
>>
>>But I don't have any context here: why is this being done? Is there some
>>kind of tree-wide clean-up underway so that a new feature can be added,
>>or is this patch just a one-off change?
>
> It is just a one-off change. I don't group other patches to use assign_bit()
> into a large patchset, just separate patches.
>
> Free to drop if it does not make sense to you.

It makes sense. But I'd rather not make assumptions.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
