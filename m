Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:42890 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751895AbeFER23 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2018 13:28:29 -0400
Received: by mail-vk0-f66.google.com with SMTP id s187-v6so1926911vke.9
        for <linux-nfs@vger.kernel.org>; Tue, 05 Jun 2018 10:28:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <17CC43F7-6649-434B-BC7E-92623BA79CF5@oracle.com>
References: <20180605155127.27429-1-kolga@netapp.com> <17CC43F7-6649-434B-BC7E-92623BA79CF5@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 5 Jun 2018 13:28:27 -0400
Message-ID: <CAN-5tyEZZXiETG=UKQ0GNn7fonzuMONLp9uBH8+o+tjYiLjAnA@mail.gmail.com>
Subject: Re: [PATCH v2 1/1] Add check of clientaddr argument
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 5, 2018 at 12:49 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On Jun 5, 2018, at 11:51 AM, Olga Kornievskaia <kolga@netapp.com> wrote:
>>
>> If the user supplies a clientaddr value,
>
> Suggest instead:
>
>  "If an NFS client administrator supplies the clientaddr mount option,"

Ok.

>> it should be either
>> a special value of either IPv4/IPv6 any address or one of the
>> machine's network addresses. Otherwise, the use of an arbitrary
>> value of the clientaddr value is not allowed.
>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>> utils/mount/network.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
>> utils/mount/network.h |  2 ++
>> utils/mount/stropts.c | 28 +++++++++++++++++++++++++---
>> 3 files changed, 72 insertions(+), 3 deletions(-)
>>
>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>> index e490399..2a54f82 100644
>> --- a/utils/mount/network.c
>> +++ b/utils/mount/network.c
>> @@ -50,6 +50,8 @@
>> #include <rpc/rpc.h>
>> #include <rpc/pmap_prot.h>
>> #include <rpc/pmap_clnt.h>
>> +#include <net/if.h>
>> +#include <ifaddrs.h>
>>
>> #include "sockaddr.h"
>> #include "xcommon.h"
>> @@ -1759,3 +1761,46 @@ int nfs_umount_do_umnt(struct mount_options *options,
>>
>>       return EX_SUCCESS;
>> }
>> +
>> +int nfs_is_inaddr_any(struct sockaddr *nfs_saddr)
>> +{
>> +     switch (nfs_saddr->sa_family) {
>> +     case AF_INET: {
>> +             if (((struct sockaddr_in *)nfs_saddr)->sin_addr.s_addr ==
>> +                             INADDR_ANY)
>> +                     return 1;
>> +     }
>> +     case AF_INET6:
>> +             if (!memcmp(&((struct sockaddr_in6 *)nfs_saddr)->sin6_addr,
>> +                             &in6addr_any, sizeof(in6addr_any)))
>> +                     return 1;
>> +     }
>> +     return 0;
>> +}
>> +
>> +int nfs_addr_matches_localips(struct sockaddr *nfs_saddr)
>> +{
>> +     struct ifaddrs *myaddrs, *ifa;
>> +     int found = 0;
>> +
>> +     /* acquire exiting network interfaces */
>> +     if (getifaddrs(&myaddrs) != 0)
>> +             return 0;
>> +
>> +     /* interate over the available interfaces and check if we
>> +      * we find a match to the supplied clientaddr value
>> +      */
>> +     for (ifa = myaddrs; ifa != NULL; ifa = ifa->ifa_next) {
>> +             if (ifa->ifa_addr == NULL)
>> +                     continue;
>> +             if (!(ifa->ifa_flags & IFF_UP))
>> +                     continue;
>> +             if (!memcmp(ifa->ifa_addr, nfs_saddr,
>> +                             sizeof(struct sockaddr))) {
>> +                     found = 1;
>> +                     break;
>> +             }
>> +     }
>> +     freeifaddrs(myaddrs);
>> +     return found;
>> +}
>
> This looks like what we discussed, and it is implemented IMO
> correctly. Can you also provide an update to nfs(5)?
>
> After all the dialog and thinking more about it, I'm less convinced
> that prohibiting non-local addresses is wise. The client can mount
> through a NAT and specify a clientaddr that points to the NAT. That
> seems like a correct configuration that would now be prohibited.
>
> However I don't know of any actual deployments like this, so it's
> hard to argue convincingly that mount.nfs needs to continue to allow
> it.
>
> May I suggest a slight alteration?
>
>  - If the value of clientaddr= is not a presentation address,
>    report the problem and fail the mount (no change)
>
>  - Allow the value of clientaddr= to be an ANY address without
>    complaint (no change)
>
>  - If the value of clientaddr= is not a local address, warn but
>    allow it (rather than failing)
>
> That permits flexibility but also gives a good indication to
> administrators who have made an honest mistake.

