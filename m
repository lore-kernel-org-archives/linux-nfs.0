Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:36393 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966179AbeE2UHk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 16:07:40 -0400
Received: by mail-ua0-f195.google.com with SMTP id c23-v6so4340991uan.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 May 2018 13:07:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0079153E-7153-4246-AFD6-864E53100D8E@oracle.com>
References: <20180524200542.22685-1-kolga@netapp.com> <48E7EEA0-C804-4AB3-9C08-10A5B14B8976@oracle.com>
 <CAN-5tyHb4WDXqqeYxQm+kzjmSquaKZ3fqsVkMW1Hx5RCmdxb2Q@mail.gmail.com>
 <63AA3A00-6272-4D91-AC0A-30C9A169DBD1@oracle.com> <CAN-5tyHXpp1DgX4ULnnWmUoyPHFUOVWR0PiMhhaD89Gxn9Hf-g@mail.gmail.com>
 <CC64DAF4-5BE4-4433-8CF7-23B8E887E668@oracle.com> <0079153E-7153-4246-AFD6-864E53100D8E@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 29 May 2018 16:07:38 -0400
Message-ID: <CAN-5tyFPDknZxR9XR28usGHAyTDKtnp5JpCOVhbB-bjBhND6dw@mail.gmail.com>
Subject: Re: [PATCH 1/1] nfs-utils: Add check of clientaddr argument
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@hammerspace.com,
        Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 25, 2018 at 6:35 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On May 25, 2018, at 10:04 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>
>>
>>> On May 25, 2018, at 9:44 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>
>>> On Fri, May 25, 2018 at 12:24 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> Hi Olga-
>>>>
>>>>> On May 25, 2018, at 7:02 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>
>>>>> Thank you for the comments. Will hopefully address them in the next version.
>>>>>
>>>>> On Thu, May 24, 2018 at 8:50 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>> Hi Olga-
>>>>>>
>>>>>>> On May 24, 2018, at 1:05 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
>>>>>>>
>>>>>>> If the user supplies a clientaddr value,
>>>>>>
>>>>>> Please say "NFS client administrator" not "user". A
>>>>>> "user" is any non-privileged user, so saying that a
>>>>>> "user" can set this value is misleading.
>>>>>
>>>>> Ok will change it.
>>>>>
>>>>>>> it should be either
>>>>>>> a special value of either IPV4/IPV6 any address or a local address
>>>>>>> on the same network that the server being mounted.
>>>>>>
>>>>>> This option should allow any local address the client has,
>>>>>> not just an address that is on the same network as the
>>>>>> server. See below for further explanation.
>>>>>
>>>>> Ok, I added this to the comment specifically as I didn't know if this
>>>>> would pose a problem. I didn't know if allowing any address was useful
>>>>> as when it's not specified the address on the same network as the
>>>>> server is chosen.
>>>>
>>>> Yep, any of the client's local addresses should be allowed.
>>>>
>>>>
>>>>>>> Otherwise, we
>>>>>>> disallow the client to use an arbitrary value of the clientaddr value.
>>>>>>> This value is used to construct a client id of SETCLIENTID and
>>>>>>> providing a false value can interfere with the real owner's mount.
>>>>>>
>>>>>> The patch description is misleading:
>>>>>>
>>>>>> Interference occurs only if the real owner's lease is
>>>>>> not protected by Kerberos AND this client has the same
>>>>>> client ID string as another client.
>>>>>
>>>>> Ok I will add this more explicit detail when the interference occurs
>>>>> (when neither of the machines are using Kerberos and the other client
>>>>> machine is not using a module parameter to add a unique identifier to
>>>>> the client ID string). I think otherwise it is knowns that client ID
>>>>> is created with the value of the clientaddr.
>>>>
>>>> The only way a problem occurs is if the clientaddr is the
>>>> same AND the cl_nodename is the same. How is that happening?
>>>
>>> Client ID in the SETCLIENTID is constructed by
>>> nfs4_init_nonuniform_client_string() function and it uses cl_ipaddr
>>> and not cl_nodename.
>>
>> 5614         scnprintf(str, len, "Linux NFSv4.0 %s/%s %s",
>> 5615                         clp->cl_ipaddr,
>> 5616                         rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR),
>> 5617                         rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_PROTO));
>>
>> So I get your point now: if two Linux NFSv4.0 clients mount the
>> same server and specify the same callback address, and do not
>> specify "migration", they will indeed present exactly the same
>> client ID string to the server.
>>
>> I had remembered there was more in that string, but I guess I
>> was thinking of the uniform client ID string.
>>
>> And it will break badly if several clients decide to use
>> clientaddr=0.0.0.0. Trond, any thoughts? Why aren't the
>> nodename or uniquifier available in this string?
>
> I can think of legitimate cases where two unique NFSv4.0
> clients having the same IP address might mount the same
> server.
>
> - clientaddr=0.0.0.0, as mentioned above

