Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 412FC352013
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 13:48:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784728141; cv=none; b=NJ1J4qpAchtgpNfM4MZGlO5ZiH86Z2kuT9/4xRSUlJfm2ikLgx58M1+X84LzlpmTC6bmgQ/+QOCbd2vMe3PdB2pKr2KWrfXCzQ3OGTWKrlNJ6+I+Mw28OeAhLXNklsA3To8HY+2vAwOOsdlnTrAttIa+/3a9lOBseKHxIURK1xw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784728141; c=relaxed/simple;
	bh=72aZ42nCrNBR8HBYkCKS3M0upwuiievg7V8XTKDpxKw=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=GTVOqrYCC7UKzffXRje1kb/AjPT6KiG1Gvo68e4Bpl0ksCmj50ATtVEQo2oRQ3BnbiLZLvC9K8du63SdQ0EDI8JAsYHNomkTdgoOsdmMu0jUw7ZTX4CE2dg5Y/bnqXR0aUkOQVVUshEbphoHi30NogXqvNlk7jjLLLJMrrbAmOc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TkCDidmz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TkCDidmz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A1F671F01558;
	Wed, 22 Jul 2026 13:48:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784728138;
	bh=wjg2W6eO66GseJ/is+z4AClw1tXHM1Wd634LdHOzhlc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=TkCDidmzTj8zYvYjfc32ytUuh7sbJOVcSd1t8hPZQumpOFdaTfqA13quIrvMQ+16c
	 pIL0Yc+CbbsFwt6IJM0eKWJoINU3SToZFxxV8RFIhxVbSPogWuxswd8WdQleE2t4Hc
	 yGv09wBig/TW+1hYc+1tcuEfi8MJZXDuLHSPQ5def1XGyXDj+vC1hVDK/4q9PcQ8rj
	 Wk4rUFLMWY9UR9bBm4tIMblJIAe/LC3sWqtVpGImSWsDEO6HCkeGtBodnovmZy801K
	 /LWA+1AUnawVaZyxGc/0CLQ1uRBAhkGGXJ1QWj26OkMTrq+0WMNdDLvkFabw2qNAMB
	 ZuryqE4t7E7ag==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 9EF85F4007C;
	Wed, 22 Jul 2026 09:48:57 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 22 Jul 2026 09:48:57 -0400
X-ME-Sender: <xms:ScpgaqJY9zhJs9SXO6gH0hGognHXmU50XLgrZI5QBing0Tlj0zj2Kg>
    <xme:Scpgas8c2YdGnyapWqnVHcSh4l9k9AJY8LN002hy6zaJRQyZkp-2mwfGbIPkHqKR4
    Qh1BLKchuvAq2r_30-EoNs66oGkyf0BSYSO7-qVfKrsGEo176t0MoE>
X-ME-Proxy-Cause: dmFkZTGC94Q8EPBhYiR7MMTYOusgRuT21HG/j/oSAnhV3QTHrC+wP+X4J00oDu3FoGe6ZU
    KcFavrzTPJCrHY+1+VOrUaB/WiMMSPR6Yndq3T+UOIwjDAd6fLYUJQKJNAu6BJVX7BuhzR
    VLCcg/i+20rxwlT7Q6EU/yyLm4hBZC7Nm90axeLcnLMG5FxL5OUdJo0rfoLPuY+q+cQ6gz
    2NpXE9CvDO0H7iLtYYAE6TNz5aMAa5PeymlQmcdtsoAY97FBgOaMoJav6bZvJm3JoTicuK
    hEwX3BIM/KGNlsUxpi2DZb1qZMN1Yylhus2ralHA4wXtjT2bzWX6xsI2ACV1l0EO35XIMG
    bJO/Cg2Ewt95rWuLysyix0xX+Y/VxPGf4U1/beWiPkAahslC1ZcKyuC6/dz7y/bb1/NYFZ
    xjgEzN2Pcf8WLYtC0EX9giE7BsZcvGk4iYSuQafmVN/rFIffnC5VFrNdvui3PQlG2wivuG
    Qjew4LStntaiZmyIL7n9200tm3fAGY0UB8vD7BdAN029EsaFdLuDHCs+tjxenJOXY0d9T/
    AeSSuIjahJEM8+r/0xfyxitPJGRGk0R3LGh8eXKI1/UJZUdlpBe0qQ4aErbV60Ws3sAtBi
    pKxLtlJD1om+K5vyjDsIl4MoVGyl4+JnXbOmf15+X+8x/zKvmcCWYOdGC8HA