Given that we are changing the kernel to not use the cl_ipaddr to
construct the client ID, then I'm ok with allowing a none local
address with a warning. But can you tell me how you think specifying a
non local address would actually work? It doesn't make sense to me as
to how the callback would ever reach the appropriate client.  When the
server establishes connected back to the NAT router IP, there is
nothing that's listening there. And also NAT router doesn't know where
to send it to.

If we are allowing but warning about the use of the arbitrary IP, do
we need any change to the nfs(5)?

>
>> diff --git a/utils/mount/network.h b/utils/mount/network.h
>> index ecaac33..0fc98ac 100644
>> --- a/utils/mount/network.h
>> +++ b/utils/mount/network.h
>> @@ -54,6 +54,8 @@ int nfs_callback_address(const struct sockaddr *, const socklen_t,
>> int clnt_ping(struct sockaddr_in *, const unsigned long,
>>               const unsigned long, const unsigned int,
>>               struct sockaddr_in *);
>> +int nfs_is_inaddr_any(struct sockaddr *);
>> +int nfs_addr_matches_localips(struct sockaddr *);
>>
>> struct mount_options;
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index d1b0708..e22216f 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -229,7 +229,8 @@ static int nfs_append_addr_option(const struct sockaddr *sap,
>>
>> /*
>>  * Called to discover our address and append an appropriate 'clientaddr='
>> - * option to the options string.
>> + * option to the options string. If the supplied 'clientaddr=' value does
>> + * not match either IPV4/IPv6 any or a local address, then fail the mount.
>>  *
>>  * Returns 1 if 'clientaddr=' option created successfully or if
>>  * 'clientaddr=' option is already present; otherwise zero.
>> @@ -242,8 +243,29 @@ static int nfs_append_clientaddr_option(const struct sockaddr *sap,
>>       struct sockaddr *my_addr = &address.sa;
>>       socklen_t my_len = sizeof(address);
>>
>> -     if (po_contains(options, "clientaddr") == PO_FOUND)
>> -             return 1;
>> +     if (po_contains(options, "clientaddr") == PO_FOUND) {
>> +             char *addr = po_get(options, "clientaddr");
>> +             union nfs_sockaddr nfs_address;
>> +             struct sockaddr *nfs_saddr = &nfs_address.sa;
>> +             socklen_t nfs_salen = sizeof(nfs_address);
>> +
>> +             /* translate the input for clientaddr to nfs_sockaddr */
>> +             if (!nfs_string_to_sockaddr(addr, nfs_saddr, &nfs_salen))
>> +                     return 0;
>> +
>> +             /* check for IPV4_ANY and IPV6_ANY */
>> +             if (nfs_is_inaddr_any(nfs_saddr))
>> +                     return 1;
>> +
>> +             /* check if ip matches local network addresses */
>> +             if (!nfs_addr_matches_localips(nfs_saddr)) {
>> +                     nfs_error(_("%s: supplied clientaddr=%s does not "
>> +                             "match any existing network addresses"),
>> +                             progname, addr);
>> +                     return 0;
>> +             } else
>> +                     return 1;
>> +     }
>>
>>       nfs_callback_address(sap, salen, my_addr, &my_len);
>>
>> --
>> 1.8.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
