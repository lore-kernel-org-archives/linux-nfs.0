Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6412C46475
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 03:00:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5FCB82082F
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 03:00:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FfKmeY2H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FCB82082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726240AbeJXL0P (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Oct 2018 07:26:15 -0400
Received: from mail-ua1-f66.google.com ([209.85.222.66]:43274 "EHLO
        mail-ua1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725998AbeJXL0P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2018 07:26:15 -0400
Received: by mail-ua1-f66.google.com with SMTP id c89so1308038uac.10
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2018 20:00:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5SdVu7y37Gg53tvjobDrpQs9G5DZEokRS39pCtOFeGs=;
        b=FfKmeY2H2epzdXLaaaQ1jwr9RMxhOOZNxUKmESgQVnNRTZwXbHKH5xlSZ8CohklHe4
         LBjg86wJVwM2MIvxL92TzSkOCBoKsRhPYKLoexhxjZyLmf6JejwfEoMnJMFn5rPmfpnZ
         Adu+8fXkidSUyzcuoL3zNKd5eQI9QWQVrqua3dtmUjWqQwP7pAjbfy+4qGKvbuCpIBPJ
         KBawdUNOAS3U7AnHGlMKio5xZw7kLoNL6A4BpHbzF8bMw/oP5SUQnMwCiUw/lfgEa40L
         86jMmvzbuc+6LoEOrkD2l9f+j2/k22AIBaFO84TB+R6aXa3ybsBfWEo+O8/Xol12q1TV
         ON5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=5SdVu7y37Gg53tvjobDrpQs9G5DZEokRS39pCtOFeGs=;
        b=mYZx8IVqAQN0hcO/qkYBWj/s/2Qd9oga0Z6oXhLgRzRElAmEdE3EAV+GGzHiGAPzqm
         pnBomXwfHEZbEp7MLFYCqoNhG3WfkKM+PJofWGmkLn3XKhhK1XDPYxCit4l8usYePS5o
         5xXCz14ctd0SjSwRO5wOYUYqIYFL31fhZbhjUG8ZmnbqY/NlLHxHteD44WLDjN8QWj6p
         J1A0sRkMQ2rQ5jLAkdKAsMKtT5SBJZ2o9tzzQY2mUmB45zYLv7w1L+/IBvgAXsTbn5nS
         idmwbsmUNOFUnEvrv19YGdzgW7TFPSSQOp+noilLBtiYGU7lOaYQfzlMTA+nx9R8UKdW
         TNog==
X-Gm-Message-State: AGRZ1gL1gdORtbwHjWbiX58twSfUC0LSUEfxscdkqT1Ew1xSsEua4HWz
        vD+foHK3QZAJOmKpdxhAvz1VT3u83Xy2a0z4zuMeJQ==
X-Google-Smtp-Source: AJdET5e1zE7W/3Jar+KFTnAW9Uk3rrLtNFnX57Sdzd8KXA3q3QiS3Fu8oIenmN/TnUT1wI/NHq9+cNh/c78d2G63ppQ=
X-Received: by 2002:ab0:24cb:: with SMTP id k11mr252372uan.104.1540343827021;
 Tue, 23 Oct 2018 18:17:07 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
 <20181019152932.32462-6-olga.kornievskaia@gmail.com> <f3e8b4a81ceb25d89456f5fb7ffbe82a5c097b57.camel@netapp.com>
In-Reply-To: <f3e8b4a81ceb25d89456f5fb7ffbe82a5c097b57.camel@netapp.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Tue, 23 Oct 2018 21:16:55 -0400
Message-ID: <CAN-5tyGc-W0yxT8gYGquYWzPygSmO0ORU2V5eTWM4CdS4MD5hQ@mail.gmail.com>
Subject: Re: [PATCH v1 05/11] NFS add COPY_NOTIFY operation
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 23, 2018 at 11:50 AM Schumaker, Anna
<Anna.Schumaker@netapp.com> wrote:
>
> Hi Olga,
>
> On Fri, 2018-10-19 at 11:29 -0400, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > Try using the delegation stateid, then the open stateid.
> >
> > Only NL4_NETATTR, No support for NL4_NAME and NL4_URL.
> > Allow only one source server address to be returned for now.
> >
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  fs/nfs/nfs42.h            |   3 +-
> >  fs/nfs/nfs42proc.c        |  91 +++++++++++++++++++++++
> >  fs/nfs/nfs42xdr.c         | 181
> > ++++++++++++++++++++++++++++++++++++++++++++++
> >  fs/nfs/nfs4file.c         |  17 +++++
> >  fs/nfs/nfs4proc.c         |   1 +
> >  fs/nfs/nfs4xdr.c          |   1 +
> >  include/linux/nfs4.h      |   1 +
> >  include/linux/nfs_fs_sb.h |   1 +
> >  include/linux/nfs_xdr.h   |  16 ++++
> >  9 files changed, 311 insertions(+), 1 deletion(-)
> >
> > diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
> > index 5abff4d..bcd0222 100644
> > --- a/fs/nfs/nfs42.h
> > +++ b/fs/nfs/nfs42.h
> > @@ -21,7 +21,8 @@
> >  int nfs42_proc_layoutstats_generic(struct nfs_server *,
> >                                  struct nfs42_layoutstat_data *);
> >  int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
> > -
> > +int nfs42_proc_copy_notify(struct file *, struct file *,
> > +                        struct nfs42_copy_notify_res *);
>
> Can you wrap this in a CONFIG_NFS_V4_2 check?  Otherwise the compiler will
> complain that nfs42_copy_notify_res doesn't exist.

Will take care of it. Thank you.

>
> Thanks,
> Anna
>
> >  static inline bool nfs42_files_from_same_server(struct file *in,
> >                                               struct file *out)
> >  {
> > diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> > index ac5b784..b1c57a4 100644
> > --- a/fs/nfs/nfs42proc.c
> > +++ b/fs/nfs/nfs42proc.c
> > @@ -3,6 +3,7 @@
> >   * Copyright (c) 2014 Anna Schumaker <Anna.Schumaker@Netapp.com>
> >   */
> >  #include <linux/fs.h>
> > +#include <linux/sunrpc/addr.h>
> >  #include <linux/sunrpc/sched.h>
> >  #include <linux/nfs.h>
> >  #include <linux/nfs3.h>
> > @@ -15,10 +16,30 @@
> >  #include "pnfs.h"
> >  #include "nfs4session.h"
> >  #include "internal.h"
> > +#include "delegation.h"
> >
> >  #define NFSDBG_FACILITY NFSDBG_PROC
> >  static int nfs42_do_offload_cancel_async(struct file *dst, nfs4_stateid
> > *std);
> >
> > +static void nfs42_set_netaddr(struct file *filep, struct nfs42_netaddr
> > *naddr)
> > +{
> > +     struct nfs_client *clp = (NFS_SERVER(file_inode(filep)))->nfs_client;
> > +     unsigned short port = 2049;
> > +
> > +     rcu_read_lock();
> > +     naddr->netid_len = scnprintf(naddr->netid,
> > +                                     sizeof(naddr->netid), "%s",
> > +                                     rpc_peeraddr2str(clp->cl_rpcclient,
> > +                                     RPC_DISPLAY_NETID));
> > +     naddr->addr_len = scnprintf(naddr->addr,
> > +                                     sizeof(naddr->addr),
> > +                                     "%s.%u.%u",
> > +                                     rpc_peeraddr2str(clp->cl_rpcclient,
> > +                                     RPC_DISPLAY_ADDR),
> > +                                     port >> 8, port & 255);
> > +     rcu_read_unlock();
> > +}
> > +
> >  static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
> >               struct nfs_lock_context *lock, loff_t offset, loff_t len)
> >  {
> > @@ -461,6 +482,76 @@ static int nfs42_do_offload_cancel_async(struct file
> > *dst,
> >       return status;
> >  }
> >
> > +int _nfs42_proc_copy_notify(struct file *src, struct file *dst,
> > +                         struct nfs42_copy_notify_args *args,
> > +                         struct nfs42_copy_notify_res *res)
> > +{
> > +     struct nfs_server *src_server = NFS_SERVER(file_inode(src));
> > +     struct rpc_message msg = {
> > +             .rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COPY_NOTIFY],
> > +             .rpc_argp = args,
> > +             .rpc_resp = res,
> > +     };
> > +     int status;
> > +     struct nfs_open_context *ctx;
> > +     struct nfs_lock_context *l_ctx;
> > +
> > +     ctx = get_nfs_open_context(nfs_file_open_context(src));
> > +     l_ctx = nfs_get_lock_context(ctx);
> > +     if (IS_ERR(l_ctx))
> > +             return PTR_ERR(l_ctx);
> > +
> > +     status = nfs4_set_rw_stateid(&args->cna_src_stateid, ctx, l_ctx,
> > +                                  FMODE_READ);
> > +     nfs_put_lock_context(l_ctx);
> > +     if (status)
> > +             return status;
> > +
> > +     status = nfs4_call_sync(src_server->client, src_server, &msg,
> > +                             &args->cna_seq_args, &res->cnr_seq_res, 0);
> > +     if (status == -ENOTSUPP)
> > +             src_server->caps &= ~NFS_CAP_COPY_NOTIFY;
> > +
> > +     put_nfs_open_context(nfs_file_open_context(src));
> > +     return status;
> > +}
> > +
> > +int nfs42_proc_copy_notify(struct file *src, struct file *dst,
> > +                             struct nfs42_copy_notify_res *res)
> > +{
> > +     struct nfs_server *src_server = NFS_SERVER(file_inode(src));
> > +     struct nfs42_copy_notify_args *args;
> > +     struct nfs4_exception exception = {
> > +             .inode = file_inode(src),
> > +     };
> > +     int status;
> > +
> > +     if (!(src_server->caps & NFS_CAP_COPY_NOTIFY))
> > +             return -EOPNOTSUPP;
> > +
> > +     args = kzalloc(sizeof(struct nfs42_copy_notify_args), GFP_NOFS);
> > +     if (args == NULL)
> > +             return -ENOMEM;
> > +
> > +     args->cna_src_fh  = NFS_FH(file_inode(src)),
> > +     args->cna_dst.nl4_type = NL4_NETADDR;
> > +     nfs42_set_netaddr(dst, &args->cna_dst.u.nl4_addr);
> > +     exception.stateid = &args->cna_src_stateid;
> > +
> > +     do {
> > +             status = _nfs42_proc_copy_notify(src, dst, args, res);
> > +             if (status == -ENOTSUPP) {
> > +                     status = -EOPNOTSUPP;
> > +                     goto out;
> > +             }
> > +             status = nfs4_handle_exception(src_server, status, &exception);
> > +     } while (exception.retry);
> > +
> > +out:
> > +     kfree(args);
> > +     return status;
> > +}
> > +
> >  static loff_t _nfs42_proc_llseek(struct file *filep,
> >               struct nfs_lock_context *lock, loff_t offset, int whence)
> >  {
> > diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
> > index 69f72ed..e6e7cbf 100644
> > --- a/fs/nfs/nfs42xdr.c
> > +++ b/fs/nfs/nfs42xdr.c
> > @@ -29,6 +29,16 @@
> >  #define encode_offload_cancel_maxsz  (op_encode_hdr_maxsz + \
> >                                        XDR_QUADLEN(NFS4_STATEID_SIZE))
> >  #define decode_offload_cancel_maxsz  (op_decode_hdr_maxsz)
> > +#define encode_copy_notify_maxsz     (op_encode_hdr_maxsz + \
> > +                                      XDR_QUADLEN(NFS4_STATEID_SIZE) + \
> > +                                      1 + /* nl4_type */ \
> > +                                      1 + XDR_QUADLEN(NFS4_OPAQUE_LIMIT))
> > +#define decode_copy_notify_maxsz     (op_decode_hdr_maxsz + \
> > +                                      3 + /* cnr_lease_time */\
> > +                                      XDR_QUADLEN(NFS4_STATEID_SIZE) + \
> > +                                      1 + /* Support 1 cnr_source_server */\
> > +                                      1 + /* nl4_type */ \
> > +                                      1 + XDR_QUADLEN(NFS4_OPAQUE_LIMIT))
> >  #define encode_deallocate_maxsz              (op_encode_hdr_maxsz + \
> >                                        encode_fallocate_maxsz)
> >  #define decode_deallocate_maxsz              (op_decode_hdr_maxsz)
> > @@ -84,6 +94,12 @@
> >  #define NFS4_dec_offload_cancel_sz   (compound_decode_hdr_maxsz + \
> >                                        decode_putfh_maxsz + \
> >                                        decode_offload_cancel_maxsz)
> > +#define NFS4_enc_copy_notify_sz              (compound_encode_hdr_maxsz + \
> > +                                      encode_putfh_maxsz + \
> > +                                      encode_copy_notify_maxsz)
> > +#define NFS4_dec_copy_notify_sz              (compound_decode_hdr_maxsz + \
> > +                                      decode_putfh_maxsz + \
> > +                                      decode_copy_notify_maxsz)
> >  #define NFS4_enc_deallocate_sz               (compound_encode_hdr_maxsz + \
> >                                        encode_putfh_maxsz + \
> >                                        encode_deallocate_maxsz + \
> > @@ -137,6 +153,25 @@ static void encode_allocate(struct xdr_stream *xdr,
> >       encode_fallocate(xdr, args);
> >  }
> >
> > +static void encode_nl4_server(struct xdr_stream *xdr, const struct nl4_server
> > *ns)
> > +{
> > +     encode_uint32(xdr, ns->nl4_type);
> > +     switch (ns->nl4_type) {
> > +     case NL4_NAME:
> > +     case NL4_URL:
> > +             encode_string(xdr, ns->u.nl4_str_sz, ns->u.nl4_str);
> > +             break;
> > +     case NL4_NETADDR:
> > +             encode_string(xdr, ns->u.nl4_addr.netid_len,
> > +                           ns->u.nl4_addr.netid);
> > +             encode_string(xdr, ns->u.nl4_addr.addr_len,
> > +                           ns->u.nl4_addr.addr);
> > +             break;
> > +     default:
> > +             WARN_ON_ONCE(1);
> > +     }
> > +}
> > +
> >  static void encode_copy(struct xdr_stream *xdr,
> >                       const struct nfs42_copy_args *args,
> >                       struct compound_hdr *hdr)
> > @@ -162,6 +197,15 @@ static void encode_offload_cancel(struct xdr_stream *xdr,
> >       encode_nfs4_stateid(xdr, &args->osa_stateid);
> >  }
> >
> > +static void encode_copy_notify(struct xdr_stream *xdr,
> > +                            const struct nfs42_copy_notify_args *args,
> > +                            struct compound_hdr *hdr)
> > +{
> > +     encode_op_hdr(xdr, OP_COPY_NOTIFY, decode_copy_notify_maxsz, hdr);
> > +     encode_nfs4_stateid(xdr, &args->cna_src_stateid);
> > +     encode_nl4_server(xdr, &args->cna_dst);
> > +}
> > +
> >  static void encode_deallocate(struct xdr_stream *xdr,
> >                             const struct nfs42_falloc_args *args,
> >                             struct compound_hdr *hdr)
> > @@ -298,6 +342,25 @@ static void nfs4_xdr_enc_offload_cancel(struct rpc_rqst
> > *req,
> >  }
> >
> >  /*
> > + * Encode COPY_NOTIFY request
> > + */
> > +static void nfs4_xdr_enc_copy_notify(struct rpc_rqst *req,
> > +                                  struct xdr_stream *xdr,
> > +                                  const void *data)
> > +{
> > +     const struct nfs42_copy_notify_args *args = data;
> > +     struct compound_hdr hdr = {
> > +             .minorversion = nfs4_xdr_minorversion(&args->cna_seq_args),
> > +     };
> > +
> > +     encode_compound_hdr(xdr, req, &hdr);
> > +     encode_sequence(xdr, &args->cna_seq_args, &hdr);
> > +     encode_putfh(xdr, args->cna_src_fh, &hdr);
> > +     encode_copy_notify(xdr, args, &hdr);
> > +     encode_nops(&hdr);
> > +}
> > +
> > +/*
> >   * Encode DEALLOCATE request
> >   */
> >  static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
> > @@ -416,6 +479,58 @@ static int decode_write_response(struct xdr_stream *xdr,
> >       return -EIO;
> >  }
> >
> > +static int decode_nl4_server(struct xdr_stream *xdr, struct nl4_server *ns)
> > +{
> > +     struct nfs42_netaddr *naddr;
> > +     uint32_t dummy;
> > +     char *dummy_str;
> > +     __be32 *p;
> > +     int status;
> > +
> > +     /* nl_type */
> > +     p = xdr_inline_decode(xdr, 4);
> > +     if (unlikely(!p))
> > +             return -EIO;
> > +     ns->nl4_type = be32_to_cpup(p);
> > +     switch (ns->nl4_type) {
> > +     case NL4_NAME:
> > +     case NL4_URL:
> > +             status = decode_opaque_inline(xdr, &dummy, &dummy_str);
> > +             if (unlikely(status))
> > +                     return status;
> > +             if (unlikely(dummy > NFS4_OPAQUE_LIMIT))
> > +                     return -EIO;
> > +             memcpy(&ns->u.nl4_str, dummy_str, dummy);
> > +             ns->u.nl4_str_sz = dummy;
> > +             break;
> > +     case NL4_NETADDR:
> > +             naddr = &ns->u.nl4_addr;
> > +
> > +             /* netid string */
> > +             status = decode_opaque_inline(xdr, &dummy, &dummy_str);
> > +             if (unlikely(status))
> > +                     return status;
> > +             if (unlikely(dummy > RPCBIND_MAXNETIDLEN))
> > +                     return -EIO;
> > +             naddr->netid_len = dummy;
> > +             memcpy(naddr->netid, dummy_str, naddr->netid_len);
> > +
> > +             /* uaddr string */
> > +             status = decode_opaque_inline(xdr, &dummy, &dummy_str);
> > +             if (unlikely(status))
> > +                     return status;
> > +             if (unlikely(dummy > RPCBIND_MAXUADDRLEN))
> > +                     return -EIO;
> > +             naddr->addr_len = dummy;
> > +             memcpy(naddr->addr, dummy_str, naddr->addr_len);
> > +             break;
> > +     default:
> > +             WARN_ON_ONCE(1);
> > +             return -EIO;
> > +     }
> > +     return 0;
> > +}
> > +
> >  static int decode_copy_requirements(struct xdr_stream *xdr,
> >                                   struct nfs42_copy_res *res) {
> >       __be32 *p;
> > @@ -458,6 +573,46 @@ static int decode_offload_cancel(struct xdr_stream *xdr,
> >       return decode_op_hdr(xdr, OP_OFFLOAD_CANCEL);
> >  }
> >
> > +static int decode_copy_notify(struct xdr_stream *xdr,
> > +                           struct nfs42_copy_notify_res *res)
> > +{
> > +     __be32 *p;
> > +     int status, count;
> > +
> > +     status = decode_op_hdr(xdr, OP_COPY_NOTIFY);
> > +     if (status)
> > +             return status;
> > +     /* cnr_lease_time */
> > +     p = xdr_inline_decode(xdr, 12);
> > +     if (unlikely(!p))
> > +             goto out_overflow;
> > +     p = xdr_decode_hyper(p, &res->cnr_lease_time.seconds);
> > +     res->cnr_lease_time.nseconds = be32_to_cpup(p);
> > +
> > +     status = decode_opaque_fixed(xdr, &res->cnr_stateid, NFS4_STATEID_SIZE);
> > +     if (unlikely(status))
> > +             goto out_overflow;
> > +
> > +     /* number of source addresses */
> > +     p = xdr_inline_decode(xdr, 4);
> > +     if (unlikely(!p))
> > +             goto out_overflow;
> > +
> > +     count = be32_to_cpup(p);
> > +     if (count > 1)
> > +             pr_warn("NFS: %s: nsvr %d > Supported. Use first servers\n",
> > +                      __func__, count);
> > +
> > +     status = decode_nl4_server(xdr, &res->cnr_src);
> > +     if (unlikely(status))
> > +             goto out_overflow;
> > +     return 0;
> > +
> > +out_overflow:
> > +     print_overflow_msg(__func__, xdr);
> > +     return -EIO;
> > +}
> > +
> >  static int decode_deallocate(struct xdr_stream *xdr, struct nfs42_falloc_res
> > *res)
> >  {
> >       return decode_op_hdr(xdr, OP_DEALLOCATE);
> > @@ -585,6 +740,32 @@ static int nfs4_xdr_dec_offload_cancel(struct rpc_rqst
> > *rqstp,
> >  }
> >
> >  /*
> > + * Decode COPY_NOTIFY response
> > + */
> > +static int nfs4_xdr_dec_copy_notify(struct rpc_rqst *rqstp,
> > +                                 struct xdr_stream *xdr,
> > +                                 void *data)
> > +{
> > +     struct nfs42_copy_notify_res *res = data;
> > +     struct compound_hdr hdr;
> > +     int status;
> > +
> > +     status = decode_compound_hdr(xdr, &hdr);
> > +     if (status)
> > +             goto out;
> > +     status = decode_sequence(xdr, &res->cnr_seq_res, rqstp);
> > +     if (status)
> > +             goto out;
> > +     status = decode_putfh(xdr);
> > +     if (status)
> > +             goto out;
> > +     status = decode_copy_notify(xdr, res);
> > +
> > +out:
> > +     return status;
> > +}
> > +
> > +/*
> >   * Decode DEALLOCATE request
> >   */
> >  static int nfs4_xdr_dec_deallocate(struct rpc_rqst *rqstp,
> > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > index 4288a6e..3a888f4 100644
> > --- a/fs/nfs/nfs4file.c
> > +++ b/fs/nfs/nfs4file.c
> > @@ -133,12 +133,29 @@ static ssize_t nfs4_copy_file_range(struct file
> > *file_in, loff_t pos_in,
> >                                   struct file *file_out, loff_t pos_out,
> >                                   size_t count, unsigned int flags)
> >  {
> > +     struct nfs42_copy_notify_res *cn_resp = NULL;
> >       ssize_t ret;
> >
> >       if (file_inode(file_in) == file_inode(file_out))
> >               return -EINVAL;
> >  retry:
> > +     if (nfs42_files_from_same_server(file_in, file_out)) {  /* Intra-ssc */
> > +             if (file_in->f_op != file_out->f_op)
> > +                     return -EXDEV;
> > +     } else {  /* Inter-ssc */
> > +             cn_resp = kzalloc(sizeof(struct nfs42_copy_notify_res),
> > +                               GFP_NOFS);
> > +             if (unlikely(cn_resp == NULL))
> > +                     return -ENOMEM;
> > +
> > +             ret = nfs42_proc_copy_notify(file_in, file_out, cn_resp);
> > +             if (ret)
> > +                     goto out;
> > +     }
> >       ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
> > +
> > +out:
> > +     kfree(cn_resp);
> >       if (ret == -EAGAIN)
> >               goto retry;
> >       return ret;
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index db84b4a..fec6e6b 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -9692,6 +9692,7 @@ static bool nfs4_match_stateid(const nfs4_stateid *s1,
> >               | NFS_CAP_ALLOCATE
> >               | NFS_CAP_COPY
> >               | NFS_CAP_OFFLOAD_CANCEL
> > +             | NFS_CAP_COPY_NOTIFY
> >               | NFS_CAP_DEALLOCATE
> >               | NFS_CAP_SEEK
> >               | NFS_CAP_LAYOUTSTATS
> > diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> > index b7bde12..2163900 100644
> > --- a/fs/nfs/nfs4xdr.c
> > +++ b/fs/nfs/nfs4xdr.c
> > @@ -7790,6 +7790,7 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct
> > nfs_entry *entry,
> >       PROC42(CLONE,           enc_clone,              dec_clone),
> >       PROC42(COPY,            enc_copy,               dec_copy),
> >       PROC42(OFFLOAD_CANCEL,  enc_offload_cancel,     dec_offload_cancel),
> > +     PROC42(COPY_NOTIFY,     enc_copy_notify,        dec_copy_notify),
> >       PROC(LOOKUPP,           enc_lookupp,            dec_lookupp),
> >  };
> >
> > diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> > index 4d76f87..d80b25e 100644
> > --- a/include/linux/nfs4.h
> > +++ b/include/linux/nfs4.h
> > @@ -537,6 +537,7 @@ enum {
> >       NFSPROC4_CLNT_CLONE,
> >       NFSPROC4_CLNT_COPY,
> >       NFSPROC4_CLNT_OFFLOAD_CANCEL,
> > +     NFSPROC4_CLNT_COPY_NOTIFY,
> >
> >       NFSPROC4_CLNT_LOOKUPP,
> >  };
> > diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> > index 0fc0b91..e5d89ff 100644
> > --- a/include/linux/nfs_fs_sb.h
> > +++ b/include/linux/nfs_fs_sb.h
> > @@ -261,5 +261,6 @@ struct nfs_server {
> >  #define NFS_CAP_CLONE                (1U << 23)
> >  #define NFS_CAP_COPY         (1U << 24)
> >  #define NFS_CAP_OFFLOAD_CANCEL       (1U << 25)
> > +#define NFS_CAP_COPY_NOTIFY  (1U << 26)
> >
> >  #endif
> > diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> > index 0e01625..dfc59bc 100644
> > --- a/include/linux/nfs_xdr.h
> > +++ b/include/linux/nfs_xdr.h
> > @@ -1428,6 +1428,22 @@ struct nfs42_offload_status_res {
> >       int                             osr_status;
> >  };
> >
> > +struct nfs42_copy_notify_args {
> > +     struct nfs4_sequence_args       cna_seq_args;
> > +
> > +     struct nfs_fh           *cna_src_fh;
> > +     nfs4_stateid            cna_src_stateid;
> > +     struct nl4_server       cna_dst;
> > +};
> > +
> > +struct nfs42_copy_notify_res {
> > +     struct nfs4_sequence_res        cnr_seq_res;
> > +
> > +     struct nfstime4         cnr_lease_time;
> > +     nfs4_stateid            cnr_stateid;
> > +     struct nl4_server       cnr_src;
> > +};
> > +
> >  struct nfs42_seek_args {
> >       struct nfs4_sequence_args       seq_args;
> >
