Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 616CD367295
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 00:43:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789519418; cv=none; b=LnW7e00Pa0ogZ1Qwv8eMdVz5lP8xi1dSmxbybopxOBjsTx/6SBilw9Zp4YHy3EtNBrd/07lLYNh88DZJvilco/2J09XuVTCsyVF7P9UtSvQlBFwLGlhMLnMAaS1UkHmbBg2eaO6srPENkov7WvzzLYCgbH1q2kD7BaWYtBTLfKs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789519418; c=relaxed/simple;
	bh=k1FSi7vu4zNASx+MCRO6Iv8kh5R++l4zWOOi53vR8Sw=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=ei1Z7CTq0doeUqyCB6jFgQVnEc6+cU/BqowylbmMlaW/LO/nKoEjDVGatN2CLlP9D9qx7fKYPs8x3NJDGLM9Ln3Ux+x4VG4JsX2UNUy52Y02eWlNu96ucNvvhxY4+D0rMQdNjydxyP9KmiZtCPupV48MK+IYz/VSsAI7KfVRXPk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OOSRY8aV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OOSRY8aV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 04B511F00893;
	Wed, 16 Sep 2026 00:43:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789519412;
	bh=l/vJey17GbTZ5uBuDsW8vZhfXhvYLd4Iim5uuyu61uU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=OOSRY8aVtU+HwXxXRo7o9CpvxVKmA2kC8Gg4TOFx6HgYgVLzZCmMIR+31g7tIleiQ
	 QC9bM8NXRswPJcrcCR9JiHfRCT33dHPVI18qRKkWwdE0x9/16Wk87qA/D5ORNs/W3M
	 xxBlidFIVN1/4LvZbyFu1Q21NF4NC58WDes4Traa2wP4geFguNvjT6AOW8AIVlI8gA
	 XrFhDa1Gb9RDQaJvHIyFhXyqkdJmpOMzN/GLxcolQ6Omp30U8Ve4F0Uj1llxdYdQCf
	 6DzHaDTmPcIa5X0NSnH68eJoxIMLD2873v5bh+mSaDTbFcrLnoheCz5wtibo7KNA/9
	 4gFHGOW/LlwTg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0794BF40066;
	Tue, 15 Sep 2026 20:43:31 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 15 Sep 2026 20:43:31 -0400
X-ME-Sender: <xms:Muapat_zhCMALTpodM0vJABAb8NwWS_DhO419IX44WNNFCXLLpXnzw>
    <xme:MuapasgD2aHuq7ZpMZsgBkitxS6JnOVmxpS3AJa0-4-JczzBQ1-8Y03MtBuK4QMjN
    lSGKBjBh3btWdA9Yqr4-mLkrMlEljHM6UiT5MeWsZ8OA-jCEEt63R8>
X-ME-Proxy-Cause: dmFkZTE/dflmObFyT2LF1ez7jrjGUY+PL15DDzjs90HK/ap23xqu60118vN752BLbALZSp
    afKfx23KUy5mf4MXwmmVvsQDus1uj4ndPYjAFRQmtlbK4FsmPZM+KOcOWnUruHHDsEtBbk
    HjcQHHziFvln6zNQvljg1BFurEj1Q3VToK+krwLie5WycjidGZAXmwJlH91rvg9OZmw3PE
    0uuZW9QBSlzeU8Nl3p4h8lBq77nWyUUUT3aOatwcMU1vlkTXT20bM/TM165KrPQIqhgjEq
    Gm2dC/xCvrbaRvkuvqRwSWEi7NZjqCl6RYwOxG53e92ifYfUFqu+0svWCQxsNVmD+B3RZl
    rnFxZXk1NXSav0lijrj0hzhf6qqMeP+hgWvFKO0ri1/w714mGUSRmlXylBt0ZlOYXG3rt8
    83wpWVvJaKjA13XnZictgiIZi3+pXm+6b7eOc7crHD+3NhtGfix61gs0VBfikgvDWGw1Vm
    jW7fsKsBhMSSt0+yZ16NxKNX958+iPTp/Yaucz1GnxjqoXvjEJ1xX6LEj4pIni5UHYz14r
    XonatFweNTY2lawarcdF7C26x4BxQ7J0YMk4bD7HFNRUM/akt92A8jsvNkulJly3E19jU5
    BP2XwN82+Nx+u2I6VWtOgFZap7VSQAD6KMJY1Cc7P+OIcRLtdVzKuxegb6GA
X-ME-Proxy: <xmx:Muapavrgi1AdWs4hFqSDyew-OzDJCANVnPa0wX53EzkViuWnm_ZiFA>
    <xmx:M-apai_WFA4jMy99js8Fx8radoTM7RsDbOWNAdq9JkHxlDaCgnu-SQ>
    <xmx:M-apajc7F1M8OBwxgfyiT03jyFin960WluXynYxXDLpkLSiZGiZnlA>
    <xmx:M-apakK_-xcdFYCJVmxiJwlM3bEWbHfeybXst7UHoXxd_tHbLlVZ2Q>
    <xmx:M-apargx5v76pHb6cixZCxJEPGEi0ubzldVaBWwZurh9fhxY7vW2Pf4T>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DEDA5780070; Tue, 15 Sep 2026 20:43:30 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Tue, 15 Sep 2026 20:43:10 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>, "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
