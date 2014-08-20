Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34564 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbaHTNmj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 09:42:39 -0400
Received: by mail-ig0-f174.google.com with SMTP id c1so11637061igq.13
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2014 06:42:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53F4994A.3060506@gmail.com>
References: <53F4994A.3060506@gmail.com>
Date: Wed, 20 Aug 2014 09:42:38 -0400
Message-ID: <CAABAsM65rWByuQYrWZ8jiieMzkitdRgVA5-zxxXTqE+ddvN8AA@mail.gmail.com>
Subject: Re: [PATCH v2] NFSD: Convert magic numbers to sizeof() for encode/decode
From: Trond Myklebust <trondmy@gmail.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 20, 2014 at 8:49 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> v2: update for 3.17.0-rc1
>
> Reported-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4acl.c      |   2 +-
>  fs/nfsd/nfs4callback.c |  18 +-
>  fs/nfsd/nfs4idmap.c    |   4 +-
>  fs/nfsd/nfs4proc.c     |  12 +-
>  fs/nfsd/nfs4state.c    |  10 +-
>  fs/nfsd/nfs4xdr.c      | 501 +++++++++++++++++++++++++------------------------
>  6 files changed, 280 insertions(+), 267 deletions(-)
>
> diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
> index 59fd766..f15dbb2 100644
> --- a/fs/nfsd/nfs4acl.c
> +++ b/fs/nfsd/nfs4acl.c
> @@ -932,7 +932,7 @@ __be32 nfs4_acl_write_who(struct xdr_stream *xdr, int who)
>         for (i = 0; i < ARRAY_SIZE(s2t_map); i++) {
>                 if (s2t_map[i].type != who)
>                         continue;
> -               p = xdr_reserve_space(xdr, s2t_map[i].stringlen + 4);
> +               p = xdr_reserve_space(xdr, sizeof(__be32) + s2t_map[i].stringlen);

OK, can someone please tell me how this is useful for documentation
purposes? Anybody who doesn't know that sizeof(__be32) == 4 has no
business working on XDR code.
I could understand this kind of patch if you were converting to
sizeof(<variable name>), as that documents exactly which variable you
are going to encode in this buffer and so is better than a naked
value, but how is sizeof(__be32) any more useful documentation than
"4"?

Trond
