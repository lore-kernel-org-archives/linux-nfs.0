Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.153
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793312329;
	b=0sx77aLL863GHvIN+qrCpd3U6h3NKahMib2rp+wr6/ucdi0I1DoF7pycll109Yv0TU7X
	 TQyXs5R8Ge5AJ4kIw7rDLoe/5UBlxmCymQL6mtRU/1mbFxB16GU2gXH1nwT3b6n+b8DKX
	 599nQIDTObk9xR4c6aMCV+eMoCUXicMTdsB3wWWdxsStkmHjZ89gpPL9qSECDCz6a3dAi
	 BovMFuSNd/KCKHIEVQXDl/JGcj/dyznHS5qnoWHe4YQC2xA3OySVBMHswEJv9S7cZwGDS
	 ucC5+sid5Up0KaKBBrJDRoCRj7Bl0a9vQ+aBVS0wQQC8d9VHzInCLsNrQ1czYFqJP3w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793312329;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=dYvNREiUsRiTBskyYYaUP+byxaqYNnm2fP1oglN4R4c=;
	b=Y0ilW4DR5LkzOpthtRZvN4GSrEX6icbsrEx8LImtuctu7QZ1nZpJz5PrhgbwV4NfEjad
	 dtdaM2HQ7GGD8gusSbNpDDVp8nFxCCVJQLq4Qi4Yg01hKvKvawkRrYtZv/5kghDaja94V
	 KmY/IIHF+U6ujSK1u6WWIYb+7Upilp6NVHBBG22e35Aul5WFrKdjEYvHrvxgjc+OvnLgx
	 f1X1G98CpxscgJNZobkZi5qhQUDKMeAMYnC18d/MN+QKHU7UnBKAsLvXNEAzG55u/YNyt
	 ic8aQApIe1fOwyqO1wtoYj/N3JBC0WE1R/vOc12/xB26RF1WGhuirFitWyIgreFvpVA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=SX01SSl1;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b="cQPIy/B5";
	arc=none smtp.remote-ip=202.12.124.153
Received: from fhigh-b2-smtp.messagingengine.com (fhigh-b2-smtp.messagingengine.com [202.12.124.153])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB7EC606A31C
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 22:18:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BB7EC606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=SX01SSl1;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=cQPIy/B5
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 374A87A012B
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:18:48 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Thu, 29 Oct 2026 18:18:48 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1793312327; x=1793398727; bh=dYvNREiUsRiTBskyYYaUP+byxaqYNnm2fP1
	oglN4R4c=; b=SX01SSl1V+NiFRXqeO+arjh7Wewr/ze8cNATsZ3+V1ARySksUhb
	jGgyW6fBBponQ9wdbda4F8WlLjttm2lx1lAF4BeUaWTg2zxsAmukMpk8t9dBD398
	p8zWw6EZU1SpY8tu3WMJQQWD1EIahm6tA5nBPhGmeZuViD8z85i2oAzKkgHAVUBX
	+XOsekuETDC44XGsY3z/YZO2gnkEVL9okmcCWpnTy0MXEVsCtYaV7qBUTrwzUW9n
	G4B8yjdDRmdruZoFI29pCs5tLstRkLfyU1HLB2o/cKbxY2h+SPctHgVYE+N/jPkY
	YB/N+jO1HjLiIV4d65uypCWS649bRy4Qzpw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1793312327; x=
	1793398727; bh=dYvNREiUsRiTBskyYYaUP+byxaqYNnm2fP1oglN4R4c=; b=c
	QPIy/B5jeSnpBwKEXIYgDUdSSR0TObTsWsoIfjKLuzFTsCkor+HqrR0P7OFUrxuf
	Bme60LFFWMPsd9utYW+hVznyITLFr+MazjdT3j+ah8q2q1DTl8QIig0USN3fO8a/
	vFREMsy/KDhQir6gKplj4hzrBUhmgalklJJzH/v/SvLC3AHLKWj1ZLNoTt3gZ9UF
	InLUSJofaw3iq4m4t2Cq2vZ+n1/syYWwj7cjDpi7E79OPu4vNDAZ4trtuid067fR
	B2Wzza3Fb4pr50tRDdEFmqGkDyRPJh2k7ZTRyLvMQy3DrG/2Rhum3Mvya56HW773
	jUtXOEZnLmjuA8/tL23qA==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793312327; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:ECHcjieelIzLN8vhxzJ2Hk5x/X5MmDjdJ7/qcszRHuKhQCm
	pAEtty9s8SRmOgMGx9VF+9XpKQzWKy/UFb8qRJqd5SGa59IY5DdDcMPThsz+IV4a
	mwGyzJJmWodoYyggzjfc4+veSB9/eHBo0Mzabuxa6wJvdryA2ppM/Slht78Z5NU5
	pPmA8mNQ9FNX9MbVGY3DfLke7HAlENA28siOeLdR+jZjvq6pr605qORLEuE4OZD+
	bK/PVXOS/JTvdDSLgMwweqchGooRRl2nmabi9LG9Uwjlvkq1H7MKJEEoSLYmi1D5
	WgrEAyTe/VTs/dvZ+xWl8aD52ZBzsuOl6l1MykQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:bcWKtY+NKsnKi3i+hHpmjZDTk2LmjLPMizOp6BBT9Is=:ZlYbz2q28kRTRvr3kCm0vKCFLMpKWgsZVGNybIuaVGA=;
