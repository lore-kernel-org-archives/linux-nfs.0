Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5226B51B192
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 16:42:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791909762; cv=none; b=nACFfC2t7nUE90Os0bQj4udXDKuRjEzZsIG4c67ZYg7CAx0VXhDa2KHCnX19jmUXsXKOHbLSxEV2CmPPKmyR+sagQHfPa7ubheDeT2/0oZqe3QnRwlElnYrkIzCvS/rMRdPPU1TK2Say8/I4ZYkU5fegC+kePeyJ/VWxcX8GguE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791909762; c=relaxed/simple;
	bh=UxaCIgPN6/F5QJpAcDbD9QvYBuwx4ml79n9HqQuSjGs=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=J2MWJ/77NjMI1+EYIxGhgQdIFNMYivVMvOdbu9rM/yUM0M6BWDgBUNv4sNWqvN1jb06znsSiEXrbMQ9tGuO2HvgMNfqPkdGYA9dSretSbt7Ycvt51X6kcFl1uEN2CJFEzGey21if29TkDUDjWCCgc82+lWsMyh86ESvWk+yL1Ak=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GFlrEHKf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GFlrEHKf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 627611F000FF;
	Tue, 13 Oct 2026 16:42:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791909760;
	bh=srzyszihH6rGkQfXiSPZnsPFcUgKHeed8nuHe03aOmc=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=GFlrEHKfo5ami+TQLuWfFTpPHwnRBXixvZ1xOHiCFrLBSbACnsM0QKgSpGxiih5HA
	 iAUbjNl31PhQ3OyXiI+/CS74uNaYdof0smwJZjYeaRM+VODS+HlOlXMr/NsCiuVI4n
	 GY43kBQffUDanm7ATtUPgKzpNsQRKQLxokq7BkxnaixhEEkhYKQYjJA4StgW74nk4+
	 +zZ2h7ePYXNCnKGKyPmw91moS6Q21qZLnuPjqkfdFIZ0tgJwc2edI5pCP/vx7ScLXX
	 MCsOor4Mq4itFPB6/U6Q58pQvYRyUWESeZ+aVbg3AQNJBXDOY6ZrTyUtMQgRrvvOMI
	 SI2Fc2Y2jMY6w==
Message-ID: <4dec0a14a4ae2db8f042cbf305fac20802b2697f.camel@kernel.org>
Subject: Re: [PATCH v3 00/34] Convert server-side NFSv3 XDR to use xdrgen
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 13 Oct 2026 12:42:38 -0400
In-Reply-To: <20261012220329.309998-1-cel@kernel.org>
References: <20261012220329.309998-1-cel@kernel.org>
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

