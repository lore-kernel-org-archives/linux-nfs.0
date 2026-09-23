Received: from mail-dy2-f12.google.com (mail-dy2-f12.google.com [74.125.229.12])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4AA6A3F8257
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 12:23:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.229.12
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790166234; cv=none; b=IxidtIjyHyIYQwHqUO+BjXHgV2/rMftVSFnTCH9PxNNLz3uz+6VCSx9tUvLxnkD1T4wVHHoj+tdX4z7zWW3Dw0yjdgxD8mA4pkGIkXn5dNAYurtVDGnw6SVrkF+LLjib4hk2XlwDhoCxavQcAKV8QEt/PrhNpVXnfxAL3xm5AkE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790166234; c=relaxed/simple;
	bh=k5YL97mfFILAF6Yu6KsFsFwoENh2hDYtRFN6DHG/twM=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=Tfg/7YwYTaMNk0bHkVVaLiCMLDaRSiEb3MOpDz727k/DEchfo/x76Tj77K0paM7hMuWkqqvH2u7/J9fxtjSEUOnMhRwUXXBssLMicIAX3nNOhzVtmyOhkGHY8ZpsNvZ9GdFvPisguKavhqjVI2rJsfjMTGr82OyK2dhs9Voa2NE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=rR/mtvFE; arc=none smtp.client-ip=74.125.229.12
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rR/mtvFE"
Received: by mail-dy2-f12.google.com with SMTP id 5a478bee46e88-328664e050bso1103198eec.0
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 05:23:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790166231; x=1790771031; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :references:in-reply-to:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=fj/G6mz7AxfG3zF07ioK8BsIOb3IY3mKd71tPMoZu8U=;
        b=rR/mtvFEL7opy7zKzMBn4coU4NjzkHAslVsenROnE8ew7UEXViduPEzBv22lt/kz/S
         cAGuNLve4Ct64LzixIuiFOrDDxiSNeMkZw72SBI5J2SzjHMLlRMGses5QlRyaN9O4w2k
         Ftew+WZA/hSgtVvKfAKLEZKjM5AO/Wgw/9YNUsHhESnguj0ukORlbiOS64prdu6DbbNP
         GrWZFr8VL3AnD0Cd0tzDpdvmYwZlR7P51px6vm3j4HPkG7CJVHvFhfZvNEsF2TNGBHnY
         Oe8QJw53PXvi/vgOet+CNo9gK3QUilfJ9gocycpxtYT5UkDS33lQ6lrxdmpleYhCrMjH
         vcLQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790166231; x=1790771031;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :references:in-reply-to:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=fj/G6mz7AxfG3zF07ioK8BsIOb3IY3mKd71tPMoZu8U=;
        b=dk0J7xGrNe8QjQHjZzAfbwGEbryr1TAgV/qbIcUoQhnqu8RP8JXpqjFzWcpDBVpe9u
         DPwTTzCcFxqlamTVih8Gq2vKmkUhK6pUKTMXpw0jiojzA8VcWkZkuWGhvZExUG4xXT4z
         6Pv71mBLb0pOcRBX17saG35oCgcm+GaPwe1Cnv3fQVACwUJT9Id4sLvU55QAwdcLClaC
         LN3IKPfQ1Y588uUc8gOzjOvTNH7BB8LADU694vznF2rnHirhwAZnGkYikDAdEUFqTTfn
         TO3D0GNv1dVPfYk6aeCLZ4ID5+XDb7GAk6POtcIPzl4gPPCf8kCJ/rVxkYAcVTXNPas/
         WtVA==
X-Gm-Message-State: AFuF++lLSWXipf50gRNp+hi7G3RGKdS49peDWKTtzvS+S+IxV1Y5Cn2N
	mHoZI3ischQPLfGUFqcSljsMciBlMiHRcv6/67dbSnLzW0/pQO1rV/Bx
X-Gm-Gg: AYBFou0j+cyxnX5o5BE8ev92FfaQX4t2JXf7EuJbe8ndKwkGNvO4DpMEs/pEJAsVu63
	utk0tujWG5pZlUj1QOQSGtw1/xb7fItx2xs/zINcfRQCGyMYyKWu414pZoyjmurjrjL1Oes6G0r
	avFcgT/XuqkksjaESuAcA7UiM1edHwOt5xKk6wTviFMyHwwOKBLh7GIaAf6EL2VC7KYv2AFQfcL
	4Eem1Plh3glCgXyd/OSFxxzpNFDEEKNBubKcGOrBjPb+qBCMwgcw5w/24nq59t92LQcrPIT78GG
	vnw46fYdjkw5sDgx4hTtC11nyXM8KKZfbb/YEuFpEnAFc8JvorQ9XMAoiR5RpACnsqziATtKNpI
	AJrUWSD3cgScHLYTsAHU6pWmzEzg8ycP1IAHc9xH6a9rjK2KPMa61r4895TLn83fMnxF4isLgfK
	4Tg22mbU0x9RuHRu+fY/4B4e4gPH4ItMLqQzspWUf3dMJlfL90LJaAyEM4O1rRPDNtLzttJaAwx
	THICLaRYwUuOA==