Message-Id: <7b57e635-9fb7-4959-bb91-9506ab76973c@app.fastmail.com>
In-Reply-To: <20260916004141.141884-1-cel@kernel.org>
References: <20260916004141.141884-1-cel@kernel.org>
Subject: Re: [PATCH v1 00/27] Convert server NFSv2 XDR layer to xdrgen
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Sep 15, 2026, at 8:41 PM, Chuck Lever wrote:
> The series replaces NFSD's NFSv2 hand-written XDR encoders and
> decoders with code that was generated mechanically from the RPC
> language definition of NFSv2.
>
> The eventual goal is to convert as much of NFSD's XDR layer to
> mechanically-derived code as possible to reduce the risks of human
> error and memory safety vulnerabilities on the front-line between
> network and internal implementation.
>
> Following this series, the next conversion steps are: NFSv3,
> NFS_ACLv2, NFS_ACLv3.
>
> I've tested this with some simple fstests runs on NFSv2. No new
> issues were found.
>
>
> Chuck Lever (27):
>   Documentation: Add the RPC language description of NFSv2
>   NFSD: Add infrastructure for generating NFSv2 XDR encoders and
>     decoders
>   NFSD: Use xdrgen-generated NFSv2 protocol definitions
>   NFSD: Remove '#include "xdr.h"' from fs/nfsd/xdr3.h
>   NFSD: Relocate the NFSv2 XDR storage union into nfsproc.c
>   NFSD: Use xdrgen XDR functions for the NFSv2 NULL procedure
>   NFSD: Use xdrgen XDR functions for NFSv2 GETATTR procedure
>   NFSD: Use xdrgen XDR functions for NFSv2 SETATTR procedure
>   NFSD: Use xdrgen XDR functions for the NFSv2 ROOT procedure
>   NFSD: Use xdrgen XDR functions for the NFSv2 LOOKUP procedure
>   NFSD: Use xdrgen XDR functions for NFSv2 READLINK procedure
>   NFSD: Use xdrgen XDR functions for NFSv2 READ procedure
>   NFSD: Use xdrgen XDR functions for the NFSv2 WRITECACHE procedure
>   NFSD: Use xdrgen XDR functions for NFSv2 WRITE procedure
>   NFSD: Refactor nfsd_proc_create()
>   NFSD: Use xdrgen XDR functions for NFSv2 CREATE procedure
>   NFSD: Use xdrgen XDR functions for the NFSv2 REMOVE procedure
>   NFSD: Use xdrgen XDR functions for the NFSv2 RENAME procedure
>   NFSD: Use xdrgen XDR functions for the NFSv2 LINK procedure
>   NFSD: Use xdrgen XDR functions for NFSv2 SYMLINK procedure
>   NFSD: Use xdrgen XDR functions for NFSv2 MKDIR procedure
>   NFSD: Use xdrgen XDR functions for NFSv2 RMDIR procedure
>   NFSD: Use xdrgen XDR functions for the NFSv2 STATFS procedure
>   NFSD: Use xdrgen XDR functions for NFSv2 READDIR arguments
>   NFSD: Add a streaming directory reader
>   NFSD: Refactor NFSv2 directory cookie encoding
>   NFSD: Use xdrgen XDR functions for NFSv2 READDIR results
>
>  Documentation/sunrpc/xdr/nfs2.x    |  254 +++++
>  fs/nfs_common/common.c             |    5 +-
>  fs/nfsd/Makefile                   |   15 +-
>  fs/nfsd/nfs2acl.c                  |    2 +-
>  fs/nfsd/nfs2xdr_gen.c              | 1079 +++++++++++++++++++
>  fs/nfsd/nfs2xdr_gen.h              |   46 +
>  fs/nfsd/nfs3xdr.c                  |    2 +
>  fs/nfsd/nfsd.h                     |    2 -
>  fs/nfsd/nfserr.h                   |    2 +-
>  fs/nfsd/nfsfh.h                    |    5 +
>  fs/nfsd/nfsproc.c                  | 1574 +++++++++++++++++++---------
>  fs/nfsd/nfsxdr.c                   |  605 +++--------
>  fs/nfsd/vfs.c                      |  239 +++--
>  fs/nfsd/vfs.h                      |   40 +
>  fs/nfsd/xdr.h                      |  167 +--
>  fs/nfsd/xdr3.h                     |    3 +-
>  include/linux/nfs_common.h         |    4 +-
>  include/linux/sunrpc/xdrgen/nfs2.h |  298 ++++++
>  18 files changed, 3121 insertions(+), 1221 deletions(-)
>  create mode 100644 Documentation/sunrpc/xdr/nfs2.x
>  create mode 100644 fs/nfsd/nfs2xdr_gen.c
>  create mode 100644 fs/nfsd/nfs2xdr_gen.h
>  create mode 100644 include/linux/sunrpc/xdrgen/nfs2.h
>
> -- 
> 2.55.0

Misfire. Please ignore.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
