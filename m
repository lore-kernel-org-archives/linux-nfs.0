Return-Path: <SRS0=4THU=SH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35268C282CE
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 19:17:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BE65621738
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 19:17:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="NQsVjMLI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731589AbfDETRh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 5 Apr 2019 15:17:37 -0400
Received: from mail-vs1-f68.google.com ([209.85.217.68]:38654 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731183AbfDETRh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2019 15:17:37 -0400
Received: by mail-vs1-f68.google.com with SMTP id s2so4134743vsi.5;
        Fri, 05 Apr 2019 12:17:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=crRi6xe1ip+wEwczbroc9fIMZiws1gwMfTQYKiXOlWg=;
        b=NQsVjMLIR6wYpQ4PO6URUOpUkswOJxhKBZlcCo/wWWB6/WFTEvywhUEMREQgM/VrdT
         J7a6RfcS89jMq7biKoUud+V7SUsQTND5gV+osW4Ysqi+BLtyFZP0oeE0blVBV3yjzRzl
         IdZiWMamZko8O+e6F/P/6CzdsntGb1KwZgpfxTSjAQXq7GZh6jF1iBumcEU6kxnOFZ1E
         PCFFeHxOzBdKMXSFAWAAbEJu56aPDKw1p9MKFG+0cw7y9duWn+WBbrOqHUw9/SMVWJvo
         AJ7/ad8GNxsXZOG9/AYIYzM2F1mF8qtgbQCv76+xs9IrqCtcgOBJQbQ3ehxwvMIdBA0X
         IReg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=crRi6xe1ip+wEwczbroc9fIMZiws1gwMfTQYKiXOlWg=;
        b=ozxQhGSh01V5illgehtd7KAgx2fZt+emmsH9jRbWtiiz6M8XULMh+3l5Qski+ZmLWK
         2eIirIfH9bFhP+v2y3WIAw1yauVo+XMhiqdajXRb6TgeLQk8Hp+sEp4p8vobgzzZpTpb
         8ppjpAmKBp/S+YMRBTha2/p1jWsgCtfXdUvgP0WIxY6zW7ZZHDNKxj6ZSL8YrEftmVWW
         5Zzf2+rYJUrjygH4G6zYShO6Z2V9wHXHZ2CzUMYO8naxnn9VRG+Z455X0sFOI08pg2Cd
         hKcDMGOrXdy0BfsMKfMGddO7avaL1k1a2NveeEXKomElvN9dYpPD+zQrPtUz/JY4kpxs
         AqTg==
X-Gm-Message-State: APjAAAU3s2ZP7tZ8KKqjig7uni9mvuhEjT7RgwZWIZJVZ2nj3qHUKKOm
        F+71m8F7NVOi6zVyY+A4CXZhuNHxge6Elaj2rMc=
X-Google-Smtp-Source: APXvYqwGDlycKmgdN1b4G65GJKk6sOjMumaPzUP0/xYP7JvTzPMN4iJHc5X73VuM8RqmjUV3rzjcEuwsQCM4k5v9Fj8=
X-Received: by 2002:a67:7f44:: with SMTP id a65mr9121704vsd.179.1554491855368;
 Fri, 05 Apr 2019 12:17:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
 <20190211162525.2817.60645.stgit@manet.1015granger.net> <CAN-5tyH1zAuW7AxoZc+psRWWQT0S9J3wDu+iDgLg4=qGTvUufA@mail.gmail.com>
 <0157F163-7554-413C-ACCA-FE6646C04716@oracle.com>
In-Reply-To: <0157F163-7554-413C-ACCA-FE6646C04716@oracle.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 5 Apr 2019 15:17:24 -0400
Message-ID: <CAN-5tyHSH75TVSok+RXdXoq6bOVse__E4AMCzuSnmYrTgzH_Vg@mail.gmail.com>
Subject: Re: [PATCH v1 20/23] NFS: Account for XDR pad of buf->pages
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Apr 5, 2019 at 1:51 PM Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>
> > On Apr 5, 2019, at 1:36 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >
> > Hi Chuck,
> >
> > This patch break ACLs. After applying this patch nfs4_getfacl fails
> > (it fails within xdr and returns ENOTSUPP). Any ideas why?
>
> Possibly the macro that defines the maximum size of the reply
> is incorrect.
>

This also breaks FS_LOCATION. I'm going to go on the limb here and say
that it probably breaks whatever else it modified. The question is:
can't we just revert it??

>
> > On Mon, Feb 11, 2019 at 11:25 AM Chuck Lever <chuck.lever@oracle.com> wrote:
> >>
> >> Certain NFS results (eg. READLINK) might expect a data payload that
> >> is not an exact multiple of 4 bytes. In this case, XDR encoding
> >> is required to pad that payload so its length on the wire is a
> >> multiple of 4 bytes. The constants that define the maximum size of
> >> each NFS result do not appear to account for this extra word.
> >>
> >> In each case where the data payload is to be received into pages:
> >>
> >> - 1 word is added to the size of the receive buffer allocated by
> >>  call_allocate
> >>
> >> - rpc_inline_rcv_pages subtracts 1 word from @hdrsize so that the
> >>  extra buffer space falls into the rcv_buf's tail iovec
> >>
> >> - If buf->pagelen is word-aligned, an XDR pad is not needed and
> >>  is thus removed from the tail
> >>
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> fs/nfs/nfs2xdr.c  |    6 +++---
> >> fs/nfs/nfs3xdr.c  |   10 +++++-----
> >> fs/nfs/nfs4xdr.c  |   15 ++++++++-------
> >> net/sunrpc/clnt.c |    6 +++++-
> >> net/sunrpc/xdr.c  |    2 ++
> >> 5 files changed, 23 insertions(+), 16 deletions(-)
> >>
> >> diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
> >> index 1dcd0fe..a7ed29d 100644
> >> --- a/fs/nfs/nfs2xdr.c
> >> +++ b/fs/nfs/nfs2xdr.c
> >> @@ -56,11 +56,11 @@
> >>
> >> #define NFS_attrstat_sz                (1+NFS_fattr_sz)
> >> #define NFS_diropres_sz                (1+NFS_fhandle_sz+NFS_fattr_sz)
> >> -#define NFS_readlinkres_sz     (2)
> >> -#define NFS_readres_sz         (1+NFS_fattr_sz+1)
> >> +#define NFS_readlinkres_sz     (2+1)
> >> +#define NFS_readres_sz         (1+NFS_fattr_sz+1+1)
> >> #define NFS_writeres_sz         (NFS_attrstat_sz)
> >> #define NFS_stat_sz            (1)
> >> -#define NFS_readdirres_sz      (1)
> >> +#define NFS_readdirres_sz      (1+1)
> >> #define NFS_statfsres_sz       (1+NFS_info_sz)
> >>
> >> static int nfs_stat_to_errno(enum nfs_stat);
> >> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> >> index a54dcf4..110358f 100644
> >> --- a/fs/nfs/nfs3xdr.c
> >> +++ b/fs/nfs/nfs3xdr.c
> >> @@ -69,13 +69,13 @@
> >> #define NFS3_removeres_sz      (NFS3_setattrres_sz)
> >> #define NFS3_lookupres_sz      (1+NFS3_fh_sz+(2 * NFS3_post_op_attr_sz))
> >> #define NFS3_accessres_sz      (1+NFS3_post_op_attr_sz+1)
> >> -#define NFS3_readlinkres_sz    (1+NFS3_post_op_attr_sz+1)
> >> -#define NFS3_readres_sz                (1+NFS3_post_op_attr_sz+3)
> >> +#define NFS3_readlinkres_sz    (1+NFS3_post_op_attr_sz+1+1)
> >> +#define NFS3_readres_sz                (1+NFS3_post_op_attr_sz+3+1)
> >> #define NFS3_writeres_sz       (1+NFS3_wcc_data_sz+4)
> >> #define NFS3_createres_sz      (1+NFS3_fh_sz+NFS3_post_op_attr_sz+NFS3_wcc_data_sz)
> >> #define NFS3_renameres_sz      (1+(2 * NFS3_wcc_data_sz))
> >> #define NFS3_linkres_sz                (1+NFS3_post_op_attr_sz+NFS3_wcc_data_sz)
> >> -#define NFS3_readdirres_sz     (1+NFS3_post_op_attr_sz+2)
> >> +#define NFS3_readdirres_sz     (1+NFS3_post_op_attr_sz+2+1)
> >> #define NFS3_fsstatres_sz      (1+NFS3_post_op_attr_sz+13)
> >> #define NFS3_fsinfores_sz      (1+NFS3_post_op_attr_sz+12)
> >> #define NFS3_pathconfres_sz    (1+NFS3_post_op_attr_sz+6)
> >> @@ -85,7 +85,7 @@
> >> #define ACL3_setaclargs_sz     (NFS3_fh_sz+1+ \
> >>                                XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE))
> >> #define ACL3_getaclres_sz      (1+NFS3_post_op_attr_sz+1+ \
> >> -                               XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE))
> >> +                               XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE)+1)
> >> #define ACL3_setaclres_sz      (1+NFS3_post_op_attr_sz)
> >>
> >> static int nfs3_stat_to_errno(enum nfs_stat);
> >> @@ -1629,7 +1629,7 @@ static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
> >>        result->op_status = status;
> >>        if (status != NFS3_OK)
> >>                goto out_status;
> >> -       result->replen = 3 + ((xdr_stream_pos(xdr) - pos) >> 2);
> >> +       result->replen = 4 + ((xdr_stream_pos(xdr) - pos) >> 2);
> >>        error = decode_read3resok(xdr, result);
> >> out:
> >>        return error;
> >> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> >> index d0fa18d..6d9d5e2 100644
> >> --- a/fs/nfs/nfs4xdr.c
> >> +++ b/fs/nfs/nfs4xdr.c
> >> @@ -215,14 +215,14 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
> >>                                 nfs4_fattr_bitmap_maxsz)
> >> #define encode_read_maxsz      (op_encode_hdr_maxsz + \
> >>                                 encode_stateid_maxsz + 3)
> >> -#define decode_read_maxsz      (op_decode_hdr_maxsz + 2)
> >> +#define decode_read_maxsz      (op_decode_hdr_maxsz + 2 + 1)
> >> #define encode_readdir_maxsz   (op_encode_hdr_maxsz + \
> >>                                 2 + encode_verifier_maxsz + 5 + \
> >>                                nfs4_label_maxsz)
> >> #define decode_readdir_maxsz   (op_decode_hdr_maxsz + \
> >> -                                decode_verifier_maxsz)
> >> +                                decode_verifier_maxsz + 1)
> >> #define encode_readlink_maxsz  (op_encode_hdr_maxsz)
> >> -#define decode_readlink_maxsz  (op_decode_hdr_maxsz + 1)
> >> +#define decode_readlink_maxsz  (op_decode_hdr_maxsz + 1 + 1)
> >> #define encode_write_maxsz     (op_encode_hdr_maxsz + \
> >>                                 encode_stateid_maxsz + 4)
> >> #define decode_write_maxsz     (op_decode_hdr_maxsz + \
> >> @@ -284,14 +284,14 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
> >> #define decode_delegreturn_maxsz (op_decode_hdr_maxsz)
> >> #define encode_getacl_maxsz    (encode_getattr_maxsz)
> >> #define decode_getacl_maxsz    (op_decode_hdr_maxsz + \
> >> -                                nfs4_fattr_bitmap_maxsz + 1)
> >> +                                nfs4_fattr_bitmap_maxsz + 1 + 1)
> >> #define encode_setacl_maxsz    (op_encode_hdr_maxsz + \
> >>                                 encode_stateid_maxsz + 3)
> >> #define decode_setacl_maxsz    (decode_setattr_maxsz)
> >> #define encode_fs_locations_maxsz \
> >>                                (encode_getattr_maxsz)
> >> #define decode_fs_locations_maxsz \
> >> -                               (0)
> >> +                               (1)
> >> #define encode_secinfo_maxsz   (op_encode_hdr_maxsz + nfs4_name_maxsz)
> >> #define decode_secinfo_maxsz   (op_decode_hdr_maxsz + 1 + ((NFS_MAX_SECFLAVORS * (16 + GSS_OID_MAX_LEN)) / 4))
> >>
> >> @@ -392,12 +392,13 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
> >>                                1 /* opaque devaddr4 length */ + \
> >>                                  /* devaddr4 payload is read into page */ \
> >>                                1 /* notification bitmap length */ + \
> >> -                               1 /* notification bitmap, word 0 */)
> >> +                               1 /* notification bitmap, word 0 */ + \
> >> +                               1 /* possible XDR padding */)
> >> #define encode_layoutget_maxsz (op_encode_hdr_maxsz + 10 + \
> >>                                encode_stateid_maxsz)
> >> #define decode_layoutget_maxsz (op_decode_hdr_maxsz + 8 + \
> >>                                decode_stateid_maxsz + \
> >> -                               XDR_QUADLEN(PNFS_LAYOUT_MAXSIZE))
> >> +                               XDR_QUADLEN(PNFS_LAYOUT_MAXSIZE) + 1)
> >> #define encode_layoutcommit_maxsz (op_encode_hdr_maxsz +          \
> >>                                2 /* offset */ + \
> >>                                2 /* length */ + \
> >> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> >> index f780605..4ea38b0 100644
> >> --- a/net/sunrpc/clnt.c
> >> +++ b/net/sunrpc/clnt.c
> >> @@ -1177,7 +1177,11 @@ void rpc_prepare_reply_pages(struct rpc_rqst *req, struct page **pages,
> >>                             unsigned int base, unsigned int len,
> >>                             unsigned int hdrsize)
> >> {
> >> -       hdrsize += RPC_REPHDRSIZE + req->rq_cred->cr_auth->au_rslack;
> >> +       /* Subtract one to force an extra word of buffer space for the
> >> +        * payload's XDR pad to fall into the rcv_buf's tail iovec.
> >> +        */
> >> +       hdrsize += RPC_REPHDRSIZE + req->rq_cred->cr_auth->au_rslack - 1;
> >> +
> >>        xdr_inline_pages(&req->rq_rcv_buf, hdrsize << 2, pages, base, len);
> >>        trace_rpc_reply_pages(req);
> >> }
> >> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> >> index 7cca515..aa8177d 100644
> >> --- a/net/sunrpc/xdr.c
> >> +++ b/net/sunrpc/xdr.c
> >> @@ -189,6 +189,8 @@ __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int nbytes)
> >>
> >>        tail->iov_base = buf + offset;
> >>        tail->iov_len = buflen - offset;
> >> +       if ((xdr->page_len & 3) == 0)
> >> +               tail->iov_len -= sizeof(__be32);
> >>
> >>        xdr->buflen += len;
> >> }
> >>
>
> --
> Chuck Lever
>
>
>
