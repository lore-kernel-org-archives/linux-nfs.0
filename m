Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34987 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbdIMOjV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Sep 2017 10:39:21 -0400
Received: by mail-it0-f65.google.com with SMTP id b76so470492itb.2
        for <linux-nfs@vger.kernel.org>; Wed, 13 Sep 2017 07:39:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170906204523.GC24694@fieldses.org>
References: <20170711164416.1982-1-kolga@netapp.com> <20170711164416.1982-26-kolga@netapp.com>
 <20170906204523.GC24694@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 13 Sep 2017 10:39:19 -0400
Message-ID: <CAN-5tyH0AHCU_nfz7+q-dK24V6DUy9D0HEMqR4oajMA+OEyYZQ@mail.gmail.com>
Subject: Re: [RFC v3 25/42] NFSD add COPY_NOTIFY operation
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 6, 2017 at 4:45 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Jul 11, 2017 at 12:43:59PM -0400, Olga Kornievskaia wrote:
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfsd/nfs4proc.c |  98 ++++++++++++++++++++++++++++++++++++++++++++++
>>  fs/nfsd/nfs4xdr.c  | 112 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
>>  fs/nfsd/xdr4.h     |  13 +++++++
>>  3 files changed, 221 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index dadb3bf..ed6b9f2 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -35,6 +35,7 @@
>>  #include <linux/file.h>
>>  #include <linux/falloc.h>
>>  #include <linux/slab.h>
>> +#include <linux/sunrpc/addr.h>
>>
>>  #include "idmap.h"
>>  #include "cache.h"
>> @@ -1087,6 +1088,82 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>>  }
>>
>>  static __be32
>> +nfsd4_set_src_nl4_netaddr(struct svc_rqst *rqstp, struct nl4_servers *svrs)
>> +{
>> +     const struct sockaddr *addr = (struct sockaddr *)&rqstp->rq_daddr;
>> +     const struct sockaddr_in *sin = (const struct sockaddr_in *)addr;
>> +     const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)addr;
>> +     int uaddr_len = rqstp->rq_daddrlen + 4 + 1; /* port (4) and '\0' (1) */
>> +     struct nfs42_netaddr *naddr;
>> +     size_t ret;
>> +     unsigned short port;
>> +
>> +     /* freed in nfsd4_encode_copy_notify */
>> +     svrs->nl_svr = kmalloc_array(svrs->nl_nsvr, sizeof(struct nl4_server),
>> +                             GFP_KERNEL);
>> +     if (svrs->nl_svr == NULL)
>> +             return nfserrno(-ENOMEM);
>> +
>> +     svrs->nl_svr->nl4_type = NL4_NETADDR;
>> +     naddr = &svrs->nl_svr->u.nl4_addr;
>> +
>> +     switch (addr->sa_family) {
>> +     case AF_INET:
>> +             port = ntohs(sin->sin_port);
>> +             sprintf(naddr->na_netid, "tcp");
>> +             naddr->na_netid_len = 3;
>> +             break;
>> +     case AF_INET6:
>> +             port = ntohs(sin6->sin6_port);
>> +             sprintf(naddr->na_netid, "tcp6");
>> +             naddr->na_netid_len = 4;
>> +             break;
>> +     default:
>> +             dprintk("NFSD  nfsd4_set_notify_src: unknown address type: %d",
>> +                     addr->sa_family);
>> +             kfree(svrs->nl_svr);
>> +             return nfserrno(-EINVAL);
>> +     }
>> +     ret = rpc_ntop(addr, naddr->na_uaddr, sizeof(naddr->na_uaddr));
>> +     snprintf(naddr->na_uaddr + ret, uaddr_len, ".%u.%u",
>> +              port >> 8, port & 255);
>> +     naddr->na_uaddr_len = strlen(naddr->na_uaddr);
>
> I'm a little surprised there isn't already a standard helper for
> this....  Actually, does net/sunrpc:addr.c:rpc_sockaddr2uaddr() do it?

That only creates the string which is just a part of the data
structure. So I don't think it would be useful.

> (Looks like there's other potential users in
> fs/nfsd/flexfilelayout.c:nfsd4_ff_proc_getdeviceinfo() and in flexfiles
> code on client side and probably some other places too.)

Both flex files and copy can be re-written to share code though. They
are setting up similar .._netaddr structure.

