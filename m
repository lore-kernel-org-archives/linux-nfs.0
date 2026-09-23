Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EA73357D1A
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 12:54:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790168057; cv=none; b=DQQJ3WVKp91PgYTPci8LEN6PhNaKbf4msNo/pGOZFv1Rwjwo/v6K9KcJ35VfJRsex4o/LiW/Lbg0pa3P/6P2bVGqjP3j6aSYqMbZqqSAUR7NFxeXrQ53KzCxZBmLf4gvYm8E+Po+LcXT4y4jDllmC8W/6Vg6FptyHfTyMdYbCtQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790168057; c=relaxed/simple;
	bh=rwSp3l1tgvdS9xWLL7ROMjD4ITSIVRqwsEl0fdMFLxA=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=FJ56aHkAWPEC/su6WLoZnsA6PKHUBpSp1HII8DePa3BlNhXrD4tkE3c3H0lRrW4zRltAv8QyR6etMq+z4FoAb64qRypv83wIM/WWxmewIykCqIqF4j4WSpLue35tcoeDVivl9kxbPh+Jj0yWV4Fii2kecQDYdgYGkhksvTGB4kM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ddIXQ8PT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ddIXQ8PT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8C9891F000FF;
	Wed, 23 Sep 2026 12:54:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790168046;
	bh=+r3qCciAOOJUD73d4Shx27/XMkWWAj4Rjnw7K1ZYc38=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=ddIXQ8PT421GrQjxyVbNLdw64CyyFsmIJIGrfNuvqf78yMFPCr+CcOchcJK7YIINi
	 7p5wrRDdYpiDNtpJ9pk0H0+I9gF6feH8e6Ethvue+Be8gzGgdng2MCoBjAn4y5pFKo
	 a7toXO4rY1Xwr4xh5Wq3C+1Oj+fkYZF4s1psJzCwkupNoDruz9cWGrvNZ/p9Z4GwZf
	 3W6KTHJwvN24rVqo0WdqgFsUb23GsdwrpQUCYBQumTAdr8boXugSfxGmjfzzVBAXW8
	 rbuPLKObuSVYTWNiBHh8L8vW9KIh+KHxUhQ4rSlP/MG/aA5eKJoAikTZ8Jka5wgCpK
	 MlQAFY/tX8kxw==
Message-ID: <6fe3c232014125343dbb90cfb31dd1260542a9bf.camel@kernel.org>
Subject: Re: NFS delegations behavior analysis
From: Jeff Layton <jlayton@kernel.org>
To: Piyush Sachdeva <s.piyush1024@gmail.com>, Anna Schumaker
	 <anna@nowheycreamery.com>, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, 
 Shyam Prasad N <nspmangalore@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Chuck Lever <cel@kernel.org>, 
 Trond Myklebust <trondmy@kernel.org>, sprasad@microsoft.com,
 vaibsharma@microsoft.com
Date: Wed, 23 Sep 2026 08:54:03 -0400
In-Reply-To: <m2wlsc88by.fsf@gmail.com>
References: <m2qzlx7eye.fsf@gmail.com>
	 <0b39c1e01a92f99fe456c76523ec7f3aa5dc1a81.camel@kernel.org>
	 <455619640.1622514.1782212671358.JavaMail.zimbra@desy.de>
	 <a9885b28-a3fb-4ec6-b6fb-1be78ef16b2e@app.fastmail.com>
	 <m2a4pqwx98.fsf@gmail.com>
	 <6b4764058582acb5a71d83fa9639df10b4c2f717.camel@kernel.org>
	 <m2wlsc88by.fsf@gmail.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-09-23 at 17:53 +0530, Piyush Sachdeva wrote:
