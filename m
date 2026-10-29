Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.151
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793311148;
	b=UK+aHVQ4469D4GpuIwqxo1qlaWyiqlNaMXNroTVJISBqP7hoq00PF+Kg/nu6kVgoRWer
	 k+dFF+++MT51ZUEuxOTLb/N8pFUS8VTTMPyFku+OJ0yIZdVJGdNUu7j6zlD/oinmgT/pB
	 WqPKABBiar6x+g16cjdbNNBfViGgK+Ub1ngamNm8YgV+apDyV0EThpDwERnlBLY76QGpu
	 mO9rDWZTS312jaPPobHP+qZMOKG7Bm7VOj4pdcBXPBaS/DRh7sNPLCmt+46ApuV2lyd2s
	 sXGUudOqFBz4Y7jlXzqXbrBSive6gRWEetvNoc3OB04o0z+vi6fKRHEhHz8roT9Ke6Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793311148;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=c+x2zXG3amuWLymq6ePZfVJna8ADEcteNj7SJgfcOvU=;
	b=2mBg8Z/9cG91V55+LXJf/FCLIJVu7mcJ7nXZv251IRAnu6fvaA4hhTNkLW8jglrVYeud
	 bUbu8kTM2pUzCkUBQ+sUZSr59eZuwocLJthAreOU5YEAzkSo+SxGraPm7kUa3BDumjE71
	 yArHcZus6e2jZ/67WqhOeFotwlPYO5uueimk0sL/dOCwTdQt1XDgaQMcDxmvUyHnXDf6t
	 J+dNcfUWDmyWrMGVAcbvGDjKhS3DKRBM7YU1JFAIw5zVZJwkIQEjU5M2MFeITpx+KwAX/
	 KaaFL5cTFkvmV4woABayyV7td6z3s3SaWcmMiVaxzjIvR1T6gKCGRLJszqgfo/espZw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=avdOim19;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=eISE7Gz9;
	arc=none smtp.remote-ip=202.12.124.151
Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB235606A31C
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 21:59:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BB235606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=avdOim19;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=eISE7Gz9
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.stl.internal (Postfix) with ESMTP id 0CA941D000D0
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 17:59:02 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Thu, 29 Oct 2026 17:59:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1793311141; x=1793397541; bh=c+x2zXG3amuWLymq6ePZfVJna8ADEcteNj7
	SJgfcOvU=; b=avdOim19vaL8ilkIxf/dAmzJHUMyQ4uaUUj5Ly/nsZfBLkxJjXb
	zbeZQrdW7AfKSl5BLcB9NE5PsJKWdV36r8kXxv10nEmt2/l67DEwM8qUQfsZzgmd
	Sf62CuXv5vn/uPJQE7eEetQ7M7fBReKf3oSjrI4/NB+2gW3UQTjxTDdEhsrYPuf9
	gcRTvCUGarRAxspwgHzWLBcCcrQa/A4hCamd6R+l/4Rlv1FTvNXOs/eNYLI+wcpU
	WJTGo6GItFFIUiQQPbEG+AltADtmkz063i1IEmJQJKQ5RmpIBL+6RY96QsMUIcIH
	ZQmwsoTsRIKhvS6/I+QO4uVtRc4YVDoIx/w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1793311141; x=
	1793397541; bh=c+x2zXG3amuWLymq6ePZfVJna8ADEcteNj7SJgfcOvU=; b=e
	ISE7Gz9+LuV2302EcEuhyDjxG9G3Fx/P+ve0tkl6m9L9MTTJTJxgcURCdkXQtbeh
	0OG7eKMngAM81WLZz06ljyVNpDi1MouHYxhOOGuSduUxr1awnVKT87um12hQ3ISy
	AG26yq2tPXlqnGvcZdgw+aPdKY6mNJ3UOnYlsAhnhkG8iEJuJAcBj4J+VK/XfKex
	y4y3/JqMXoDbGSLTIpwTaSWGkY6Wbo13mWD3PFKw6QEWOZqFw850Z0emWSsVCCwz
	mlRz8jhXCCAzqjiLfs3ZcRZrqSLBCw8fuw5iC6hl2aGeApLJjMH7M5bvGZaN4F9y
	wKODtOOGm0MCS9rOOnzow==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793311141; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:OW9xe9fExQvkZINwp+Z5ed1fyDHqJ6y0Ek+eG33KcX8klDF
	yvuqo0QRUgkWwVDbhBDq0zI6bVs4i/Ul++Q4EVAXW0GItvrrpc52nbVQnQrfF9fd
	E+MmE5wt53TvO23dV+j2iwlR3Ll42/MZU+7UmZZpgPbmk4kCB/tDAKyW9PfnqSuw
	27UEXiWo/vsYH2dmUGak0+L06A6Nd6QocrdO5pCtE+GNxsljEtSrMt++SzlSs63O
	N0OPXYhmsk5TJYbi/OajfzPQdLEKh+yedMh012Iaek7yODXVLBVwGszng8AI6a/C
	NMvNikomKqGYI+Zy8e/yHqO13rCh2XQbbHaWAeQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:sMGlCpjnw+OREV8xYkN1gvoG/pExrpB4so0YUWK7Ynw=:dau+IJCwRRSXtCiunmYk8G3JxQFtG0dAokr4ca7ALAw=;