X-ME-Proxy: <xmx:Scpgapar1D_HMDwTAGVNjhSRp0JuyJoOBQZL5uHr1HeiISRG-4Dn_g>
    <xmx:Scpgag2Jn5OHjPRn2Mk7nkKXgH_IR2LDvTfZyY1MWFzFIuxaQ9HKkA>
    <xmx:ScpgasoEEpdHuh0RK0bNZibTsJpl_9VDLSy_Kp1VkUC1Wun9VglaIg>
    <xmx:ScpgavNs_ZDM3VyxIrUUXIZKfhCT37Nz0qPQ7yFb18w6pw5I33uX2g>
    <xmx:Scpgalrucwn1eL9DSCEL7KIbQh1ufCBIZ_MBvECQXRxwEUHGJ9MK9Z84>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 7D944780070; Wed, 22 Jul 2026 09:48:57 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A6eHHh02FZ7o
Date: Wed, 22 Jul 2026 09:48:36 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Thorsten Leemhuis" <regressions@leemhuis.info>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, "Wolfgang Walter" <linux@stwm.de>,
 "Linux kernel regressions list" <regressions@lists.linux.dev>
Message-Id: <255376e5-9fba-4da1-ae0b-2b116ebf6fcb@app.fastmail.com>
In-Reply-To: <0a0a98af-2004-4926-a7d8-1a0acb78df5a@leemhuis.info>
References: <20260709-cel-v4-0-1d519d9be0cb@kernel.org>
 <20260709-cel-v4-1-1d519d9be0cb@kernel.org>
 <0a0a98af-2004-4926-a7d8-1a0acb78df5a@leemhuis.info>
Subject: Re: [PATCH v4 1/9] NFSD: Prevent lock owner use-after-free during client
 teardown
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Wed, Jul 22, 2026, at 6:24 AM, Thorsten Leemhuis wrote:
> On 7/9/26 19:40, Chuck Lever wrote:
>> __destroy_client() releases a client's open owners, but a lock owner
>> whose only reference is a blocked lock (nbl) stays on
>> cl_ownerstr_hashtbl.  client_has_state() does not count a bare owner,
>> so DESTROY_CLIENTID can reach __destroy_client() with such owners
>> present.
>>
>> [...]
>>
>> Reported-by: Wolfgang Walter <linux@stwm.de>
>> Closes: https://lore.kernel.org/linux-nfs/6eccafaaaa60651ef091257c3439c46b@stwm.de/
>> Fixes: 68ef3bc31664 ("nfsd: remove blocked locks on client teardown")
>
> What's the plan to merge this change? From the outside it looks like a
> fix for a user reported regression from this merge window, as Wolfgang
> afaics blamed commit 516403d4d85607 ("Revert "NFSD: Defer sub-object
> cleanup in export put callbacks""), which also made it to various stable
> trees.
>
> So shouldn't this change ideally be on it's way to Linus by now? Ideally
> with a stable tag to ensure quick backporting? Or is it not a good idea
> to have this in without the follow-up patches from this series?
>
> Or did I get something totally wrong (which is easily possible from my
> external point)?

Thorsten, thanks for your attention to this issue.

Here is the plan of record:

This commit is currently in nfsd-testing:

https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git/commit/?h=nfsd-testing&id=3055ac7c996369876342aa22a33bcc68cd4abca1

It will matriculate to nfsd-next in a week or so and then be
sent to Linus in the initial nfsd-7.3 pull request.

A stable tag is on this commit, so it will get picked up by
stable automation as soon as Linus merges it. That will
include 7.2.y, which will still be open at that point.

Notes:

The Fixes tag refers to a commit in v4.16. That makes it
technically a fix for a bug that was introduced not in the
most recent merge window.

My general policy is to subject fixes to the same review
and CI that is mandated for any other change regardless
of urgency, since historically getting such fixes in
quickly has been the source of defects in released
kernels.

Both CI and review latency are subject to forces outside
of my control so I leave a lengthy window for both.


-- 
Chuck Lever
