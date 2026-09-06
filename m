Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6474254B03
	for <linux-nfs@vger.kernel.org>; Sun,  6 Sep 2026 18:46:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788720406; cv=none; b=iOhJAuSQv/zNUPVkCpTlXKXp6o31R/WyrNtA1kG7sM+t7thEBlsldRsapTRA0i6+Z1RsdQIVmc916l7MarGq7LMtWdQCPZrOgP312G2t2CbHhGzgy7RjC97eeBZ0IlKrmjPesmacYtJnaxbcrMzbVX3BRQW2YeMOyXuEBeI+m/g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788720406; c=relaxed/simple;
	bh=00suynMnnPAFKtSFa5xjyTDK7BocOzsFSI6z+62Z1Zg=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Aljm4PfC2c+a/6IUcCZNUtEbrKP2cpXD+AFNpIIlWVINdrei1d3V7BJBoEy/QZMQuNPdudItjbdfKVN5NVCBBdL3esxc4NQyMeDrZzx0wSOw2HGBrfmVq4k/wy6CAY3MRy0ofcndh288E5onPywFWtaS1vUcQJwZdyEogl4u+CI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CM0eHGQs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CM0eHGQs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 322271F00A3A;
	Sun,  6 Sep 2026 18:46:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788720405;
	bh=QRp9YaVVwtWF9fJIFdP4uQCdclXfGGAIz+zimG4Ojo4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=CM0eHGQsqYZuLz+OqKMqD19dKRA/RxkRannfCByfyZU0vkQfGQMvAG/dEIF/eBita
	 pCru23NzMK/oczYWJCobIqbEfTO0qvex+nVhow5bPG3rIz58VATXOn1Ec3Ie6eE+r7
	 Thu9w7K6HoHEUV9U1DltbLjt7eDkDzvTANwHCBKYe9IPOKppfbXiRSJ/zmqImqEgrU
	 OtpCB5yQxzPtpFqxiWqRVfBIQJ5/z2eFFUc5vZ5B28NejnLlPDZ4NHKxZ7rnkSXE11
	 K65bWocrV6vE1ctVDEIZ0pkdlA10tNpt3a1CqwRaOxFppQeINaKJAjG2v1Zs3tYxkd
	 t5N1PtnEoMlwA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 59951F4006A;
	Sun,  6 Sep 2026 14:46:44 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 06 Sep 2026 14:46:44 -0400
X-ME-Sender: <xms:FLWdag_nbHQyqjT_FAGGzL3-QTqTFNgDpHB79ZMWz5OZgmZ4slpZGw>
    <xme:FLWdajivWEnedlms4vlpaa7nlElq3iMZOam2sk4QueOwY0Oxb_Q2jWTaVW9G5teu1
    LWT2eROhWJNA6RGPexD1l93vqWgK1h-4W5JY9c11UbpW5IinBIfvMra>
X-ME-Proxy-Cause: dmFkZTENVwahc0i1OAvMfT3X7TSMpgA1rvGw9q5MPx5IIp4GKQ2sBhXc08FYZfXU0YUoZ3
    eCQJ0eVrc6v4rcOcgrD2CfIAE243VkIR2NsC6BbNkPMULrGOrpB3obEdmDdyskJDpvosOO
    svxYPdfg31xJRAS6B8OloZLFRQe9Hg7lEBXzJHcALMVssJ8UNP4w642/sgEW2h3Q8Js2+5
    7LjTJr9vQztpgfS+2M0S25f+Rcr0qiZPMuiOHQPS+bS29HjH/9/EwN/We6/KSws1ENig8e
    GHI5R9SNiN5E+m79YdKnDN6i4v4USFa2nB9pKqJKAmtnuU+6LMaNlqM5b0B3dm4mIgaaET
    ZBRJU5j0Y9ZyACZoj81dReOWJvnFniLKqc3WOs/E0SJnRKVwd5tx2Nv/5qjzVidyy1tyLe
    bidNUIwRCCXVhYlmwjSj2XnCkt37qWRER/RsizqSwxJfYmjiOHQTbkO1fyKd15mdCRTwdD
    VAoOjPWs8wdW6g4JCLd0oE6olKsJ16BMm9sUGEVXwMX/QaKBABI0icXHKEXuGUyZaQIkcY
    mzRJMsbnSNuF3t0ITu0K4ikGy4kLSzfwESP3hTf3a08QpSWFloDJ+WUEiJKHxFTEBHWf0R
    4eFzVn6PlpFldhH/FwXnqYkha904Gx5RickLrtbhqEDsZKnhJnPsjK46h85Q
