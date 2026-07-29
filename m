Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4AD68313E03
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jul 2026 01:47:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785289640; cv=none; b=EoRTzqaqOV44FBy+6drjrnr4132AKlYjDFQ3VrkS+tPV4UW5X5T/idkKmfwm/ao3/3oDjv3CEtdFlrmn8sXcgit4NU91wthAaBoYKkJHbEXc4GFP6+EeVaz6kjHS8t9zhki4UowJEOcwqklYM/7UWlz1P2edwKAA5n8rvMQSNWg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785289640; c=relaxed/simple;
	bh=njenc6WMqgPA2LJp2AaxnR51R/BCckHNf4jGC6KDjAU=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=YCiaTFJWhROw8mjn0YX5idGwQIqvzr67NOPTM7xwM8aAEJQ6B48YFZ9oWtShZXJPMO7b2TkeJiWH/D/zJOdxGZ2bYJm91YKuzhbeeXw5SDJlOHkJuvMG3HWaVdXUI7WyRAgbYnm5mIaBs2nbLPG1OFrraJ7NDf0Ns7qanw1lSHg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jYKEb+kI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jYKEb+kI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C64E81F00A3A;
	Wed, 29 Jul 2026 01:47:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785289639;
	bh=XZj5qT+LSXNo0oytQKjz37y75ChDQM7jEKmxY4KZ0zw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=jYKEb+kI+5HeA29jYJj4MlRxhtFN0lSTSBh+zEiucB/QSB/kR9ppv/iVyjdzHeoHH
	 pikRbBHcnT3wZOFBvLrrxP0coXuhRJNg6E6ZXAKzy3P2UffxQJGxYnTlWFtPKEoJaF
	 LcSEhEGlB/Jl71lhAIUpl9Ik9NkLZctcDXPBWJe9qMGZXSdmDtnbCbiCbY5K/AYqzh
	 1hQOUNCjWeCZywMJ1eGFfgjMRPiUq9V8Ef8h8ErSYOEdIg/TIMtCmDIIdO/GX2/CWj
	 1s3LOL9gpEoyMcsvFGVpL5G8rOJ6/v2Sh1mSM0iQvPjRhU4AEQIIkb5oCrle+XTnBa
	 NzzZaLy335QCQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id C8643F40066;
	Tue, 28 Jul 2026 21:47:17 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 28 Jul 2026 21:47:17 -0400
X-ME-Sender: <xms:pVtpalX5EjLMcP8lc8hUX6Bj5T8SoduOCUR9bhzz4fgCO7TiRKWLGQ>
    <xme:pVtpagZbAco3OVtTcmYzLWGu6Ti16fOowIA5eIVy7p2Yfv-mbqykaSxR4hHROgYRS
    CrJc9yQNLI403Tzx5j21QL7ru9TAT3HD1W0xQtYQyt-fkBPGK_Ri7g>
X-ME-Proxy-Cause: dmFkZTEM62oAPEBWKFUt6Wk9PslD9c4o/RztYMkJxl3CFY9FdPujtidQaES7J3q7XTCRu7
    7P6lqkzaXbNfFB1cl5mKg6X1F/0q0fVSeN9H7aqCKMTRngVR5Y47zP5yyiZRimX+VAQuJf
    5O7Vk5/d2lUpmdCTezXHBc6wwraUh3+2sEKEha4o0wBwtRY0Sbj0p//X4LnH3JJY3KzvME
    sD6nx1N/51x2j1Sv+6jVkIfFq+SS2Glka3qhfKAnR1CrJb4+bldu9dVHHL7Xyyfzrla33x
    TBNzci5/u7wJZTBGNpnLTabY4rnNxVOpgxyCrx6HyxGSC1b+uHE5cZyWxrMoQmvi7qdmqz
    f5F6QDQysaVfsBDb8ew4YzcvtiW3Z7IDFWIhzQguFsl5v/ujV8LbNi5RrycFkjkdKjRqZL
    UezsUMF+KQ8n1i3B4YzzRbngLrIkSxYZyFWg7DnBALyyZrdvzsRG3YiXS8yj6Dy5yvV56N
    qAaOllWXamLlQN7Z+3SMFYLQt5WAMkQbB4keAlckqxsRvFmCDduHrrTRp5fhvMODYImttZ
    IjTYKmUwFgd1oJFIKS49yeocoJ2bYvjRWGt2GChiqFDMLFYcPypSsEB4FjPZokkDV+fTLU
    kNaEJ2ioq9Yq93wAaNG9bSDGzAabvZCL3OmWZsUnuFFLFRDUMzdb/+wcOPKw
X-ME-Proxy: <xmx:pVtpamMcRElQvF2VQq9PsV4H6EQ91JV24KvIrQAd48aIItj6IDlXsA>
    <xmx:pVtpasjXVr8Ce7xwB2-mUVKHotFuRqL-z7MdZ9HTJQiF9enLjP4BRQ>
    <xmx:pVtpas6a4vTDqQkiZ4wmdQHd4t4qf5OdLNikFQrig8Mny1o4G09N1g>
    <xmx:pVtpajddLOnaVZaoPBDT8iPtWw6nPjCaaZZTeIg1h3iDHe8A19N0Ig>
    <xmx:pVtpalCiqNjCe9lP0BUpRUk2VPJhchm7C8dA-vtb4yAz6vQ5dsHrdPIj>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A758D780070; Tue, 28 Jul 2026 21:47:17 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Tue, 28 Jul 2026 21:46:57 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jakub Kicinski" <kuba@kernel.org>
Cc: "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>,
 "Sabrina Dubroca" <sd@queasysnail.net>, "Shuah Khan" <shuah@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Message-Id: <97b61f5f-57df-4a29-85a0-613f7b7e75eb@app.fastmail.com>
In-Reply-To: <20260728184312.20b21582@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260728184312.20b21582@kernel.org>
Subject: Re: [PATCH net-next v2 0/6] Deliver TLS control records to kernel read_sock
 consumers
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Jul 28, 2026, at 9:43 PM, Jakub Kicinski wrote:
> On Mon, 20 Jul 2026 10:27:54 -0400 Chuck Lever wrote:
>> - The no-data cap (patch 1) is a prerequisite, not a stand-alone fix.
>>   Once control records reach read_sock, a record carrying no payload
>>   stops advancing the caller's read descriptor, so a peer streaming
>>   such records would pin the socket lock and the kernel receive
>>   context for as long as the flood lasts. Bounding consecutive
>>   no-data records supplies the return boundary a system call would
>>   otherwise provide. The cap is scoped to tls_sw_read_sock() alone:
>>   splice and recvmsg run in the caller's own context, reschedule, and
>>   drop the lock on return, so they need nothing.
>
> Is it just me or this is incomprehensible slop? Run on sentences 
> full of terms no kernel developer would use?

It makes sense to me. Which terms do you have trouble with?

Patch 1 is moving to a pre-requisite series, so this can be dropped
from the cover letter.

-- 
Chuck Lever