> Jeff Layton <jlayton@kernel.org> writes:
>=20
> > On Wed, 2026-09-09 at 15:40 +0530, Piyush Sachdeva wrote:
> > > "Anna Schumaker" <anna@nowheycreamery.com> writes:
> > >=20
> > > > On Tue, Jun 23, 2026, at 7:04 AM, Mkrtchyan, Tigran wrote:
> > > > > ----- Original Message -----
> > > > > > From: "Jeff Layton" <jlayton@kernel.org>
> > > > > > To: "Piyush Sachdeva" <s.piyush1024@gmail.com>, "linux-nfs" <li=
nux-nfs@vger.kernel.org>, "Chuck Lever" <cel@kernel.org>,
> > > > > > "trondmy" <trondmy@kernel.org>, sfrench@samba.org, sprasad@micr=
osoft.com
> > > > > > Cc: vaibsharma@microsoft.com
> > > > > > Sent: Tuesday, 23 June, 2026 12:50:16
> > > > > > Subject: Re: NFS delegations behavior analysis
> > > > >=20
> > > > > > On Tue, 2026-06-23 at 15:31 +0530, Piyush Sachdeva wrote:
> > > > > > > Hi,
> > > > > > > Lately I have been running micro benchmarks around the `ls` c=
ommand and
> > > > > > > reading through the code documentation of the NFS client to b=
etter
> > > > > > > understand the client side caching behavior with and without
> > > > > > > delegations.
> > > > > > >=20
> > > > > > > Understanding so far:
> > > > > > > Delegations (both file and directory) are granted by the serv=
er to the
> > > > > > > client, indefinitely (until revoked or under the watermark) t=
o cache
> > > > > > > attributes. The caching of data is a result of the attribute
> > > > > > > cache. Hence forth, a directory delegation will cache the dir=
ectory
> > > > > > > attributes and the names of the files in the directory, and a=
 file
> > > > > > > delegation will cache the attributes of the file and the file=
 data.
> > > > > > >=20
> > > > > > > Workload run:
> > > > > > > I focused on the 2 workloads below, doing 2 passes of a large=
 flat
> > > > > > > directory (with close to 100K files) -
> > > > > > > a cold pass, and warm pass using the cache from the cold pass=
:
> > > > > > > - lslr - ls -lR on both runs
> > > > > > > - lsmix - ls -R (cold) and then ls -lR (warm)
> > > > > > >=20
> > > > > > > I also played with the rdirplus behavior using both the defau=
lt
> > > > > > > heuristic behavior and the `rdirplus=3Dforce` set at mount ti=
me.
> > > > > > >=20
> > > > > > > Numbers:
> > > > > > > actimeo=3D5s, rdirplus=3Dforce, ACLs off, flat_dir
> > > > > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > > > > >=20
> > > > > > >                  |         LSLR          |         LSMIX
> > > > > > >                  |  (ls -lR cold / warm) |  (p1 ls -R / p2 ls=
 -lR)
> > > > > > > Operation        |  flat cold  | flat warm |   flat p1   | fl=
at p2
> > > > > > > -----------------+-------------+-----------+-------------+---=
------
> > > > > > > READDIR calls    |    27       |     0     |   27        |   =
 0
> > > > > > > READDIR recv B   | 23,603,024  |     0     | 23,603,024  |   =
 0
> > > > > > >    call type     | readdirplus |    --     | readdirplus |   =
 --
> > > > > > > LOOKUP           |     1       |     0     |    1        |   =
 0
> > > > > > > GETATTR          |     3       |  100,000  |    2        | 10=
0,001
> > > > > > > ACCESS           |     2       |     0     |    2        |   =
 0
> > > > > > > -----------------+-------------+-----------+-------------+---=
------
> > > > > > > Elapsed (age)    |  ~14 s      |  ~62 s    |   ~16 s     |  ~=
63 s
> > > > > > >=20
> > > > > > >=20
> > > > > > > Observations:
> > > > > > > When doing `ls` or `ls -l` on a directory, due to the open(2)=
 on the
> > > > > > > directory, the client gets a directory delegation - caching t=
he
> > > > > > > directory attributes and file names. However, as we don't hav=
e file
> > > > > > > delegations due to no open(2) calls to any of the files. Henc=
eforth,
> > > > > > > the cache of file attributes is governed by `actimeo`.
> > > > > > > Now here is the interesting bit, if the next `ls -l` is issue=
d after
> > > > > > > the `actimeo`, a massive GETATTR storm hits the server, doing=
 stat()
> > > > > > > calls for every file in the directory. As a result, the perfo=
rmance of
> > > > > > > this warm `ls -l` run ends up being worse than the cold pass.=
 I am
