Received: from ewsoutbound.kpnmail.nl (ewsoutbound.kpnmail.nl [195.121.94.185])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A17453FAE11
	for <linux-nfs@vger.kernel.org>; Tue, 26 May 2026 13:43:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.121.94.185
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779803007; cv=none; b=ZsdNNq/EtexQg6SZqn7uaWRrIXjGbOXP+PGRQGG/pKXcZmfxayLnsHL1s7rPIRDn0Zl2Ow1+y36csjMKLlUiCQYDs26W/EPstw1jqA/Vxi/EQsgjolpoJ8xirUKE9Kl9MJxSn3YbFQTKnPVEnOgGYgjOwN1oSq60UanQBOZX0nM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779803007; c=relaxed/simple;
	bh=8j4J6xvlAhpVrOG+E4BYywLjoOctEvwdCxpFwaPq8+U=;
	h=Date:From:To:Cc:Message-ID:In-Reply-To:References:Subject:
	 MIME-Version:Content-Type; b=IwnQXU69xBWHxIZSuIsoxBnadMEiGPPgCkU9XMp0Tlc/BSsjPN4L65jBWQUKQzBW7cDbf/NqCpQzoleSOl10HfzwKmOr/POVX0bXY7F2vfV4wpaI9fFcngRbGJa0iBsu98xQw+hNTxJhLkqZPzuXQma78mSPzAbzVC8849HKioc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl; spf=pass smtp.mailfrom=xs4all.nl; dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b=buOleBEt; arc=none smtp.client-ip=195.121.94.185
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b="buOleBEt"
X-KPN-MessageId: dca9501c-5908-11f1-8ff5-005056999439
Received: from mta.kpnmail.nl (unknown [10.31.161.189])
	by ewsoutbound.so.kpn.org (Halon) with ESMTPS
	id dca9501c-5908-11f1-8ff5-005056999439;
	Tue, 26 May 2026 15:43:22 +0200 (CEST)
Received: from mtaoutbound.kpnmail.nl (unknown [10.128.135.190])
	by mta.kpnmail.nl (Halon) with ESMTP
	id dcaae02b-5908-11f1-b5d4-0050569981f5;
	Tue, 26 May 2026 15:43:22 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=xs4all.nl; s=xs4all01;
	h=content-type:mime-version:subject:message-id:to:from:date;
	bh=GvpQVK7RatjG4ryuyEnD73CiD8zHOCrC5D5YhywbG9Q=;
	b=buOleBEthf4vUocsd3ghJ7p2om8pt+5/ioBhmuRYG1WUmpKHiNrobstVttxThEtQaRFvbHgIpBuU0
	 EZveXP/Xn0w8JkxXTcXtk4ZFqazRkDiPd1USA8+XNIizO1knDHXUbr02J8A6s6Tczk+Im185SLcGUW
	 meT4MlIInjwDiDhSYskLFVcNGVag2WQQ8NkscAoH6aksZkZ7de2MAUdNXCWAa2VngEdsQ1AN1GnWCq
	 8gd3WW1nZHMJ2crrjiwaXtil6a4KdyDFk7zIrGDfFcnD6iVZ12uAGGF+aSIb3wNaAzMb2nlDdIPh8t
	 J7hLE5pGiwipo5ffPmmj0TDdZVs844Q==
X-KPN-MID: 33|dqhfT8jeRlQzBoXW/bzllYBmBnsrgpqLadwptsnaC7WNBUQD9EHJsdwXkanRUYI
 /tsmYuoBAzrL0n17gGkBo7RyUvEggpo4d/rb+6C9cCI8=
X-CMASSUN: 33|uM02s+TRMEJ0UH3gphz8Nnf9ZxHz3o7/6xXkh8Inyi5Iqvctrp/nFDcse2Wftiz
 StkAO8PegZn7bqWNqOfPUVQ==
X-KPN-VerifiedSender: Yes
Received: from cpxoxapps-mh01 (cpxoxapps-mh01.personalcloud.so.kpn.org [10.128.135.207])
	by mtaoutbound.kpnmail.nl (Halon) with ESMTPSA
	id dc97aadb-5908-11f1-b8d7-005056995d6c;
	Tue, 26 May 2026 15:43:22 +0200 (CEST)
Date: Tue, 26 May 2026 15:43:22 +0200 (CEST)
From: Jori Koolstra <jkoolstra@xs4all.nl>
To: NeilBrown <neil@brown.name>, NeilBrown <neilb@ownmail.net>
Cc: Mateusz Guzik <mjguzik@gmail.com>,
	Christian Brauner <brauner@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Message-ID: <1393975057.2602302.1779803002070@kpc.webmail.kpnmail.nl>
In-Reply-To: <177979585120.3379282.15888962273037831904@noble.neil.brown.name>
References: <177969022571.3379282.16448744624428323496@noble.neil.brown.name>
 <36bvv2anew3cegsd374uzwdgue2txpgnzo2357ye5pldqi4by6@lafavyjgevqo>
 <ahVXG28wpqDwZpFT@lt-jori.localdomain>
 <177979585120.3379282.15888962273037831904@noble.neil.brown.name>
Subject: Re: [PATCH] VFS: fix possible failure to unlock in
 nfsd4_create_file()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Priority: 3
Importance: Normal


> Op 26-05-2026 13:44 CEST schreef NeilBrown <neilb@ownmail.net>:
> 
>  
> On Tue, 26 May 2026, Jori Koolstra wrote:
> > 
> > I only notice Neil's patch now. I found this same bug and submitted a
> > patch on the same day :) [1]. I think it is awkward that atomic_open()
> > dputs the dentry on failure, so that is the approach I chose. But
> > perhaps there are good reasons for it, although vfs_create() does not do
> > this for instance.
> > 
> > There are also some other things going on, including a stale docstring,
> > perhaps I should have separated that out.
> > 
> > [1]: https://lore.kernel.org/linux-fsdevel/20260525101544.195832-1-jkoolstra@xs4all.nl/T/#u
> > 
> 
> I would rather no big changes to atomic_open just now.  I'm about to
> post patches to rearrange lookup_open.  I'll include you and would value
> your review.
> 
> Thanks,
> NeilBrown

Of course. Happy to review!

My current proposal for O_CREAT|O_DIRECTORY touches lookup_open() as well [1], but
depending on your changes it should not be too hard to rework that. If you have time
I would always appreciate feedback :).

As for this patch, you can also add:

Reviewed-by: Jori Koolstra <jkoolstra@xs4all.nl>

Best,
Jori.

[1]: https://lore.kernel.org/linux-fsdevel/20260525202937.466497-1-jkoolstra@xs4all.nl/T/#m8b203bb3ebe259f78652d7e9def9451a619daa5c