X-ME-Sender: <xms:pcHjatJC1jTQXTC_s5uiCurNIIiskE8aY6UcSMuhMe2GrIXuY19FiQ>
    <xme:pcHjaqtciedbeN4EwMs_GhaWy8fGEaMOUkzZ9b3qVHLFu7Qf7EDe1gBhgY8pR-n9i
    ZTnWfLRhWM_UQ9L77A2iruuLcVN_C1BO11KjFpfkRwz17KsT3QL>
X-ME-Received: <xmr:pcHjak-t7Pys_jCNc9OPWzwJkLth2HXqTl8EC_tpapjOF8r39ZTUjPpCAoyLd6rvgnmcyiJFuy5JSQcse0Q6jfz3WrD__tA>
X-ME-Proxy-Cause: dmFkZTGkxPqAa7t880SSnwldi4Sgk4W+uswz2b5HSO7z5R23uxu/k0naZt+xYec9ViTgoy
    9jFo8yl5ejHD6thtQvXeHgndnYjUXvho++FNJsmurGtOtb155uxkweBMsIR1FFARiAcvJB
    aqvLRWN6VlWQjX9KRwW1jE2aF0hVnb1Z8Qz+dD/wQ9SnhWoyk/VOLuX8B9jZ/aRteanvMV
    j1mjQZTR00FkNoCDr644GkWfz4uUw4B6PNXAcV4GrOT7vcSEH2lPOvD0Ba5fRKe+ub/h+a
    3nHS2kf8IPPbZ5AwXWQ4KjtntZnuCNjcKNq0dW9Gr0L+7z2CdrD74ytg7TCh8Ig7zMiFhQ
    buZ6NIJaZSpdWC+pDTkTgDG9UyaHGkxaMQ4z/xJO3QLoam0Ry2jqgzn1fj55ZKEoqaWYm7
    IjNqYZ8GP0mNRTIYC6Z3sgVM/B5s2XWc/1I3Wt35mZumfU4gOa2TcC/NYh3ZG/XhN8/ccC
    BX/3yfx0dkrudhSX383nCpNCyega+LNS/6eWmozb3WP8At7Ilga15loyhq4PlI/r+Vyi63
    Bstz6Ihe8QBVcuJTSOMQRO8fQoFnzwbxV4SWCyz3czgZUVyoeAEaVR/NURC6qG757htjyS
    z2acN47QB5BcqH6pXa4WNX5zLTq0GGSes9NWh+6tKTUz6YeEnPoNG4kNQr5Q
X-ME-Proxy: <xmx:pcHjak2WTcZLmK7rXWSxNdxtaAgzaJDt3nZ7KC-SWkqjXbpYnuwqYw>
    <xmx:pcHjapg6p0IGHZPbFKoPXfQEJoqRmXI851QSnJ_ovOfBvwAq9MBCcQ>
    <xmx:pcHjakYBY8ZdGmxSZt2y31zP_KswKq4hjXI-unBD3kqw0i0hxMVA7A>
    <xmx:pcHjalWQxMh7-KWvkpvy5CFu6fEydPFYvm-jOy7Te2aiqK3ZusPDAA>
    <xmx:pcHjagtXZwwkEu13tY8GVpokeVy-1YHU9Ca-fDAItne2rK1tz7RopGXn>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 29 Oct 2026 17:58:57 -0400 (EDT)
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
Cc: "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Chuck Lever" <cel@kernel.org>, "Jan Kara" <jack@suse.cz>,
 linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org
Subject:
 Re: [PATCH 0/3] nfs: fix the silly-delete hand-off that 2/9 makes reachable
In-reply-to: <20261029180950.387072-1-jonathan.flynn@hammerspace.com>
References: <20261028041023.3738553-3-neilb@ownmail.net>
  <20261029180950.387072-1-jonathan.flynn@hammerspace.com>
Date: Fri, 30 Oct 2026 08:58:53 +1100
Message-id: <179331113330.1157394.13262534245118948192@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 30 Oct 2026, Jonathan Flynn wrote:
> Hi Neil,
> 
> Your "nfs: fix nfs_call_unlink()" computes the silly name's hash before
> d_alloc_parallel(), so nfs_call_unlink() can now find another cached
> entry for that name and hand it the pending silly-delete.  With it
> applied, that happens: an entry made by a fresh lookup of the silly
> name, after the original entry was invalidated, receives the delete
> when the file is closed.  Three problems in the hand-off become
> reachable with it, and these patches fix them:

