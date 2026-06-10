Received: from relay.yourmailgateway.de (relay.yourmailgateway.de [194.59.206.189])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5237409E0F;
	Wed, 10 Jun 2026 16:12:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=194.59.206.189
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781107945; cv=none; b=I7KoTwenidMLo96aHGB2OKj2+BMrCKyPHphgz2jmcxIAuaCF1W9o/J5KSZEKCAeUp3E46RAC0vs8rLjfwXg1fc8imTviRnTXGdtTlr4qYjlLPVvjPig9ZD/np8VbVm4stSN48nIvVqQ+JCYMrVZUvl2+EgzsztmUuxtsxVlu0To=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781107945; c=relaxed/simple;
	bh=N2Vp3+NXkkwYGSeyZCVnIKlKNyk2cVjtZANmuIr7ATU=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=mw7QNYGYOvF26JuL0iCCdtXstFGRm+Iaw9Za8bxhQKOurJCu4pMAMLVaCyTLCDb4/PqQQPVJqXGRZErMeO5r8Ab3yigB1N8ygx6cU7M82GU9Fot/CwVQt8Px9EVZ0++eKfHV/ZN0ICI01Y3KpegfkNdJNKGvqvdHtXRTuBr0kXw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=leemhuis.info; spf=pass smtp.mailfrom=leemhuis.info; dkim=pass (2048-bit key) header.d=leemhuis.info header.i=@leemhuis.info header.b=f7zf+0ga; arc=none smtp.client-ip=194.59.206.189
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=leemhuis.info
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=leemhuis.info
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=leemhuis.info header.i=@leemhuis.info header.b="f7zf+0ga"
Received: from relay02-mors.netcup.net (localhost [127.0.0.1])
	by relay02-mors.netcup.net (Postfix) with ESMTPS id 4gb9lc2DqRz4KZQ;
	Wed, 10 Jun 2026 18:12:12 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=leemhuis.info;
	s=key2; t=1781107932;
	bh=N2Vp3+NXkkwYGSeyZCVnIKlKNyk2cVjtZANmuIr7ATU=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=f7zf+0gau605TEMXVnszT5wNaUhLb/9Am3A7QwUssOgQhyVzOP+yX5LonAn8CHn2h
	 pjmQVN6DcBtgQJKqhJihUIwzP7iPFhVdcTM8E8VumZvDhLP6XsvL79VNe+aOFR7tPE
	 qqlpBs/RJxff+dcLigXkJuuMMJ+sqTmt+iqZPfDdfxug0H1og9k1Gcv6f7t2l/yb02
	 9pu6A9LBYIZzOO/eZ9L+rH/2JFE+CXGo56OktJF4FbVixqXXwEs4icjvT/eLdWGQob
	 RGya8uPhle85LeIk35Js9AICDEUQp72zAZyuOFQg1Zql5TFneRuOsTNp63+NRtCrfu
	 gyUg8/m9XJAWg==
Received: from policy02-mors.netcup.net (unknown [46.38.225.35])
	by relay02-mors.netcup.net (Postfix) with ESMTPS id 4gb9lc1XXHz7xM6;
	Wed, 10 Jun 2026 18:12:12 +0200 (CEST)
Received: from mxe9fb.netcup.net (unknown [10.243.12.53])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by policy02-mors.netcup.net (Postfix) with ESMTPS id 4gb9lb3yj0z8svF;
	Wed, 10 Jun 2026 18:12:11 +0200 (CEST)
Received: from [IPV6:2a02:8108:8984:1d00:a0cf:1912:4be:477f] (unknown [IPv6:2a02:8108:8984:1d00:a0cf:1912:4be:477f])
	by mxe9fb.netcup.net (Postfix) with ESMTPSA id 349E660363;
	Wed, 10 Jun 2026 18:12:10 +0200 (CEST)
Authentication-Results: mxe9fb;
        spf=pass (sender IP is 2a02:8108:8984:1d00:a0cf:1912:4be:477f) smtp.mailfrom=regressions@leemhuis.info smtp.helo=[IPV6:2a02:8108:8984:1d00:a0cf:1912:4be:477f]
Received-SPF: pass (mxe9fb: connection is authenticated)
Message-ID: <5492f53d-600f-4de9-ba98-1f82a4880bf1@leemhuis.info>
Date: Wed, 10 Jun 2026 18:12:08 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] NFSv4: clear exception state on successful mkdir retry
To: Anna Schumaker <anna@kernel.org>, Trond Myklebust <trondmy@kernel.org>,
 NeilBrown <neil@brown.name>, Igor Raits <igor.raits@gmail.com>
Cc: =?UTF-8?B?SmFuIMSMw61wYQ==?= <jan.cipa@gooddata.com>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org,
 Linux kernel regressions list <regressions@lists.linux.dev>
References: <177745671692.1474915.5018486129724109553@noble.neil.brown.name>
 <20260429104938.1776671-1-igor.raits@gmail.com>
 <971ecb6c-2687-429f-af86-fc980c2d04f9@leemhuis.info>
 <5cbf8431-e3c4-41d9-afcd-fb121dc12395@leemhuis.info>
 <fa68fbe1-466e-4fa3-8245-8eb61243b409@app.fastmail.com>
From: Thorsten Leemhuis <regressions@leemhuis.info>
Content-Language: de-DE, en-US
In-Reply-To: <fa68fbe1-466e-4fa3-8245-8eb61243b409@app.fastmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-PPP-Message-ID: <178110793057.3660475.9284108534434954215@mxe9fb.netcup.net>
X-Rspamd-Server: rspamd-worker-8404
X-Rspamd-Queue-Id: 349E660363
X-NC-CID: KamAnLYGUEdl9CtO3ghd1LrSXt6ggQZ6fk1YhWZonMwh555PCmA=