X-ME-Sender: <xms:R8bjaq2pkkKEktwQDiS3pZlkyTp2Jv0R78JQnWBmhyikriA48KIr6A>
    <xme:R8bjasrrfSx09QnycAGBPW_W6Yp8D_ZX2YqlMxxi7Gofgf_4mmre1sWo6FtDZNSnE
    irwJe6UfhFHUmA8Jpl0CkR3aRb8V0kIkVSQPkBUzq4l7TGp50Y>
X-ME-Received: <xmr:R8bjanN0KID3facnSu2tKd7bDKl6-mHFF-myodVG1L5g-EJAGtzwSNT7KXD92VcF9ib04xCdGONkzOmfemZJPby5Ks8mEZI>
X-ME-Proxy-Cause: dmFkZTFcmWZ/tmvOmtAan2z4XuabBZX5fEAAKJ7SGDLJh2EbPK8Gfszm2r19Vs2ZriVmnD
    qFJFAGF08f5mR6EVVYhc9agp58e9Ua1PLMBf5rFvck02LDl1HYIRKdzUsEn6E5tj52PX0H
    LIyINRiXO1mFbpYi2F4opfUYe33Ww0yA8W18dVeFeAir+Gvj4Z/SHfA7Un27HtED5I83rY
    X7WjpPY12RBcKFoz7kxJCzHFIyTkXADEEzlbF2TUDn8N5K1jY2XTpqBsp83S0JjhLHSyJR
    R4GrdFclvjhFL7/ATIs1CVu4K2LtRgd+ZOE2IfoQFBtG6nsUOoo4gjavbAU6tcqUL5OqEz
    4i9pfZ2QrZuAMlOFKZ/b0kV5S9cs9akcOwv/5x/yI0jPQ1iKVlEaEFGehXVTz7d02WuNwp
    HxJL6pmlir3MOzBnuGKJxThU0JZPsPggJgbJSr9PqqmzUcSeuV+P9lqrnOAQFdNtK5Vsw8
    LI8pHR2XCZ3JqRUkpKdiUyZGXTrsMXucy90AcUNbHqcA/5O+qyyRirYxiB6h6rIXYNmgCi
    0Gua/Nken+5m+n6RkxdDpKKQQX45Y6bhKZmlPAKwkgnD8E5CAi52NWky5hi/4OcnLd5zJb
    +z+14eJZ8KjIv6EQOuI0nnArP3eoeLgUKqkAntwAWrc5M6WkWtr+xDomv9kg
X-ME-Proxy: <xmx:R8bjauVmvT6C9PcAKIfx5eDYreVa91oZnY3I9DNGZ9sBbwtwq1Wu7g>
    <xmx:R8bjaqse7pRFAX3emtiwRWATRJj4dZqOUVzsaWdDZdT-a-6bDivRow>
    <xmx:R8bjap3FyW9imvrfJUd5abQSxTYSayox4hvJ3K_uVf3v9CoAg2khZw>
    <xmx:R8bjar7R9t_SkdNxSWgDJQH6H7_8rOA8LYGgtYwJ2g-X87N4dW-GsQ>
    <xmx:R8bjak2SoPN3fgf3nFncJVLZiExQHUJlVM-XpK-TM6fkhFTEH5oeNJF9>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 29 Oct 2026 18:18:43 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jan Kara" <jack@suse.cz>, "Jonathan Corbet" <corbet@lwn.net>,
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject:
 Re: [PATCH RFC 00/12] vfs, nfs: concurrent create and unlink in one directory
In-reply-to: <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
References: <20261028041023.3738553-1-neilb@ownmail.net>
  <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