X-ME-Proxy: <xmx:FLWdavh2mQ7TGFpjWUnMn_PiDydSZllexuw-qEPYnl5iHl799RLhuA>
    <xmx:FLWdatihe1pwGvinOEVyf6FOrYLSlmM8w6A0-dzVVj8IAhTHA6rnCQ>
    <xmx:FLWdavK1QVIH2JzTqDBq_ZxvzWreswSC5rcTOTEJrLX4LbdCVdCaQw>
    <xmx:FLWdasE9hqor2yD8uT38BWgblMiMOsz5BFFbhpHa5njzXSFzAomBlw>
    <xmx:FLWdajT5yNhd-Ym7SCLnr5NvMa2qZqmNLFXmf_PA3kh1o9C9vC05EWz2>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 32C857811F0; Sun,  6 Sep 2026 14:46:44 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A3w_KCyJ6oRR
Date: Sun, 06 Sep 2026 14:46:21 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Chuck Lever" <chuck.lever@oracle.com>,
 "Jeff Layton" <jlayton@kernel.org>, "Christian Brauner" <brauner@kernel.org>,
 linux-nfs@vger.kernel.org
Message-Id: <d775d13a-f7f0-4b41-b7f3-b851d6b2713e@app.fastmail.com>
In-Reply-To: <178867037632.207413.7103786340154818903@noble.neil.brown.name>
References: <178831622346.3510150.10735958308429473076@noble.neil.brown.name>
 <8212e77c-fced-476b-ba64-3b8defcc65ad@app.fastmail.com>
 <178867037632.207413.7103786340154818903@noble.neil.brown.name>
Subject: Re: [PATCH] nfsd: switch nfsd4_open() to use vfs_lookup_open()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sun, Sep 6, 2026, at 12:52 AM, NeilBrown wrote:
> On Thu, 03 Sep 2026, Chuck Lever wrote:

>> > diff --git a/fs/namei.c b/fs/namei.c
>> > index d95249dd527c..85fd5e8221e2 100644
>> > --- a/fs/namei.c
>> > +++ b/fs/namei.c
>> > @@ -4632,7 +4632,7 @@ struct file *vfs_lookup_open(struct path *parent, 
>> > struct qstr *last,
>> >  	int error = 0;
>> > 
>> >  	WARN_ONCE(mode & ~S_IALLUGO, "mode must only have permission bits");
>> > -	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR),
>> > +	WARN_ONCE(open_flag & 
>> > ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR|O_LARGEFILE),
>> >  		  "open_flag has unsupported flags");
>> 
>> Two subtle behavior changes here. Were these intentional?
>> 
>> A client sending mode 0040755 gets an inode created with S_IFSOCK|0755 and
>> trips this WARN_ONCE. The old code clamped the incoming mode with S_IALLUGO.
>
> Thanks for catching that - easily fixed.
> Though maybe it should be caught earlier - at xdr time? 
> RFC8881 section 18.16.3 says
>     The set of attributes may include any writable attribute valid for
>     regular files
> and it would be hard to argue that S_IFSOCK is valid for regular files.
> Maybe it isn't worth doing that sort of validation in xdr-decode.

Before the "always open file" series, the v4 create went through
nfsd_create_locked() in fs/nfsd/vfs.c, which masks with S_IALLUGO and
ORs in the caller's type. The v3 path still works this way, and the
v3 decoder does no masking at all. I'd prefer that the v4 XDR decoder
should also remain pure data representation and leave policy and
protocol to the upper layers.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
