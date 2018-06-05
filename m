Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:43240 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751764AbeFERpB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2018 13:45:01 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH v2 1/1] Add check of clientaddr argument
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyEZZXiETG=UKQ0GNn7fonzuMONLp9uBH8+o+tjYiLjAnA@mail.gmail.com>
Date: Tue, 5 Jun 2018 13:44:45 -0400
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <747B9FD7-6FA5-4B11-9B77-299693C90DB1@oracle.com>
References: <20180605155127.27429-1-kolga@netapp.com>
 <17CC43F7-6649-434B-BC7E-92623BA79CF5@oracle.com>
 <CAN-5tyEZZXiETG=UKQ0GNn7fonzuMONLp9uBH8+o+tjYiLjAnA@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 5, 2018, at 1:28 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Tue, Jun 5, 2018 at 12:49 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>> On Jun 5, 2018, at 11:51 AM, Olga Kornievskaia <kolga@netapp.com> =
wrote:
>>>=20
>>> If the user supplies a clientaddr value,
>>=20
>> Suggest instead:
>>=20
>> "If an NFS client administrator supplies the clientaddr mount =
option,"
>=20
> Ok.
>=20
>>> it should be either
>>> a special value of either IPv4/IPv6 any address or one of the
>>> machine's network addresses. Otherwise, the use of an arbitrary
>>> value of the clientaddr value is not allowed.
>>=20
>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>> ---
>>> utils/mount/network.c | 45 =
+++++++++++++++++++++++++++++++++++++++++++++
>>> utils/mount/network.h |  2 ++
>>> utils/mount/stropts.c | 28 +++++++++++++++++++++++++---
>>> 3 files changed, 72 insertions(+), 3 deletions(-)
>>>=20
>>> diff --git a/utils/mount/network.c b/utils/mount/network.c
>>> index e490399..2a54f82 100644
>>> --- a/utils/mount/network.c
>>> +++ b/utils/mount/network.c
>>> @@ -50,6 +50,8 @@
>>> #include <rpc/rpc.h>
>>> #include <rpc/pmap_prot.h>
>>> #include <rpc/pmap_clnt.h>
>>> +#include <net/if.h>
>>> +#include <ifaddrs.h>
>>>=20
>>> #include "sockaddr.h"
>>> #include "xcommon.h"
>>> @@ -1759,3 +1761,46 @@ int nfs_umount_do_umnt(struct mount_options =
*options,
>>>=20
>>>      return EX_SUCCESS;
>>> }
>>> +
>>> +int nfs_is_inaddr_any(struct sockaddr *nfs_saddr)
>>> +{
>>> +     switch (nfs_saddr->sa_family) {
>>> +     case AF_INET: {
>>> +             if (((struct sockaddr_in *)nfs_saddr)->sin_addr.s_addr =
=3D=3D
>>> +                             INADDR_ANY)
>>> +                     return 1;
>>> +     }
>>> +     case AF_INET6:
>>> +             if (!memcmp(&((struct sockaddr_in6 =
*)nfs_saddr)->sin6_addr,
>>> +                             &in6addr_any, sizeof(in6addr_any)))
>>> +                     return 1;
>>> +     }
>>> +     return 0;
>>> +}
>>> +
>>> +int nfs_addr_matches_localips(struct sockaddr *nfs_saddr)
>>> +{
>>> +     struct ifaddrs *myaddrs, *ifa;
>>> +     int found =3D 0;
>>> +
>>> +     /* acquire exiting network interfaces */
>>> +     if (getifaddrs(&myaddrs) !=3D 0)
>>> +             return 0;
>>> +
>>> +     /* interate over the available interfaces and check if we
>>> +      * we find a match to the supplied clientaddr value
>>> +      */
>>> +     for (ifa =3D myaddrs; ifa !=3D NULL; ifa =3D ifa->ifa_next) {
>>> +             if (ifa->ifa_addr =3D=3D NULL)
>>> +                     continue;
>>> +             if (!(ifa->ifa_flags & IFF_UP))
>>> +                     continue;
>>> +             if (!memcmp(ifa->ifa_addr, nfs_saddr,
>>> +                             sizeof(struct sockaddr))) {
>>> +                     found =3D 1;
>>> +                     break;
>>> +             }
>>> +     }
>>> +     freeifaddrs(myaddrs);
>>> +     return found;
>>> +}
>>=20
>> This looks like what we discussed, and it is implemented IMO
>> correctly.

While I was watching TV and eating lunch, it occurred to me
that mount.nfs could pass the clientaddr value to bind(2).
bind(2) should work for an ANY address or a local address, but
would fail with a non-local address, unless I'm confused. Just
a random thought.


>> Can you also provide an update to nfs(5)?