Date: Fri, 30 Oct 2026 09:18:40 +1100
Message-id: <179331232046.1157394.9372059519045294205@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 30 Oct 2026, Jonathan Flynn wrote:
> Hi Neil,
> 
> Thank you for this series; it is what makes these patches possible.  I
> had them on your v3 and have rebased them onto v4.  They extend it so
> that processes on one NFSv4 client can create and remove files in one
> directory concurrently.
> 
>   operations per second   parent exclusive   parent shared   ratio
>   creates                            2,616          29,939   11.4x
>   removals                           2,157          32,360   15.0x

Thanks for the stats.  This confirms that this a useful project to
continue on :-)

But I think you are racing ahead and that we do this "properly" without
per-fs flags etc.

Reflecting on me current plans, I see that rmdir and rename require
the most work.  It would make sense (I think) to delay those and
focus on create/unlink which are relatively straight-forward.

Once all the current prep work lands I want to list d_alloc_parallel()
out of i_rwsem and then add dentry locking.  Then we can move 
i_rwsem locking into ->atomic_open and ->create and ->lookup and
->unlink, and then you can remove that locking for NFS.

I think trying to take a short cut would slow the whole process down.
The 'create' changes you made aren't too bad, but the unlink work is
too complex I think.

But I'm really happy that you've written this proof-of-concept.

Thanks,
NeilBrown


