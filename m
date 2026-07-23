Received: from email.studentenwerk.mhn.de (email.studentenwerk.mhn.de [141.84.225.229])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30B264399FF
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 09:56:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=141.84.225.229
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784800611; cv=none; b=u7AmY+qPSeExrRqB/6TGJBOneKuFZrIGQ/x/vZ715FhAOdQaZwBARDqgmiT7kPdXSDqIem9a7PSuZS+f8ZXYQlVPRbDzSz5sLi5YgIEtlqzB1ev/JziOIRF1AqGnfXNIMQ72CLwQ0hvLI2Iynk9xIXEvezogsZo5DAirHHADGko=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784800611; c=relaxed/simple;
	bh=jhXZHrdVem/tdTftT1WzCi+U+6BNfJpt8ZY9pIQnduI=;
	h=MIME-Version:Date:From:To:Cc:Subject:In-Reply-To:References:
	 Message-ID:Content-Type; b=KZ9s3jSLz0SVeKcx4I1A6Try+2x31fWJWbhJ0FGFuKcij5PRaKftyhm5spcDkQOdIRiu/8iT2hkRZbfgRHkc+mJvzJUuygT+rW4gvNjepSQQzd2mbW+vZIt1sWDoXipN/TYqsABYdWA7bDkmPzBL2oXE0GbAQ0KhYsKVIuftv1k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=stwm.de; spf=pass smtp.mailfrom=stwm.de; dkim=pass (2048-bit key) header.d=stwm.de header.i=@stwm.de header.b=bOwnlwlf; arc=none smtp.client-ip=141.84.225.229
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=stwm.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=stwm.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=stwm.de header.i=@stwm.de header.b="bOwnlwlf"
Received: from mailhub.studentenwerk.mhn.de (mailhub.studentenwerk.mhn.de [127.0.0.1])
	by email.studentenwerk.mhn.de (Postfix) with ESMTPS id 4h5RC16Zn2zRhRh;
	Thu, 23 Jul 2026 11:48:29 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=stwm.de; s=stwm-20170627;
	t=1784800109;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=zNqfVl9aqOBcvUizsHiYDMuyMpSMH55YUWJhOb5PVlY=;
	b=bOwnlwlfnGfX9eqpQNcwkZBz1xMVGZ0WBsx1meqLOKIfj1CEsjFzGc/O4byVsKqqxCv79i
	Qv91nJneGLjiLi+oC6zRZfWtIyGPc8FbRvcipALSZUHW7ep05ThGGleGBJgl60utXmyzxk
	gKG/ve9EMcP2xQkUiDwv9ULOlwjROcXEou1hqDNsXJCYi4M00LezcH6MRRz8kPM6VmtxYB
	M04AbBzem/MHngX5im2od65awg3gOElHSueNzmY8zewm3Mt3QOLAWflYRiGHTwv7GponV3
	oNi8I8zZ3yoqQdDILFzfHkklSrAnXzHlxzlwFsoGHqc4wEvBSyiCJqjVBe5/FQ==
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Thu, 23 Jul 2026 11:48:29 +0200
From: Wolfgang Walter <linux@stwm.de>
To: Thorsten Leemhuis <regressions@leemhuis.info>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai
 Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 linux-nfs@vger.kernel.org, Linux kernel regressions list
 <regressions@lists.linux.dev>
Subject: Re: [PATCH v4 1/9] NFSD: Prevent lock owner use-after-free during
 client teardown
In-Reply-To: <27667adc-3dab-424d-9e6f-52c91c47a51d@leemhuis.info>
References: <20260709-cel-v4-0-1d519d9be0cb@kernel.org>
 <20260709-cel-v4-1-1d519d9be0cb@kernel.org>
 <0a0a98af-2004-4926-a7d8-1a0acb78df5a@leemhuis.info>
 <255376e5-9fba-4da1-ae0b-2b116ebf6fcb@app.fastmail.com>
 <27667adc-3dab-424d-9e6f-52c91c47a51d@leemhuis.info>
Message-ID: <eb5d774709b3cbb01f5ed081a587305c@stwm.de>
X-Sender: linux@stwm.de
Organization: =?UTF-8?Q?Studierendenwerk_M=C3=BCnchen_Oberbayern?=
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit

