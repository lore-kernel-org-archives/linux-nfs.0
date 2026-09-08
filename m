Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE771559CAE;
	Tue,  8 Sep 2026 17:48:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788889718; cv=none; b=CIFiODo1sMc+dqXYBQ6uK/BoErkWnQUTiaSi7UpHE1T5yqfcT/lMunQ70RKRqdMza5PW7GVj+LikP9KzaVwtoYhPz+9A/ahTtNcQqe/1Dx325Tk1+R+YfV1Ovi19pqoUSFn5crQYNJtzjuz3kgIJhb3etXubnbALpZYTrQIdRkc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788889718; c=relaxed/simple;
	bh=wvBPNj9OterCwkimblQPBinr1PHnmb/ajP5hbeoLV6w=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Y6M6RnjgAUbplAuCRYayUm7m36hvXToilJ6De53Cbc8rnAPHhsQ9kpWYwkU3bHyPQWejOIOIJVzbID67FYChHlVEjDNx1JW6ytgxWCshI7Z+9z6GgPxii0RBnqX9Hu3ctYFUHkqP5qEnjBApNszbar7rxobPP55NBZw1qUTnNU4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nD49gsmd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nD49gsmd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E2461F00A3E;
	Tue,  8 Sep 2026 17:48:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788889716;
	bh=suVYu0flawAIGb6LTxk0rYk4yMRfiEp4g6OhEqLdxBA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=nD49gsmdPUiBpueZMeHvAWUU+/7psO6FR0bRYAE+3uCAMGZ/58dNuFXNXSXwK44ag
	 hGk9Pg+m9rI7LuGpHK4dgYjGZbnCLPF8hidc3jxCDjy05FiWjzygQeda6bvoSA1Jfo
	 rUz1/aBLr01R8mfrD/8EG1JUeH/8Ij+Yczfn+dywHq/EG3U5eRyogucPX6rqExwUaz
	 +gd/mJvL5fBsVoQMsQPA07rMrPZbPpIC3mJ7sVdPeYTbESlM+hw6M846FahX1nEndK
	 l8O//MDYd9QEhY0ZzyV0CTv1mUdRO5Q5GGzTEWR+ZRL5owaMVVfQcD7tPR0ovAAAau
	 iTBBgWCPSEkRg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 502E0F40066;
	Tue,  8 Sep 2026 13:48:35 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 08 Sep 2026 13:48:35 -0400
X-ME-Sender: <xms:c0qgarDebhbBbGL4UsXY9HML7nR3LoAaFIZQDr6bdIqzJKvepbisWg>
    <xme:c0qgasXEFe_e_E7kE7ZXOHJjIzlGekLaHeOt-szGx_HJsSHjFW4USBtrd0A9p-NOI
    sPFjUZ0abtZy5bMwOrTxBQDq2vRpo3CpkPGEyAxMhR2mdwjSQ7nCkFf>
X-ME-Proxy-Cause: dmFkZTE2m1p/MuFhJCNmrVU1fEI66CkfUtA6WoSQ9U7djLADntYMaDfdVNN7eKo3JhTVDj
    lfdaeJCl3uYaeMGzsVnYmwRanTfM+mPqQ+PAFr48E9zdm3GeQtDpphzQYvixBPao+gHWeM
    AqyjvNikaYMbPEkqf2OLL0WmOQVVQAGcPleZZH6+FDOO6uBVXzj757ThH0qNhV2SuQrZkR
    NI4IcZFegMlGOl1HexxublDOX3KDe8fCH4ENOmqO0ZGel7DQI0J2v/ISUE2kpE1rSN4kNY
    PqdJsWCq/nS5ZFFw0ZQAoD3p9+QKdlqnVM/QSNJRaZiKAGg+ACwU+Z3w6lN+GxN1tFHZUt
    YS5dIQdQodcecgfCyFTC+dNpC7b5skyxX2kzjssT3mXjN48TkKJ+zaCfpXUwR5NF9dRFRd
    5n8z4m3EqMxHrUoIHSaDNIlxUee5IgXXDomydPGwMky6q2JK+RFL9zpaJAGPgXDWS0+Uuh
    XtvAUb0VFGdQcppr7xHKIlLZ+rbguP1ghsiABKw+iTG8M05qXH3E+UE5DZ/M1hBI8XDLRi
    pWUiE11iSBrRAZB5Kd9nAWPtY79wa0Bz0BuJpv0YoCdu4OSkAqORdAgnQRHVBuqMKZ4E3v
    0VafajjsPIcQnZh4NhmI4mp3GDud+xP0MnSikGPQEqoYoaYBLO6GA8o0nVAA
X-ME-Proxy: <xmx:c0qgalHvG4iohYf5xttosP35IJkWOxcbu9PBmSKQZuMTmthF5X4Xqw>
    <xmx:c0qgapam_He0vB--RjNFVEta-6J5z7UUz698HsVS1_x7FlK4sq4NrQ>
    <xmx:c0qgatVvEk5XKGdvz_gZ8OcDxZhVBkTl9_jK-HOqvt4zJSCEu-0Aew>
    <xmx:c0qgankZmBGND1CMlEDVDhP0RK28xCkZ7TQHRUgCFCCBB3h57bCt0g>
    <xmx:c0qgagAdcLavyLCALcwu0sYIApkBubEIgwOAoYuSxYvUeEKIj6q4ciT1>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 2DC5C7811F4; Tue,  8 Sep 2026 13:48:35 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AVDdeL5Kf7nV
Date: Tue, 08 Sep 2026 13:48:14 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>, linux-nfs@vger.kernel.org,
 "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>
Cc: dm-devel@lists.linux.dev, "Jens Axboe" <axboe@kernel.dk>,
 "Jeff Layton" <jlayton@kernel.org>, david.flynn@hammerspace.com
Message-Id: <f6a9430a-93b2-445b-9cb3-a6a41ae5445e@app.fastmail.com>
In-Reply-To: <aqA5qgfUTbNi0nHJ@kernel.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org> <aqA5qgfUTbNi0nHJ@kernel.org>
Subject: Re: [PATCH 0/4] block, nfsd: fixes for sub-sector bvec direct I/O
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Sep 8, 2026, at 12:36 PM, Mike Snitzer wrote:
> Apologies for the git-send-email misfire.. still not sure what
> happened, but will sort it out for future.

3/4 looks sensible, and can go in now. 4/4 might need some
adjustment. Assuming, of course, there is no functional or
mechanical dependency on having 1/2 and 2/2 in the tree
first.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
