Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f177.google.com ([209.85.217.177]:33714 "EHLO
        mail-ua0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934496AbeEYOCD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 May 2018 10:02:03 -0400
Received: by mail-ua0-f177.google.com with SMTP id i2-v6so3535203uah.0
        for <linux-nfs@vger.kernel.org>; Fri, 25 May 2018 07:02:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <48E7EEA0-C804-4AB3-9C08-10A5B14B8976@oracle.com>
References: <20180524200542.22685-1-kolga@netapp.com> <48E7EEA0-C804-4AB3-9C08-10A5B14B8976@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 25 May 2018 10:02:00 -0400
Message-ID: <CAN-5tyHb4WDXqqeYxQm+kzjmSquaKZ3fqsVkMW1Hx5RCmdxb2Q@mail.gmail.com>
Subject: Re: [PATCH 1/1] nfs-utils: Add check of clientaddr argument
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thank you for the comments. Will hopefully address them in the next version.

On Thu, May 24, 2018 at 8:50 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi Olga-
>
>> On May 24, 2018, at 1:05 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
>>
>> If the user supplies a clientaddr value,
>
> Please say "NFS client administrator" not "user". A
> "user" is any non-privileged user, so saying that a
> "user" can set this value is misleading.

Ok will change it.

>> it should be either
>> a special value of either IPV4/IPV6 any address or a local address
>> on the same network that the server being mounted.
>
> This option should allow any local address the client has,
> not just an address that is on the same network as the
> server. See below for further explanation.

Ok, I added this to the comment specifically as I didn't know if this
would pose a problem. I didn't know if allowing any address was useful
as when it's not specified the address on the same network as the
server is chosen.

>> Otherwise, we
>> disallow the client to use an arbitrary value of the clientaddr value.
>> This value is used to construct a client id of SETCLIENTID and
>> providing a false value can interfere with the real owner's mount.
>
> The patch description is misleading:
>
> Interference occurs only if the real owner's lease is
> not protected by Kerberos AND this client has the same
> client ID string as another client.

Ok I will add this more explicit detail when the interference occurs
(when neither of the machines are using Kerberos and the other client
machine is not using a module parameter to add a unique identifier to
the client ID string). I think otherwise it is knowns that client ID
is created with the value of the clientaddr.

> The Linux client's client ID string also contains the
> system's cl_nodename. Both the cl_nodename and the
> callback address have to be the same as some other
> client's, and they both have to be Linux, for this to
> be a problem.
>
> It's more likely that the customer's clients are all
> named the same (maybe they are copied from the same
> system image), and reverse DNS lookup is giving them
> all the same clientaddr= . That's an unsupported
> configuration and there are already ways to address
> this.
>
> Or perhaps I don't understand the use case that is
> causing the problem. Can the patch description explain
> why your customer is trying to set clientaddr= ?

The customer case was a simple mistake of including the wrong address.
Do you fundamentally disagree that there is a case for
denial-of-service here?

>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>> utils/mount/stropts.c | 24 ++++++++++++++++++++----
>> 1 file changed, 20 insertions(+), 4 deletions(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index d1b0708..44a6ff5 100644
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
>> @@ -242,11 +243,26 @@ static int nfs_append_clientaddr_option(const struct sockaddr *sap,
>>       struct sockaddr *my_addr = &address.sa;
>>       socklen_t my_len = sizeof(address);
>>
>> -     if (po_contains(options, "clientaddr") == PO_FOUND)
>> -             return 1;
>> -
>>       nfs_callback_address(sap, salen, my_addr, &my_len);
>>
>> +     if (po_contains(options, "clientaddr") == PO_FOUND) {
>> +             char *addr = po_get(options, "clientaddr");
>> +             char address[NI_MAXHOST];
>> +
>> +             if (!strcmp(addr, "0.0.0.0") || !strcmp(addr, "::"))
>> +                     return 1;
>
> IN6ADDR_ANY can be spelled in other ways than "::".
>
> Please don't compare presentation address strings.
> First step is to convert the clientaddr= value to an
> nfs_sockaddr. If that cannot be done, then clearly
> this is not a valid mount option.
>
>
>> +             if (!nfs_present_sockaddr(my_addr, my_len, address,
>> +                                             sizeof(address)))
>> +                     goto out;
>> +
>> +             if (strcmp(addr, address)) {
>> +                     nfs_error(_("%s: failed to validate clientaddr "
>> +                                     "address"), progname);
>> +                     return 0;
>> +             }
>
> This needs to check whether the supplied address is a
> local address on _any_ of the client's interfaces. That's
> the point of allowing an admin to set clientaddr= ...
> sometimes the automatic setting (which comes from
> nfs_callback_address) is wrong.
>
> Think of a multi-homed client, or a client with public and
> private interfaces, or a weird firewall configuration.
> This check will break all those cases.
>
> So here, use a reliable mechanism for determining whether
> the passed-in clientaddr= value specifies the address of
> one of the local interfaces on the client.
>
>
>> +             return 1;
>> +     }
>> +out:
>>       return nfs_append_generic_address_option(my_addr, my_len,
>>                                                       "clientaddr", options);
>> }
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
