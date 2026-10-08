Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B6833CB544
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 19:39:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791488355; cv=none; b=k1n1kwR83ZX4K/fVB8gpJOV60Y0sscL+YTA22JwEZl0LXSSIPRmmnmFvkM4RruTWXDKnsS7bwxpoqxyvwUrORLnwfF6n6BD9N9H9bxH4eQOIlm/4FcsZY/fC3tQeFyFSck2YIPLOysYmbvgIWmtflgAjLSOUEo2d0ne0eyqtQC8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791488355; c=relaxed/simple;
	bh=s1sHwnFrTD36A10q9o5vomfUrCf0QfCj36o+QmY14Pk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=neZHXqrpMGlEr+6v+YhmepEdL+ls79FjAi/KOMWVrWuUo+U3MxNksHtCjigDAC+HQCU8s6qcAC/EDQdS+3ZLgiwZhTHzfCb80tt3SBZhL3rk3gAA4Neo/XlElS7VwKQeoZ3+WeH7SvsUBERxRW1CQLzHaZEmi4dv27002WzmEDA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lRSEWGQN; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lRSEWGQN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 23AFC1F00893
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 19:39:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791488354;
	bh=VU+N2cPFWzWHjkKpL5/Idrd4eD289aexM+kZQ3/YByA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=lRSEWGQN0Hv+GMsLyuKfvuFFwtKMfEP9PTweoVgSJ+Ucou6UXjMBmRz90AjyCwRaL
	 nrV/po70jCFmqsaSjomEQve4Fu8c8gFFuXhPn+l7+nZ4+SDbA1Vbooo+qjso5hhdWS
	 iHOrdsllkV/bgnlOiakxMbzFWHwYYstWyixn3Snvjqy6eW6zPbK/0gnEzJ5ftkEmkf
	 rzrxUQHcNPT8xC0ImI6C+bt1lLv3vVXcOeMLzT+kl8Lq+HbH6ys/HsYAQ65x6DKZOK
	 JDfr8bAfGhGjMkhZ2+OHC8IDMvXfmUvHk3qRlxHd6GhzRAt7fsKq+q+4g9PovNHan3
	 FFv7m410XKUxw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 518B0F40067;
	Thu,  8 Oct 2026 15:39:13 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 08 Oct 2026 15:39:13 -0400
X-ME-Sender: <xms:YfHHauv2NnAfd194W7CK_NaiWfbgFD9eMR7kdON9nYK7J0exKkzxbQ>
    <xme:YfHHauQXcW_S-emHJkSUQT9LxWoSzsxDjmYpHFwwclGNmHedTjU4ukrnXPzMWjv7j
    GZQVMj1-lWDh6mMZ-n0GYaNBy1UH8ThcQajjwcDa-WbKptAktEXouQs>
X-ME-Proxy-Cause: dmFkZTE/x9BpbsvCGLxMG+6XPvyYwTuVj1nks0bVhuuZi2HbK94eTFjq5K1fp5IO/E50pN
    jQAPYWNTxD8h8nXAPSEnzZ/bknrAGURscKJJtBgmEpw9eTeSbInr3Y8waHHvt2piax1nox
    rfSmNKNylVNCWfv9qWGAB3d4C0CteXYkLjtMwRZ85smLB7cUQ6hFLjetQHwrudc5xO12is
    TPECe1wYJ2p/iegWtAd3BD0hGgLG7hHA2anVuuPC5lZ1d6pVioAVD+LFmQ7J1hvQVU96gW
    PUVZDBeUDOKrKySBhE14J/Xu/TUG6wefNoflIfG4V3yy5S8UP/ITpYeumGl7vF/ugG2aTh
    HzUOwNKoG0IeWDw6xgKJlIW5VRe2KZwA5hDj8hoEH7wQqJ2XPRinuazO0tPqZbVHy7c7UW
    Y8ZM8Y01czszM6loM8e6X17QN35ZSJwdRI+PH5MpqY11oH7aB1HzSLY+7waWrnSUcC0xTT
    MhjKwSppkKv/fApqNYJipXexsxGUhQXdjoQAgP7f2a8hToJTF6bwUWkwxQP6zyEqoDUeN8
    E+wHR4MC1tZiDUy5QInuFlUBxOjold21c3JBOF9j7x42i9ZDmkAbM314SbsThTKVXWJgGL
    eaLVIHgiew6aLgEX4T7VQh36gBkyr6pkXiFMoNOImoYEzgOG/t2LqClzGMKw
