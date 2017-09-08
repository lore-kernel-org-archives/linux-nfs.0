Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33934 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932322AbdIHUwA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Sep 2017 16:52:00 -0400
Received: by mail-io0-f196.google.com with SMTP id b142so1665249ioe.1
        for <linux-nfs@vger.kernel.org>; Fri, 08 Sep 2017 13:52:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170906203520.GB24694@fieldses.org>
References: <20170711164416.1982-1-kolga@netapp.com> <20170711164416.1982-17-kolga@netapp.com>
 <20170906203520.GB24694@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 8 Sep 2017 16:51:59 -0400
Message-ID: <CAN-5tyFrVnC0dRVMxbUwaFoiGHbMDdF=Q-V69tihYPWy6gmYJQ@mail.gmail.com>
Subject: Re: [RFC v3 16/42] NFS NFSD defining nl4_servers structure needed by both
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 6, 2017 at 4:35 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Jul 11, 2017 at 12:43:50PM -0400, Olga Kornievskaia wrote:
>> These structures are needed by COPY_NOTIFY on the client and needed
>> by the nfsd as well
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  include/linux/nfs4.h | 33 +++++++++++++++++++++++++++++++++
>>  1 file changed, 33 insertions(+)
>>
>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>> index 7262908..4179c78 100644
>> --- a/include/linux/nfs4.h
>> +++ b/include/linux/nfs4.h
>> @@ -15,6 +15,7 @@
>>  #include <linux/list.h>
>>  #include <linux/uidgid.h>
>>  #include <uapi/linux/nfs4.h>
>> +#include <linux/sunrpc/msg_prot.h>
>>
>>  enum nfs4_acl_whotype {
>>       NFS4_ACL_WHO_NAMED = 0,
>> @@ -659,4 +660,36 @@ struct nfs4_op_map {
>>       } u;
>>  };
>>
>> +struct nfs42_netaddr {
>> +     unsigned int    na_netid_len;
>> +     char            na_netid[RPCBIND_MAXNETIDLEN + 1];
>> +     unsigned int    na_uaddr_len;
>> +     char            na_uaddr[RPCBIND_MAXUADDRLEN + 1];
>> +};
>> +
>> +enum netloc_type4 {
>> +     NL4_NAME                = 1,
>> +     NL4_URL                 = 2,
>> +     NL4_NETADDR             = 3,
>> +};
>> +
>> +struct nl4_server {
>> +     enum netloc_type4       nl4_type;
>> +     union {
>> +             struct { /* NL4_NAME, NL4_URL */
>> +                     int     nl4_str_sz;
>> +                     char    nl4_str[NFS4_OPAQUE_LIMIT + 1];
>> +             };
>> +             struct nfs42_netaddr    nl4_addr; /* NL4_NETADDR */
>> +     } u;
>> +};
>> +
>> +/*  support 1 nl4_server for now */
>> +#define NFS42_MAX_SSC_SRC       1
>
> In that case, let's just build that assumption into the data structures
> and embed struct nl4_server in nl4_servers and drop the unnecessary
> kmalloc()s.

Wouldn't we still want to malloc as the structure is too big to be
allocated on the stack?

Anna has also suggested dropping nl4_servers since the code sets maximum to 1.
I have resisted making the change because I felt like it was easier to
increase the
MAX_SSC_SRC to say something like 10 and support a multi-home server. Then
the destination server can add smarts to chose between the available address to
connect to the source server with.

Is this not a good argument to keep the structures? Should I change
value to 2 to
indicate desire to support multi-path?

>
> --b.
>
>> +
>> +struct nl4_servers {
>> +     int                     nl_nsvr;
>> +     struct nl4_server       *nl_svr;
>> +};
>> +
>>  #endif
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
