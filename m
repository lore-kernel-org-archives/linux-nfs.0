Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 136C93F9A05
	for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2026 17:49:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789926586; cv=none; b=ZTjsnFCOZaNe7BwQUG3zUMFm2uzIPhjNPYHdYjmV/sokLa09ISPCIq+szAcAhTNStwQXL2NUOgOj16DNAwgOS7kUu16Rrmzrg6Ce7bZQDvjZUld3civx1bm/NWnn5VlwZwFZsPAKpjTxcblHDNypCiwumupwNpEjBmw3cehHbBg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789926586; c=relaxed/simple;
	bh=T7HAxX40EyMROFWR0LnLvpLw6CPIpaqDrAhGnzRZlFo=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=c5/ifeM+cxden2gnZooG3MJtZlE5tVQLoGMceeLykeJT20HLDtRbweBwUbyH/6uaB61YfTfgXgbon2PZ+FjWG7lHQF7hU5DpigB2Z+CDHbN5gi+ZUNeD40qvwUBbMSMk2l1iKZ157OXUY+0vCttjB/TUX7SdPo2U9UsbTZMsu8s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Cq9alOpm; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Cq9alOpm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7238E1F00893;
	Sun, 20 Sep 2026 17:49:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789926584;
	bh=BMkG8+zzoZwD6yqtf1zpQZtrEJBIldey8WMU7iLda2g=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Cq9alOpmueXETq0RRumwGH1Fu8IBjllumO2dF4Vs7vveS0U+XeUSNzscjqjsWzUev
	 oWXuYcqNnVpe+DHQVTvSSHMfVdI6wxeQSwiXyiXWj8WzcsTBhBQa2yO/mnMNFcfaun
	 diproQlzrxCoJGMhFeX9uafCvq48ofN+uMn0/PN/vwYj+8JzV45+OPzOGUEIIZkjQn
	 fq9VDSiUjmMBDJI9l4z9Tp7YViXEQveRMUX0OcGfx0tMPlXKkHNEpjin1PdlSeXdkR
	 9qvfwF26mwqHHppKxYWnDihBTbWuL/ZxGCuIfDyiXbrLofnJEm4U4IOajaJ4ID9ox+
	 DePZpEf8OQErA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A175DF40068;
	Sun, 20 Sep 2026 13:49:43 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 20 Sep 2026 13:49:43 -0400
X-ME-Sender: <xms:txywaiZli6jUmKotkLbCZ-BJRkfuWL1RfVsTVeXYcx7ZayFKrV7q8A>
    <xme:txywagMJ0Q5H1bgx-O_B8Ry9raMUvHjYaljrG_4GdFKtOQbxjPJm6LD90SRwcvOJz
    o6Ec1MJZQHBJon0iAPE7l_UzqOnCbo8LlrVeb541q-D5_3rTuQeWPTn>
X-ME-Proxy-Cause: dmFkZTELmR7Q5Ny6p51Q/XRBkSWnvCea/Lg/aUpOYssiePJ6ySUgVewQ5vlksYp7PRL0fu
    VFNv51fWuAIafCgXf7XTLuRQeGrlbjH9pyI0gsD1dhIfHX/mIwx5QAQazVd/BvzS7Q6e6W
    KX9VA8Vy5hTaY58DPQlCEidWC+/h6WhkgcMXlBJK91FRxd9Weu26EJwEP4ndGFXqcqHuZf
    r/91qFpXYQ73TmkdUE2XAs9gG/ToShB3RILDAQJSvdmzzsMm+gYNSyZhHr7XBie03/S2k7
    9eaxwXvqiQj/FV+h+xd0RtawrL7L4brOhW7gZWeX4vKSLkfMEsRAmGfNQzTfOoyBhgDupR
    8Nrcy56trY3+6L8umfPWDkJ7EBAPvm/w/HzWA1EvnS765nHlsf56sZ7aO4gY/4jxHS5AZg
    YC53sW1kpoOyFHvKeB2rUc7LeqXPYyZPK7MQVeLrnv+wH6rqqdQbG+/VsDz6nRSpjv1jgx
    ooEk5p3B1T9WnQf4dQF7S4rHnbdlO62j/JSmoPXJ8hPLAVnHz//wQrnK+MaWjOWLBh11Ik
    /wneusS5dQW9IcWXikCSoXNh1IgyAZlVm+phicWGBd+TRAVvlLPZvbIyzc9MWov0bpynI2
    KDRFhQGX4IbS1wExfC0IN5EFh5f5DmimweUDYGaiSFaDa5WieyJDhPNYJaKA
X-ME-Proxy: <xmx:txywakTi0360dyVgqayL8erSYoz68SbEWmgkQmfZhBuJjLFJostaWw>
    <xmx:txywaifd33rSOPkUjlwjNOVT3_dsqIS0xvOj80mzPkIc3p4795GElg>
    <xmx:txywagAIq2snRRXEgapenxndHzhuKyzhB7i0RU1nmGsQINO9po6_Vg>
    <xmx:txywasnHTzN3JSzd5-ZD2VCwGHvAQ5ij8JOzWciEmbs5lhGmKLAb2A>
    <xmx:txywajcCnXWOVeyb7g3H4ePQGWzAhGN1ac9oHva5sxk9sR3FSXOC2aL3>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8406D780070; Sun, 20 Sep 2026 13:49:43 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Ahez1a8JXu07
Date: Sun, 20 Sep 2026 13:49:14 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org
Message-Id: <7bff5367-c22d-43fb-acbd-e3b5b91e25d7@slotpi15m67>
In-Reply-To: <178990066075.37859.2365005183271933047@noble.neil.brown.name>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
 <20260918-duplicate-reply-cache-v5-11-b6aba9ebf2f4@kernel.org>
 <178977475436.207413.9806283444174908649@noble.neil.brown.name>
 <85a7313b-6c69-41bd-9a12-18ab4fec4b5b@app.fastmail.com>
 <178990066075.37859.2365005183271933047@noble.neil.brown.name>
Subject: Re: [PATCH v5 11/11] NFSD: Remove DRC checksum and payload_misses stat
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, Sep 20, 2026, at 6:37 AM, NeilBrown wrote:
> On Sun, 20 Sep 2026, Chuck Lever wrote:
>> Just to be clear, by "ignore" do you mean "drop the request" or "reply
>> with the cached reply" ?
>
> I mean "RC_DROPIT".  If the connection we sent the reply on is still
> active - active enough to get requests - and we haven't seen the ack
> yet, then in a sense the request is in "RC_INPROG" and so RC_DROPIT
> is appropriate.
>
> Even if we *have* seen the ack, I think RC_DROPIT is appropriate.

I'll remove the "treat an acknowledged match as a new call" block,
then. A match whose entry was sent on the same connection now
returns RC_DROPIT whether or not the reply has been acknowledged.

The test is a recorded reply position plus a matching xpt_id, so
UDP entries, which carry no position, are still replayed, and so is
an entry whose reply svc_process() dropped.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