> > > > > > > guessing this is most likely due to the compounded "rdirplus"=
 being more
> > > > > > > efficient than stat() calls.
> > > > > > >=20
> > > > > > >=20
> > > > > > > Proposal:
> > > > > > > For large directories, this ends up being a massive problem, =
taking 1-2
> > > > > > > minutes when enumerating a directory on the warm passes.
> > > > > > > - An easier way to tackle this could be to do a rdirplus=3D[a=
uto | forced]
> > > > > > >   instead of issuing the stat(2) storm to the server: When th=
e client
> > > > > > >   notices that there are cache misses, which would be the cas=
e of file
> > > > > > >   attributes, instead of fetching file names from the directo=
ry-delegation
> > > > > > >   cache and attributes from GETATTR, the client does a READDI=
RPLUS to
> > > > > > >   the server, nonetheless.
> > > > > > > - A more tedious would be the to cache file attributes as wel=
l, as a part
> > > > > > >   of the directory delegation. This would end up requiring a =
change in the
> > > > > > >   NFS protocol spec though.
> > > > > > > - Bulk GETATTR calls: I am uncertain of the feasibility of th=
is, but
> > > > > > >   what if, the client could do 1 GETATTR call for getting att=
ributes
> > > > > > >   for multiple files.
> > > > > >=20
> > > > > >=20
> > > > > > ls is such a hard workload to get right, because we don't reall=
y get an
> > > > >=20
> > > > > 100% agree. And there were a couple of attempts to address this i=
ssue
> > > > > (second ls that is slow).
> > > > >=20
> > > > > > indication in the kernel of what userland's intentions are. It'=
s
> > > > > > basically a readdir() call followed by a bunch of stat()'s, but=
 at the
> > > > > > point where we're getting the readdir() call, we don't know if =
userland
> > > > > > intends to stat() those files or not. We have to make a guess a=
bout
> > > > > > that intention.
> > > > > >=20
> > > > > > In this case, it sounds like the directory cache was valid, so =
the
> > > > > > client decided it didn't need to do a READDIR at all, but the
> > > > > > individual files had caches that timed out.
> > > > > >=20
> > > > > > So imagine you're the kernel client and have been given that se=
cond
> > > > > > readdir() call: Why should you decide to do a READDIRPLUS at th=
at point
> > > > > > instead of a regular READDIR?
> > > > >=20
> > > > > May we need some kind of client-side heuristics, like on the serv=
er side
> > > > > for open-delegations, where after seeing some `stats` for files i=
n the
> > > > > In the same directory, the client will decide to switch to READDI=
R (v4)
> > > > > to get all attributes in one go.
> > > >=20
> > > > We do something like that already. I don't think we'll ever have a =
readdir
> > > > plus heuristic that makes everybody happy without userspace somehow=
 telling
