Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 278042DB794
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 17:06:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790960797; cv=none; b=D6b1jdUmT1GusAz536yE9p7r3f5huO/FRrgUeqbsZwVl8aCED7mGCd2hhrMhOjIiqucpx3gwoxfR1xnKHWpRPRHfSsbd13aBT7+XzkMbPF+ABwdcNhBrWk4MtV4Ne1kUjq34l1v73HxestG2zUDxsBh1Yqt43I89IAmhfYEEHew=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790960797; c=relaxed/simple;
	bh=GjKjt10tQOX4FaEExDh1EWumuThJajCVU7emDfqiGKc=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=mHVEAAUX+zkcUUU0apqo/mvsQnv3BL6riVVWfBXJ8Ha+dSngqwY/oDgG8aZXBRMPl/JODxa1Z0davYAbEpjzF2LuUFAyFqPe3pA2RWq/yztl/m313qklvlJteie2cxakvV+I+YDujpiNmZqM4WwAJOjFh02tWFTWGfPczZLQ6Zw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Spr+S5tO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Spr+S5tO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D41F11F000FF
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 17:06:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790960791;
	bh=zj8YWBK5hyEq+jdLUqdX1QUbph8933I44kI4Bvsiyu4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Spr+S5tOFuOJ7GXeCWd/7SyWSU9hosQ73DWUP3/vdV5iVZvna4sOdfyH61WCUgVjW
	 CDip78Tz93nWn+E/3rxa2oIGHCoDOmFDT8sC5tUHrQD1dZYtz+t9CvKodfRV6KLbq3
	 I61lxGHYZbQ3kjbkJJ2kN1thsYBQyuuW8bG+aVS7ZWyqVaSjsQi9J3cTKwAfLwpUzO
	 fvtR0IHwXxtw0mbj/aJvaisFRSxKoJb/90hoB9YwVilChHHmEli39nLhIlV9Jzisti
	 h/QuVBnu1t9q9Oq0V8XTAEXp4erN4cJMNrT8KJBQ1L7nKlGQ+snFZtRAuz2tSd0Ou+
	 WG2EbHEk8s67w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id D7168F4006A;
	Fri,  2 Oct 2026 13:06:29 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 02 Oct 2026 13:06:29 -0400
X-ME-Sender: <xms:leS_atYIrWFyYWq69XUyIjkNCQFaSlPRoKMKFga3ByyzczVpjL7y1g>
    <xme:leS_avPac6GszhkJgjjv8i2XJZJ1bTE54f6yPTmzftpoTpr6bLO2BQrE6zv4ed4wQ
    EVsMqsVj8zpDOSiUJSGo7cQ8f1ukt132U0Mo0fMv4u65fA2C7tOc-gs>
X-ME-Proxy-Cause: dmFkZTGQ1vVbl3ImccugrXEBy4odGtbXNl3B4R2pTZkqSpkCDYniq/ixoplnyXIQLilb62
    Ah05SGLQl5KMjLOuode8ecb2BzvOxq9vizR/MRHjb85aMXiQpK8fbzdQFCA/ws9UZeNZts
    PiKVVp362cWdND49FMHbpvht0y1ZEc/ax913ia+eCCTWWcA8eqgFVqyqB5vwarOna5RwMq
    tvk8F48ulcD8U1ZAQ9eEenfOPpT+GMNM47MwPZDVqxbTub7eqg72Z2R9mzgsiZTV6JHzHv
    Lu5ho6orHoS3dpoP+gQAl6eM3OYDus0vkDQfG2MLWwcBDv/ihH/f2UAhow2LjV2VwkixFk
    RIkKh3W75pUx8+9yaZ+U2aFkCcLE6WApjSTgwPoJPbeKH2ckEgQrf1VKqnYcGcnAK71Ows
    Y8e22GlcWbDRiHoFXH69IDHtGv18KHRKRe6BkhIJnwqoGP4O0KeYz1lTS3LvwKvbyscB6N
    Uy6vx82a8bBMNmj+qlC3WNUIL/3Ypak9Uuccnvgkbh86fEakIBbnS93tRjATb9hnxWE/EW
    URYUA0CykTnyFpeAOysJmvAnG6pfdl0tw/FKUV4XBZoPcXzIBT+lu5Dzq6/7YWHUaj8y+n
    byy7YyqBkF/EabP2W6I/8Ooss1ZAFlx2NkYPWDxvuDlRygnbJSdGW8k2/72g
X-ME-Proxy: <xmx:leS_aiCQ3iz-AZvjWD6zI7-0jdwUuFYMRpYZ6sUFFiHFLy5u3v6T2g>
    <xmx:leS_aqUr4IY4owgFh08N1_gpqLQznb6jeUfSgp8G6cAAo7R8R6uyRg>
    <xmx:leS_agAJBtRhu_W5tLxVGBV7mqbnNdzFlrTTKGteGMqVRRG1KERW5Q>
    <xmx:leS_at8iPk176p8K-LyObn7Gx8ECI_OlWzC4vTMejdgfFdiRzFUlrQ>
    <xmx:leS_anFGSMZuzFE-VvZDpWXxYyn8A15yMOXBjwok0RCQ0R4TTKHdAdhn>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id B81A9780075; Fri,  2 Oct 2026 13:06:29 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A4G4TDAM4BMs
Date: Fri, 02 Oct 2026 10:06:09 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org
Message-Id: <2588e487-1126-4592-819c-b025e4ab346e@slotpi15m67>
In-Reply-To: 
 <5b162e1a03d59bd0d3cc479891965834d0d4f0c8.1790948398.git.bcodding@hammerspace.com>
References: 
 <5b162e1a03d59bd0d3cc479891965834d0d4f0c8.1790948398.git.bcodding@hammerspace.com>
Subject: Re: [PATCH] SUNRPC: wake a thread after re-queueing transports in
 svc_clean_up_xprts()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hey Ben -

> -		if (q)
> -			lwq_enqueue_batch(q, &pool->sp_xprts);
> +		if (q && lwq_enqueue_batch(q, &pool->sp_xprts))
> +			svc_pool_wake_idle_thread(pool);

I'd rather the wake not depend on the return value:

		if (q) {
			lwq_enqueue_batch(q, &pool->sp_xprts);
			svc_pool_wake_idle_thread(pool);
		}

svc_xprt_enqueue() ignores what lwq_enqueue() returns and wakes a
thread every time. The conditional form is correct only if a "queue
was not empty" answer means some other thread is already on its way
to the batch, and a reader has to work that out from the lwq and
svc_recv() internals.

This path runs once per pass of a namespace shutdown, and a wake that
finds nothing to do costs one trip through svc_thread_should_sleep().
The unconditional wake needs no such argument, and it matches the
other enqueue site.

One nit in the description: nfsd's svc_serv is per-net, so every
transport it drains belongs to the namespace going away and nothing
is left to put back. The sentence about the 5 second timeout reads as
if nfsd were exposed with a bound. Let's drop nfsd from it and name
only lockd and the NFSv4 callback service.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