X-ME-Proxy: <xmx:YfHHamR-hxSqiZcDzlBYEiECMDSwwPRe8RwLAKVrUmeDw06IejhakQ>
    <xmx:YfHHao5lhOrkeJY4nRwCp0YeUvhlcoM4PDgnCUANaCSvH4b8BU8Glg>
    <xmx:YfHHai0rgZR_VJ0xLG3oFIg51G1BBxBsqGXL8GRyPAtCJSv-xpgTiQ>
    <xmx:YfHHajAYf3HvwPIs1vFJpyHvt9dbdz1hjKj5Ds_iyJMALh0CgyxMbQ>
    <xmx:YfHHatOtiWZQ-SAFpzz5_hVnnOAbfJt4fMOWSnDy5SPOnDiH5PhrZwQF>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 31BCBB6006F; Thu,  8 Oct 2026 15:39:13 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A5hC8rs67Wx7
Date: Thu, 08 Oct 2026 15:38:43 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "rushil.patel@gsacapital.com" <rushil.patel@gsacapital.com>
Cc: linux-nfs@vger.kernel.org, "Trond Myklebust" <trondmy@kernel.org>,
 "Valentino Aguiar" <valentino.aguiar@gsacapital.com>
Message-Id: <71a8991f-3c52-4483-be26-e4083cb8c628@app.fastmail.com>
In-Reply-To: <327DB787-70B2-45A4-B5FD-7F49531B317B@hammerspace.com>
References: <20261008160253.1702053-1-rushil.patel@gsacapital.com>
 <3E653493-0BDC-487C-92ED-9647E5D8CDE0@hammerspace.com>
 <20261008191903.1770486-1-rushil.patel@gsacapital.com>
 <327DB787-70B2-45A4-B5FD-7F49531B317B@hammerspace.com>
Subject: Re: [RFC PATCH] NFSv4.1: don't stall installing an OPEN stateid after a failed
 CLOSE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Oct 8, 2026, at 3:34 PM, Benjamin Coddington wrote:
> On 8 Oct 2026, at 15:19, Rushil Patel wrote:
>
>> Hi Ben,
>>
>>> I think the server is broken here, and the client's wait is doing what
>>> it's supposed to do.
>>
>> Agreed on the server being broken. We've since isolated this to ONTAP's
>> Concurrent Open Close path. Disabling COC removes the reproducer, and
>> re-enabling it restores the stalls with the client, kernel, mount and
>> workload unchanged. We also have both replies captured on the same
>> session, with matching filehandle and full stateid identity. We're taking
>> that to NetApp.
>>
>>> The client already handles the compliant case: OLD_STATEID goes through
>>> nfs4_refresh_open_old_stateid(), waits for the OPEN's update, and then
>>> close_prepare sees the new opener and doesn't send anything. There's
>>> no 5 second stall.
>>
>> Understood. I'm not arguing that the compliant case is mishandled, or
>> that the ordering guard should be removed.
>>
>> The question I was trying to get at is whether we can handle this
>> particular server failure more gracefully.
>
> The maintiners (Trond, Anna) would have to answer that one.  In the past
> there's been a strong position of not taking fixes in the client for server
> bugs.

I think working with Netapp to fix this issue with their server is probably
the better path than trying to wallpaper over it with the client. Bugs happen,
and if we mask them in the client then they might not be noticed or fixed
server side.

Anna

>
> Ben
