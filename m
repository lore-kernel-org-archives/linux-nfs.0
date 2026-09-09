Received: from mail-pj2-f12.google.com (mail-pj2-f12.google.com [74.125.227.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A96F43515FB
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 12:07:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788955635; cv=none; b=NSyHYdm4kWtcHD2fnDVRakyz+ylLV29GBlSykAPxPJor2Gd9ARIW1vwZsTwsmVHhWWAXmpSiEMcMeQTy10P5n8dNyeFsZhS82yn7Y/VCWgh7CK98tr5Bw6ndzWA0eCcTaNgPVIdabX9JXGcZFv1NKUe/1vlMZxncucKydbHpYcM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788955635; c=relaxed/simple;
	bh=5/hJSt+dPh0kbJ2p5m3QKho3iaQNvIYAnmY7DizK5UU=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=RwlQsAnye9tdrW02ktZAyHYBTDSwBM4MK2LQhWZZTTcfLP9Z0VA0Z44XHow+ANz60pMtH7VvTeVNIrhUbH/F20x+7qOLIdN3xhlUYPDZ92qUte536DY50k5EyFIv7FTgYevePmXPUiBCWm0FnnDhFMlC4pc+MrB/UT6ZwhyOvSc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=S2jjhG0F; arc=none smtp.client-ip=74.125.227.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="S2jjhG0F"
Received: by mail-pj2-f12.google.com with SMTP id 98e67ed59e1d1-396ccda24a3so81176a91.0
        for <linux-nfs@vger.kernel.org>; Wed, 09 Sep 2026 05:07:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788955633; x=1789560433; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :references:in-reply-to:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=d4+fWhzQirAoJOs0zAhMqBpqj9d/exLFr5ooPAyQado=;
        b=S2jjhG0Fwf7VZuTkEifWMdj8gx0wVE1IK+H5lsDuNsBV64N/EwwuyGLSPjSxgNYTFP
         AHvaHVNfeULiJeK2MsuVKxdbN1usUROa4BfNB1wzBvCKfBB+igYfNpPSj90HjilA02XB
         AiSDTng3dD0ZA8k09Hzjsd/Oausms3VYasMrLFQ/OBVkvqQRHzF4BWw5a6Yc5FLtBI73
         /yfUjsjDiZWZYiJEafddcX1Vl+vUJDSmvmdAQ6T5k4ssXYEdDdC7K9I3MpCknDUo0kxo
         0NlhLnknHYu6idx9fQZRDkFBY/igxa5UTt8M2A456Dtx8joTpmNRZA1HlCHpv/9bzcE+
         Ed2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788955633; x=1789560433;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :references:in-reply-to:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=d4+fWhzQirAoJOs0zAhMqBpqj9d/exLFr5ooPAyQado=;
        b=EHVntu23JI9+hSUoU4J5/IujE4gLpwWtBleTVxsR/xw5GpS3boKmnjk8Y+GDbqMO8Q
         prU2cHE/CmX5HnNBl0VyO7gWMgn2try6bzxNwK/iHvKbsNkvmZ28gNS9VKqRVXiLS+Xu
         XsckTzbKpczHHYQUJhHYA6g5m2b0AXcGnZr4XDve/eHWZftem53g9JHSf7q5eHoPkJQy
         qxl0EjfhAM89C45BIku8Xh1nq8Tn4hUWVFTyW+EyFWVebj9cATT95YI00q04d+9Bg7AZ
         BDdCDxsdr21q7RPC7nL52Pzhf9RjFr5N7e8vl1D8eACwAJfwpw+75ebXNyOTBZ3QLj+e
         bgfA==
X-Gm-Message-State: AFuF++l9/YfrwlJJdS7C6/56CXxRgZdagykm95kthr8tZ7YXXNiJ3euy
	coG0vUK32BH7wZFu9W7pk0tMOfMlQgTUiTZ4GnYwxIiIiuxSIvTmdTMmdLjHzw==
X-Gm-Gg: AYBFou118+7xa3N5j9JO8Svthzs5XAyZ+774hH9BpLRegZTZLbFzqk1kqdfyfjZb8wI
	53jL8jqakKCgVi8arO9jqRg7mh5cp6MCKGvjmcSZjEv8xWJrMJDpSoZrbXgebKtCfqMJBPU2/lh
	M1piZ6rjqwqv/wboKOIRyjaQoziIrW4BrTmgT4ikMu2jryfDGoD0ynAKPGFMzX9ItI8T2kUwjZy
	VEp7DMnaOeEhdbdkBLEmFnZJwElkpnIztfwgF/26zFhMKJuUzPNaUhZz/b60Qg/4KdxfzC3sSTN
	L+rjp7PoU0Gk+Te04Empxl3gIYZU2YHGqnQhBLcgOyMbsnMl4CXij75WgdfdI0Vu9dgXV/qUIVr
	HAZZo7dFeeKqs7CWQwNy+Q3qfgRdBHj4ZT2chhADnx2kYPwQidOc1kSY//8WdRhF3+gZhyXEfSY
	ijSiCAoTJprfSJFUJqFfhb/PwevEktW2VnoMTLe+K0SlW+9Ox7Muy3VXe0CjVqq0ECi+xzjkTIq
	S1EHFVTc9p37to=
X-Received: by 2002:a17:90b:3a44:b0:36d:9e0b:3801 with SMTP id 98e67ed59e1d1-39d70a4fa27mr689921a91.8.1788955632679;
        Wed, 09 Sep 2026 05:07:12 -0700 (PDT)
Received: from localhost ([49.207.148.23])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-14344a86512sm17645418c88.10.2026.09.09.05.07.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 09 Sep 2026 05:07:12 -0700 (PDT)
From: Piyush Sachdeva <s.piyush1024@gmail.com>
To: Anna Schumaker <anna@nowheycreamery.com>, Tigran Mkrtchyan
 <tigran.mkrtchyan@desy.de>, Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Chuck Lever <cel@kernel.org>,
 Trond Myklebust <trondmy@kernel.org>, sfrench@samba.org,
 sprasad@microsoft.com, vaibsharma@microsoft.com
Subject: Re: NFS delegations behavior analysis
In-Reply-To: <m2a4pqwx98.fsf@gmail.com>
References: <m2qzlx7eye.fsf@gmail.com>
 <0b39c1e01a92f99fe456c76523ec7f3aa5dc1a81.camel@kernel.org>
 <455619640.1622514.1782212671358.JavaMail.zimbra@desy.de>
 <a9885b28-a3fb-4ec6-b6fb-1be78ef16b2e@app.fastmail.com>
 <m2a4pqwx98.fsf@gmail.com>
Date: Wed, 09 Sep 2026 17:37:08 +0530
Message-ID: <m25x0ewrv7.fsf@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Piyush Sachdeva <s.piyush1024@gmail.com> writes:

> "Anna Schumaker" <anna@nowheycreamery.com> writes:
>
>> On Tue, Jun 23, 2026, at 7:04 AM, Mkrtchyan, Tigran wrote:
>>> ----- Original Message -----
>>>> From: "Jeff Layton" <jlayton@kernel.org>
>>>> To: "Piyush Sachdeva" <s.piyush1024@gmail.com>, "linux-nfs" <linux-nfs=
@vger.kernel.org>, "Chuck Lever" <cel@kernel.org>,
>>>> "trondmy" <trondmy@kernel.org>, sfrench@samba.org, sprasad@microsoft.c=
om
>>>> Cc: vaibsharma@microsoft.com
>>>> Sent: Tuesday, 23 June, 2026 12:50:16
>>>> Subject: Re: NFS delegations behavior analysis
>>>
>>>> On Tue, 2026-06-23 at 15:31 +0530, Piyush Sachdeva wrote:
>>>>> Hi,
>>>>> Lately I have been running micro benchmarks around the `ls` command a=
nd
>>>>> reading through the code documentation of the NFS client to better
>>>>> understand the client side caching behavior with and without
>>>>> delegations.
>>>>>=20
>>>>> Understanding so far:
>>>>> Delegations (both file and directory) are granted by the server to the
>>>>> client, indefinitely (until revoked or under the watermark) to cache
>>>>> attributes. The caching of data is a result of the attribute
>>>>> cache. Hence forth, a directory delegation will cache the directory
>>>>> attributes and the names of the files in the directory, and a file
>>>>> delegation will cache the attributes of the file and the file data.
>>>>>=20
>>>>> Workload run:
>>>>> I focused on the 2 workloads below, doing 2 passes of a large flat
>>>>> directory (with close to 100K files) -
>>>>> a cold pass, and warm pass using the cache from the cold pass:
>>>>> - lslr - ls -lR on both runs
>>>>> - lsmix - ls -R (cold) and then ls -lR (warm)
>>>>>=20
>>>>> I also played with the rdirplus behavior using both the default
>>>>> heuristic behavior and the `rdirplus=3Dforce` set at mount time.
>>>>>=20
>>>>> Numbers:
>>>>> actimeo=3D5s, rdirplus=3Dforce, ACLs off, flat_dir
>>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>>>=20
>>>>>                  |         LSLR          |         LSMIX
>>>>>                  |  (ls -lR cold / warm) |  (p1 ls -R / p2 ls -lR)
>>>>> Operation        |  flat cold  | flat warm |   flat p1   | flat p2
>>>>> -----------------+-------------+-----------+-------------+---------
>>>>> READDIR calls    |    27       |     0     |   27        |    0
>>>>> READDIR recv B   | 23,603,024  |     0     | 23,603,024  |    0
>>>>>    call type     | readdirplus |    --     | readdirplus |    --
>>>>> LOOKUP           |     1       |     0     |    1        |    0
>>>>> GETATTR          |     3       |  100,000  |    2        | 100,001
>>>>> ACCESS           |     2       |     0     |    2        |    0
>>>>> -----------------+-------------+-----------+-------------+---------
>>>>> Elapsed (age)    |  ~14 s      |  ~62 s    |   ~16 s     |  ~63 s
>>>>>=20
>>>>>=20
>>>>> Observations:
>>>>> When doing `ls` or `ls -l` on a directory, due to the open(2) on the
>>>>> directory, the client gets a directory delegation - caching the
>>>>> directory attributes and file names. However, as we don't have file
>>>>> delegations due to no open(2) calls to any of the files. Henceforth,
>>>>> the cache of file attributes is governed by `actimeo`.
>>>>> Now here is the interesting bit, if the next `ls -l` is issued after
>>>>> the `actimeo`, a massive GETATTR storm hits the server, doing stat()
>>>>> calls for every file in the directory. As a result, the performance of
>>>>> this warm `ls -l` run ends up being worse than the cold pass. I am
>>>>> guessing this is most likely due to the compounded "rdirplus" being m=
ore
>>>>> efficient than stat() calls.
>>>>>=20
>>>>>=20
>>>>> Proposal:
>>>>> For large directories, this ends up being a massive problem, taking 1=
-2
>>>>> minutes when enumerating a directory on the warm passes.
>>>>> - An easier way to tackle this could be to do a rdirplus=3D[auto | fo=
rced]
>>>>>   instead of issuing the stat(2) storm to the server: When the client
>>>>>   notices that there are cache misses, which would be the case of file
>>>>>   attributes, instead of fetching file names from the directory-deleg=
ation
>>>>>   cache and attributes from GETATTR, the client does a READDIRPLUS to
>>>>>   the server, nonetheless.
>>>>> - A more tedious would be the to cache file attributes as well, as a =
part
>>>>>   of the directory delegation. This would end up requiring a change i=
n the
>>>>>   NFS protocol spec though.
>>>>> - Bulk GETATTR calls: I am uncertain of the feasibility of this, but
>>>>>   what if, the client could do 1 GETATTR call for getting attributes
>>>>>   for multiple files.
>>>>=20
>>>>=20
>>>> ls is such a hard workload to get right, because we don't really get an
>>>
>>> 100% agree. And there were a couple of attempts to address this issue
>>> (second ls that is slow).
>>>
>>>> indication in the kernel of what userland's intentions are. It's
>>>> basically a readdir() call followed by a bunch of stat()'s, but at the
>>>> point where we're getting the readdir() call, we don't know if userland
>>>> intends to stat() those files or not. We have to make a guess about
>>>> that intention.
>>>>=20
>>>> In this case, it sounds like the directory cache was valid, so the
>>>> client decided it didn't need to do a READDIR at all, but the
>>>> individual files had caches that timed out.
>>>>=20
>>>> So imagine you're the kernel client and have been given that second
>>>> readdir() call: Why should you decide to do a READDIRPLUS at that point
>>>> instead of a regular READDIR?
>>>
>>> May we need some kind of client-side heuristics, like on the server side
>>> for open-delegations, where after seeing some `stats` for files in the
>>> In the same directory, the client will decide to switch to READDIR (v4)
>>> to get all attributes in one go.
>>
>> We do something like that already. I don't think we'll ever have a readd=
ir
>> plus heuristic that makes everybody happy without userspace somehow tell=
ing
>> us their intentions. I know a statx-based readdir plus system call proba=
bly
>> sounds crazy, but something like that would go a long way to take all the
>> guesswork out of things on our end.
>>
>> Anna
>>
>>>
>>> Best regards,
>>>    Tigran.
>>>
>>>> --
>>>> Jeff Layton <jlayton@kernel.org>
>>>
>>> Attachments:
>>> * smime.p7s
>
> Hi,
> I believe the problem from this discussion has been the cost associated
> with GETATTRs during directory enumerations, compounded by the fact that
> the kernel can't know whether more GETATTRs on the same directory are
> coming.
>
> Since the readdirplus heuristic rework in v5.18, plaing READDIRs
> fetching the file type in v6.8, and introduction of rdirplus=3Dforce in
> v6.14, the client has become quite performant especially for the
> ls-style workloads. find and du, still suffer from GETATTR storms for
> large-enough directories, as they enumerate the directory once then
> stat() every child. Note that nfs_getattr() already feeds the
> cache_hit/cache_miss counters (since v4.10), but that signal lives on
> the open-directory context and is consumed only inside nfs_readdir().
> This is where the performance hurts the most.
>
> As a benchmark, I prototyped a solution for older kernels (v4.18, v5.14,
> v6.4-based distros). An eBPF-based detector recognizes GETATTR/LOOKUP
> storms on large flat directories and triggers a userspace helper to
> enumerate the directory (READDIR(PLUS), start -> EOF). The returned
> entries refresh the attribute/dcache so subsequent GETATTR/LOOKUP calls
> are served from cache.  We measured directory-enumeration time and
> GETATTR/LOOKUP counts drop by ~50=E2=80=9380x on large directories, for l=
s,
> find, and du.
>
> With that as evidence, I'd like to propose exploring two in-kernel
> directions and get your opinion on feasibility and desirability:
> 1. Extend the existing getattr miss-tracking: when cache_misses on a
>    directory cross a threshold, trigger a deferred, background
>    READDIRPLUS to refresh that directory's child attributes. This gives
>    the find / du case a consumer for the miss signal it already
>    generates.
> 2. A batched-GETATTR path so tools like du /find can request many
>    children's attributes in fewer round-trips. I recognize there's no
>    batched-stat() interface today and that this spans userspace and the
>    kernel, so I'm raising it mainly to ask whether a metadata-batching
>    interface (or wiring stat readahead to an NFSv4 multi-GETATTR
>    compound) is something the community would consider.
>
> I'd appreciate your thoughts on both, particularly whether (1) is best
> framed as an extension of the v5.18 heuristic.
>
> --=20
> Best,
> Piyush Sachdeva

I am posting the benchmark numbers of the directory enumeration workload
both with and without the eBPF-based tool for reference.

Different workloads:
- ls_r: 2 iterations of - ls -R "$TARGET_DIR"
- ls_lr: 2 iterations of - ls -lR "$TARGET_DIR"
- lsmix: ls -R "$TARGET_DIR" followed by ls -lR "$TARGET_DIR"
- find: 2 iterations of - find "$TARGET_DIR" -type f -size +0c
- du: 2 iterations of - du "$TARGET_DIR"

- The share gets remounted in between each workload runs.
- Each workload has 2 successive iterations (no gap) - a cold run that
  populates the cache, and after, a warm run that re-uses the cache.
- Distro(kernel): SLES 15 SP5 (v5.14)
- $TARGET_DIR - Flat large directory; file count - 1 Million files
- actimeo=3D30

Numbers:
- Iteration 1 (cold) - without eBPF / with eBPF

op               ls_r                  ls_lr                 lsmix         =
        du                      find
---------------  --------------------  --------------------  --------------=
------  ----------------------  ----------------------
READDIR calls    217 / 455             263 / 263             217 / 454     =
        127 / 422               127 / 421
READDIR recv(B)  210,687,496 /         248,029,456 /         210,687,496 / =
        115,395,048 /           115,395,048 /
                 440,573,116           248,029,456           439,524,444   =
        405,689,200             404,640,792
LOOKUP           30,178 / 6,161        1 / 1                 30,178 / 6,691=
        733,573 / 19,465        733,573 / 5,837
GETATTR          61 / 5                1 / 1                 63 / 5        =
        177,623 / 5             177,622 / 4
ACCESS           2 / 2                 2 / 2                 2 / 2         =
        2 / 2                   2 / 2
elapsed (ms)     919,684 / 40,657      23,938 / 24,984       947,506 / 41,1=
33      2,643,906 / 78,684      2,627,536 / 38,337


- Iteration 2 (warm) - without eBPF / with eBPF

op               ls_r                  ls_lr                 lsmix         =
        du                      find
---------------  --------------------  --------------------  --------------=
------  ----------------------  ----------------------
READDIR calls    217 / 0               0 / 0                 258 / 256     =
        124 / 317               123 / 417
READDIR recv(B)  208,601,368 / 0       0 / 0                 248,909,816 / =
        109,134,232 /           109,134,232 /
                                                             248,909,816   =
        398,379,976             398,379,976
LOOKUP           0 / 0                 0 / 0                 0 / 0         =
        0 / 0                   0 / 0
GETATTR          301,214 / 1           1 / 1                 127 / 127     =
        822,266 / 26,329        822,267 / 25,611
ACCESS           0 / 0                 0 / 0                 0 / 0         =
        0 / 0                   0 / 0
elapsed (ms)     550,011 / 2,648       5,231 / 6,419         23,264 / 24,09=
0       1,494,821 / 65,103      1,527,773 / 64,990


You can see the reduction in total time, GETATTRs and LOOKUPs.=20

--=20
Best,
Piyush Sachdeva <s.piyush1024@gmail.com>