Hello Thorsten!

Am 2026-07-22 16:33, schrieb Thorsten Leemhuis:
> On 7/22/26 15:48, Chuck Lever wrote:
>> On Wed, Jul 22, 2026, at 6:24 AM, Thorsten Leemhuis wrote:
>>> On 7/9/26 19:40, Chuck Lever wrote:
>>>> __destroy_client() releases a client's open owners, but a lock owner
>>>> whose only reference is a blocked lock (nbl) stays on
>>>> cl_ownerstr_hashtbl.  client_has_state() does not count a bare 
>>>> owner,
>>>> so DESTROY_CLIENTID can reach __destroy_client() with such owners
>>>> present.
>>>> 
>>>> [...]
>>>> 
>>>> Reported-by: Wolfgang Walter <linux@stwm.de>
>>>> Closes: 
>>>> https://lore.kernel.org/linux-nfs/6eccafaaaa60651ef091257c3439c46b@stwm.de/
>>>> Fixes: 68ef3bc31664 ("nfsd: remove blocked locks on client 
>>>> teardown")
>>> 
>>> What's the plan to merge this change? From the outside it looks like 
>>> a
>>> fix for a user reported regression from this merge window, as 
>>> Wolfgang
>>> afaics blamed commit 516403d4d85607 ("Revert "NFSD: Defer sub-object
>>> cleanup in export put callbacks""), which also made it to various 
>>> stable
>>> trees.
>>> 
>>> So shouldn't this change ideally be on it's way to Linus by now? 
>>> Ideally
>>> with a stable tag to ensure quick backporting? Or is it not a good 
>>> idea
>>> to have this in without the follow-up patches from this series?
>>> 
>>> Or did I get something totally wrong (which is easily possible from 
>>> my
>>> external point)?
>> 
>> Thorsten, thanks for your attention to this issue.
> 
> Thank you for the answer!
>> Here is the plan of record:
>> 
>> This commit is currently in nfsd-testing:
>> 
>> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git/commit/?h=nfsd-testing&id=3055ac7c996369876342aa22a33bcc68cd4abca1
> 
> Ahh, I see, the change gained a stable tag somewhere along the way, 
> great!
> 
>> It will matriculate to nfsd-next in a week or so and then be
>> sent to Linus in the initial nfsd-7.3 pull request.
> 
> Hmmm. Just reread your reply to Wolfgang's report where you explain
> things in more detail:
> https://lore.kernel.org/stable/20260703160306.1651327-1-cel@kernel.org/
> 
> I now understand this better and it still feels to me like a situation
> where Linus would want the fix to be included in mainline quickly[1] --
> among others to not have another release with the bug[2] and because
> it's something a user reported[3]. Yes, the root of the problem might 
> be
> in an older commit the Fixes: tag quoted above refers to -- but
> apparently something (maybe the change Wolfgang and you suspected) 
> seems
> to have exposed the problem or made it happen more often at least in
> 6.18.y.
> 
> Anyway, if Wolfgang is the only one that seems to hit this and is happy
> with the state of things I guess it's not worth arguing further about.
> 

I'm very happy having this patch and especially that I got it so fast. 
If I build a new version of a stable kernel I just rebase this patch on 
top of it. Git makes carrying such patches very easy.

So I'm pefectly fine if this goes into stable/lts a bit later.

> Thanks again for taking the time to answer my mail!
> 
> Ciao, Thorsten
> 
> [1] and Greg likely as well, as situations like that are the reason why
> stable kernels released during or shortly after the merge window have
> many hundreds of changes that have seen little testing (and we are
> currently at the point where it could get some testing before hitting a
> new release)
> 
> [2]
> https://lore.kernel.org/all/CAHk-=wis_qQy4oDNynNKi5b7Qhosmxtoj1jxo5wmB6SRUwQUBQ@mail.gmail.com/
> 
> [3]
> https://www.kernel.org/doc/html/latest/process/handling-regressions.html#on-how-quickly-regressions-should-be-fixed

Ciao,
-- 
Wolfgang Walter
Studierendenwerk München Oberbayern
Anstalt des öffentlichen Rechts
