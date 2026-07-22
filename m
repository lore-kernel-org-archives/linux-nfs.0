Received: from relay.yourmailgateway.de (relay.yourmailgateway.de [46.38.247.119])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B9D893382DE
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 14:33:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=46.38.247.119
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784730827; cv=none; b=mh7yRNUjv2npnKPLNa4CQsm8fPg/x6AUWu1OUDNKLDPEcd5RttvWKKWZo9yJTEv3kAvgTOySiyN3XTNIfwdNT5EFrb9WfMkenHzH9YDAHZpEgypF0gKyoNp2GO4Ys/pw6y7qKQPlQ59c0bv6SzviHqgPn+E9CZn0Zm3qq4cn9Sc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784730827; c=relaxed/simple;
	bh=+kOX3Xtu9EsNtk03iP5mLB76zlKk/UYMSTKMwWMCV/U=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=S1M96JFMBxL/yYN5DeHtIfdOOEhcZZv474yRV83hI7ACI9tImk8gp+a7QDKU7gcjO4IzkISyNuElsI3oYhoCvkL6q2fcT2lnqXz2rkB6OIjujBK9OngulLkfNDioIal81wkIyVK2lYs5JhMeZiAXqdMeJpRqTiiPD6tP4yspXF4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=leemhuis.info; spf=pass smtp.mailfrom=leemhuis.info; dkim=pass (2048-bit key) header.d=leemhuis.info header.i=@leemhuis.info header.b=hj7Xq7rJ; arc=none smtp.client-ip=46.38.247.119
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=leemhuis.info
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=leemhuis.info
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=leemhuis.info header.i=@leemhuis.info header.b="hj7Xq7rJ"
Received: from mors-relay-8404.netcup.net (localhost [127.0.0.1])
	by mors-relay-8404.netcup.net (Postfix) with ESMTPS id 4h4xZG5jnsz83yP;
	Wed, 22 Jul 2026 16:33:26 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=leemhuis.info;
	s=key2; t=1784730806;
	bh=+kOX3Xtu9EsNtk03iP5mLB76zlKk/UYMSTKMwWMCV/U=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=hj7Xq7rJWhsYgwx2JFIs40MJhSvuyoLDbO11l8eHOoSBmX9NJKf5+/eTHcKuSRCew
	 Jf1KAvTEi2mcSsVi8gQjnXFsae1yDXmz+hpyzT8Hf/KLz3CVdt+JJUJwqPzEZE9nyR
	 wD1eOH1pHuX8V7wFnB4IXQ2mKnqirTrcWX9prs536ZXkt3QXvC0phIaYBST4ief4bf
	 uA2m+Idcba9UUodCOvvcjgvJ7PCbwXFNJbYN1REg4M7jtmV1r4zX/oB0BnO+iY/8Ci
	 /bAiWyYMaI+SOBxf2ou4o7G0oyXtc0GKyyUkTNqYqe8wbaXZt/wZR0uS2qB8yX+nOE
	 hhqdPjW2kVhPw==
Received: from policy02-mors.netcup.net (unknown [46.38.225.35])
	by mors-relay-8404.netcup.net (Postfix) with ESMTPS id 4h4xZG50Vxz4y8q;
	Wed, 22 Jul 2026 16:33:26 +0200 (CEST)
Received: from mxe9fb.netcup.net (unknown [10.243.12.53])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by policy02-mors.netcup.net (Postfix) with ESMTPS id 4h4xZF4qRlz8svW;
	Wed, 22 Jul 2026 16:33:25 +0200 (CEST)
Received: from [IPV6:2a02:8108:8984:1d00:a0cf:1912:4be:477f] (unknown [IPv6:2a02:8108:8984:1d00:a0cf:1912:4be:477f])
	by mxe9fb.netcup.net (Postfix) with ESMTPSA id 120275FA12;
	Wed, 22 Jul 2026 16:33:25 +0200 (CEST)
Authentication-Results: mxe9fb;
        spf=pass (sender IP is 2a02:8108:8984:1d00:a0cf:1912:4be:477f) smtp.mailfrom=regressions@leemhuis.info smtp.helo=[IPV6:2a02:8108:8984:1d00:a0cf:1912:4be:477f]