>> After all the dialog and thinking more about it, I'm less convinced
>> that prohibiting non-local addresses is wise. The client can mount
>> through a NAT and specify a clientaddr that points to the NAT. That
>> seems like a correct configuration that would now be prohibited.
>>=20
>> However I don't know of any actual deployments like this, so it's
>> hard to argue convincingly that mount.nfs needs to continue to allow
>> it.
>>=20
>> May I suggest a slight alteration?
>>=20
>> - If the value of clientaddr=3D is not a presentation address,
>>   report the problem and fail the mount (no change)
>>=20
>> - Allow the value of clientaddr=3D to be an ANY address without
>>   complaint (no change)
>>=20
>> - If the value of clientaddr=3D is not a local address, warn but
>>   allow it (rather than failing)
>>=20
>> That permits flexibility but also gives a good indication to
>> administrators who have made an honest mistake.
>=20
> Given that we are changing the kernel to not use the cl_ipaddr to
> construct the client ID, then I'm ok with allowing a none local
> address with a warning. But can you tell me how you think specifying a
> non local address would actually work? It doesn't make sense to me as
> to how the callback would ever reach the appropriate client.  When the
> server establishes connected back to the NAT router IP, there is
> nothing that's listening there. And also NAT router doesn't know where
> to send it to.

How it might work:

- Each client would have it's own callback service running on
  a distinct port

- The NAT would need to be programmed to route the callback
  connection to the correct client, by port


> If we are allowing but warning about the use of the arbitrary IP, do
> we need any change to the nfs(5)?

Hm...

You mentioned nfs(5) doesn't document the clientaddr=3DANY trick.
If we want to leave that undocumented (say, to try to implement
a more pleasant administrative interface to disable NFSv4.0
callback) then I suppose we could leave nfs(5) alone.


>>> diff --git a/utils/mount/network.h b/utils/mount/network.h
>>> index ecaac33..0fc98ac 100644
>>> --- a/utils/mount/network.h
>>> +++ b/utils/mount/network.h
>>> @@ -54,6 +54,8 @@ int nfs_callback_address(const struct sockaddr *, =
const socklen_t,
>>> int clnt_ping(struct sockaddr_in *, const unsigned long,
>>>              const unsigned long, const unsigned int,
>>>              struct sockaddr_in *);
>>> +int nfs_is_inaddr_any(struct sockaddr *);
>>> +int nfs_addr_matches_localips(struct sockaddr *);
>>>=20
>>> struct mount_options;
>>>=20
>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>> index d1b0708..e22216f 100644
>>> --- a/utils/mount/stropts.c
>>> +++ b/utils/mount/stropts.c
>>> @@ -229,7 +229,8 @@ static int nfs_append_addr_option(const struct =
sockaddr *sap,
>>>=20
>>> /*
>>> * Called to discover our address and append an appropriate =
'clientaddr=3D'
>>> - * option to the options string.
>>> + * option to the options string. If the supplied 'clientaddr=3D' =
value does
>>> + * not match either IPV4/IPv6 any or a local address, then fail the =
mount.
>>> *
>>> * Returns 1 if 'clientaddr=3D' option created successfully or if
>>> * 'clientaddr=3D' option is already present; otherwise zero.
>>> @@ -242,8 +243,29 @@ static int nfs_append_clientaddr_option(const =
struct sockaddr *sap,
>>>      struct sockaddr *my_addr =3D &address.sa;
>>>      socklen_t my_len =3D sizeof(address);
>>>=20
>>> -     if (po_contains(options, "clientaddr") =3D=3D PO_FOUND)
>>> -             return 1;
>>> +     if (po_contains(options, "clientaddr") =3D=3D PO_FOUND) {
>>> +             char *addr =3D po_get(options, "clientaddr");
>>> +             union nfs_sockaddr nfs_address;
>>> +             struct sockaddr *nfs_saddr =3D &nfs_address.sa;
>>> +             socklen_t nfs_salen =3D sizeof(nfs_address);
>>> +
>>> +             /* translate the input for clientaddr to nfs_sockaddr =
*/
>>> +             if (!nfs_string_to_sockaddr(addr, nfs_saddr, =
&nfs_salen))
>>> +                     return 0;
>>> +
>>> +             /* check for IPV4_ANY and IPV6_ANY */
>>> +             if (nfs_is_inaddr_any(nfs_saddr))
>>> +                     return 1;
>>> +
>>> +             /* check if ip matches local network addresses */
>>> +             if (!nfs_addr_matches_localips(nfs_saddr)) {
>>> +                     nfs_error(_("%s: supplied clientaddr=3D%s does =
not "
>>> +                             "match any existing network =
addresses"),
>>> +                             progname, addr);
>>> +                     return 0;
>>> +             } else
>>> +                     return 1;
>>> +     }
>>>=20
>>>      nfs_callback_address(sap, salen, my_addr, &my_len);
>>>=20
>>> --
>>> 1.8.3.1
>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



