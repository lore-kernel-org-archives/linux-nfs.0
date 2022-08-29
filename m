Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 587DBECAAD5
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Aug 2022 13:49:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230332AbiH2NtT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Aug 2022 09:49:19 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51784 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230343AbiH2NtQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2022 09:49:16 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 972CD96741
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2022 06:49:15 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id E4CAA60DBF
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2022 13:49:14 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 14BF5C433C1;
        Mon, 29 Aug 2022 13:49:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1661780954;
        bh=i/BhSomZ4QjRi6LppWHNJsWYtHQdrTGqKk3m38t/shs=;
        h=Subject:From:To:Date:In-Reply-To:References:From;
        b=d1rhqOe6Q4gxV3J+1PZchKFRkfJ0ZmUnczQoQ8P9CMkfKg/5/JnbpQpFC9SdSu1vq
         7ZAwiX4xyhap9D4t7yAA97P2ba39Fa5qlsM+1577qM38P8Dd8csQQhHRCz17MF2gaS
         t4Toq7ElACJqMkZOXq/wJDTAuZd2d99JIQjPpbMO6kI6RwNA2Ii7jgyvN6dg9/gHt+
         /GhWvOdJvIxQ2p+M80qcBdwOGSVISTz2SQaitIAe1WLlhK3YkDllcVXJk1vhZLKG7e
         ZPpxRoLmu4zoqOV7if8uLI2aK9h1DE+c6HV82sTSifOPjymhKtffxyQYP+R2mC0Bff
         JwLkUNG1f2HHA==
Message-ID: <a1790685fd8967838243ced5fe54d7acca43df88.camel@kernel.org>
Subject: Re: [PATCH v2 5/7] NFSD: Clean up WRITE arg decoders
From:   Jeff Layton <jlayton@kernel.org>
To:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date:   Mon, 29 Aug 2022 09:49:12 -0400
In-Reply-To: <166171264742.21449.12798598095676580927.stgit@manet.1015granger.net>
References: <166171174172.21449.5036120183381273656.stgit@manet.1015granger.net>
         <166171264742.21449.12798598095676580927.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.44.4 (3.44.4-1.fc36) 
MIME-Version: 1.0
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, 2022-08-28 at 14:50 -0400, Chuck Lever wrote:
> xdr_stream_subsegment() already returns a boolean value.
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfs3xdr.c |    4 +---
>  fs/nfsd/nfsxdr.c  |    4 +---
>  2 files changed, 2 insertions(+), 6 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index 71e32cf28885..3308dd671ef0 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -571,10 +571,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, str=
uct xdr_stream *xdr)
>  		args->count =3D max_blocksize;
>  		args->len =3D max_blocksize;
>  	}
> -	if (!xdr_stream_subsegment(xdr, &args->payload, args->count))
> -		return false;
> =20
> -	return true;
> +	return xdr_stream_subsegment(xdr, &args->payload, args->count);
>  }
> =20
>  bool
> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
> index aba8520b4b8b..caf6355b18fa 100644
> --- a/fs/nfsd/nfsxdr.c
> +++ b/fs/nfsd/nfsxdr.c
> @@ -338,10 +338,8 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, stru=
ct xdr_stream *xdr)
>  		return false;
>  	if (args->len > NFSSVC_MAXBLKSIZE_V2)
>  		return false;
> -	if (!xdr_stream_subsegment(xdr, &args->payload, args->len))
> -		return false;
> =20
> -	return true;
> +	return xdr_stream_subsegment(xdr, &args->payload, args->len);
>  }
> =20
>  bool
>=20
>=20

Reviewed-by: Jeff Layton <jlayton@kernel.org>
