Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1FD1E285061
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 00:45:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790815527; cv=none; b=jzIbtG4gNL1ebo/HOMeYTTjQUaoeh9zp+5fxY7vGyFlaLzbGnQT7yhhrk7usiqGfYJN7SnyRH497NLp6lUnCbdY/gs7+m8ZpOhl3sp/2K+XlyGNqzjZ7As8TVVXzE0+VPSPCxKK0sO+EDPcuZNcEDD+ntxW7V0FFdlMD+gD+zys=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790815527; c=relaxed/simple;
	bh=nej9w2a4zKnNbUQLQPqw2odQFV+W0Ed+Uh9nS5WnVY4=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=IzjxSnmCZ8/tGOVb/zTGBAj7CKCWmrtNmsADINBW6v8X1leak6pUCGuwX2sJw1I2+6htEzGdIbGkgZmHec4CZucRo4P0itkmwpr6I5AUVUDQhOspTHvmfG4bs5QhFRmYxNru/uXGvEi162ZuaXk9VTxVqmPsvzccFqOFf42IaSU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XcAVzEMy; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XcAVzEMy"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7A4BF1F000FF;
	Thu,  1 Oct 2026 00:45:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790815525;
	bh=24Q7nkVG60uonnG/UCNJ/D7nGyuduhVHhhIliaofhjc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=XcAVzEMyCAyKP5iaGNZDRETzjE1/698ydUJBZwR4M61vM2ucaWBIv82UtAZzvEV/v
	 lUP/h+IP0K+TAClY3SntrO3jGWpvkMwv1YhHuOU5pvPyvO8omhgjmuXsQXhHEfXgRH
	 pl3nDNTW5MoU2x8d5nfholiZJu2Nq3y2IrE4XHHYmLXSu8XbhF0NjFBtDUkuotlLvl
	 qYlyLgz3wjT5EAH+CXTp1zttFcGszd7MjHj9//NFd9515YGOnjXvxb3Pu6PqtPy0i6
	 phiAM+KwDUYyfFnbsWOsU4k+Fr5RjhXN0a5/PRg/Y8At43IDVjp5+rfpQ14YooIuDi
	 W2yUnIGM48K3A==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 980BDF40066;
	Wed, 30 Sep 2026 20:45:24 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 30 Sep 2026 20:45:24 -0400
X-ME-Sender: <xms:JK29anr3GBpOsT5dfqVs0O7YCFAL2kmu-svD4NDKoQIBcOhSpAjl5A>
    <xme:JK29asfO_1aYQkrTSkFPKrJtYOT8_wEu4LoHvUchDcbJvFjLYu2-PkiepSkHsv7PF
    nUW1EAuPcUAilLbRkY_ts5naezWjH_48FolQjbJTLeWBeQTLf-35bRA>
X-ME-Proxy-Cause: dmFkZTEoBwJsao7+xiatbuChShC7gTfryUjShgm4e3rWNIH5iRdKrEgl7bVgZF+VtrBTda
    NyFFkIPqySFDDK6hQ7011si1ehYazu753eHPwYqPSJezFw0sjP6AEo5s61WcYBGWBang3B
    vJ/9NERCZdMgppfBb3BOy0JEbEbw169Uxy3HiZKoCZUzZN8soBBhxdrGjB1o7EaJyBCmBv
    bfP2bIhf5LbZ1s3FtsODZqILQNntuH2SoHfHUZ0YTn7A+YfA6nlnqHQ6QcHnS3MbFvaE6c
    7iYd1bfPsgbYvTpNDONJNMbvbcCSIt9ppMc2JszI3e5yT9zZd6FtEpJgOqu2vkHoN+BTG/
    5rtHoE3AJRBPdHgEahZrBGqJjKcis+Ro3wO6gTTaDeIbGGSJ8Hfavq2lHCZyGZPxnYSnZa
    mNQ5lkMb7rfJzghOyciZa/mzV6s6fYmXponld9VMitk/Znr0MAEQzpLQGt7r9HVc2yyVzg
    38c5bHNjGdDUPzlmqk3EXsjurHIJhHQglHS3EQjPQvBbWihJiQp4fgy44kWkcl78yNqYYW
    84LL/1cF58yLKPtgiFZ0PU7Z23Uc6TiAHtdKGUZzoJrUSv4J4Ua9uecDZ5wepqXu70LRNR
    3eSscITHGXwyYZb9eqXxrnkgBcDO15Kn4QtML/FiEtCyMMsOuFcdJGUjLyeg
X-ME-Proxy: <xmx:JK29asnjDGHBpMMH_Z9cvZo8nlffAf39eKzlOmA8D6XY-syRdbNLUQ>
    <xmx:JK29agxI_D8Awj3vVcmTRg_0M07rQxWNkjHis2cLjvgoAo2gPuKvSA>
    <xmx:JK29au6ktTsrTF6d-9QofUN38CWhwv5p5tiDge43Zjz0YtRjE8rSCg>
    <xmx:JK29aoXDjh_XnZJcE2C6BR8nwwD2Dud129uByOHy3-kFGb0zZwQl7Q>
    <xmx:JK29auK5FRFoSwtxjH7_mGkzhuTvnVXI72pf1zMmCssxpS3NWnAHRc2H>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 7E528780075; Wed, 30 Sep 2026 20:45:24 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AfxYUlV62NL-
Date: Wed, 30 Sep 2026 17:45:04 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Jinpyo Lee" <bint4b13@gmail.com>
Cc: linux-nfs@vger.kernel.org, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Willy Tarreau" <w@1wt.eu>, bobtobabz@gmail.com
Message-Id: <cccac395-a71a-4fb0-a91b-737d76216777@slotpi15m67>
In-Reply-To: <20260930055235.135503-1-bint4b13@gmail.com>
References: <20260930055235.135503-1-bint4b13@gmail.com>
Subject: Re: [PATCH v2] nfsd: hash only the supplied client-owner bytes
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Jinpyo -

On Wed, Sep 30, 2026 at 02:52:35PM +0900, Jinpyo Lee wrote:
> Pass name.len to opaque_hashval() so hashing is bounded by the length
> validated by the XDR decoder.

Thanks for the report and the patch. Boyan Liu posted the same
one-line change to clientstr_hashval() on September 27:

https://lore.kernel.org/linux-nfs/20260927142319.12054-1-yymhvert@gmail.com/

I have already applied that patch to my private testing tree, so this
one is not needed.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