Received-SPF: pass (mxe9fb: connection is authenticated)
Message-ID: <27667adc-3dab-424d-9e6f-52c91c47a51d@leemhuis.info>
Date: Wed, 22 Jul 2026 16:33:24 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v4 1/9] NFSD: Prevent lock owner use-after-free during
 client teardown
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Wolfgang Walter <linux@stwm.de>,
 Linux kernel regressions list <regressions@lists.linux.dev>
References: <20260709-cel-v4-0-1d519d9be0cb@kernel.org>
 <20260709-cel-v4-1-1d519d9be0cb@kernel.org>
 <0a0a98af-2004-4926-a7d8-1a0acb78df5a@leemhuis.info>
 <255376e5-9fba-4da1-ae0b-2b116ebf6fcb@app.fastmail.com>
From: Thorsten Leemhuis <regressions@leemhuis.info>
Content-Language: de-DE, en-US
In-Reply-To: <255376e5-9fba-4da1-ae0b-2b116ebf6fcb@app.fastmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-PPP-Message-ID: <178473080540.2236016.9044575877088627403@mxe9fb.netcup.net>
X-NC-CID: NqT06h1UC4FBekCImEexrNokib539fM27ka7bgLMLlBCP/+JWJs=

On 7/22/26 15:48, Chuck Lever wrote:
> On Wed, Jul 22, 2026, at 6:24 AM, Thorsten Leemhuis wrote:
>> On 7/9/26 19:40, Chuck Lever wrote:
>>> __destroy_client() releases a client's open owners, but a lock owner
>>> whose only reference is a blocked lock (nbl) stays on
>>> cl_ownerstr_hashtbl.  client_has_state() does not count a bare owner,
>>> so DESTROY_CLIENTID can reach __destroy_client() with such owners
>>> present.
>>>
>>> [...]
>>>
>>> Reported-by: Wolfgang Walter <linux@stwm.de>
>>> Closes: https://lore.kernel.org/linux-nfs/6eccafaaaa60651ef091257c3439c46b@stwm.de/
>>> Fixes: 68ef3bc31664 ("nfsd: remove blocked locks on client teardown")
>>
>> What's the plan to merge this change? From the outside it looks like a
>> fix for a user reported regression from this merge window, as Wolfgang
>> afaics blamed commit 516403d4d85607 ("Revert "NFSD: Defer sub-object
>> cleanup in export put callbacks""), which also made it to various stable
>> trees.
>>
>> So shouldn't this change ideally be on it's way to Linus by now? Ideally
>> with a stable tag to ensure quick backporting? Or is it not a good idea
>> to have this in without the follow-up patches from this series?
>>
>> Or did I get something totally wrong (which is easily possible from my
>> external point)?
> 
> Thorsten, thanks for your attention to this issue.

Thank you for the answer!
> Here is the plan of record:
> 
> This commit is currently in nfsd-testing:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git/commit/?h=nfsd-testing&id=3055ac7c996369876342aa22a33bcc68cd4abca1

Ahh, I see, the change gained a stable tag somewhere along the way, great!

> It will matriculate to nfsd-next in a week or so and then be
> sent to Linus in the initial nfsd-7.3 pull request.

Hmmm. Just reread your reply to Wolfgang's report where you explain
things in more detail:
https://lore.kernel.org/stable/20260703160306.1651327-1-cel@kernel.org/

I now understand this better and it still feels to me like a situation
where Linus would want the fix to be included in mainline quickly[1] --
among others to not have another release with the bug[2] and because
it's something a user reported[3]. Yes, the root of the problem might be
in an older commit the Fixes: tag quoted above refers to -- but
apparently something (maybe the change Wolfgang and you suspected) seems
to have exposed the problem or made it happen more often at least in
6.18.y.

Anyway, if Wolfgang is the only one that seems to hit this and is happy
with the state of things I guess it's not worth arguing further about.

Thanks again for taking the time to answer my mail!

Ciao, Thorsten

[1] and Greg likely as well, as situations like that are the reason why
stable kernels released during or shortly after the merge window have
many hundreds of changes that have seen little testing (and we are
currently at the point where it could get some testing before hitting a
new release)

[2]
https://lore.kernel.org/all/CAHk-=wis_qQy4oDNynNKi5b7Qhosmxtoj1jxo5wmB6SRUwQUBQ@mail.gmail.com/

[3]
https://www.kernel.org/doc/html/latest/process/handling-regressions.html#on-how-quickly-regressions-should-be-fixed
