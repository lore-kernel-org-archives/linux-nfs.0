Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D2C3B4B04AB
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2026 16:36:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786898166; cv=none; b=nI52sb4fLrhxTTKcrVaTE+nM0dTJcEudtRGi6h52es2LN348/1YrTEbyMjZI28X0UdlPgCvDSVAorNRUs9OIz3gC45dPu9Y9vHeIcf7/PzTN4ymd7uxsHva7FE/S7vs1Sv5EBgxgZuR5wj2DYHDc91r7SAKEjeWv2CcGwHmV4lk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786898166; c=relaxed/simple;
	bh=lkt6Nn2kBVr9iIPp3m2EVO0dYS4Mr+dxgPT7ulqKjwI=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=GpWwyV6d3OLZFVjU04xLSYpdX5eeR3UIMsGatgZe0Njc2mRK3CGa0lmzm50pTPN+oc0svwyDVC+gpgh9WRciz2g+ZkeuZSngdVoyNQY6y8sdcaugzCDe2UevQbhknq6+0PYkcoi6Gq/EGDG7V4ERE6/ue87W4EKuZR8OjkC7QwY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GwI9oXO/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GwI9oXO/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3C2311F000E9;
	Sun, 16 Aug 2026 16:36:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786898165;
	bh=HtWdBEj8Wh+hO726CP+YVfku5tJNLV5YOswpipB4UP8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=GwI9oXO/rPd55QYw3mYBQPxcIKfc0rhGGIkSlhQeL2/B9pxVJ4+CRi/F8WEiNSvd/
	 kIQSkSUli/myWS4ptF9v3JmxvE8Wu9eyL1M3ZiUR1PBwgcZpqLdFhm1tyA+9DdPclG
	 ZoVpy9/1Tr2jDY6TcbSQb1Ii4fW4+UWSArlcrXqQcIizPhQJZ08FH33TvnZj/v3u4q
	 kQ9iBTY6iTBF1wDECWl3Lmirz2+P0CL3a/D3rsiqijc96/yPhgqVmVPBk22TfL6909
	 day9kVb+iBxXZBPdmMzI5CaZE7ZLaPgDMfCXI03z2U/nN03pmkCh95+4iVUMl/ZHO7
	 B/uIpq3ddgOHQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 4BF74F40068;
	Sun, 16 Aug 2026 12:36:04 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 16 Aug 2026 12:36:04 -0400
X-ME-Sender: <xms:9OaBain5lzoEjJ89TmCRgLlisCD3OknyhODRLvxppE850gH14OVHew>
    <xme:9OaBakrA6pc_NJiPcwvoZnTNve5zVnNi8HP-ltYwI4ld4I8h74DyDHz5s24zsC9om
    y-w18QI4nPfdNNRwPXpzC4JYdSKBmrLW-j5MroL5rmhej5A7lheD3YI>
X-ME-Proxy-Cause: dmFkZTFrBP/w0b9ovX9sbkmDB0rIcEnea0e52jtF5pYa4hQAvAi8dczuLcx/Uee5n6d+NE
    3aWbxrVcogTrwiQzhh1dOVPW7J3mrqvAhb6WYvll/treXDzrkScyXcWP1+/oHXgByXdGRF
    jrC2fM3irLCDYJ5Y8oaq8d8UfSu6G0rIMdIixHHog9ZmHy8f7JxbISUmS3Gx0+Bta9BdQr
    hhQ5CahU8iE7dZdPhUsn+MlGf6xFlsY3EXWJ5FWxA/Vuc6d4qE6WbsvVI4bkfO6euJnYiV
    dbSjEWltmWaLLBAydlzXpBLvpwUeuPIiyG5jgg0PEBfABqK8hyZUHRGIEkv5VYEpB2Mdex
    AQU4zjdYDfdfiSzMvosiaqzqZUSgh1/N2+0aqACZ4MTARirW0fDCRUFGycxov0Aj+beR+s
    F/l79p51goeoG+GV0ZXq/h6YkAQJehsZAQ5aGSCfgtjA1LA/AoZNOPacyXeiXx2ifCE+Lt
    WF8GvUInOH3VvT5acPaY3j4seVZShE5OSbXikfrWhNSVyR1o4q3KnDN0ujeV52kj0BPMe1
    r/1U2e/w3K33p9q0mfOKviTbNlaExWdeLXUyr/QBldqsd6zf9FUWULvoFPABiwie91jlFn
    Q5Bh0EvWjAw1gJY1B6vz3Iq8v8HqCVg5v+nlC8adMGED5CNs2A5f1BgTqzRQ
X-ME-Proxy: <xmx:9OaBapT8ZlIeBwXADf28q8fdu4dmaD1UGsNCC54xCtkR-bNnFnP5rg>
    <xmx:9OaBagvMEPW7IdPG4HGlVY2Gm4zh2a_k-WDuepKImf-V9TIToDj7Bw>
    <xmx:9OaBamZAY_0V3YtwGlX1U53glSjYkpLnvHqzVUsLx-CrYQl7ZEHsWg>
    <xmx:9OaBatv6vX6RWCPS89Po-asj_sntRGL3suKYeZHZM8FqzBDR6RRWBA>
    <xmx:9OaBagFEva3hoC4PIyHwJhpHeWF91LT9qh-2YfmaOSxZyDgikhb6K3CF>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 31D457811F0; Sun, 16 Aug 2026 12:36:04 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A4wtWgH_3Rsw
Date: Sun, 16 Aug 2026 12:35:44 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Cedric Blancher" <cedric.blancher@gmail.com>
Cc: linux-nfs@vger.kernel.org
Message-Id: <f2745695-328f-45ab-88d9-eb1d102066cd@app.fastmail.com>
In-Reply-To: 
 <CALXu0Udh--HV_H-90PxVzGA8vuP-u54fkwsqkf0_gkDnEg_C6w@mail.gmail.com>
References: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
 <20260815-recall-any-keep-count-v4-4-bfb5b83d6cb1@kernel.org>
 <CALXu0Udh--HV_H-90PxVzGA8vuP-u54fkwsqkf0_gkDnEg_C6w@mail.gmail.com>
Subject: Re: [PATCH v4 4/8] NFSD: Send a meaningful CB_RECALL_ANY keep count
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Sun, Aug 16, 2026, at 2:42 AM, Cedric Blancher wrote:
> Could you please backport this to the stable branches up to Linux
> 5.10,

v6.18 is as far back as this series can apply with reasonable
effort.


> because conforming NFSv4.1 clients get robbed of all their
> delegations if craa_objects_to_keep=0.

What you are describing is a client bug. RFC 8881 Section 20.6.3
says clients get to choose which and how many delegations to
return in response to a CB_RECALL_ANY request.

I say this to suggest that, if this situation is troublesome in
your environment, clients that respond to CB_RECALL_ANY by
returning all delegations unconditionally are not conformant,
but are defective and should be fixed.


-- 
Chuck Lever