> 
> One client, 96 processes in one directory, each creating files (open
> O_CREAT, a small write, close) for a set time, then removing them all;
> NFSv4.2 to a pNFS metadata server that is not knfsd; your v4, the 7.4
> VFS changes it builds on, the three silly-delete fixes and this series
> on a 7.3-based kernel, among other patches.  Each row switched only its
> own path, by a test-only module parameter not in this series, with the
> other path on; one run each.  The creates row comes from 300 s of
> creates.  The removals row comes from 120 s of creates, and each of its
> runs removed about 3.7 million files; the removal rates vary with that
> number, so it is given.  With the parent held exclusive, operations go
> one server round trip at a time.  2/12 quotes an earlier measurement,
> on a 7.1.13-based kernel.
> 
> How it works.  2/12 lets a filesystem have the parent locked shared for
> O_CREAT (a flag in a new ->iop_flags field), and 6/12 for unlink(2)
> (->unlink_shared() and ->unlink_shared_done()).  The dentry then
> excludes the name: for a create, its in-lookup state, all
> nfs_atomic_open() needs since your 3/9; for a removal, an NFS mark that
> lookups, opens and creates of the name wait on until
> ->unlink_shared_done(), which the VFS calls after the fsnotify delete
> event, if any.  What NFS cannot order that way, such as an open file,
> it hands back to ->unlink() under the exclusive lock; where the server
> reports itself case-insensitive or not case-preserving, NFS sets
> SB_I_NAMES_COLLIDE (3/12) and both keep the exclusive lock.  Both paths
> call d_alloc_parallel() under the shared lock, as lookup does.  When
> your directory-locking changes lift d_alloc_parallel() above i_rwsem,
> these calls have to move with lookup's; the exclusion does not change,
> and the opt-ins go once the VFS stops taking the parent lock (2/12,
> 6/12).
> 
> Patch flow:
>   prereq   1  store re-read server capabilities in one step, for 3
>   create   2  VFS opt-in to take the parent lock shared for O_CREAT
>            3  NFS sets SB_I_NAMES_COLLIDE where names can collide
>            4  NFSv4 directories opt in for O_CREAT
>   remove   5  factor vfs_unlink() into a helper, no functional change
>            6  VFS opt-in: ->unlink_shared(), ->unlink_shared_done()
>            7  a second ->d_fsdata mark, for removals under a shared lock
>            8  keep a dentry carrying that mark hashed
>            9  no new dentries from a listing that a removal overlapped
>           10  the removal method, handing back what it cannot order
>           11  look a name up again once its removal has unhashed it
>           12  NFSv4 directories opt in for unlink
> 
> Three fixes for the silly-delete hand-off, which your 2/9 makes
> reachable, are posted separately, in reply to 2/9.
> 
> Tested on the same kernel over NFSv4.2, with the new paths on and off:
> removal races (with listings, and with tasks killed); O_EXCL creates
> racing unlink, with a kernel-side check that no revalidation trusted a
> removed entry; inotify event order; two clients; and an overlayfs mount
> whose lower file another client renamed away and back.  All passed,
> with no kernel warning or hung task, except the two-client test's check
> that nothing was left behind: on this kernel and on one with an earlier
> revision of this series, it found one silly-renamed file in three of
> four runs, with the new paths off as well as on, so they are not the
> cause.  Each time, the file left behind was not the one that had been
> silly-renamed: the silly-rename's RENAME, which goes by name, had moved
> another file of that name onto the hidden name.  A PROVE_LOCKING and
> KASAN build ran the removal, killed-task and O_EXCL tests with no
> report.  A case-insensitive server, where two spellings of a name never
> made two files, was tested on that earlier revision only; that code has
> not changed since.  Not run: fstests, knfsd as the server, NFSv4.0 or
> 4.1, directory delegations (the server grants none), CONFIG_DEBUG_VFS, a
> weakly ordered CPU.
> 
> One question: are the opt-ins in 2/12 and 6/12 acceptable as interim
> interfaces until the directory-locking changes land?
> 
> The series applies to 83f32c773255 in Linus's tree on top of your v4
> and the three silly-delete fixes.  fs/ compiles there without warnings
> at every commit, with and without CONFIG_DEBUG_VFS and lockdep; I have
> run it only on the 7.3-based kernel above.
> 
> Tools: these patches, their changelogs, the race tests and this letter
> were written with Claude Code, using Anthropic's Claude Opus 5 and
> Claude Opus 5.5 models, at my direction over many sessions: I chose
> among the designs it proposed and directed each revision.  It found, by
> reading the code, the bug that 1/12 fixes: while the client reads a
> server's capabilities again, a capability the server still offers can
> look missing.  The three silly-delete fixes, posted separately, say
> which of their problems it found and how they were tested.
> 
> Thanks,
> Jonathan
> 
> Jonathan Flynn (12):
>   nfs: update a server's capabilities in one step
>   vfs: allow the parent lock to be shared for O_CREAT
>   nfs: tell the VFS when two names can be one entry on the server
>   nfs: concurrent O_CREAT in one NFSv4 directory
>   vfs: factor file removal into a helper, no functional change
>   vfs: let a filesystem remove files with the parent directory locked
>     shared
>   nfs: add a second mark for a removal made with the parent locked
>     shared
>   nfs: keep the dentry of a shared-parent removal hashed
>   nfs: do not cache a name from a listing that a removal overlapped
>   nfs: add the removal method for a parent directory locked shared
>   nfs: look a name up again once its removal has unhashed it
>   nfs: remove files with the parent directory locked shared on NFSv4
> 
>  .../filesystems/directory-locking.rst         |  60 +++
>  Documentation/filesystems/locking.rst         | 259 ++++++++++++-
>  Documentation/filesystems/porting.rst         |  35 ++
>  Documentation/filesystems/vfs.rst             |  25 ++
>  fs/namei.c                                    | 360 +++++++++++++++++-
>  fs/nfs/client.c                               |   1 +
>  fs/nfs/dir.c                                  | 300 ++++++++++++++-
>  fs/nfs/inode.c                                |   2 +
>  fs/nfs/internal.h                             | 211 ++++++++++
>  fs/nfs/nfs4file.c                             |   9 +-
>  fs/nfs/nfs4proc.c                             |  35 +-
>  fs/nfs/nfstrace.h                             |   2 +
>  fs/nfs/super.c                                |   2 +
>  fs/nfs/unlink.c                               |  16 +-
>  include/linux/fs.h                            |  72 ++++
>  include/linux/fs/super_types.h                |   1 +
>  include/linux/nfs_fs.h                        |  28 ++
>  17 files changed, 1361 insertions(+), 57 deletions(-)
> 
> 
> base-commit: 83f32c773255720a661aa45d83e36278135f23f5
> prerequisite-patch-id: 3405b4d6ab8b0bf24ba63a898083d617deec4f24
> prerequisite-patch-id: 096657d6d80d7ca533ccb574d2af65611ede4af2
> prerequisite-patch-id: 1a2319c14739918aef86116647fea28ae85ad4df
> prerequisite-patch-id: 725cb18c3936d50141ef27dafc159bf50b64a5bd
> prerequisite-patch-id: b39cdd352b97e2cd247311fd5db620dbff227bd7
> prerequisite-patch-id: f9f3f0e945cadf96113d4ac9ab8f7b0c207af4e5
> prerequisite-patch-id: 4c09a15390bb556d79bea1ee733f52a58bec80ef
> prerequisite-patch-id: 7c026717a97b2c86a169539822f5d14650f68f8a
> prerequisite-patch-id: a702d54495d0f3d7f88b82411d884dcf5aacf9a0
> prerequisite-patch-id: a7e7263e8916612f3e4b767946b5d9259029f50e
> prerequisite-patch-id: a8e5414df9d9912dcdf9bb1dbb2811ce326a1e1f
> prerequisite-patch-id: e8050b998d5790f3bb4311bc65011735ed7d8b2f
> -- 
> 2.43.0
> 
> 

