Received: from fout-b5-smtp.messagingengine.com (fout-b5-smtp.messagingengine.com [202.12.124.148])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 840E93FA5D0
	for <linux-nfs@vger.kernel.org>; Thu,  4 Jun 2026 21:16:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.148
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780607817; cv=none; b=qFj0Wia5NqgqS2fv93fjtYdhjR5DuJq0x286pH7OEI3DXMJeQBczOqifPqtbFcufWJTV/sYvLb/rTe5gQvHsXbhsSg5WFVa5S93V4Vgm9lyyloezDwSascicg8kgjlfZPQu1CCKssj15ENTh0ZmWX4iNczjbJd2Eo7yvIYoT6kE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780607817; c=relaxed/simple;
	bh=poumDmcUCYdA+A+95Q0LO+exqs189n+2/gtJf2v+q6E=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=pYdtqEaue0WzihzjDHamVTG+B/B2yDmAwXQvn/jsZ9X7egNuyL+Kk4rKr5QWpNTOYN7NYHmZJpNy8fNxNojEfiyugFQHqECqH02CihpvqnGv0g8jsfAsern6dPLq7rKI2b3YLlQyjNib9rGId3yi6vAJnv76/uheIWW8KwJMbGI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=GyAgYyrF; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=cBh7yFku; arc=none smtp.client-ip=202.12.124.148
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="GyAgYyrF";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="cBh7yFku"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id CB2261D0004B;
	Thu,  4 Jun 2026 17:16:54 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Thu, 04 Jun 2026 17:16:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1780607814; x=1780694214; bh=r14mHmu33pByi91DTedwvCPbDQdIap1m1Qu
	WBOU7JHc=; b=GyAgYyrFG9OLNt+acD0oXtAWLzZdDjlUhyMidhJeJLii+i1V24V
	PPR98i9pYdjOK5Ulp9YgDfBUc+JgdFEXP/Vj//K9vC+yudxZBC9Ohmd2CWeQPdHB
	e/JO4iZRCFhtNDo5Mx1v00bM8s/U4VFqnfcR9JmhXt7SjlwWpBVWJHJrp2eK41cv
	+TouJSQfRmpIAC9uia/dbrEDkfozLBDlGxxZkpw6W4KIlOl21C7cV+0bmUYzTlf1
	XYwF0SkUF3iuqTvPVrU3JYtESmQVREHGwGbefboXQ4tegcFdKWeB5z0ykwy2r/7P
	+K2KCXxeaOIDwI2xgywllrjxzlwPp/CZNwg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1780607814; x=
	1780694214; bh=r14mHmu33pByi91DTedwvCPbDQdIap1m1QuWBOU7JHc=; b=c
	Bh7yFkuFJlBSX2A8gC8yT+wgMsNmHQGC0ciVd8xIQmk3+xWauWR2wrKOOroSfEvh
	yO7UU/ehcDM6LlklxsdtTf8qD14wygjUtfPXWKlvanWSXPx3aeS32NqqrEPtb/oz
	ZtAmHB3GzN3ZK4+iOa47htOyPJQusYgmbSScUF8rUi7XVW8eCepWXYAMroxgFKbi
	UWVUI50oWTNIJveWxYgQt53xu4Q27lbzqHJaCi90xR2ePt+tl6cKNIBl+pQJdESr
	9BpqYK0o1uCREMVQFni9CA5QDVnbE7z9oIodRNlHqPsDDlAcA5qP2KcVRQudNVdJ
	+o72ZgFLcEzHL/I0/goBw==
X-ME-Sender: <xms:RushagfX_SwmCesAF2WEbfAQ2UfBnIHd3i1QvtKuFYPN-ToHTMmFYw>
    <xme:RushapOY5-Zh5AiOvPO88kQJm8pJGJSltMClsEcnk8z6s1Z4fFSzEmi2HOmxRtteH
    SJA_w4ofj_mwZ_WIFg7G9Q3drh6E_E0ZHQJQSbBiFcTRcnaUg>