I think this should be prohibited. If this is used a way to signify to
the server to no give out delegations, then there could be other means
of doing so. Let's add a mount option 'nodeleg', client would send a
valid callback info to the server but if the option is set, then it
will not start a callback server. That would prevent the server from
being able to establish a callback path (which is the same thing as
sending 0.0.0.0).

> - clients behind NATs using a private subnet that happen
> to be numbered the same (192.168.0.77, say).

Are we talking about a scenario where we have two private network
which are numbered the same sitting behind a NAT-ed routers and both
then accessing an NFS server on the internet? So how about then adding
a MAC address?

> Restricting the addresses allowed as the clientaddr=
> value does not address these cases.

> We already have some workarounds:

Since this is really a not a "bug" but an attack, I think having
workarounds is not sufficient. I think whatever it is needs to be
enforced.

> - Use NFSv4.1 or later
>
> - Use NFSv4.0 with the "migration" option
>
> - Use Kerberos (give the clients and server service
>   principals) and fix the server to reject SETCLIENTID
>   using a recognized client ID string but an unrecognized
>   authentication flavor and principal
>
> And possible fixes might include:
>
> - Improve the Linux client's non-UCS format

How about adding a MAC address to the string.

> - Make "migration" the default behavior

That would mean we totally scrap the use of
nfs4_init_nonuniform_string(). Spec suggestions that client ip, server
ip, + others to be used in creation of the client ID. A uniform client
string does not include client ip + server ip (+transport). We can't
assume existence of the unique identifier, so the only thing that'll
be there is a cl_nodename. Can it be assumed to always be configured
correctly? Can't this value frequently be just "localhost.localhost"?

How about instead of having uniform and non-uniform have just a single
function that will include all of it client ip, server ip, transport,
unique identifier (if present), and cl_nodename (and add a mac)? Of
course all if it will have to fit into 1024 opaque limit size.


> I am still in favor of validating the clientaddr value,
> but again, IMO that just papers over the real problem,
> which is the current non-UCS client ID string format.

I think at the nfs-utils, we can still check that supplied value is
one of the network addresses machine has (do not allow 0.0.0.0 or also
probably not 127.0.0.1 (or ipv6 equivalent)). I'm not sure if mac
should be queried and passed into the kernel or the kernel acquires
it.


> Have a restful holiday weekend.
>
>
>>>> Why are the cl_nodenames the same? If they are not the same,
>>>> then it is not possible that the clients' leases are inter-
>>>> fering with each other, and something else is going on.
>>>>
>>>>
>>>>>> The Linux client's client ID string also contains the
>>>>>> system's cl_nodename. Both the cl_nodename and the
>>>>>> callback address have to be the same as some other
>>>>>> client's, and they both have to be Linux, for this to
>>>>>> be a problem.
>>>>>>
>>>>>> It's more likely that the customer's clients are all
>>>>>> named the same (maybe they are copied from the same
>>>>>> system image), and reverse DNS lookup is giving them
>>>>>> all the same clientaddr= . That's an unsupported
>>>>>> configuration and there are already ways to address
>>>>>> this.
>>>>>>
>>>>>> Or perhaps I don't understand the use case that is
>>>>>> causing the problem. Can the patch description explain
>>>>>> why your customer is trying to set clientaddr= ?
>>>>>
>>>>> The customer case was a simple mistake of including the wrong address.
>>>>
>>>> But that doesn't answer the question. Why did the
>>>> customer feel the need to set clientaddr= ?
>>>
>>> I don't know. In the end they decided they didn't need the clientaddr at all.
>>>
>>>>> Do you fundamentally disagree that there is a case for
>>>>> denial-of-service here?
>>>>
>>>> The only service that is affected if the clientaddr is
>>>> set incorrectly is on the client where the mistake
>>>> occurs. If the cl_nodenames are all unique then other
>>>> clients should not be affected by the mistake. If
>>>> that is happening, that's a server bug.
>>>>
>>>> If the problem was that the customer set the wrong
>>>> address, let's say that, rather than claiming that the
>>>> patch prevents lease tampering.
>>>
>>> Ok I can change it to lease tampering (I really don't care that much).
>>> But to just to discuss a bit further, how's lease tampering not a
>>> denial-of-service? It interfere with a client's ability to make
>>> progress.
>>
>>
>> --
>> Chuck Lever
>>
>>
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
