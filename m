Received: from flow-a5-smtp.messagingengine.com (flow-a5-smtp.messagingengine.com [103.168.172.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FFD41FF7B3;
	Fri,  6 Mar 2026 21:16:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772831785; cv=none; b=j5N1aU1JXZGRI10hRE+xSfpQ1Sd7LIJ5F4kE5l7bmYzxUhfLLbD4Wkg8AndmeL1MpCKrD3Z6ZqEYs1/CTP10KLnq9/c2HXm8ZuG4HgLf9031mpwT9yIvnpzHRzh+NzAc5RvK7b4wnB+r5C3FGgH1tTC5Ul7L7zaNscZSTQewmKE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772831785; c=relaxed/simple;
	bh=p8V4FHrQC4m8637OVnfjLNcJnocBX1xyNi6aeXzGHlI=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=sM29lII4JGX1mG/QMSmSxvHcldmdHqc/7PTXsUWFQrBqKjeJ01phGpw7Hrt/UBK5Rm9oymWoni+oNCUpo63ITZ1YEqKeKgjmrMD62HuidL1P+3OY6fspP3TmbpRrfYFt38LppgjCWer/vBQXiHcKYc9HfD+WLRI6qTvTJz5qroc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=UVAQhacP; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Vy0WAoWA; arc=none smtp.client-ip=103.168.172.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="UVAQhacP";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Vy0WAoWA"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailflow.phl.internal (Postfix) with ESMTP id 7C033138098B;
	Fri,  6 Mar 2026 16:16:23 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Fri, 06 Mar 2026 16:16:23 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1772831783; x=1772838983; bh=Ab8MrdB2xn5ObAHYuc8S2EbzsQbqvnFcs2E
	SbOGqQKc=; b=UVAQhacPc5XIYM9fEieLMrbbP4mz7xOBtKxVB+jA3mYd94wd+dF
	jEXzQY3ONA0MGR3X5WwGY4b7q3XwxeFX3wq2coJUKuMI96TEIRRqFJ+/qNdjDNWv
	Gd5FHc2PbfPSrd9O+gW0JjxQfKgvbV98ORq6w0G9LV4Wz418LzdeNcly0jWOCgqw
	DJh1DbmjKcx/mEMpsLNvubkQonu2mWGxmt2mgSnuAgo9fz2MXyLLO/W6MXEP0/at
	ESNsMh7IlfoSXol1+A5Ex7PhnyysuWIqn1IOSLvDFQwWeCeRU3haz3CvAr9+ifa0
	23GiQZwCsMsd8eZnEJQjDWRuPrUvZsAxEyg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1772831783; x=
	1772838983; bh=Ab8MrdB2xn5ObAHYuc8S2EbzsQbqvnFcs2ESbOGqQKc=; b=V
	y0WAoWAK7T67vqma/jdF1OOgiymtNP7nJANg1VtrdE5A9t5fjGaHY1G5WZWPw9LC
	UiAKagfYVdA4frDZhs56+nrazJiwuxj32lU8pX1X9X8raFvHJcQA7VqpX9L1pPph
	NOk+XxSIeFJoj45+mUB9k4hl0A8dUFhMCEQpyvoNqSMl9wvELeh4PROXQ4y1vYP9
	t1sB23ze6OXSU0MomtZcUvcbNSAvI4nnZPa1UJNUBS+lc/dIJpOw9jUyJfLvHm9t
	TigJFbwN5k6U8BlRsbrrI7VJetauC4ewDNo/1G+5NqaJHVPNM4jcFUnnhMbeWtpM
	vSfsxGoaLrqC+Bk1bDwLA==
X-ME-Sender: <xms:JkSrafQhLITjPiq0amdhmpkUbxlxXCSbJ5MOMQyZYLD3hDiEgFk-Wg>
    <xme:JkSraUv0ZaCvsdoVLliqEx6OVARx3ampkfHw1dOYOSfQlp_cM2YYaswN8z9nHJG-6
    -wfvgocjC0P4YJaX0MLF8jyeqJjMQwnCjlNrvVA8VWKA0BF6g>
X-ME-Received: <xmr:JkSradWlxWyX1LDdEVNr_gqJIbQypMFQscxHyziJ5Y-602V3lU_PrZTKVRqTO72vRywD61jqdDZ4QyBqx02GFPQKvWWviVoq1djZkcQ1hR-A>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvjedtfeehucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurheptgfgggfhvfevufgjfhffkfhrsehtjeertddttdejnecuhfhrohhmpefpvghilheu
    rhhofihnuceonhgvihhlsgesohifnhhmrghilhdrnhgvtheqnecuggftrfgrthhtvghrnh
    epudetfefhudevhedvfeeufedvffekveekgfdtfefggfekheejgefhteeihffggfelnecu
    vehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehmrghilhhfrhhomhepnhgvihhlsg
    esohifnhhmrghilhdrnhgvthdpnhgspghrtghpthhtohepvddvpdhmohguvgepshhmthhp
    ohhuthdprhgtphhtthhopehvihhrohesiigvnhhivhdrlhhinhhugidrohhrghdruhhkpd
    hrtghpthhtohepshgvlhhinhhugiesvhhgvghrrdhkvghrnhgvlhdrohhrghdprhgtphht
    thhopehlihhnuhigqdhunhhiohhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhgpdhrtg
    hpthhtoheplhhinhhugidqshgvtghurhhithihqdhmohguuhhlvgesvhhgvghrrdhkvghr
    nhgvlhdrohhrghdprhgtphhtthhopehlihhnuhigqdhnfhhssehvghgvrhdrkhgvrhhnvg
    hlrdhorhhgpdhrtghpthhtoheplhhinhhugidqkhgvrhhnvghlsehvghgvrhdrkhgvrhhn
    vghlrdhorhhgpdhrtghpthhtoheplhhinhhugidqfhhsuggvvhgvlhesvhhgvghrrdhkvg
    hrnhgvlhdrohhrghdprhgtphhtthhopehmihhklhhoshesshiivghrvgguihdrhhhupdhr
    tghpthhtohepjhgrtghksehsuhhsvgdrtgii
X-ME-Proxy: <xmx:JkSraYkKXev7nWHoUUKReSkmUFpmphxn6OD05b8LjrKgcrxUQ9_7JQ>
    <xmx:JkSraQDlKCGfhubivZyvPvLT40RSy0qS6U3eQy-tWOT86jED3JoiVQ>
    <xmx:JkSrad-ScPeN4sl-OA9v-z2Mxc4yIE6WEbDzhlshfakRoInVDU8fkQ>
    <xmx:JkSraSQJaJb6gkiuPjPftwxA1nSbRkeSmCnEylob_GFzeruPj3JPVA>
    <xmx:J0SraZprheB4umpetfSLW72QN1aB3Al_WZnhyU5Cvq7SVszou5SM_T0h>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 6 Mar 2026 16:16:16 -0500 (EST)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Christian Brauner" <brauner@kernel.org>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "David Howells" <dhowells@redhat.com>, "Jan Kara" <jack@suse.cz>,
 "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton" <jlayton@kernel.org>,
 "Miklos Szeredi" <miklos@szeredi.hu>, "Amir Goldstein" <amir73il@gmail.com>,
 "John Johansen" <john.johansen@canonical.com>,
 "Paul Moore" <paul@paul-moore.com>, "James Morris" <jmorris@namei.org>,
 "Serge E. Hallyn" <serge@hallyn.com>,
 "Stephen Smalley" <stephen.smalley.work@gmail.com>,
 "Darrick J. Wong" <djwong@kernel.org>, linux-kernel@vger.kernel.org,
 netfs@lists.linux.dev, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-unionfs@vger.kernel.org,
 apparmor@lists.ubuntu.com, linux-security-module@vger.kernel.org,
 selinux@vger.kernel.org
Subject:
 Re: [PATCH v3 00/15] Further centralising of directory locking for name ops.
In-reply-to: <20260306-wildfremd-wildfremd-43848a9e91cd@brauner>
References: <20260224222542.3458677-1-neilb@ownmail.net>,
 <177267387855.7472.13497219877141601891@noble.neil.brown.name>,
 <20260306-wildfremd-wildfremd-43848a9e91cd@brauner>
Date: Sat, 07 Mar 2026 08:16:14 +1100
Message-id: <177283177498.7472.3648884661239054468@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 06 Mar 2026, Christian Brauner wrote:
> On Thu, Mar 05, 2026 at 12:24:38PM +1100, NeilBrown wrote:
> > 
> > Hi Christian,
> >  do you have thoughts about this series?  Any idea when you might have
> >  time to review and (hopefully) apply them?
> 
> Sorry, for the delay I picked it up but have two minor comments.
> 

Thanks!  I'll take a little while to examine the cachefiles code.
Thanks for the thorough review!

NeilBrown