X-ME-Received: <xmr:RushamgWHvOVvoBg8CG1S0UwUQYscMDoZjxhj1Zb2Jr0dF9hqjlO0yKqoJ3m0z77KR1SOJbbN5rb6Othy9FgSC7uFbwmhZg>
X-ME-Proxy-Cause: dmFkZTF4PzAbgWjU4mgZ7VcNn8M4jUBgNcbeYYSxcSEZNkmugTksQukEJYW/Ixw0IruatR
    DV/bElnpqtD/18/iokf1bsTB4x6zuoKrBi4N4Tav4jgus4Grn9WqTzNrogkGmo1MahEPXW
    39qnzRxEJPr9ZAQO5DQNLan9H55XMQ7pbC7NGdMNdDySRSfv8Fr2dOE0kDSYFeQ0lO8/P8
    svWGx9enKy7/uXlDVE+NP5pUu8NXxrq7zk9d2v+w0KNvt+6Oaijo1TI1dj/au6zAYYz3Ff
    y1wHaSNsGsONZIcce5Yit5kCW1t1004Pg+oPdGLJaxRJWyxww1Llr66gv9WMQIHn4qntPD
    Q9i8zakbirhKoj9VU9eImZuAJLrNttBt9ZZuPXMFfOqF1sSxIXoWWwhobr4bbXLBrvOOQn
    RoCugmlU3d+S3PRQuOfqZGpm8Y/rHLeDm8GJbnfb3exVrsoYaMqsy1hn+Hv2TOVUIt1Pqh
    xc6ErvKZWeQSe6LrVzlAQIBmLlEalS6mhP2wPeodc9gKpE6jMDk/9vpDALKdC02z5kFJk3
    ljIBOBz6HqwiowgKeN3CFypOis6REWZFjQU6IEwH9ie19oDQZXQnjLQeayx++7qAQAS66D
    Vbx/zVCsSeuhHyClIaWoQKbQaNZKXIvG9aRb5Gjd1VdOHcupe/FoAieGfJCg
X-ME-Proxy: <xmx:Rushak0I8TxY_1ODF9cD07zrm0Uj2tuQ9qkmT96T76gE_QzYaxfF2A>
    <xmx:RushaojsUprxyx8B59AazCzHsrgIsnXq_KJu2MJJ-SuV_UZUUV7UZw>
    <xmx:Rushasczx4FNZ7drGayErW05qHwVEZ4yLLNsd0q93T26u-ZrOcUfXQ>
    <xmx:RushajnptA_TE0_vdVKzp4ytJUJNSWJQVoL54SkzL73G4uNCReD-eA>
    <xmx:RushajcIBk0Tq0i5w34qU7OtBxcvDiq2X3v25cWHyMJur-UoGu8wZHTV>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 4 Jun 2026 17:16:52 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>
Cc: "Chuck Lever" <cel@kernel.org>,
 "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [RFC] knfsd: per-client fair scheduling to prevent single-client
 starvation
In-reply-to: <20555E8B-0E49-4328-8B31-0F73C3D286FE@hammerspace.com>
References: <D33770A1-9098-4F1A-93EF-590E6C0B7638@hammerspace.com>
  <473e337b-fabc-4884-a6c4-0f04b6874d0b@app.fastmail.com>
  <3AB7EB6A-B207-4B91-A695-66C4704D0E31@hammerspace.com>
  <4c5dbb98-0209-4572-8eac-1578536bbd78@app.fastmail.com>
  <AED22AED-E97D-40E3-9839-BF8307EF8B65@hammerspace.com>
  <1a5c70d8-e7f4-4671-a29a-023be7c107fc@app.fastmail.com>
  <178044079821.2082204.6117918610145832039@noble.neil.brown.name>
  <561e9ac6-348f-4d6d-b896-38dbe5ede3bc@app.fastmail.com>
  <20555E8B-0E49-4328-8B31-0F73C3D286FE@hammerspace.com>
Date: Fri, 05 Jun 2026 07:16:49 +1000
Message-id: <178060780940.3392745.3574880233025675236@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 03 Jun 2026, Benjamin Coddington wrote:
> On 2 Jun 2026, at 23:44, Chuck Lever wrote:
> 
> > On Tue, Jun 2, 2026, at 3:53 PM, NeilBrown wrote:
> 
> >> Idle clients will get pushed back to 1 slot, active client will tend
> >> towards a "fair" share based on how comparatively busy they are.
> >>
> >> This wouldn't help for v3 of course but I don't think we need these
> >> advanced features for v3.
> >
> > Ben’s employer might disagree with that :-)
> 
> Yes - v3 is pretty important to us here.

Can you remind me why v3 is important for you?  Is it the lower
state-management overhead, or something else?
Is there some way would could improve the v4 implementation or protocol
to make it comparable to v3 for your use case?

Thanks,
NeilBrown