On Mon, 2026-10-12 at 18:02 -0400, Chuck Lever wrote:
> Replace NFSD's NFSv3 XDR encoders and decoders with code that is
> mechanically generated directly from the NFSv3 RPC language
> specification. Unlike NFSv2, where there are at least two
> incomplete language specifications and much lore, nfs3.x here is
> based closely on RFC 1813.
>=20
> As we convert newer NFS versions to use xdrgen, I expect a reduction
> in human coding errors, improved spec compliance, quicker implement-
> ation of new protocol, and better memory safety for the more complex
> NFS procedures.
>=20
> Changes in v3:
> - Copy the SYMLINK target with nfsd_symlink_target(), moved into vfs.c.
> - Add a patch removing the now-unused svc_fill_symlink_pathname().
> - Reject a READDIRPLUS entry on its minimum size before the lookup.
> - Drop the pr_warn_once() for an unexpected file type in GETATTR.
> - Explain why a late readdir host error is not reported as the status.
> - Write "committed", not "on the wire", in the first-batch patch.
> - Link to v2: https://lore.kernel.org/linux-nfs/20260924171012.3978-1-cel=
@kernel.org/
>=20
> Changes in v2:
> - Include the generated NFSv3 header directly in nfsfh.c and nfsctl.c.
> - Remove the unused struct nfsd3_createargs in the MKDIR patch.
> - Regenerate the READDIR and READDIRPLUS result decoders.
> - Drop the decode-hook stubs the regenerated decoders no longer call.
> - Link to v1: https://lore.kernel.org/linux-nfs/20260923132811.244160-1-c=
el@kernel.org/
>=20
> Chuck Lever (34):
>   NFSD: Report a first-batch readdir error in the reply status
>   Documentation: Add the RPC language description of NFSv3
>   NFSD: Add infrastructure for generating NFSv3 XDR encoders and
>     decoders
>   NFSD: Replace nfs3.h with nfs3xdr_gen.h
>   NFSD: Replace the nfsd3_createres macro
>   NFSD: Relocate the NFSv3 XDR storage union into nfs3proc.c
>   NFSD: Use xdrgen XDR functions for the NFSv3 NULL procedure
>   NFSD: Use xdrgen XDR functions for NFSv3 GETATTR procedure
>   NFSD: Use xdrgen XDR functions for NFSv3 SETATTR procedure
>   NFSD: Use xdrgen XDR functions for the NFSv3 LOOKUP procedure
>   NFSD: Use xdrgen XDR functions for NFSv3 ACCESS procedure
>   NFSD: Use xdrgen XDR functions for NFSv3 READLINK procedure
>   NFSD: Use xdrgen XDR functions for NFSv3 READ procedure
>   NFSD: Use xdrgen XDR functions for NFSv3 WRITE procedure
>   NFSD: Use xdrgen XDR functions for NFSv3 CREATE procedure
>   NFSD: Use xdrgen XDR functions for NFSv3 MKDIR procedure
>   NFSD: Use xdrgen XDR functions for NFSv3 SYMLINK procedure
>   NFSD: Use xdrgen XDR functions for NFSv3 MKNOD procedure
>   NFSD: Use xdrgen XDR functions for the NFSv3 REMOVE procedure
>   NFSD: Use xdrgen XDR functions for the NFSv3 RMDIR procedure
>   NFSD: Use xdrgen XDR functions for the NFSv3 RENAME procedure
>   NFSD: Use xdrgen XDR functions for the NFSv3 LINK procedure
>   NFSD: Use xdrgen XDR functions for the NFSv3 FSSTAT procedure
>   NFSD: Use xdrgen XDR functions for the NFSv3 FSINFO procedure
>   NFSD: Use xdrgen XDR functions for the NFSv3 PATHCONF procedure
>   NFSD: Use xdrgen XDR functions for the NFSv3 COMMIT procedure
>   NFSD: Use xdrgen XDR functions for NFSv3 READDIR arguments
>   NFSD: Use xdrgen XDR functions for NFSv3 READDIRPLUS arguments
>   NFSD: Refactor NFSv3 directory cookie encoding
>   NFSD: Refactor NFSv3 directory entry encoding
>   NFSD: Split struct nfsd3_readdirres
>   NFSD: Use xdrgen XDR functions for NFSv3 READDIR results
>   NFSD: Use xdrgen XDR functions for NFSv3 READDIRPLUS results
>   SUNRPC: Remove svc_fill_symlink_pathname()
>=20
>  Documentation/sunrpc/xdr/nfs3.x    |  839 ++++++
>  fs/nfsd/Makefile                   |   15 +-
>  fs/nfsd/nfs2acl.c                  |   41 +-
>  fs/nfsd/nfs3acl.c                  |   12 +-
>  fs/nfsd/nfs3proc.c                 | 2541 +++++++++++++------
>  fs/nfsd/nfs3xdr.c                  | 1374 +++-------
>  fs/nfsd/nfs3xdr_gen.c              | 3808 ++++++++++++++++++++++++++++
>  fs/nfsd/nfs3xdr_gen.h              |   82 +
>  fs/nfsd/nfsctl.c                   |    2 +-
>  fs/nfsd/nfserr.h                   |    2 +-
>  fs/nfsd/nfsfh.c                    |    2 +-
>  fs/nfsd/nfsproc.c                  |   22 -
>  fs/nfsd/vfs.c                      |  105 +-
>  fs/nfsd/vfs.h                      |    1 +
>  fs/nfsd/xdr3.h                     |  300 +--
>  include/linux/nfs3.h               |    3 -
>  include/linux/sunrpc/svc.h         |    3 -
>  include/linux/sunrpc/xdrgen/nfs3.h | 1092 ++++++++
>  net/sunrpc/svc.c                   |   50 -
>  19 files changed, 8052 insertions(+), 2242 deletions(-)
>  create mode 100644 Documentation/sunrpc/xdr/nfs3.x
>  create mode 100644 fs/nfsd/nfs3xdr_gen.c
>  create mode 100644 fs/nfsd/nfs3xdr_gen.h
>  create mode 100644 include/linux/sunrpc/xdrgen/nfs3.h

I skimmed over the changes. They all look fairly straightforward and I
definitely support moving toward machine-generated code for this sort
of thing.

Acked-by: Jeff Layton <jlayton@kernel.org>
