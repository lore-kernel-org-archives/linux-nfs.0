Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34847 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbdIMOiz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Sep 2017 10:38:55 -0400
Received: by mail-it0-f68.google.com with SMTP id b76so469718itb.2
        for <linux-nfs@vger.kernel.org>; Wed, 13 Sep 2017 07:38:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170906213421.GD24694@fieldses.org>
References: <20170711164416.1982-1-kolga@netapp.com> <20170711164416.1982-26-kolga@netapp.com>
 <20170906213421.GD24694@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 13 Sep 2017 10:38:53 -0400
Message-ID: <CAN-5tyHERP1ifYj3zmn_-dEDg4gHh6xw4bXvL95qR6N+8OtZaw@mail.gmail.com>
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

On Wed, Sep 6, 2017 at 5:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
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
>
> Either we should fix the stuff mentioned in the comment or figure out
> why it's not necessary.

Sorry yes this comment should be removed from this patch. Another patch (29)
removes it.

> I guess I don't see what the value would be of verifying the IP address.

Correct no value is there. Also the READ request can come from a different IP
then what the client sends in COPY_NOTIFY. Destination server can be
multi-homed and share a high speed link with the source server and not with
the client.

> Our choice of IP address to return here is a little arbitrary anyway.

What the source server is returning shouldn't be arbitrary it should return
all the IPs (networks) that it might want to receive requests from the
destination
server.

> And I assume the eventualy READ calls are going to be verified with all
> the usual export and file permission checks.
>
> If we don't save the cna_src_stateid, then I guess that means the COPY
> might still succeed after the original OPEN/LOCK stateid is no longer
> valid?  I can't decide if that will cause problems in practice or not.

No we store the stateid (it's a part of the nfsd4_copy_notify structure and
gets saved from nfs4_preprocess_stateid_op. Then in patch 29 we generate
the unique stateid to be used for the copy itself and its validity is
tied to the
open/lock stateid and also it has to start to be used within the configured
lease time (nfsd_net->nfsd4_lease value).



>
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
>
> This code will never be used as far as I can tell.  We could
> BUG_ON(nl4_type != NL4_NETADDR) (or even just remove nl4_type).

Sure.

>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
