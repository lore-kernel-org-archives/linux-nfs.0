Received: from mail-pj1-f41.google.com (mail-pj1-f41.google.com [209.85.216.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83B754B4876
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 10:10:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788948651; cv=none; b=MDn+qnW8v4xRtkP2ukR4J9kvb509KAYPfmQMPKYwYJW1mS+24I/nFAvy+PrBKNy2ksrRkrooKTxmIgzeS0PHnp5UEj96yR20IjiMkNEdAFEgIonVT9wLyDiCk4rwO93bFV12RFKPXDkGTdlyDffiD7QpT7dxU/PJm2ckqTYTFe4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788948651; c=relaxed/simple;
	bh=fzZ2Mc9RGrXOmShwl7iXcGAF+blRi4mOOw8d80E6nrQ=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=l24fH/F3dJq/4H6tXkx/V13gH0Hl6H9m6D5xqnsKqlOXYybq7lTZCRVD47DZYOc7PrsOJVOUN56pdo9wBEKxLBWv3u7hgkrZS9MDaNVaSbAU/wvrWfG/lDPXVcXYisjmfRZz+zhyl0idUrxHuHcTcf8WYWHtz3dJLozEqIGtEH4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=XqCaZGbP; arc=none smtp.client-ip=209.85.216.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XqCaZGbP"
Received: by mail-pj1-f41.google.com with SMTP id 98e67ed59e1d1-3964e480f76so6576036a91.1
        for <linux-nfs@vger.kernel.org>; Wed, 09 Sep 2026 03:10:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788948649; x=1789553449; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :references:in-reply-to:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=9omal2xwzFIwUc6Vk+uKQeus1cm4KFgGFES1z7Y33eA=;
        b=XqCaZGbPpy8o0HT/7fVu3kT+N7WtEtPvre4YEgkxs0LkzkCIUqI1OVzqT/lK3wzVR7
         l8x7IcRBiWszjMXPbKhkdSUrl+VSNS7cd59BzHeRNQuVF9T46FsK2xXPKedfyqCLmrvq
         VrtcmHdnrTrA5T/N7fN2FPbQlnAgFWlyWWjj3ukF686zz/Cexp/cL2eQ6owYT3N3WGgg
         5/MVCYRwHr7qD1iOROv2zaDfEygbHqASui1iRgFstII9+nkoxnugnmYzyDVBe0OEGVqF
         dhLKZWzbGmmTnoizv89Za2cK6l5s4eZVY88Le+l3LgvUgs/rk0QB/4Zoaoz7b6EEYx/7
         11XA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788948649; x=1789553449;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :references:in-reply-to:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=9omal2xwzFIwUc6Vk+uKQeus1cm4KFgGFES1z7Y33eA=;
        b=CZEnGqTaefVc35lPOu/t1TPFVtOdlw+tkS/U+ue7pbDQwOwgcbrv6BIIW2031wCvTM
         A83SV/uqF2ZKBb132yoSSsUruY9NM/a94qoJrzvipcoA/I81l6zUHbI0Ajj14OiH37TR
         HXW7CHxK4KaeI24bhkAcYy+FQv5odZxdgjyQqLD1TGU+/1Kza5U01X5e92sSvZInfzFB
         moqWI3BgJ7pA03LNA7af42RjWPmoZ8OyutTRHIl5KMIR5zF5WYtJR7xXA4OBQYRSlSUw
         TQx4DZ2mStnJ+r8p3WX+WH6QEQXqr6RMW9OJ3sUtiKsit+UGUgwv4VJkJuDNM1Q38dff
         wIog==
X-Gm-Message-State: AFuF++mob5Q4gdsyjETIFFKemcQrOMnruCCa8+svXwkEKsBd68Wjsn9G
	woUEmkWN3NDiMY7wz3Zjrar2vhziabsgxQU8JI/q0apBXqDATrZU3y5f
X-Gm-Gg: AYBFou3dZdrcWdiU+zLx4Qx0PlrhmcOYEo3sIuNpzIC+sA5789Kpf1zzxMoJsdR0p8Z
	kNJwCbtW+YMlwdMx1uZhxxAgwL8dBIJqLR8VgSYvU4VX/DDwetR+3VDEqNUhlOjzzwzGk0oNvZv
	RadhFKC4InGFHvG4glzRjb53syXNj2mYlY/ZN0MLCMAKQ8a4btcAcL4T0PVdGhkISzjo0KMH7tA
	tyIIjDmHpsw3i4z/gghN8FWIWN5FVtL6zmm061Ca9zEOSnfCL/gVHVQu54hKFXmoiZvbE1zMU44
	BrfK9hZt0TYLU2Yfrde7nDxELBwLbS5cWenJttzeVOYRBQ1OaIGUI3t3jJZFpcEY6z8sjdeb5Dr
	2ASnMgyD4rDBIi8PG1xmfYpadG/J8tOqS4dOJvQn/9bW5fZGQKI7B+AWZO4l42rBssxFga3cnpM
	RGjO7iwC0f96eFMmgipJyKoql6GrOmqnW40DZ2R/nCRSdhk06fikM4LOm8Z844O2KkdjJzGtSJE
	mi9pGK53C0cuw==
X-Received: by 2002:a17:90a:1c96:b0:39b:66ee:a14 with SMTP id 98e67ed59e1d1-39b66ee3442mr17484229a91.25.1788948648777;
        Wed, 09 Sep 2026 03:10:48 -0700 (PDT)
Received: from localhost ([49.207.148.23])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-14324356931sm67432892c88.4.2026.09.09.03.10.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 09 Sep 2026 03:10:47 -0700 (PDT)
From: Piyush Sachdeva <s.piyush1024@gmail.com>
To: Anna Schumaker <anna@nowheycreamery.com>, Tigran Mkrtchyan
 <tigran.mkrtchyan@desy.de>, Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Chuck Lever <cel@kernel.org>,
 Trond Myklebust <trondmy@kernel.org>, sfrench@samba.org,
 sprasad@microsoft.com, vaibsharma@microsoft.com
Subject: Re: NFS delegations behavior analysis
In-Reply-To: <a9885b28-a3fb-4ec6-b6fb-1be78ef16b2e@app.fastmail.com>
References: <m2qzlx7eye.fsf@gmail.com>
 <0b39c1e01a92f99fe456c76523ec7f3aa5dc1a81.camel@kernel.org>
 <455619640.1622514.1782212671358.JavaMail.zimbra@desy.de>
 <a9885b28-a3fb-4ec6-b6fb-1be78ef16b2e@app.fastmail.com>
Date: Wed, 09 Sep 2026 15:40:43 +0530
Message-ID: <m2a4pqwx98.fsf@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

"Anna Schumaker" <anna@nowheycreamery.com> writes:

> On Tue, Jun 23, 2026, at 7:04 AM, Mkrtchyan, Tigran wrote:
>> ----- Original Message -----
>>> From: "Jeff Layton" <jlayton@kernel.org>
>>> To: "Piyush Sachdeva" <s.piyush1024@gmail.com>, "linux-nfs" <linux-nfs@=
vger.kernel.org>, "Chuck Lever" <cel@kernel.org>,
>>> "trondmy" <trondmy@kernel.org>, sfrench@samba.org, sprasad@microsoft.com
>>> Cc: vaibsharma@microsoft.com
>>> Sent: Tuesday, 23 June, 2026 12:50:16
>>> Subject: Re: NFS delegations behavior analysis
>>
>>> On Tue, 2026-06-23 at 15:31 +0530, Piyush Sachdeva wrote:
>>>> Hi,
>>>> Lately I have been running micro benchmarks around the `ls` command and
>>>> reading through the code documentation of the NFS client to better
>>>> understand the client side caching behavior with and without
>>>> delegations.
>>>>=20
>>>> Understanding so far:
>>>> Delegations (both file and directory) are granted by the server to the
>>>> client, indefinitely (until revoked or under the watermark) to cache
>>>> attributes. The caching of data is a result of the attribute
>>>> cache. Hence forth, a directory delegation will cache the directory
>>>> attributes and the names of the files in the directory, and a file
>>>> delegation will cache the attributes of the file and the file data.
>>>>=20
>>>> Workload run:
>>>> I focused on the 2 workloads below, doing 2 passes of a large flat
>>>> directory (with close to 100K files) -
>>>> a cold pass, and warm pass using the cache from the cold pass:
>>>> - lslr - ls -lR on both runs
>>>> - lsmix - ls -R (cold) and then ls -lR (warm)
>>>>=20
>>>> I also played with the rdirplus behavior using both the default
>>>> heuristic behavior and the `rdirplus=3Dforce` set at mount time.
>>>>=20
>>>> Numbers:
>>>> actimeo=3D5s, rdirplus=3Dforce, ACLs off, flat_dir
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>>=20
>>>>                  |         LSLR          |         LSMIX
>>>>                  |  (ls -lR cold / warm) |  (p1 ls -R / p2 ls -lR)
>>>> Operation        |  flat cold  | flat warm |   flat p1   | flat p2
>>>> -----------------+-------------+-----------+-------------+---------
>>>> READDIR calls    |    27       |     0     |   27        |    0
>>>> READDIR recv B   | 23,603,024  |     0     | 23,603,024  |    0
>>>>    call type     | readdirplus |    --     | readdirplus |    --
>>>> LOOKUP           |     1       |     0     |    1        |    0
>>>> GETATTR          |     3       |  100,000  |    2        | 100,001
>>>> ACCESS           |     2       |     0     |    2        |    0
>>>> -----------------+-------------+-----------+-------------+---------
>>>> Elapsed (age)    |  ~14 s      |  ~62 s    |   ~16 s     |  ~63 s
>>>>=20
>>>>=20
>>>> Observations:
>>>> When doing `ls` or `ls -l` on a directory, due to the open(2) on the
>>>> directory, the client gets a directory delegation - caching the
>>>> directory attributes and file names. However, as we don't have file
>>>> delegations due to no open(2) calls to any of the files. Henceforth,
>>>> the cache of file attributes is governed by `actimeo`.
>>>> Now here is the interesting bit, if the next `ls -l` is issued after
>>>> the `actimeo`, a massive GETATTR storm hits the server, doing stat()
>>>> calls for every file in the directory. As a result, the performance of
>>>> this warm `ls -l` run ends up being worse than the cold pass. I am
>>>> guessing this is most likely due to the compounded "rdirplus" being mo=
re
>>>> efficient than stat() calls.
>>>>=20
>>>>=20
>>>> Proposal:
>>>> For large directories, this ends up being a massive problem, taking 1-2
>>>> minutes when enumerating a directory on the warm passes.
>>>> - An easier way to tackle this could be to do a rdirplus=3D[auto | for=
ced]
>>>>   instead of issuing the stat(2) storm to the server: When the client
>>>>   notices that there are cache misses, which would be the case of file
>>>>   attributes, instead of fetching file names from the directory-delega=
tion
>>>>   cache and attributes from GETATTR, the client does a READDIRPLUS to
>>>>   the server, nonetheless.
>>>> - A more tedious would be the to cache file attributes as well, as a p=
art
>>>>   of the directory delegation. This would end up requiring a change in=
 the
>>>>   NFS protocol spec though.
>>>> - Bulk GETATTR calls: I am uncertain of the feasibility of this, but
>>>>   what if, the client could do 1 GETATTR call for getting attributes
>>>>   for multiple files.
>>>=20
>>>=20
>>> ls is such a hard workload to get right, because we don't really get an
>>
>> 100% agree. And there were a couple of attempts to address this issue
>> (second ls that is slow).
>>
>>> indication in the kernel of what userland's intentions are. It's
>>> basically a readdir() call followed by a bunch of stat()'s, but at the
>>> point where we're getting the readdir() call, we don't know if userland
>>> intends to stat() those files or not. We have to make a guess about
>>> that intention.
>>>=20
>>> In this case, it sounds like the directory cache was valid, so the
>>> client decided it didn't need to do a READDIR at all, but the
>>> individual files had caches that timed out.
>>>=20
>>> So imagine you're the kernel client and have been given that second
>>> readdir() call: Why should you decide to do a READDIRPLUS at that point
>>> instead of a regular READDIR?
>>
>> May we need some kind of client-side heuristics, like on the server side
>> for open-delegations, where after seeing some `stats` for files in the
>> In the same directory, the client will decide to switch to READDIR (v4)
>> to get all attributes in one go.
>
> We do something like that already. I don't think we'll ever have a readdir
> plus heuristic that makes everybody happy without userspace somehow telli=
ng
> us their intentions. I know a statx-based readdir plus system call probab=
ly
> sounds crazy, but something like that would go a long way to take all the
> guesswork out of things on our end.
>
> Anna
>
>>
>> Best regards,
>>    Tigran.
>>
>>> --
>>> Jeff Layton <jlayton@kernel.org>
>>
>> Attachments:
>> * smime.p7s

Hi,
I believe the problem from this discussion has been the cost associated
with GETATTRs during directory enumerations, compounded by the fact that
the kernel can't know whether more GETATTRs on the same directory are
coming.

Since the readdirplus heuristic rework in v5.18, plaing READDIRs
fetching the file type in v6.8, and introduction of rdirplus=3Dforce in
v6.14, the client has become quite performant especially for the
ls-style workloads. find and du, still suffer from GETATTR storms for
large-enough directories, as they enumerate the directory once then
stat() every child. Note that nfs_getattr() already feeds the
cache_hit/cache_miss counters (since v4.10), but that signal lives on
the open-directory context and is consumed only inside nfs_readdir().
This is where the performance hurts the most.

As a benchmark, I prototyped a solution for older kernels (v4.18, v5.14,
v6.4-based distros). An eBPF-based detector recognizes GETATTR/LOOKUP
storms on large flat directories and triggers a userspace helper to
enumerate the directory (READDIR(PLUS), start -> EOF). The returned
entries refresh the attribute/dcache so subsequent GETATTR/LOOKUP calls
are served from cache.  We measured directory-enumeration time and
GETATTR/LOOKUP counts drop by ~50=E2=80=9380x on large directories, for ls,
find, and du.

With that as evidence, I'd like to propose exploring two in-kernel
directions and get your opinion on feasibility and desirability:
1. Extend the existing getattr miss-tracking: when cache_misses on a
   directory cross a threshold, trigger a deferred, background
   READDIRPLUS to refresh that directory's child attributes. This gives
   the find / du case a consumer for the miss signal it already
   generates.
2. A batched-GETATTR path so tools like du /find can request many
   children's attributes in fewer round-trips. I recognize there's no
   batched-stat() interface today and that this spans userspace and the
   kernel, so I'm raising it mainly to ask whether a metadata-batching
   interface (or wiring stat readahead to an NFSv4 multi-GETATTR
   compound) is something the community would consider.

I'd appreciate your thoughts on both, particularly whether (1) is best
framed as an extension of the v5.18 heuristic.

--=20
Best,
Piyush Sachdeva
