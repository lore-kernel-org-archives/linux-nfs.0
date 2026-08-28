Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3032344AB98
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 13:44:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787924641; cv=none; b=XAcszmq0QSB8os2zsd28ktF0ueTU1cNYSGURhGP3tzMQxG9Tw0IVTejfSxpm5e22+7vZIQ7u722Kn7dvRZLjL56PuQWiI9JVI6j+FYbRp6nchkyrdXoMKLTErTOE4jHNugGwGDEpOjOj29GAjKQmtm8ie1On/7b7Q47S7aeqasM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787924641; c=relaxed/simple;
	bh=gT30tbsMhDz5g+0/hURTtIYU4GPAfQ3xC3HFd44lfPQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=TwRVxlRLmxbeqnMfdQvol61NeR5evXtjZwWOMTUEtUZD+MI2rx0qj93t0RRL9xvHCRAHSfcCWhJ4pEeV95HZ12B79eGkwXbK02kko48AcQi+TiJIzG6nLV52O/6yoq34GNMmHhi9hwrfgIf7+GevBQJC8YSsPeHkG+1+1FlTq90=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cbY+XoYA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cbY+XoYA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9BD8D1F00A3A;
	Fri, 28 Aug 2026 13:43:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787924640;
	bh=SLONH+AoEVkvJHqHSlkrIz7ivop4/NRwBDGMuTUi3L0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=cbY+XoYAUhOBpBl8FKdYM5LEJjSHl2r3mQ2wpizV0j8wlY7HICRJGjyJBkQNNXxon
	 FTvLaov6vpN31A1DhYYlVUFXaA0xqHH9yRNcil5xlYcno42X7sJ1OqaEQDUaHlwqI9
	 RWOEzzNNnQ/2p11PxPsod9vD6q/DB25150eSh8OkqN2uYJoyI1w4vLknMyQM3rlaWX
	 A38obhK1pSl9OKiBkfuGfhXQx+4R448Y63snmRVZzo26APvEPXNE76BxMOi/0rVZkO
	 4UTciBo21WGYx5fcdD4JLGZQaVfaxFS7IOXS5o2c59jOChGVVl9aI3JWJn1+Splrvr
	 GClo15EsNRa1Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id BF7CDF40067;
	Fri, 28 Aug 2026 09:43:58 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 28 Aug 2026 09:43:58 -0400
X-ME-Sender: <xms:npCRarJwul-sx0sGysP2dkBDIWj6Pm8JCsHF7t3j9nvY7SfCK_-cLg>
    <xme:npCRap-7SF_gdMUu1HMwcDnXqg-2AKGouM3HFp08B0r1ZEHP_Rl0FxvG-w2NsY0GQ
    qk3lbEneL8--gPqTUelgoTBgJT-ybEFwuFYjr9pD7TDe9_bsPFiSAcW>
X-ME-Proxy-Cause: dmFkZTFtRjSOGHXDhdlaO+ssepuBQ9bmzOmjvP30tuJtUxE5N22iO5dGfGuCZeIAtfdzSK
    sV+sEaUtjDTBBqINmNMOXi1vzBhq4QXEZnh+C6DTtFcB3n72wfpQ6k2Vk3ODRhNc1+l7SM
    4Z9TmDI9wnfK2Hl8vu7LUOlRGVn1b36vCR1sWZkSH6H61xyrCrIUgJcEbKhSPfnmR6ztVu
    TKRJFKHndEZzLWVbkcBc7OVOyXa3jUn6QO5vzul1d8WokgiVQOzLPjnoY4F4mwhTHvokOe
    M5omA4NHWXwGAYUhtDwez3r/XX8KvHvxNwo+bUqnd06XA5s5j/F4qIn+gtC8mAgKzAnJCC
    aD4t+ZrJsniTNMIeTsl9g3pJYPzMGbocp3UDVdQWUu/1C3R4P/w0l/OJX7rJiSopGl1x/S
    1+9lR/cCEP18I/TZDyNVUyTku7s7cynkRXOZ5EOxFjXUWMb72n0o37rFl8qDeBy+toBREK
    WjclSAowBwZJFDn6jw07vdx5Th8fJ+9P7JM0JRZyoPVO2MxoL8NLu4l/werMGzTc7J6HKl
    oW26PHX0minpoGhnzcjxsARL2Y5Ye8mIepiAK2Ge9aLCCxVd8nEOBjIVLmQXNFy/ocE/20
    SAnAsg6aSSuTTXO/HsDM4Tx70j5qU5u7RxwFwowilYQdFE1g1vJ1AJIhdXvA
X-ME-Proxy: <xmx:npCRal02jCEWp3Z4OJgOZjiXifq1nbuP-gy5ppNry0i49yaDMur2Ng>
    <xmx:npCRaiErSd48j3Yz2tbXjDYQ2nwkaHAcu0j_y3NK5GtDSctxjMT-Og>
    <xmx:npCRagtsE1ZVh5GKn8iXhA4iJnc3VHJ8SCAZcXShO0xQtGqdEjR8pQ>
    <xmx:npCRalrz7P8K8YHxNEOAoLNyn89HY7rw1WJsRzIsqyBJ_4z8i_IBeA>
    <xmx:npCRanU7-cYcwaNar2UlRu4WX9EJUoFF9uuiksw3vfqY83DvDQkwW-JB>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 97B417811F0; Fri, 28 Aug 2026 09:43:58 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A0AurJh4UZM-
Date: Fri, 28 Aug 2026 09:43:41 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Prabhakar Pujeri" <prabhakar.pujeri@dell.com>,
 "Jeff Layton" <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Donald Hunter" <donald.hunter@gmail.com>,
 "Jakub Kicinski" <kuba@kernel.org>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <be88803f-4932-4b7c-8752-8a228bd67407@app.fastmail.com>
In-Reply-To: <20260828133351.923-1-prabhakar.pujeri@dell.com>
References: <cover.1787638668.git.prabhakar.pujeri@dell.com>
 <3fd25e2178458fbb44f57f1b0e068c12a6503d17.1787638668.git.prabhakar.pujeri@dell.com>
 <1046756851d9d7d688ac612a7f175e48745d2b84.camel@kernel.org>
 <20260827045139.4353-1-prabhakar.pujeri@dell.com>
 <1c53950d-66ba-490a-872f-b2318c584d3c@app.fastmail.com>
 <20260828133351.923-1-prabhakar.pujeri@dell.com>
Subject: Re: [PATCH v1 1/3] nfsd: report NFSv4 grace state through Netlink
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Aug 28, 2026, at 9:33 AM, Prabhakar Pujeri wrote:
> On Thu, 2026-08-27 at 09:06 -0400, Chuck Lever wrote:
>> I'd like any new API to avoid foreclosing the ability to move exports
>> in and out of grace individually.
>
> Thanks, that makes sense. A network-namespace-wide boolean would remain
> useful as an aggregate, but the current single attribute does not make
> its scope explicit enough for future per-export grace.
>
> I will avoid freezing that ABI in this reroll. I'll drop the
> grace-reporting patch from the client-visibility v2 and post the client
> dump and state-count patches separately.
>
> I'll follow up with a dedicated grace-status proposal whose records
> carry an explicit scope, so it can represent the server-wide state today
> and individual exports later. I also prefer to get agreement on the
> export identity before adding that part speculatively.
>
> Does that direction address your concern?

WFM!

-- 
Chuck Lever
