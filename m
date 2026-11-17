Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=85.215.255.24
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794910111;
	b=C9BlLO1lG2Y2ZwmS5sN/nuiuBw+BmoFafl2nWkyrpL/cB98Ly8QwwaHZxJ9rA+pljQui
	 +OV9rElheyIpFhvoP1B5SPh7GzZYtQywKYjzxWDFckaYaQHI7iqG8joCS4ryM9TwC/3ZP
	 Gn3VYqaVc4MYLD3VJuLJGB6JRPOHPZ4aeZI6xdqiHj1y/u86sQYEgnPSMX1X8qX4rJYHZ
	 cHY9nV3GmC74lyJ1UFzaGHJzZYy70J8eQLkgKCRoRc4crScGwuVLD0h1YTOTmydlI7esx
	 ZIeEeOLSLVC1nA3XCLGe1Pt06OVSt8VvFT3HhIdaHz/9xCcueN6LJycQAAHQ9y8lvWg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794910111;
	h=DMARC-Filter:X-RZG-CLASS-ID:DKIM-Signature:DKIM-Signature:X-RZG-AUTH:
	 Received:Received:Message-ID:Date:MIME-Version:User-Agent:Subject:To:
	 Cc:References:Content-Language:From:Autocrypt:In-Reply-To:
	 Content-Type:Content-Transfer-Encoding;
	bh=tdtIlvmTijcNb9Hhe9XU/v6/BDW7yZKn/hQ83QaO6qU=;
	b=cfCsLkYVTvp0tYehHIf7QgczEZ+ivXL1ZpyaVCZ8G6Je4kKnDUQglPmcMSPa8ij6NGqA
	 cTJWucuzr2+cN+Q9Fae6vbKqlGdFeORMlLC/rTkqQEp27pNeglxRpzkJ52Eit2ATHD4sr
	 IqPlVx1q9QXI644oOhavY32HI26pw7PZHdoOlGSmRH4f5vEAFPWhPbSEbLmJgeH1Cv+EX
	 VcTXG0C1wYZon35O/FxxEiMNDa/zAQGxxeJHPM/aKmX+UfiFVlIEuADDSH2l6lxgj00aZ
	 yq6NfdYQcuzC0zQWz5cQPLLO0545P4+gpOnlt4SuFGvJfeHCOZPYcJC1mUpAP8BUpBw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=garloff.de;
	spf=none smtp.mailfrom=garloff.de;
	dkim=pass header.d=garloff.de header.i=@garloff.de header.a=rsa-sha256 header.s=strato-dkim-0002 header.b=IDZhoKmC;
	dkim=pass header.d=garloff.de header.i=@garloff.de header.a=ed25519-sha256 header.s=strato-dkim-0003 header.b=BKdbzz7q;
	arc=pass header.oldest-pass=0 smtp.remote-ip=85.215.255.24
Received: from mo4-p00-ob.smtp.rzone.de (mo4-p00-ob.smtp.rzone.de [85.215.255.24])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0568B606A32A;
	Tue, 17 Nov 2026 10:08:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0568B606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=garloff.de
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=garloff.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=garloff.de header.i=@garloff.de header.a=rsa-sha256 header.s=strato-dkim-0002 header.b=IDZhoKmC;
	dkim=pass header.d=garloff.de header.i=@garloff.de header.a=ed25519-sha256 header.s=strato-dkim-0003 header.b=BKdbzz7q
ARC-Seal: i=1; a=rsa-sha256; t=1794910102; cv=none;
    d=strato.com; s=strato-dkim-0002;
    b=bPuGpt1MzOC61muO0r1t+Z9//xyGIPsdzqtd6YBNLpqiNDXWIVI8njvb6UMAig/vVv
    VXeiYpvhJT9seNIbf9W51a2d4GBo5bHuHJAgqLWYC+3nHOwXMlAOJRQWUFPlPlvxNPeV
    6FxNpzWGfLwgsCW61NatJINRnbImfP9FDs9rboR8+C06oqwwn4iJ/OCt5fKhmQrIAMcz
    E6PjKuKe9KPT5XnAZP3z8lqbSZ+DN6T0ku3SvBqkA+OFLz4NNIvfWcs6ceka+/Eihbat
    G7RmIr0UtAK4hWjw0IhRUiRIp8cbZTRBK97qP5cCOklEaBkCGg0mzNMEJdFCNaQyb7TP
    XcFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; t=1794910102;
    s=strato-dkim-0002; d=strato.com;
    h=In-Reply-To:From:References:Cc:To:Subject:Date:Message-ID:Cc:Date:
    From:Subject:Sender;
    bh=tdtIlvmTijcNb9Hhe9XU/v6/BDW7yZKn/hQ83QaO6qU=;
    b=TXGlybsHHUupk+PkSyGFjhyBh8MIP5EKiTxUiwg1qaj2viqVUf28T6qm8PzDZwGNSL
    oSCzV6gvQfq745hyCnD79/5LzK/2mpO0ZE3558xWXbsc0CXh9qBWzLFZA2HdemHyl1mU
    /Geu2i6Ufj1QXT+gvgdf6CaPZWXpMphg7NHCdX0A8okwm8rJ+FsDKcDmC3d86YUAHjQ4
    6wyab2UmkZTWzMQWWqheONzhxTKpJHa4+q+/sbitYFrHM//h71UdsjUgka4cVUsLR3A1
    0ULPIQJ390WNjkhTqXhfCiHogGzN5YEy5EovcEhSv4JCpWaxKQ+DLQe7fJ5AaTtIn3zf
    rGAQ==