X-Received: by 2002:a05:7300:fb15:b0:334:2bee:348e with SMTP id 5a478bee46e88-33e8dbc413amr2388336eec.22.1790166230678;
        Wed, 23 Sep 2026 05:23:50 -0700 (PDT)
Received: from localhost ([49.207.151.207])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-33e96358e2bsm6676544eec.16.2026.09.23.05.23.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 23 Sep 2026 05:23:50 -0700 (PDT)
From: Piyush Sachdeva <s.piyush1024@gmail.com>
To: Jeff Layton <jlayton@kernel.org>, Anna Schumaker
 <anna@nowheycreamery.com>, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
 Shyam Prasad N <nspmangalore@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Chuck Lever <cel@kernel.org>,
 Trond Myklebust <trondmy@kernel.org>, sprasad@microsoft.com,
 vaibsharma@microsoft.com
Subject: Re: NFS delegations behavior analysis
In-Reply-To: <6b4764058582acb5a71d83fa9639df10b4c2f717.camel@kernel.org>
References: <m2qzlx7eye.fsf@gmail.com>
 <0b39c1e01a92f99fe456c76523ec7f3aa5dc1a81.camel@kernel.org>
 <455619640.1622514.1782212671358.JavaMail.zimbra@desy.de>
 <a9885b28-a3fb-4ec6-b6fb-1be78ef16b2e@app.fastmail.com>
 <m2a4pqwx98.fsf@gmail.com>
 <6b4764058582acb5a71d83fa9639df10b4c2f717.camel@kernel.org>
Date: Wed, 23 Sep 2026 17:53:45 +0530
Message-ID: <m2wlsc88by.fsf@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Jeff Layton <jlayton@kernel.org> writes:

> On Wed, 2026-09-09 at 15:40 +0530, Piyush Sachdeva wrote:
>> "Anna Schumaker" <anna@nowheycreamery.com> writes:
>>=20
>> > On Tue, Jun 23, 2026, at 7:04 AM, Mkrtchyan, Tigran wrote:
>> > > ----- Original Message -----
>> > > > From: "Jeff Layton" <jlayton@kernel.org>
>> > > > To: "Piyush Sachdeva" <s.piyush1024@gmail.com>, "linux-nfs" <linux=
-nfs@vger.kernel.org>, "Chuck Lever" <cel@kernel.org>,
>> > > > "trondmy" <trondmy@kernel.org>, sfrench@samba.org, sprasad@microso=
ft.com
>> > > > Cc: vaibsharma@microsoft.com
>> > > > Sent: Tuesday, 23 June, 2026 12:50:16
>> > > > Subject: Re: NFS delegations behavior analysis
>> > >=20
>> > > > On Tue, 2026-06-23 at 15:31 +0530, Piyush Sachdeva wrote:
>> > > > > Hi,
>> > > > > Lately I have been running micro benchmarks around the `ls` comm=
and and
>> > > > > reading through the code documentation of the NFS client to bett=
er
>> > > > > understand the client side caching behavior with and without
>> > > > > delegations.
>> > > > >=20
>> > > > > Understanding so far:
>> > > > > Delegations (both file and directory) are granted by the server =
to the
>> > > > > client, indefinitely (until revoked or under the watermark) to c=
ache
>> > > > > attributes. The caching of data is a result of the attribute
>> > > > > cache. Hence forth, a directory delegation will cache the direct=
ory
>> > > > > attributes and the names of the files in the directory, and a fi=
le
>> > > > > delegation will cache the attributes of the file and the file da=
ta.
>> > > > >=20
>> > > > > Workload run:
>> > > > > I focused on the 2 workloads below, doing 2 passes of a large fl=
at
>> > > > > directory (with close to 100K files) -
>> > > > > a cold pass, and warm pass using the cache from the cold pass:
>> > > > > - lslr - ls -lR on both runs
>> > > > > - lsmix - ls -R (cold) and then ls -lR (warm)
>> > > > >=20
>> > > > > I also played with the rdirplus behavior using both the default
>> > > > > heuristic behavior and the `rdirplus=3Dforce` set at mount time.
>> > > > >=20
>> > > > > Numbers:
>> > > > > actimeo=3D5s, rdirplus=3Dforce, ACLs off, flat_dir
>> > > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > > > >=20
>> > > > >                  |         LSLR          |         LSMIX
>> > > > >                  |  (ls -lR cold / warm) |  (p1 ls -R / p2 ls -l=
R)
>> > > > > Operation        |  flat cold  | flat warm |   flat p1   | flat =
p2
>> > > > > -----------------+-------------+-----------+-------------+------=
---
>> > > > > READDIR calls    |    27       |     0     |   27        |    0
>> > > > > READDIR recv B   | 23,603,024  |     0     | 23,603,024  |    0
>> > > > >    call type     | readdirplus |    --     | readdirplus |    --
>> > > > > LOOKUP           |     1       |     0     |    1        |    0
>> > > > > GETATTR          |     3       |  100,000  |    2        | 100,0=
01
>> > > > > ACCESS           |     2       |     0     |    2        |    0
>> > > > > -----------------+-------------+-----------+-------------+------=
---
>> > > > > Elapsed (age)    |  ~14 s      |  ~62 s    |   ~16 s     |  ~63 s
>> > > > >=20
>> > > > >=20
>> > > > > Observations:
>> > > > > When doing `ls` or `ls -l` on a directory, due to the open(2) on=
 the
