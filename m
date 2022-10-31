Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B41E5FA3741
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Oct 2022 16:34:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231382AbiJaQeG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 31 Oct 2022 12:34:06 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50738 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231821AbiJaQeE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2022 12:34:04 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3D732DBA
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2022 09:34:01 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 95F80B818EB
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2022 16:34:00 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D25E6C433C1;
        Mon, 31 Oct 2022 16:33:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1667234039;
        bh=SxG5812bo2s9MBwlD+mj2KQQLrQ1jNpLaJVTtMhSU9U=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=V/9uGivHIy8wQKELqEMYMjRkodRWj8wYmHoFNVK7BvhlkX5V/Wt/UdXV2AVXdheyB
         eMLoT27MZJgGPszsrRqYcvLtUrTw69Y0qH6tx5arfSOuNtB8ZaQet3+nvslN8FtAFH
         cJKi2ZTEbq0GpvuxKf2+kQmk3LH/SD/68L3PBHwjzr2lZBI9sgp1KUUUi0YDa3bLSn
         m0N69fmzWDEufFyJEIrJmD5HmMknJ6uJXMtkSlJ1IINwn08dbwRXcGQNPyzA3+3Z6i
         YsSeneRO7Le5Yq8piT6PuwZ/Y1XGL2vzZB5lwadLC/2uiI+2LiaaOR14IszG0etReO
         vS2Qwx2F78DrA==
Message-ID: <d25c6d283466ac2710ca8bd499eed7aa34d1dd2d.camel@kernel.org>
Subject: Re: [PATCH v7 08/14] NFSD: Update file_hashtbl() helpers
From:   Jeff Layton <jlayton@kernel.org>
To:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Cc:     neilb@suse.de
Date:   Mon, 31 Oct 2022 12:33:57 -0400
In-Reply-To: <166696844244.106044.9547058764290901363.stgit@klimt.1015granger.net>
References: <166696812922.106044.679812521105874329.stgit@klimt.1015granger.net>
         <166696844244.106044.9547058764290901363.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.44.4 (3.44.4-2.fc36) 
MIME-Version: 1.0
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2022-10-28 at 10:47 -0400, Chuck Lever wrote:
> Enable callers to use const pointers for type safety.
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Reviewed-by: NeilBrown <neilb@suse.de>
> ---
>  fs/nfsd/nfs4state.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2e6e1ee096b5..60f1aa2c5442 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -710,7 +710,7 @@ static unsigned int ownerstr_hashval(struct xdr_netob=
j *ownername)
>  #define FILE_HASH_BITS                   8
>  #define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
> =20
> -static unsigned int file_hashval(struct svc_fh *fh)
> +static unsigned int file_hashval(const struct svc_fh *fh)
>  {
>  	struct inode *inode =3D d_inode(fh->fh_dentry);
> =20
> @@ -4671,7 +4671,7 @@ move_to_close_lru(struct nfs4_ol_stateid *s, struct=
 net *net)
> =20
>  /* search file_hashtbl[] for file */
>  static struct nfs4_file *
> -find_file_locked(struct svc_fh *fh, unsigned int hashval)
> +find_file_locked(const struct svc_fh *fh, unsigned int hashval)
>  {
>  	struct nfs4_file *fp;
> =20
>=20
>=20

Reviewed-by: Jeff Layton <jlayton@kernel.org>
