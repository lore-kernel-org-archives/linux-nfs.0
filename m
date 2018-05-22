Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:35868 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752370AbeEVUia (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 16:38:30 -0400
Received: by mail-vk0-f42.google.com with SMTP id i185-v6so11772895vkg.3
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2018 13:38:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <537AAFBD-62BA-4F0B-9B2E-D27500A1205B@oracle.com>
References: <CAN-5tyEo3d18aWny5U65NWGP1G_4kdrKGw2VDEO8vipCoivAQw@mail.gmail.com>
 <594BD2F7-35FC-4E26-81D7-404194B7005A@oracle.com> <CAN-5tyHXhy7yS+6mNAyTzr9tX4vA9gma8AeRtvNG0-FNZaL_Yg@mail.gmail.com>
 <537AAFBD-62BA-4F0B-9B2E-D27500A1205B@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 22 May 2018 16:38:28 -0400
Message-ID: <CAN-5tyHLEm3SQ5_ayDr6_TECpQndN_haKSyodf7Ls61RbLR2_g@mail.gmail.com>
Subject: Re: [RFC] protect against denial-of-service on a 4.0 mount
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 22, 2018 at 4:22 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On May 22, 2018, at 1:17 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Tue, May 22, 2018 at 4:08 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>
>>>> On May 22, 2018, at 1:03 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>
>>>> I'm looking for comments on the approach to deal with the following
>>>> denial-of-service issue.
>>>>
>>>> Currently, during the nfs4.0 mount, the code takes the content
>>>> supplied by the user in the mount command for "clientaddr" and that
>>>> becomes part of the content of the SETCLIENTID client id. There are no
>>>> verifications that the supplied address belongs to the client
>>>> initiating the mount.
>>>>
>>>> A denial of services comes from where there are 2 clients with IP A
>>>> and IP B (bad one). Client IP A mounts and has "IP A" in the
>>>> SETCLIENTID. Client IP B does a mount and specified "clientaddr=IP A".
>>>> This causes the server to invalidate the lease for the legitimate
>>>> client IP A.
>>>
>>> Generally if this is a concern, Kerberos can be used during
>>> the SETCLIENTID to mutually authenticate the client and
>>> server. Shouldn't that prevent client B from tampering with
>>> client A's lease?
>>
>> It turns out to be a concern by folks (customers) that are using the
>> code. Kerberos does not help here. Client IP B can have a valid
>> Kerberos identity and still supply "clientaddr=" not belonging to it
>> for the SETCLIENTID and interfere with the other's lease.
>
> SETCLIENTID is associated with a client ID string and a Kerberos
> principal. The server is supposed to deny a client with the same
> string (and perhaps the same callback information) but a different
> Kerberos identity from purging an existing lease belonging to a
> different principal. NFS4ERR_CLID_INUSE.
>
> Are you saying the two clients have exactly the same host
> principal? That seems... wrong.
>

Are you sure client ID is associated with a Kerberos principal?

Looking ta the code that constructs the clientid content. I don't see
that cl_nodename takes in principal identity.
        scnprintf(str, len, "Linux NFSv%u.%u %s",
                        clp->rpc_ops->version, clp->cl_minorversion,
                        clp->cl_rpcclient->cl_nodename);

I have also tried to do a mount with and without Kerberos and the
clientid string is that same has NFSv4.0 client ip/server ip.

>>>> My suggested approach to fixing it, is to have nfs-utils do a sanity
>>>> checking that will check if the clientaddr that's suppose matches the
>>>> IP of the machine. Then currently, if it doesn't then it will ignore
>>>> the supplied value and use the IP of the machine. Whether this is
>>>> desirable vs say failing the mount and forcing the user to specify the
>>>> correct value is up for debate. Also, I'm not sure if the check for
>>>> the value of clientaddr should be done in the kernel itself instead of
>>>> the nfs-utils.
>>>>
>>>> Below is the rough fix to the nfs-utils. Please comment.
>>>
>>> One thing we want to be able to continue to do is specify
>>> "clientaddr=0.0.0.0" to disable NFSv4.0 callback (and thus
>>> delegation).
>>
>> Ok so some extra logic to check for the special value?
>
> There is some value in stronger input validation here,
> outside of the particular issue you described above. I
> think such validation should allow INADDR_ANY (and the
> IPv6 equivalent).

Ok.

>
>
>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>> index 1217823..982927e 100644
>>>> --- a/utils/mount/stropts.c
>>>> +++ b/utils/mount/stropts.c
>>>> @@ -242,11 +242,21 @@ static int nfs_append_clientaddr_option(const
>>>> struct sockaddr *sap,
>>>> struct sockaddr *my_addr = &address.sa;
>>>> socklen_t my_len = sizeof(address);
>>>>
>>>> - if (po_contains(options, "clientaddr") == PO_FOUND)
>>>> - return 1;
>>>> -
>>>> nfs_callback_address(sap, salen, my_addr, &my_len);
>>>>
>>>> + if (po_contains(options, "clientaddr") == PO_FOUND) {
>>>> + char *addr = po_get(options, "clientaddr");
>>>> +         char address[NI_MAXHOST];
>>>> +
>>>> +         if (!nfs_present_sockaddr(my_addr, my_len, address,
>>>> + sizeof(address)))
>>>> +                 goto out;
>>>> +
>>>> + if (strcmp(addr, address))
>>>> + goto out;
>>>> + return 1;
>>>> + }
>>>> +out:
>>>> return nfs_append_generic_address_option(my_addr, my_len,
>>>> "clientaddr", options);
>>>> }
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> --
>>> Chuck Lever
>
> --
> Chuck Lever
>
>
>