On 6/10/26 16:28, Anna Schumaker wrote:
> On Tue, Jun 9, 2026, at 6:05 AM, Thorsten Leemhuis wrote:
>> On 5/13/26 09:18, Thorsten Leemhuis wrote:
>>> [top-posting to facilitate processing]
>>> 
>>> @NFSv4 maintainers, just wondering, did this patch maybe fall
>>> through the cracks? It fixes a regression, that's why it's on my
>>> radar. Or was there some progress and I missed it?
> 
> The patch is in my linux-next branch here: https://git.linux-
> nfs.org/?p=anna/linux-
> nfs.git;a=commit;h=238e9b51aa29f48b6243212a3b75c8e48d6b96fd
> 
> It'll be included when the merge window opens this weekend.

Great, thx Anna. Was a bit confused why I could not see in -next 90
minutes ago (that where I checked yesterday before prodding, too), but
it turned up there in the new -next release that was published a few
minutes ago. :-D

Ciao, Thorsten

>> Still no progress afaics. Feels like I'm missing something obvious
>> or like I'm totally of track.
>> 
>> Igor, Neil, is that the case? Or are you also waiting for the fix
>> to make progress?
>> 
>> Ciao, Thorsten
>> 
>>> On 4/29/26 12:49, Igor Raits wrote:
>>>> After a server returns NFS4ERR_DELAY for an NFSv4 CREATE
>>>> issued by mkdir(2), the client correctly waits and retries.
>>>> When the retry succeeds, however, mkdir(2) can still surface -
>>>> EEXIST to userspace even though the directory was just created
>>>> on the server.
>>>> 
>>>> Reproducer (random 16-hex names so collisions are not the
>>>> cause) against an in-kernel Linux nfsd; reproduces under both
>>>> NFSv4.0 and NFSv4.2:
>>>> 
>>>> N=2000000; base=/var/gdc/export for ((i=1; i<=N; i++)); do 
>>>> d=$base/$(openssl rand -hex 8) mkdir "$d" 2>/dev/null || echo
>>>> "$(date +%T) failed loop=$i $d" rmdir "$d" 2>/dev/null done
>>>> 
>>>> Failures cluster at the cadence at which the server-side auth/
>>>> export cache refresh path causes nfsd to return NFS4ERR_DELAY
>>>> for CREATE.
>>>> 
>>>> A wire trace of one failure (the three CREATE RPCs all come
>>>> from a single mkdir(2), generated by the do-while in
>>>> nfs4_proc_mkdir()):
>>>> 
>>>> client -> server  CREATE name=...  -> NFS4ERR_DELAY ~100 ms
>>>> later client -> server  CREATE name=...  -> NFS4_OK
>>>> (dir created) ~80 us later client -> server  CREATE name=...  -
>>>> > NFS4ERR_EXIST   (correct)
>>>> 
>>>> Since commit dd862da61e91 ("nfs: fix incorrect handling of
>>>> large-number NFS errors in nfs4_do_mkdir()"),
>>>> nfs4_handle_exception() is called only when _nfs4_proc_mkdir()
>>>> returned an error.  That gate breaks retry-state hygiene:
>>>> nfs4_do_handle_exception() resets exception.{delay,recovering, 
>>>> retry} to 0 on entry, so calling it on success is what
>>>> previously cleared the retry flag set by the preceding
>>>> NFS4ERR_DELAY iteration. With the gate in place,
>>>> exception.retry stays at 1 after the successful retry, the
>>>> loop runs once more, and the resulting CREATE for an already-
>>>> created name yields NFS4ERR_EXIST -> -EEXIST to userspace.
>>>> 
>>>> Drop the conditional and call nfs4_handle_exception()
>>>> unconditionally, matching every other do-while in fs/nfs/
>>>> nfs4proc.c (nfs4_proc_symlink(), nfs4_proc_link(), etc.).  The
>>>> dentry/status separation introduced by that commit is
>>>> preserved.
>>>> 
>>>> Fixes: dd862da61e91 ("nfs: fix incorrect handling of large-
>>>> number NFS errors in nfs4_do_mkdir()") Reported-and-tested-by:
>>>> Jan Čípa <jan.cipa@gooddata.com> Closes: https://
>>>> lore.kernel.org/linux-nfs/
>>>> CA+9S74hSp_tJu2Ffe2BPNC2T25gfkhgjjDkdgSsF5c2rnJq_wA@mail.gmail.com/
>>>>  Reviewed-by: NeilBrown <neil@brown.name> Cc:
>>>> stable@vger.kernel.org Signed-off-by: Igor Raits
>>>> <igor.raits@gmail.com> --- fs/nfs/nfs4proc.c | 5 ++--- 1 file
>>>> changed, 2 insertions(+), 3 deletions(-)
>>>> 
>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c index
>>>> a0885ae55abc..ffd14141ea1d 100644 --- a/fs/nfs/nfs4proc.c +++
>>>> b/fs/nfs/nfs4proc.c @@ -5393,10 +5393,9 @@ static struct
>>>> dentry *nfs4_proc_mkdir(struct inode *dir, struct dentry
>>>> *dentry, do { alias = _nfs4_proc_mkdir(dir, dentry, sattr,
>>>> label, &err); trace_nfs4_mkdir(dir, &dentry->d_name, err); +
>>>> err = nfs4_handle_exception(NFS_SERVER(dir), err, &exception); 
>>>> if (err) -			alias =
>>>> ERR_PTR(nfs4_handle_exception(NFS_SERVER(dir), -
>>>> err, -							      &exception)); +			alias = ERR_PTR(err); }
>>>> while (exception.retry); nfs4_label_release_security(label);
>>>> 
>>> 