> --b.
>
>> +     return 0;
>> +}
>> +
>> +static __be32
>> +nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> +               struct nfsd4_copy_notify *cn)
>> +{
>> +     __be32 status;
>> +     struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
>> +
>> +     status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
>> +                                     &cn->cpn_src_stateid, RD_STATE, NULL,
>> +                                     NULL);
>> +     if (status)
>> +             return status;
>> +
>> +     cn->cpn_sec = nn->nfsd4_lease;
>> +     cn->cpn_nsec = 0;
>> +
>> +
>> +     /** XXX Save cpn_src_statid, cpn_src, and any other returned source
>> +      * server addresses on which the source server is williing to accept
>> +      * connections from the destination e.g. what is returned in cpn_src,
>> +      * to verify READ from dest server.
>> +      */
>> +
>> +     /**
>> +      * For now, only return one server address in cpn_src, the
>> +      * address used by the client to connect to this server.
>> +      */
>> +     cn->cpn_src.nl_nsvr = 1;
>> +
>> +     return nfsd4_set_src_nl4_netaddr(rqstp, &cn->cpn_src);
>> +}
>> +
>> +static __be32
>>  nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>>               struct nfsd4_fallocate *fallocate, int flags)
>>  {
>> @@ -2042,6 +2119,21 @@ static inline u32 nfsd4_copy_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>>               1 /* cr_synchronous */) * sizeof(__be32);
>>  }
>>
>> +static inline u32 nfsd4_copy_notify_rsize(struct svc_rqst *rqstp,
>> +                                     struct nfsd4_op *op)
>> +{
>> +     return (op_encode_hdr_size +
>> +             3 /* cnr_lease_time */ +
>> +             1 /* We support one cnr_source_server */ +
>> +             1 /* cnr_stateid seq */ +
>> +             op_encode_stateid_maxsz /* cnr_stateid */ +
>> +             1 /* num cnr_source_server*/ +
>> +             1 /* nl4_type */ +
>> +             1 /* nl4 size */ +
>> +             XDR_QUADLEN(NFS4_OPAQUE_LIMIT) /*nl4_loc + nl4_loc_sz */)
>> +             * sizeof(__be32);
>> +}
>> +
>>  #ifdef CONFIG_NFSD_PNFS
>>  static inline u32 nfsd4_getdeviceinfo_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>>  {
>> @@ -2446,6 +2538,12 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>>               .op_name = "OP_SEEK",
>>               .op_rsize_bop = (nfsd4op_rsize)nfsd4_seek_rsize,
>>       },
>> +     [OP_COPY_NOTIFY] = {
>> +             .op_func = (nfsd4op_func)nfsd4_copy_notify,
>> +             .op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
>> +             .op_name = "OP_COPY_NOTIFY",
>> +             .op_rsize_bop = (nfsd4op_rsize)nfsd4_copy_notify_rsize,
>> +     },
>>  };
>>
>>  /**
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 031d06d..3e08c15 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -1820,6 +1820,22 @@ static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
>>  }
>>
>>  static __be32
>> +nfsd4_decode_copy_notify(struct nfsd4_compoundargs *argp,
>> +                      struct nfsd4_copy_notify *cn)
>> +{
>> +     int status;
>> +
>> +     status = nfsd4_decode_stateid(argp, &cn->cpn_src_stateid);
>> +     if (status)
>> +             return status;
>> +     status = nfsd4_decode_nl4_server(argp, &cn->cpn_dst);
>> +     if (status)
>> +             return status;
>> +
>> +     return status;
>> +}
>> +
>> +static __be32
>>  nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
>>  {
>>       DECODE_HEAD;
>> @@ -1920,7 +1936,7 @@ static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
>>       /* new operations for NFSv4.2 */
>>       [OP_ALLOCATE]           = (nfsd4_dec)nfsd4_decode_fallocate,
>>       [OP_COPY]               = (nfsd4_dec)nfsd4_decode_copy,
>> -     [OP_COPY_NOTIFY]        = (nfsd4_dec)nfsd4_decode_notsupp,
>> +     [OP_COPY_NOTIFY]        = (nfsd4_dec)nfsd4_decode_copy_notify,
>>       [OP_DEALLOCATE]         = (nfsd4_dec)nfsd4_decode_fallocate,
>>       [OP_IO_ADVISE]          = (nfsd4_dec)nfsd4_decode_notsupp,
>>       [OP_LAYOUTERROR]        = (nfsd4_dec)nfsd4_decode_notsupp,
>> @@ -4355,6 +4371,52 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>>  }
>>
>>  static __be32
>> +nfsd42_encode_nl4_server(struct nfsd4_compoundres *resp, struct nl4_server *ns)
>> +{
>> +     struct xdr_stream *xdr = &resp->xdr;
>> +     struct nfs42_netaddr *addr;
>> +     __be32 *p;
>> +
>> +     p = xdr_reserve_space(xdr, 4);
>> +     *p++ = cpu_to_be32(ns->nl4_type);
>> +
>> +     switch (ns->nl4_type) {
>> +     case NL4_NAME:
>> +     case NL4_URL:
>> +             p = xdr_reserve_space(xdr, 4 /* url or name len */ +
>> +                                   (XDR_QUADLEN(ns->u.nl4_str_sz) * 4));
>> +             if (!p)
>> +                     return nfserr_resource;
>> +             *p++ = cpu_to_be32(ns->u.nl4_str_sz);
>> +             p = xdr_encode_opaque_fixed(p, ns->u.nl4_str, ns->u.nl4_str_sz);
>> +                     break;
>> +     case NL4_NETADDR:
>> +             addr = &ns->u.nl4_addr;
>> +
>> +             /** netid_len, netid, uaddr_len, uaddr (port included
>> +              * in RPCBIND_MAXUADDRLEN)
>> +              */
>> +             p = xdr_reserve_space(xdr,
>> +                     4 /* netid len */ +
>> +                     (XDR_QUADLEN(addr->na_netid_len) * 4) +
>> +                     4 /* uaddr len */ +
>> +                     (XDR_QUADLEN(addr->na_uaddr_len) * 4));
>> +             if (!p)
>> +                     return nfserr_resource;
>> +
>> +             *p++ = cpu_to_be32(addr->na_netid_len);
>> +             p = xdr_encode_opaque_fixed(p, addr->na_netid,
>> +                                         addr->na_netid_len);
>> +             *p++ = cpu_to_be32(addr->na_uaddr_len);
>> +             p = xdr_encode_opaque_fixed(p, addr->na_uaddr,
>> +                                     addr->na_uaddr_len);
>> +             break;
>> +     }
>> +
>> +     return 0;
>> +}
>> +
>> +static __be32
>>  nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
>>                 struct nfsd4_copy *copy)
>>  {
>> @@ -4375,6 +4437,52 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>>  }
>>
>>  static __be32
>> +nfsd4_encode_copy_notify(struct nfsd4_compoundres *resp, __be32 nfserr,
>> +                      struct nfsd4_copy_notify *cn)
>> +{
>> +     struct xdr_stream *xdr = &resp->xdr;
>> +     struct nl4_server *ns;
>> +     __be32 *p;
>> +     int i;
>> +
>> +     if (nfserr)
>> +             return nfserr;
>> +
>> +     /* 8 sec, 4 nsec */
>> +     p = xdr_reserve_space(xdr, 12);
>> +     if (!p)
>> +             return nfserr_resource;
>> +
>> +     /* cnr_lease_time */
>> +     p = xdr_encode_hyper(p, cn->cpn_sec);
>> +     *p++ = cpu_to_be32(cn->cpn_nsec);
>> +
>> +     /* cnr_stateid */
>> +     nfserr = nfsd4_encode_stateid(xdr, &cn->cpn_src_stateid);
>> +     if (nfserr)
>> +             return nfserr;
>> +
>> +     /* cnr_src.nl_nsvr */
>> +     p = xdr_reserve_space(xdr, 4);
>> +     if (!p)
>> +             return nfserr_resource;
>> +
>> +     *p++ = cpu_to_be32(cn->cpn_src.nl_nsvr);
>> +
>> +     ns = cn->cpn_src.nl_svr;
>> +     for (i = 0; i < cn->cpn_src.nl_nsvr; i++) {
>> +             nfserr = nfsd42_encode_nl4_server(resp, ns);
>> +             if (nfserr)
>> +                     return nfserr;
>> +             ns++;
>> +     }
>> +
>> +     /* allocated in nfsd4_copy_notify */
>> +     kfree(cn->cpn_src.nl_svr);
>> +     return nfserr;
>> +}
>> +
>> +static __be32
>>  nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
>>                 struct nfsd4_seek *seek)
>>  {
>> @@ -4474,7 +4582,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>>       /* NFSv4.2 operations */
>>       [OP_ALLOCATE]           = (nfsd4_enc)nfsd4_encode_noop,
>>       [OP_COPY]               = (nfsd4_enc)nfsd4_encode_copy,
>> -     [OP_COPY_NOTIFY]        = (nfsd4_enc)nfsd4_encode_noop,
>> +     [OP_COPY_NOTIFY]        = (nfsd4_enc)nfsd4_encode_copy_notify,
>>       [OP_DEALLOCATE]         = (nfsd4_enc)nfsd4_encode_noop,
>>       [OP_IO_ADVISE]          = (nfsd4_enc)nfsd4_encode_noop,
>>       [OP_LAYOUTERROR]        = (nfsd4_enc)nfsd4_encode_noop,
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index 6b1a61fc..5db7cd8 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -540,6 +540,18 @@ struct nfsd4_seek {
>>       loff_t          seek_pos;
>>  };
>>
>> +struct nfsd4_copy_notify {
>> +     /* request */
>> +     stateid_t               cpn_src_stateid;
>> +     struct nl4_server       cpn_dst;
>> +
>> +     /* response */
>> +     /* Note: cpn_src_stateid is used for cnr_stateid */
>> +     u64                     cpn_sec;
>> +     u32                     cpn_nsec;
>> +     struct nl4_servers      cpn_src;
>> +};
>> +
>>  struct nfsd4_op {
>>       int                                     opnum;
>>       __be32                                  status;
>> @@ -595,6 +607,7 @@ struct nfsd4_op {
>>               struct nfsd4_fallocate          deallocate;
>>               struct nfsd4_clone              clone;
>>               struct nfsd4_copy               copy;
>> +             struct nfsd4_copy_notify        copy_notify;
>>               struct nfsd4_seek               seek;
>>       } u;
>>       struct nfs4_replay *                    replay;
>> --
>> 1.8.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