Hi Jonathan,
 thanks for these.  The first 2 definitely make sense. I haven't
 completely thought through the third but it is probably good too.

 But it all seems rather ugly and I'm hoping there is a better way.
 I would like to avoid the hand-off altogether.

 There is a tiny window between the silly dentry being unhashed, and the
 ->d_iput() call which triggers the d_alloc_parallel of a new name.
 A new lookup has to happen in this window to cause a problem.
 I'd like to prevent that lookup from completing.

 I wonder if we could link all the nfs_unlinkdata for a given
 parent directory together and change nfs_lookup() to check that
 list first.  Hopefully it would mostly be empty...
 I think it would be safe to only add a nfs_unlink to the per-directory
 list in nfs_dentry_delete() if DCACHE_NFSFS_RENAMED is set.
 We then remove it once the d_alloc_parallel() completes.
 If nfs_lookup() ever finds the name it wants on the list it ... uhmmm
 maybe blocks on ->rmdir_sem.
 We would need to change the d_alloc_parallel() in nfs_call_unlink()
 to d_alloc_trylock().

 Then we wouldn't need the hand-off at all.  Once nfs_dentry_delete()
 adds the dentry to the per-directory list, the unlink must complete
 and no other dentry will be involved.

 Does that make any sense to you?  Do you think it is worth a try?

Thanks,
NeilBrown


> 
>   1/3  the hand-off can overwrite NFS_FSDATA_BLOCKED on an entry whose
>        REMOVE or RENAME is in flight (Sashiko's review of 2/9 reports
>        this too);
>   2/3  the other order: nfs_rename() tests its target before it takes
>        ->d_lock, so a hand-off landing in between is kfree()d by
>        block_revalidate(), leaving DCACHE_NFSFS_RENAMED set with no
>        data and a NULL dereference at the final dput(); a hand-off
>        that the VFS's unlocked test missed also trips the WARN_ON()s
>        in nfs_unlink() and nfs_rename().  nfs_rename() now tests under
>        ->d_lock, and both return -EBUSY, as may_delete_dentry() does;
>   3/3  nfs_call_unlink() holds rmdir_sem for read across its lookup and
>        across the dput() of the alias, and either can kill a dentry
>        carrying a silly-delete, which re-enters nfs_call_unlink() with
>        rmdir_sem still held: that deadlocks against a waiting rmdir()
>        (Sashiko's review of 2/9 reports the alias case).  It now takes
>        rmdir_sem only for the REMOVE it sends, which also closes an
>        older route to the same re-entry that does not need 2/9:
>        NFSv4's delegation return in ->unlink_setup().
> 
> They have to go wherever 2/9 goes, and its Fixes: tag will take it to
> stable.  Fold them into 2/9 if you prefer, as you did with the d_seq fix
> in 1/9.
> 
> One window is not covered, and you may prefer to close it another way.
> After nfs_unlink() or nfs_rename() clears the mark, and before the
> VFS's d_delete() or nfs_rename()'s d_move(), a hand-off can still land
> on the entry.  For an unlink, that costs only a second REMOVE, which
> finds nothing.  For a rename onto the silly name, the target is left
> owing a REMOVE of a name that now belongs to the renamed file.  That
> REMOVE is normally dropped, because nfs_call_unlink() then finds the
> renamed file's own entry and its file handle differs; but if that entry
> has left the dcache by the time the target's last reference goes, the
> REMOVE is sent and deletes the renamed file.  Closing the rename case
> would take the hand-off refusing an alias that is no longer hashed, and
> nfs_rename() dropping, under ->d_lock and after d_move(), a
> silly-delete that landed after its mark cleared.  I have a draft of
> that, and can test and send it if you want it.
> 
> Tested with your v4 and these patches on a 7.3-based kernel, over
> NFSv4.2 to a pNFS metadata server that is not knfsd.  The hand-off
> happens as described above.  With 3/3, the nested nfs_call_unlink()
> that follows it starts with rmdir_sem not held, where without 3/3 it
> ran with rmdir_sem held for read, and the REMOVE is sent once.  The
> removal race tests of my RFC, posted in reply to your 0/9, passed on
> this kernel, as did a PROVE_LOCKING and KASAN build running them,
> though lockdep does not see rmdir_sem's read hold, which is taken with
> down_read_non_owner().  No test here hits the races that 1/3 and 2/3
> close, or the deadlock itself, so for those the fixes rest on the code.
> 
> The series applies to 83f32c773255 in Linus's tree with your v4, and
> fs/ compiles without warnings at each patch.
> 
> Tools: these patches, their changelogs and this letter were written
> with Claude Code, using Anthropic's Claude Opus 5 and Claude Opus 5.5
> models, at my direction.  It found the problems fixed by 1/3 and 2/3,
> and two of the three routes in 3/3, reading the code with and without
> Sashiko's review prompts; Sashiko's own review of 2/9 reported the
> problem in 1/3 as well, and the route through the alias in 3/3.
> 
> Thanks,
> Jonathan
> 
> Jonathan Flynn (3):
>   nfs: do not transfer a sillydelete onto a blocked dentry
>   nfs: answer a handed-off silly-delete on a removal target with -EBUSY
>   nfs: take rmdir_sem for a silly-delete only when its REMOVE is sent
> 
>  fs/nfs/dir.c    | 32 ++++++++++++++++++++++++++------
>  fs/nfs/unlink.c | 39 ++++++++++++++++++++++++++++++++-------
>  2 files changed, 58 insertions(+), 13 deletions(-)
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
> -- 
> 2.43.0
> 
> 