> > > > us their intentions. I know a statx-based readdir plus system call =
probably
> > > > sounds crazy, but something like that would go a long way to take a=
ll the
> > > > guesswork out of things on our end.
> > > >=20
> > > > Anna
> > > >=20
> > > > >=20
> > > > > Best regards,
> > > > >    Tigran.
> > > > >=20
> > > > > > --
> > > > > > Jeff Layton <jlayton@kernel.org>
> > > > >=20
> > > > > Attachments:
> > > > > * smime.p7s
> > >=20
> > > Hi,
> > > I believe the problem from this discussion has been the cost associat=
ed
> > > with GETATTRs during directory enumerations, compounded by the fact t=
hat
> > > the kernel can't know whether more GETATTRs on the same directory are
> > > coming.
> > >=20
> > > Since the readdirplus heuristic rework in v5.18, plaing READDIRs
> > > fetching the file type in v6.8, and introduction of rdirplus=3Dforce =
in
> > > v6.14, the client has become quite performant especially for the
> > > ls-style workloads. find and du, still suffer from GETATTR storms for
> > > large-enough directories, as they enumerate the directory once then
> > > stat() every child. Note that nfs_getattr() already feeds the
> > > cache_hit/cache_miss counters (since v4.10), but that signal lives on
> > > the open-directory context and is consumed only inside nfs_readdir().
> > > This is where the performance hurts the most.
> > >=20
> > > As a benchmark, I prototyped a solution for older kernels (v4.18, v5.=
14,
> > > v6.4-based distros). An eBPF-based detector recognizes GETATTR/LOOKUP
> > > storms on large flat directories and triggers a userspace helper to
> > > enumerate the directory (READDIR(PLUS), start -> EOF). The returned
> > > entries refresh the attribute/dcache so subsequent GETATTR/LOOKUP cal=
ls
> > > are served from cache.  We measured directory-enumeration time and
> > > GETATTR/LOOKUP counts drop by ~50=E2=80=9380x on large directories, f=
or ls,
> > > find, and du.
> > >=20
> > > With that as evidence, I'd like to propose exploring two in-kernel
> > > directions and get your opinion on feasibility and desirability:
> > > 1. Extend the existing getattr miss-tracking: when cache_misses on a
> > >    directory cross a threshold, trigger a deferred, background
> > >    READDIRPLUS to refresh that directory's child attributes. This giv=
es
> > >    the find / du case a consumer for the miss signal it already
> > >    generates.
> >=20
> > Tough call. This adds load to the server for attributes that will never
> > be used. My gut feeling is that that might help some workloads, but
> > hurt others.
> >=20
>=20
> I understand the hesitation Jeff, however, based on the numbers above,
> it is clear that despite the higher number of READDIR(PLUS)s its still
> significantly beneficial compared to the sustained GETATTR storm.
> READDIR(PLUS)s may have doubled, but they save us both time and GETATTRs
> by close to 50-80x which is tremendous.
>=20
> Currently cache_miss increments happen for stat() calls anyway, right?
> So, the heuristics are updated even today. All we are proposing here is
> to trigger a batched pre-fetch of those attributes to the cache using
> READDIR(PLUS).
>=20
> Doing a READDIR(PLUS) during find / du - It might seem wasteful fetching
> those attributes, especially if the directory size is large enough for
> the enumeration to take longer than actimeo (acregmin). With the patch,
> although the first fetch would still be wasteful, but we would end up
> offering better performance with subsequent background getdents() called
> from stat().
>=20
> > > 2. A batched-GETATTR path so tools like du /find can request many
> > >    children's attributes in fewer round-trips. I recognize there's no
> > >    batched-stat() interface today and that this spans userspace and t=
he
> > >    kernel, so I'm raising it mainly to ask whether a metadata-batchin=
g
> > >    interface (or wiring stat readahead to an NFSv4 multi-GETATTR
> > >    compound) is something the community would consider.
> > >=20
> > > I'd appreciate your thoughts on both, particularly whether (1) is bes=
t
> > > framed as an extension of the v5.18 heuristic.
> >=20
> >=20
> > #2 sounds like a mess to get right....
> >=20
> > What might be more reasonable is adding a real readdirplus() style-
> > system call, like Anna mentioned. Something where userland can do a
> > readdir() and pass down a statx() mask to tell the kernel what
> > attributes it's interested in, and get back a list of filenames and
> > their inodes' attributes in one shot.
> >=20
> > That too might not be accepted upstream (it has been attempted before),
> > but that seems like it would be a fairly straightforward thing for
> > userland, and would work well for "ls -l" and the like.
>=20
> For both #2 and Anna's recommendation, I believe that there would be a
> path needed for findutils as well. Making a case for a change in
> findutils / coreutils might not be as straight forward. As a result I am
> leaning toward a kernel patch.
>=20

Oh yeah, this would definitely be a long-term solution. It requires a
new syscall and new userland code that can take advantage of it
(witness the the slow transition to statx()).

Realistically this is a years-long project, but I think we've milked
heuristics as best we can at this point when it comes to readdir(). You
basically can't help some workloads without regressing others.

The fundamental problem is that the kernel doesn't know what attrs the
application is interested in (if any) when it does a readdir() and so
it can never make an informed choice about whether to do a "rich"
readdir or not. A new readdirx() syscall would remove that ambiguity
(but it is a lot of work).

--=20
Jeff Layton <jlayton@kernel.org>