>> > > > > directory, the client gets a directory delegation - caching the
>> > > > > directory attributes and file names. However, as we don't have f=
ile
>> > > > > delegations due to no open(2) calls to any of the files. Hencefo=
rth,
>> > > > > the cache of file attributes is governed by `actimeo`.
>> > > > > Now here is the interesting bit, if the next `ls -l` is issued a=
fter
>> > > > > the `actimeo`, a massive GETATTR storm hits the server, doing st=
at()
>> > > > > calls for every file in the directory. As a result, the performa=
nce of
>> > > > > this warm `ls -l` run ends up being worse than the cold pass. I =
am
>> > > > > guessing this is most likely due to the compounded "rdirplus" be=
ing more
>> > > > > efficient than stat() calls.
>> > > > >=20
>> > > > >=20
>> > > > > Proposal:
>> > > > > For large directories, this ends up being a massive problem, tak=
ing 1-2
>> > > > > minutes when enumerating a directory on the warm passes.
>> > > > > - An easier way to tackle this could be to do a rdirplus=3D[auto=
 | forced]
>> > > > >   instead of issuing the stat(2) storm to the server: When the c=
lient
>> > > > >   notices that there are cache misses, which would be the case o=
f file
>> > > > >   attributes, instead of fetching file names from the directory-=
delegation
>> > > > >   cache and attributes from GETATTR, the client does a READDIRPL=
US to
>> > > > >   the server, nonetheless.
>> > > > > - A more tedious would be the to cache file attributes as well, =
as a part
>> > > > >   of the directory delegation. This would end up requiring a cha=
nge in the
>> > > > >   NFS protocol spec though.
>> > > > > - Bulk GETATTR calls: I am uncertain of the feasibility of this,=
 but
>> > > > >   what if, the client could do 1 GETATTR call for getting attrib=
utes
>> > > > >   for multiple files.
>> > > >=20
>> > > >=20
>> > > > ls is such a hard workload to get right, because we don't really g=
et an
>> > >=20
>> > > 100% agree. And there were a couple of attempts to address this issue
>> > > (second ls that is slow).
>> > >=20
>> > > > indication in the kernel of what userland's intentions are. It's
>> > > > basically a readdir() call followed by a bunch of stat()'s, but at=
 the
