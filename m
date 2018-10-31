Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3313ECDE44
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 15:28:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2B27B20664
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 15:28:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ra1jZYSX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B27B20664
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729245AbeKAA1M (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 20:27:12 -0400
Received: from mail-vs1-f68.google.com ([209.85.217.68]:34292 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729243AbeKAA1M (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 20:27:12 -0400
Received: by mail-vs1-f68.google.com with SMTP id q15so10285681vso.1;
        Wed, 31 Oct 2018 08:28:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=h6MQvrDt8DGnTWUKmBEc/Ok20U/0WsL+K2dDvEb0kS0=;
        b=ra1jZYSXdZJPBloafiNg5KAkav63wnvwlot6LSnF6ZLhdB0GkiQYyZreshOkGV8sHM
         n18+n9ML4uYeFknVZENrnSbuvUKcKDz25sLI44kCb9oSjowvtF9fPKgOMyGGjfdus/zM
         OxEDxLt7QobCrwKCelRm4VPCcfhKJKTd99oqFd4KwEXrDaYp7sttwRMnn4yGrxx7hSi9
         j1566ge0qSh0FQCEfoCzSIZIdUJvuxvg2Kxcy48Sg8t/e4BwONpC/hcwIAi6VWQi38cp
         1masTcsa2JNVoZ9DRi6vCs2u6TylwK6DVRpZbhUTuxRfAtayWRSdYstwfzXnXk1EmPQp
         AvVQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=h6MQvrDt8DGnTWUKmBEc/Ok20U/0WsL+K2dDvEb0kS0=;
        b=uIqPCwjUcbZevb3hXC/QMlrZZ3NLhk38nCt5r2fofywkVSy7BWETGmRt7LrIc5sya8
         vKJUjLSMQN3G8V8bTNUCXmP5rxY60cxNMcS24VK48VQTLZDhr7u3upnpXGcGPTKER6Ve
         9013/qV2L4jmiFSM+9hWSBwOL0SdEk+LNotU/VQ6YAmDBw6PeE4PmbBwQ2btnZFuvQ7n
         itCS/KDkTD1ZYDdGFc6+ezn0Da6brZKA6Gp21lmFzr5PUMW2S3tbZFEJfI5g8OUKXdIo
         YXPwvkhtNknwctP9J3wZvwDJEkZgq0hZLxt0n8c++JD2aVXEXqbSAgDy5e+EG9wrRVV4
         hh7A==
X-Gm-Message-State: AGRZ1gIxAmOKuTtdoTmDvXh7oV7kTyFjarUsNHKed6PCl/OH2gbiihTH
        2O/CQ0JmVB45V1Pfg3m4QU3dt6F9eORQEZQraXs=
X-Google-Smtp-Source: AJdET5cg6zh5y9AfVmnUbeJOhGxNkIA3t6egLoIk+MBbCbeUDZMn8Z1/dXGwT1zh8yOzjvoPS+jrvoeH5bhq3w6zFPk=
X-Received: by 2002:a67:4285:: with SMTP id p127mr1487762vsa.134.1540999721283;
 Wed, 31 Oct 2018 08:28:41 -0700 (PDT)
MIME-Version: 1.0
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
 <20181030205614.40754-6-olga.kornievskaia@gmail.com> <cfdccad3433336a02201e79d77daf78f1e2c7e78.camel@netapp.com>
In-Reply-To: <cfdccad3433336a02201e79d77daf78f1e2c7e78.camel@netapp.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Wed, 31 Oct 2018 11:28:29 -0400
Message-ID: <CAN-5tyEAHBENqSij0rNf1TjD31Mk9fUND8XTkBFDCWE2ezaDrQ@mail.gmail.com>
Subject: Re: [PATCH v7 04/11] NFS: add COPY_NOTIFY operation
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     viro@zeniv.linux.org.uk, Steve French <smfrench@gmail.com>,
        trond.myklebust@hammerspace.com,
        Miklos Szeredi <miklos@szeredi.hu>,
        linux-unionfs@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-man@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 31, 2018 at 11:07 AM Schumaker, Anna
<Anna.Schumaker@netapp.com> wrote:
>
> Hi Olga,
>
> On Tue, 2018-10-30 at 16:56 -0400, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > Try using the delegation stateid, then the open stateid.
> >
> > Only NL4_NETATTR, No support for NL4_NAME and NL4_URL.
> > Allow only one source server address to be returned for now.
> >
> > To distinguish between same server copy offload ("intra") and
> > a copy between different server ("inter"), do a check of server
> > owner identity.
> >
> > Reviewed-by: Jeff Layton <jlayton@redhat.com>
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  fs/nfs/nfs42.h            |  12 +++
> >  fs/nfs/nfs42proc.c        |  91 +++++++++++++++++++++++
> >  fs/nfs/nfs42xdr.c         | 181
> > ++++++++++++++++++++++++++++++++++++++++++++++
> >  fs/nfs/nfs4_fs.h          |   2 +
> >  fs/nfs/nfs4client.c       |   2 +-
> >  fs/nfs/nfs4file.c         |  14 ++++
> >  fs/nfs/nfs4proc.c         |   1 +
> >  fs/nfs/nfs4xdr.c          |   1 +
> >  include/linux/nfs4.h      |   1 +
> >  include/linux/nfs_fs_sb.h |   1 +
> >  include/linux/nfs_xdr.h   |  16 ++++
> >  11 files changed, 321 insertions(+), 1 deletion(-)
> >
> > diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
> > index 19ec38f8..bbe49a3 100644
> > --- a/fs/nfs/nfs42.h
> > +++ b/fs/nfs/nfs42.h
> > @@ -13,6 +13,7 @@
> >  #define PNFS_LAYOUTSTATS_MAXDEV (4)
> >
> >  /* nfs4.2proc.c */
> > +#ifdef CONFIG_NFS_V4_2
> >  int nfs42_proc_allocate(struct file *, loff_t, loff_t);
> >  ssize_t nfs42_proc_copy(struct file *, loff_t, struct file *, loff_t,
> > size_t);
> >  int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
> > @@ -20,5 +21,16 @@
> >  int nfs42_proc_layoutstats_generic(struct nfs_server *,
> >                                  struct nfs42_layoutstat_data *);
> >  int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
> > +int nfs42_proc_copy_notify(struct file *, struct file *,
> > +                        struct nfs42_copy_notify_res *);
> > +static inline bool nfs42_files_from_same_server(struct file *in,
> > +                                             struct file *out)
> > +{
> > +     struct nfs_client *c_in = (NFS_SERVER(file_inode(in)))->nfs_client;
> > +     struct nfs_client *c_out = (NFS_SERVER(file_inode(out)))->nfs_client;
> >
> > +     return nfs4_check_serverowner_major_id(c_in->cl_serverowner,
> > +                             c_out->cl_serverowner);
> > +}
> > +#endif /* CONFIG_NFS_V4_2 */
> >  #endif /* __LINUX_FS_NFS_NFS4_2_H */
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
> > diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> > index 8d59c96..7d17b31 100644
> > --- a/fs/nfs/nfs4_fs.h
> > +++ b/fs/nfs/nfs4_fs.h
> > @@ -460,6 +460,8 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
> >                       struct nfs_client **, struct rpc_cred *);
> >  extern void nfs4_schedule_session_recovery(struct nfs4_session *, int);
> >  extern void nfs41_notify_server(struct nfs_client *);
> > +bool nfs4_check_serverowner_major_id(struct nfs41_server_owner *o1,
> > +                     struct nfs41_server_owner *o2);
> >  #else
> >  static inline void nfs4_schedule_session_recovery(struct nfs4_session
> > *session, int err)
> >  {
> > diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> > index 8f53455..ac00eb8 100644
> > --- a/fs/nfs/nfs4client.c
> > +++ b/fs/nfs/nfs4client.c
> > @@ -625,7 +625,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
> >  /*
> >   * Returns true if the server major ids match
> >   */
> > -static bool
> > +bool
> >  nfs4_check_serverowner_major_id(struct nfs41_server_owner *o1,
> >                               struct nfs41_server_owner *o2)
> >  {
> > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > index 7838bdf..beda4b3 100644
> > --- a/fs/nfs/nfs4file.c
> > +++ b/fs/nfs/nfs4file.c
> > @@ -133,6 +133,7 @@ static ssize_t nfs4_copy_file_range(struct file *file_in,
> > loff_t pos_in,
> >                                   struct file *file_out, loff_t pos_out,
> >                                   size_t count, unsigned int flags)
> >  {
> > +     struct nfs42_copy_notify_res *cn_resp = NULL;
> >       ssize_t ret;
> >
> >       if (pos_in >= i_size_read(file_inode(file_in)))
> > @@ -144,7 +145,20 @@ static ssize_t nfs4_copy_file_range(struct file *file_in,
> > loff_t pos_in,
> >       if (file_inode(file_in) == file_inode(file_out))
> >               return -EINVAL;
> >  retry:
> > +     if (!nfs42_files_from_same_server(file_in, file_out)) {
>
> I'm seeing this crash when I try to use vfs_copy_file_range() on NFS v4.0.  I
> think it's because clients don't have a cl_serverowner defined in this case:

Thanks for the catch. Will fix it.

> [  +0.051545] BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000008
> [  +0.002032] PGD 0 P4D 0
> [  +0.002021] Oops: 0000 [#4] PREEMPT SMP PTI
> [  +0.001980] CPU: 1 PID: 1194 Comm: nfscopy Tainted: G      D           4.19.0-
> ANNA+ #2124
> [  +0.001386] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  +0.001266] RIP: 0010:nfs4_check_serverowner_major_id+0x5/0x30 [nfsv4]
> [  +0.001254] Code: ff ff 48 8b 7c 24 10 eb 95 41 bf da d8 ff ff eb da e8 ef ec
> eb d3 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 0f 1f 44 00 00 <8b> 57 08 31
> c0 3b 56 08 75 12 48 83 c6 0c 48 83 c7 0c e8 64 06 63
> [  +0.002487] RSP: 0018:ffffac0b40b77e50 EFLAGS: 00010246
> [  +0.001233] RAX: ffff8eb6f45a6000 RBX: ffff8eb77738e500 RCX: 0000000000000000
> [  +0.001218] RDX: ffff8eb6f45a6000 RSI: 0000000000000000 RDI: 0000000000000000
> [  +0.001271] RBP: ffff8eb6f533eb00 R08: 0000000080000000 R09: ffff8eb778c10800
> [  +0.000956] R10: ffff8eb77aa36f98 R11: ffff8eb77ab66320 R12: 0000000000000000
> [  +0.000848] R13: 0000000080000000 R14: 0000000000000000 R15: 0000000080000000
> [  +0.000880] FS:  00007f7bf84d9500(0000) GS:ffff8eb77cb00000(0000)
> knlGS:0000000000000000
> [  +0.000876] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  +0.000815] CR2: 0000000000000008 CR3: 00000000b3e80005 CR4: 0000000000160ee0
> [  +0.000809] Call Trace:
> [  +0.000803]  nfs4_copy_file_range+0x8b/0x120 [nfsv4]
> [  +0.000793]  vfs_copy_file_range+0x135/0x360
> [  +0.000768]  __se_sys_copy_file_range+0xce/0x1f0
> [  +0.000756]  do_syscall_64+0x5b/0x170
> [  +0.000765]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [  +0.000728] RIP: 0033:0x7f7bf840a40d
> [  +0.000718] Code: 00 c3 66 2e 0f 1f 84 00 00 00 00 00 90 f3 0f 1e fa 48 89 f8
> 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0
> ff ff 73 01 c3 48 8b 0d 23 7a 0c 00 f7 d8 64 89 01 48
> [  +0.001446] RSP: 002b:00007ffd9ee8c158 EFLAGS: 00000202 ORIG_RAX:
> 0000000000000146
> [  +0.000771] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f7bf840a40d
> [  +0.000727] RDX: 0000000000000004 RSI: 0000000000000000 RDI: 0000000000000003
> [  +0.000709] RBP: 00007ffd9ee8c1a0 R08: 0000000080000000 R09: 0000000000000000
> [  +0.000692] R10: 0000000000000000 R11: 0000000000000202 R12: 0000561b5b15e720
> [  +0.000680] R13: 00007ffd9ee8c360 R14: 0000000000000000 R15: 0000000000000000
> [  +0.000667] Modules linked in: rpcsec_gss_krb5 nfsv4 nfs fscache rpcrdma
> ib_isert iscsi_target_mod ib_iser libiscsi scsi_transport_iscsi ib_srpt
> target_core_mod ib_srp scsi_transport_srp ib_ipoib rdma_ucm ib_uverbs ib_umad
> rdma_cm ib_cm iw_cm ib_core crct10dif_pclmul crc32_pclmul cfg80211
> ghash_clmulni_intel nfsd joydev mousedev psmouse aesni_intel auth_rpcgss rfkill
> aes_x86_64 8021q crypto_simd nfs_acl cryptd lockd mrp input_leds glue_helper
> led_class grace evdev pcspkr intel_agp i2c_piix4 intel_gtt sunrpc mac_hid
> ip_tables x_tables ata_generic pata_acpi ata_piix libata scsi_mod serio_raw
> atkbd libps2 i8042 floppy serio xfs virtio_gpu drm_kms_helper syscopyarea
> sysfillrect sysimgblt fb_sys_fops ttm drm libcrc32c crc32c_generic crc32c_intel
> virtio_balloon virtio_net net_failover failover agpgart virtio_pci virtio_blk
> virtio_ring virtio
> [  +0.004802] CR2: 0000000000000008
> [  +0.000742] ---[ end trace 24756b969e170fa4 ]---
>
>
> Thanks,
> Anna
>
> > +             cn_resp = kzalloc(sizeof(struct nfs42_copy_notify_res),
> > +                             GFP_NOFS);
> > +             if (unlikely(cn_resp == NULL))
> > +                     return -ENOMEM;
> > +
> > +             ret = nfs42_proc_copy_notify(file_in, file_out, cn_resp);
> > +             if (ret)
> > +                     goto out;
> > +     }
> > +
> >       ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
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
> > index 4803507..9e49a6c 100644
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
