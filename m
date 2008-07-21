From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 4/8] SUNRPC: Clean up svc_register
Date: Mon, 21 Jul 2008 15:24:24 -0400
Message-ID: <76bd70e30807211224p42674398id2cbe2b9646bd1f0@mail.gmail.com>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net>
	 <20080630224553.24887.73617.stgit@ellison.1015granger.net>
	 <20080718232931.GB15850@fieldses.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:36589 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbYGUTY0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2008 15:24:26 -0400
Received: by ug-out-1314.google.com with SMTP id h2so298697ugf.16
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2008 12:24:24 -0700 (PDT)
In-Reply-To: <20080718232931.GB15850@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 18, 2008 at 7:29 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Jun 30, 2008 at 06:45:53PM -0400, Chuck Lever wrote:
>> In preparation for adding rpcbind version 4 support to svc_register, clean
>> it up.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  include/linux/sunrpc/svc.h |    4 ++-
>>  net/sunrpc/svc.c           |   61 +++++++++++++++++++++++++++-----------------
>>  2 files changed, 41 insertions(+), 24 deletions(-)
>>
>>
>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>> index a27178b..05312e7 100644
>> --- a/include/linux/sunrpc/svc.h
>> +++ b/include/linux/sunrpc/svc.h
>> @@ -394,7 +394,9 @@ struct svc_serv *  svc_create_pooled(struct svc_program *, unsigned int,
>>  int             svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
>>  void            svc_destroy(struct svc_serv *);
>>  int             svc_process(struct svc_rqst *);
>> -int             svc_register(struct svc_serv *, int, unsigned short);
>> +int             svc_register(const struct svc_serv *, const unsigned short,
>> +                             const unsigned short);
>> +
>>  void            svc_wake_up(struct svc_serv *);
>>  void            svc_reserve(struct svc_rqst *rqstp, int space);
>>  struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index a41b163..c31a1e4 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -749,43 +749,58 @@ svc_exit_thread(struct svc_rqst *rqstp)
>>  }
>>  EXPORT_SYMBOL(svc_exit_thread);
>>
>> -/*
>> - * Register an RPC service with the local portmapper.
>> - * To unregister a service, call this routine with
>> - * proto and port == 0.
>> +static int __svc_register(const u32 program, const u32 version,
>> +                       sa_family_t family,
>> +                       const unsigned short protocol,
>> +                       const unsigned short port)
>> +{
>> +     int error, result;
>> +
>> +     error = rpcb_register(program, version, protocol, port, &result);
>> +     if (!result)
>> +             error = -EACCES;
>> +     return error;
>> +}
>> +
>> +/**
>> + * svc_register - register an RPC service with the local portmapper
>> + * @serv: svc_serv struct for the service to register
>> + * @protocol: transport protocol number to advertise
>> + * @port: port to advertise
>> + *
>>   */
>> -int
>> -svc_register(struct svc_serv *serv, int proto, unsigned short port)
>> +int svc_register(const struct svc_serv *serv, const unsigned short protocol,
>> +              const unsigned short port)
>>  {
>> -     struct svc_program      *progp;
>> -     unsigned int            i;
>> -     int                     error = 0, dummy;
>> +     struct svc_program *progp;
>> +     u32 version;
>
> Same style nit (i/version) as before.

It doesn't make any sense to me to name "proto", "port", "progp", and
even "vs_hidden" after their usage, but leave the RPC version number
as "i".

>  (Also: u32?  If we ever have to
> care how big the array index is here, we've got bigger problems....)

The array index is already bounds-checked by the for() statement, so
the range of the index variable should be inconsequential, right?

"u32" is a better type for an RPC version number than "int".

The RPC header is defined in RFC 1831, and the version field is
defined as an XDR unsigned int.  In RFC 1832, an XDR unsigned int is
defined as a 32-bit value.  Since on some hardware platforms an "int"
is not 32 bits, "u32" is the safest choice, and matches the Internet
standard definition of an RPC version number.  (__be32 is, of course,
the correct choice for an RPC version number that has already been
marshaled).

And, as mentioned before, I have already changed function arguments,
variables, and structure fields in other areas that contain RPC
version numbers to u32.  I would like to stay consistent, and
eliminate unnecessary implicit type conversions.

Thanks for the review.

> I don't really see "protocol" as much clearer than "proto" either, but
> OK.
>
> Seems good otherwise.
>
> --b.
>
>> +     int error = 0;
>>
>> -     BUG_ON(proto == 0 && port == 0);
>> +     BUG_ON(protocol == 0 && port == 0);
>>
>>       for (progp = serv->sv_program; progp; progp = progp->pg_next) {
>> -             for (i = 0; i < progp->pg_nvers; i++) {
>> -                     if (progp->pg_vers[i] == NULL)
>> +             for (version = 0; version < progp->pg_nvers; version++) {
>> +                     if (progp->pg_vers[version] == NULL)
>>                               continue;
>>
>> -                     dprintk("svc: svc_register(%s, %s, %d, %d)%s\n",
>> +                     dprintk("svc: svc_register(%s, %u, %u, %s, %u)%s\n",
>>                                       progp->pg_name,
>> -                                     proto == IPPROTO_UDP?  "udp" : "tcp",
>> +                                     version,
>> +                                     serv->sv_family,
>> +                                     protocol == IPPROTO_UDP ?
>> +                                                     "udp" : "tcp",
>>                                       port,
>> -                                     i,
>> -                                     progp->pg_vers[i]->vs_hidden?
>> -                                             " (but not telling portmap)" : "");
>> +                                     progp->pg_vers[version]->vs_hidden ?
>> +                                       " (but not telling portmap)" : "");
>>
>> -                     if (progp->pg_vers[i]->vs_hidden)
>> +                     if (progp->pg_vers[version]->vs_hidden)
>>                               continue;
>>
>> -                     error = rpcb_register(progp->pg_prog, i, proto, port, &dummy);
>> +                     error = __svc_register(progp->pg_prog, version,
>> +                                             serv->sv_family, protocol,
>> +                                             port);
>>                       if (error < 0)
>>                               break;
>> -                     if (port && !dummy) {
>> -                             error = -EACCES;
>> -                             break;
>> -                     }
>>               }
>>       }
>>
>>

-- 
Chuck Lever
