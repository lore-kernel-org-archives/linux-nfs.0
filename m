Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33701 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751593AbdCCTkB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Mar 2017 14:40:01 -0500
MIME-Version: 1.0
In-Reply-To: <20170302010409.28DA36610A8@gitolite.kernel.org>
References: <20170302010409.28DA36610A8@gitolite.kernel.org>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 3 Mar 2017 20:39:21 +0100
Message-ID: <CAMuHMdWUnm9-A_6y6FEKujQSv=B4r5wD-Fgya7g6w9J=wFCnBQ@mail.gmail.com>
Subject: Re: SUNRPC: Add generic helpers for xdr_stream encode/decode
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Thu, Mar 2, 2017 at 2:04 AM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Web:        https://git.kernel.org/torvalds/c/0ae060ca2bdfe11181094699b0f=
76437ec210b17
> Commit:     0ae060ca2bdfe11181094699b0f76437ec210b17
> Parent:     9761a2469dc287c6d75ca148f4fc483becbcad88
> Refname:    refs/heads/master
> Author:     Trond Myklebust <trond.myklebust@primarydata.com>
> AuthorDate: Sun Feb 19 16:08:25 2017 -0500
> Committer:  Anna Schumaker <Anna.Schumaker@Netapp.com>
> CommitDate: Tue Feb 21 16:56:16 2017 -0500
>
>     SUNRPC: Add generic helpers for xdr_stream encode/decode
>
>     Add some generic helpers for encoding/decoding opaque structures and
>     basic u32/u64.
>
>     Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>     Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

> --- a/include/linux/sunrpc/xdr.h
> +++ b/include/linux/sunrpc/xdr.h

> +/**
> + * xdr_stream_decode_u32 - Decode a 32-bit integer
> + * @xdr: pointer to xdr_stream
> + * @ptr: location to store integer
> + *
> + * Return values:
> + *   %0 on success
> + *   %-EBADMSG on XDR buffer overflow
> + */
> +static inline ssize_t

I think you should either change the return type to "int", or return the
length instead of storing it in *ptr, like all other functions returning
ssize_t do.

The latter will probably kill the (false positive) compiler warning I'm
seeing, too.

> +xdr_stream_decode_u32(struct xdr_stream *xdr, __u32 *ptr)
> +{
> +       const size_t count =3D sizeof(*ptr);
> +       __be32 *p =3D xdr_inline_decode(xdr, count);
> +
> +       if (unlikely(!p))
> +               return -EBADMSG;
> +       *ptr =3D be32_to_cpup(p);
> +       return 0;
> +}
> +
> +/**
> + * xdr_stream_decode_opaque_fixed - Decode fixed length opaque xdr data
> + * @xdr: pointer to xdr_stream
> + * @ptr: location to store data
> + * @len: size of buffer pointed to by @ptr
> + *
> + * Return values:
> + *   On success, returns size of object stored in @ptr
> + *   %-EBADMSG on XDR buffer overflow
> + */
> +static inline ssize_t
> +xdr_stream_decode_opaque_fixed(struct xdr_stream *xdr, void *ptr, size_t=
 len)
> +{
> +       __be32 *p =3D xdr_inline_decode(xdr, len);
> +
> +       if (unlikely(!p))
> +               return -EBADMSG;
> +       xdr_decode_opaque_fixed(p, ptr, len);
> +       return len;
> +}
> +
> +/**
> + * xdr_stream_decode_opaque_inline - Decode variable length opaque xdr d=
ata
> + * @xdr: pointer to xdr_stream
> + * @ptr: location to store pointer to opaque data
> + * @maxlen: maximum acceptable object size
> + *
> + * Note: the pointer stored in @ptr cannot be assumed valid after the XD=
R
> + * buffer has been destroyed, or even after calling xdr_inline_decode()
> + * on @xdr. It is therefore expected that the object it points to should
> + * be processed immediately.
> + *
> + * Return values:
> + *   On success, returns size of object stored in *@ptr
> + *   %-EBADMSG on XDR buffer overflow
> + *   %-EMSGSIZE if the size of the object would exceed @maxlen
> + */
> +static inline ssize_t
> +xdr_stream_decode_opaque_inline(struct xdr_stream *xdr, void **ptr, size=
_t maxlen)
> +{
> +       __be32 *p;
> +       __u32 len;
> +
> +       *ptr =3D NULL;
> +       if (unlikely(xdr_stream_decode_u32(xdr, &len) < 0))
> +               return -EBADMSG;

With gcc-4.1.2, which isn't smart enough to derive the relation between
the initialization of &len and the return value:

    fs/nfs/nfs4xdr.c: In function =E2=80=98decode_opaque_inline=E2=80=99:
    include/linux/sunrpc/xdr.h:409: warning: =E2=80=98len=E2=80=99 may be u=
sed
uninitialized in this function

> +       if (len !=3D 0) {
> +               p =3D xdr_inline_decode(xdr, len);
> +               if (unlikely(!p))
> +                       return -EBADMSG;
> +               if (unlikely(len > maxlen))
> +                       return -EMSGSIZE;
> +               *ptr =3D p;
> +       }
> +       return len;
> +}

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