>> > > > point where we're getting the readdir() call, we don't know if use=
rland
>> > > > intends to stat() those files or not. We have to make a guess about
>> > > > that intention.
>> > > >=20
>> > > > In this case, it sounds like the directory cache was valid, so the
>> > > > client decided it didn't need to do a READDIR at all, but the
>> > > > individual files had caches that timed out.
>> > > >=20
>> > > > So imagine you're the kernel client and have been given that second
>> > > > readdir() call: Why should you decide to do a READDIRPLUS at that =
point
>> > > > instead of a regular READDIR?
>> > >=20
>> > > May we need some kind of client-side heuristics, like on the server =
side
>> > > for open-delegations, where after seeing some `stats` for files in t=
he
>> > > In the same directory, the client will decide to switch to READDIR (=
v4)
>> > > to get all attributes in one go.
>> >=20
>> > We do something like that already. I don't think we'll ever have a rea=
ddir
>> > plus heuristic that makes everybody happy without userspace somehow te=
lling
>> > us their intentions. I know a statx-based readdir plus system call pro=
bably
>> > sounds crazy, but something like that would go a long way to take all =
the
>> > guesswork out of things on our end.
>> >=20
>> > Anna
>> >=20
>> > >=20
>> > > Best regards,
>> > >    Tigran.
>> > >=20
>> > > > --
>> > > > Jeff Layton <jlayton@kernel.org>
>> > >=20
>> > > Attachments:
>> > > * smime.p7s
>>=20
>> Hi,
>> I believe the problem from this discussion has been the cost associated
>> with GETATTRs during directory enumerations, compounded by the fact that
>> the kernel can't know whether more GETATTRs on the same directory are
>> coming.
>>=20
>> Since the readdirplus heuristic rework in v5.18, plaing READDIRs
>> fetching the file type in v6.8, and introduction of rdirplus=3Dforce in
>> v6.14, the client has become quite performant especially for the
>> ls-style workloads. find and du, still suffer from GETATTR storms for
>> large-enough directories, as they enumerate the directory once then
>> stat() every child. Note that nfs_getattr() already feeds the
>> cache_hit/cache_miss counters (since v4.10), but that signal lives on
>> the open-directory context and is consumed only inside nfs_readdir().
>> This is where the performance hurts the most.
>>=20
>> As a benchmark, I prototyped a solution for older kernels (v4.18, v5.14,
>> v6.4-based distros). An eBPF-based detector recognizes GETATTR/LOOKUP
>> storms on large flat directories and triggers a userspace helper to
>> enumerate the directory (READDIR(PLUS), start -> EOF). The returned
>> entries refresh the attribute/dcache so subsequent GETATTR/LOOKUP calls
>> are served from cache.  We measured directory-enumeration time and
>> GETATTR/LOOKUP counts drop by ~50=E2=80=9380x on large directories, for =
ls,
>> find, and du.
>>=20
>> With that as evidence, I'd like to propose exploring two in-kernel
>> directions and get your opinion on feasibility and desirability:
>> 1. Extend the existing getattr miss-tracking: when cache_misses on a
>>    directory cross a threshold, trigger a deferred, background
>>    READDIRPLUS to refresh that directory's child attributes. This gives
>>    the find / du case a consumer for the miss signal it already
>>    generates.
>
> Tough call. This adds load to the server for attributes that will never
> be used. My gut feeling is that that might help some workloads, but
> hurt others.
>

I understand the hesitation Jeff, however, based on the numbers above,
it is clear that despite the higher number of READDIR(PLUS)s its still
significantly beneficial compared to the sustained GETATTR storm.
READDIR(PLUS)s may have doubled, but they save us both time and GETATTRs
by close to 50-80x which is tremendous.

Currently cache_miss increments happen for stat() calls anyway, right?
So, the heuristics are updated even today. All we are proposing here is
to trigger a batched pre-fetch of those attributes to the cache using
READDIR(PLUS).

Doing a READDIR(PLUS) during find / du - It might seem wasteful fetching
those attributes, especially if the directory size is large enough for
the enumeration to take longer than actimeo (acregmin). With the patch,
although the first fetch would still be wasteful, but we would end up
offering better performance with subsequent background getdents() called
from stat().

>> 2. A batched-GETATTR path so tools like du /find can request many
>>    children's attributes in fewer round-trips. I recognize there's no
>>    batched-stat() interface today and that this spans userspace and the
>>    kernel, so I'm raising it mainly to ask whether a metadata-batching
>>    interface (or wiring stat readahead to an NFSv4 multi-GETATTR
>>    compound) is something the community would consider.
>>=20
>> I'd appreciate your thoughts on both, particularly whether (1) is best
>> framed as an extension of the v5.18 heuristic.
>
>
> #2 sounds like a mess to get right....
>
> What might be more reasonable is adding a real readdirplus() style-
> system call, like Anna mentioned. Something where userland can do a
> readdir() and pass down a statx() mask to tell the kernel what
> attributes it's interested in, and get back a list of filenames and
> their inodes' attributes in one shot.
>
> That too might not be accepted upstream (it has been attempted before),
> but that seems like it would be a fairly straightforward thing for
> userland, and would work well for "ls -l" and the like.

For both #2 and Anna's recommendation, I believe that there would be a
path needed for findutils as well. Making a case for a change in
findutils / coreutils might not be as straight forward. As a result I am
leaning toward a kernel patch.

I think a prototype-patch could be a good start and during its testing
we can iron out its regression impact (if any) on workloads. During my
experiments with the eBPF based tool, I haven't seen any negative affect
on any of the workload types. If you have a specific workload in mind, I
can give it a shot as well and share the numbers. It'll definitely help
me make my tool more resilient. :)
I think if the thresholds are chosen after keeping sufficient buffers,
we can ensure that the background getdents() are triggered only when the
access pattern is detected.

--=20
Best,
Piyush Sachdeva <s.piyush1024@gmail.com>