ARC-Authentication-Results: i=1; strato.com;
    arc=none;
    dkim=none
X-RZG-CLASS-ID: mo00
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1794910102;
    s=strato-dkim-0002; d=garloff.de;
    h=In-Reply-To:From:References:Cc:To:Subject:Date:Message-ID:Cc:Date:
    From:Subject:Sender;
    bh=tdtIlvmTijcNb9Hhe9XU/v6/BDW7yZKn/hQ83QaO6qU=;
    b=IDZhoKmCgqCqAovxb1eYdaK2mzm4H9odurkIg1XGhXD9D4FFczyFdAxIR6eLxzUjEa
    4XaVk06fMkYlQojf3UrB9wqSAKUluCoTPIRrubHUD2CFuqNxkLVZ9VmnvO+vnVQ5K8Vp
    xnYzXS70udGGn8UGJRLkxlgYcOlLHvNWzKwEpmZizH5NbERUpnY+w+q6BPB3suhfHr8R
    4L6MpsRfHjXCnacXa3EteH/RWSlkNOzUtMwuTPz3I+aXNPXo+2UDZLsqqlt7WYiRvRu+
    LPP44LULikEaVsHTyTMhWdbeym3z2Uas2Qi/jR1tfkwNJw6qYhDcTLCk35aHCfWHiTCw
    JsRg==
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; t=1794910102;
    s=strato-dkim-0003; d=garloff.de;
    h=In-Reply-To:From:References:Cc:To:Subject:Date:Message-ID:Cc:Date:
    From:Subject:Sender;
    bh=tdtIlvmTijcNb9Hhe9XU/v6/BDW7yZKn/hQ83QaO6qU=;
    b=BKdbzz7qqTwoeTVJgmc65iwTx2csUjQnqXoFhshCumHXZXeq4/tWtSBf8S/Ifrvpxt
    CmTOmqCzdUL9/t6lEGDQ==
X-RZG-AUTH: ":J3kWYWCveu3U88BfwGxYwcN+YZ41GOdzUdLW+J8VEEt5iZSjU3o6iSISOg8L"
Received: from mail.garloff.de
    by smtp.strato.de (RZmta 55.6.3 DYNA|AUTH)
    with ESMTPSA id L82ab22AHA8MHZe
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256 bits))
	(Client did not present a certificate);
    Tue, 17 Nov 2026 11:08:22 +0100 (CET)
Received: from [192.168.155.137] (ap5.garloff.de [192.168.155.10])
	by mail.garloff.de (Postfix) with ESMTPSA id B460960AAB;
	Tue, 17 Nov 2026 11:08:21 +0100 (CET)
Message-ID: <9b9501a2-025c-4348-b16e-6ebbc9ae9147@garloff.de>
Date: Tue, 17 Nov 2026 11:08:19 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v3 0/3] fs/nfsd: accept a backdated timestamp from a
 delegation holder
To: Jeff Layton <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>,
 Neil Brown <neil@brown.name>, Jan Kara <jack@suse.cz>,
 linux-nfs@vger.kernel.org
References: <35138d17-c7ed-4705-b66c-8c84f44525ac@garloff.de>
 <fac9f04e446b425573b957b67ffa399a9e10c9cd.camel@kernel.org>
Content-Language: en-US
From: Kurt Garloff <kurt@garloff.de>
Autocrypt: addr=kurt@garloff.de; keydata=
 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
In-Reply-To: <fac9f04e446b425573b957b67ffa399a9e10c9cd.camel@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

On 17/11/2026 00.51, Jeff Layton wrote:

> On Mon, 2026-11-16 at 13:43 +0100, Kurt Garloff wrote:
>> Hi Jeff,
>>
>> thanks for your nfsd patches to accept backdated stamps from a
>> delegation holder!
>> Without them, I can't even extract a tarball with correct timestamps,
>> which is pretty ridiculous.
>> This breaks compilation of some source trees hosted on a Linux knfsd,
>> e.g. openwrt.
>>
>> I applied your patches against 7.3.4 and they fix the issue.
>>
>> Tested-by: Kurt Garloff <kurt@garloff.de>
> Thanks for the testing, but agentic review has found a pile of problems
> with this approach, so I decided to take a different one. I'll
> hopefully be sending v4 sometime this week, so if you can test that
> too, that would be helpful.

Thanks for the update!
Fortunately, the agent-found problems have not resulted in real-world
trouble on my knfsd yet. If I should expect some, please let me know.

Please copy me on the v4 submission, I am not subscribed to the
linux-*@vger lists these days. I'll do some testing in return.

Best,

-- 
Kurt Garloff <kurt@garloff.de>, Cologne

