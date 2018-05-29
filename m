Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:41356 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966175AbeE2Uxt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 16:53:49 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH 1/1] nfs-utils: Add check of clientaddr argument
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyFPDknZxR9XR28usGHAyTDKtnp5JpCOVhbB-bjBhND6dw@mail.gmail.com>
Date: Tue, 29 May 2018 16:53:20 -0400
Cc: trond.myklebust@hammerspace.com,
        Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FA8C3ECA-948F-42B1-AC8B-1C257212DD59@oracle.com>
References: <20180524200542.22685-1-kolga@netapp.com>
 <48E7EEA0-C804-4AB3-9C08-10A5B14B8976@oracle.com>
 <CAN-5tyHb4WDXqqeYxQm+kzjmSquaKZ3fqsVkMW1Hx5RCmdxb2Q@mail.gmail.com>
 <63AA3A00-6272-4D91-AC0A-30C9A169DBD1@oracle.com>
 <CAN-5tyHXpp1DgX4ULnnWmUoyPHFUOVWR0PiMhhaD89Gxn9Hf-g@mail.gmail.com>
 <CC64DAF4-5BE4-4433-8CF7-23B8E887E668@oracle.com>
 <0079153E-7153-4246-AFD6-864E53100D8E@oracle.com>
 <CAN-5tyFPDknZxR9XR28usGHAyTDKtnp5JpCOVhbB-bjBhND6dw@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 29, 2018, at 4:07 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Fri, May 25, 2018 at 6:35 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>> On May 25, 2018, at 10:04 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>>=20
>>>=20
>>>=20
>>>> On May 25, 2018, at 9:44 AM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>=20
>>>> On Fri, May 25, 2018 at 12:24 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>> Hi Olga-
>>>>>=20
>>>>>> On May 25, 2018, at 7:02 AM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>>=20
>>>>>> Thank you for the comments. Will hopefully address them in the =
next version.
>>>>>>=20
>>>>>> On Thu, May 24, 2018 at 8:50 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>> Hi Olga-
>>>>>>>=20
>>>>>>>> On May 24, 2018, at 1:05 PM, Olga Kornievskaia =
<kolga@netapp.com> wrote:
>>>>>>>>=20
>>>>>>>> If the user supplies a clientaddr value,
>>>>>>>=20
>>>>>>> Please say "NFS client administrator" not "user". A
>>>>>>> "user" is any non-privileged user, so saying that a
>>>>>>> "user" can set this value is misleading.
>>>>>>=20
>>>>>> Ok will change it.
>>>>>>=20
>>>>>>>> it should be either
>>>>>>>> a special value of either IPV4/IPV6 any address or a local =
address
>>>>>>>> on the same network that the server being mounted.
>>>>>>>=20
>>>>>>> This option should allow any local address the client has,
>>>>>>> not just an address that is on the same network as the
>>>>>>> server. See below for further explanation.
>>>>>>=20
>>>>>> Ok, I added this to the comment specifically as I didn't know if =
this
>>>>>> would pose a problem. I didn't know if allowing any address was =
useful
>>>>>> as when it's not specified the address on the same network as the
>>>>>> server is chosen.
>>>>>=20
>>>>> Yep, any of the client's local addresses should be allowed.
>>>>>=20
>>>>>=20
>>>>>>>> Otherwise, we
>>>>>>>> disallow the client to use an arbitrary value of the clientaddr =
value.
>>>>>>>> This value is used to construct a client id of SETCLIENTID and
>>>>>>>> providing a false value can interfere with the real owner's =
mount.
>>>>>>>=20
>>>>>>> The patch description is misleading:
>>>>>>>=20
>>>>>>> Interference occurs only if the real owner's lease is
>>>>>>> not protected by Kerberos AND this client has the same
>>>>>>> client ID string as another client.
>>>>>>=20
>>>>>> Ok I will add this more explicit detail when the interference =
occurs
>>>>>> (when neither of the machines are using Kerberos and the other =
client
>>>>>> machine is not using a module parameter to add a unique =
identifier to
>>>>>> the client ID string). I think otherwise it is knowns that client =
ID
>>>>>> is created with the value of the clientaddr.
>>>>>=20
>>>>> The only way a problem occurs is if the clientaddr is the
>>>>> same AND the cl_nodename is the same. How is that happening?
>>>>=20
>>>> Client ID in the SETCLIENTID is constructed by
>>>> nfs4_init_nonuniform_client_string() function and it uses cl_ipaddr
>>>> and not cl_nodename.
>>>=20
>>> 5614         scnprintf(str, len, "Linux NFSv4.0 %s/%s %s",
>>> 5615                         clp->cl_ipaddr,
>>> 5616                         rpc_peeraddr2str(clp->cl_rpcclient, =
RPC_DISPLAY_ADDR),
>>> 5617                         rpc_peeraddr2str(clp->cl_rpcclient, =
RPC_DISPLAY_PROTO));
>>>=20
>>> So I get your point now: if two Linux NFSv4.0 clients mount the
>>> same server and specify the same callback address, and do not
>>> specify "migration", they will indeed present exactly the same
>>> client ID string to the server.
>>>=20
>>> I had remembered there was more in that string, but I guess I
>>> was thinking of the uniform client ID string.
>>>=20
>>> And it will break badly if several clients decide to use
>>> clientaddr=3D0.0.0.0. Trond, any thoughts? Why aren't the
>>> nodename or uniquifier available in this string?
>>=20
>> I can think of legitimate cases where two unique NFSv4.0
>> clients having the same IP address might mount the same
>> server.
>>=20
>> - clientaddr=3D0.0.0.0, as mentioned above
>=20
> I think this should be prohibited. If this is used a way to signify to
> the server to no give out delegations, then there could be other means
> of doing so. Let's add a mount option 'nodeleg', client would send a
> valid callback info to the server but if the option is set, then it
> will not start a callback server. That would prevent the server from
> being able to establish a callback path (which is the same thing as
> sending 0.0.0.0).

That introduces delays while the server is probing the client's
callback server. The spec specifically allows a client to send
0.0.0.0 to signify that the server should not use callbacks.

And mount.nfs has allowed that setting for a long time.

IMO we have to continue to allow 0.0.0.0.


>> - clients behind NATs using a private subnet that happen
>> to be numbered the same (192.168.0.77, say).
>=20
> Are we talking about a scenario where we have two private network
> which are numbered the same sitting behind a NAT-ed routers and both
> then accessing an NFS server on the internet? So how about then adding
> a MAC address?

If there are multiple ethernet devices on the client, how do
we guarantee the NFS client will choose the same MAC address
after every reboot?

What if the administrator changes the MAC or replaces the
network device between client reboots?

Of course a malicious admin can create a VM that has the
same MAC as some other client, or a hardware company can
re-use MAC addresses.


>> Restricting the addresses allowed as the clientaddr=3D
>> value does not address these cases.
>=20
>> We already have some workarounds:
>=20
> Since this is really a not a "bug" but an attack, I think having
> workarounds is not sufficient. I think whatever it is needs to be
> enforced.

These are all valid if someone came to us this afternoon with
an existing client and said "I can't deploy a code change for
a while. How do I close this hole today?"

I'm not proposing these as the fix (although some might be
inclined to opine that "stop using NFSv4.0" is a/the real fix).


>> - Use NFSv4.1 or later
>>=20
>> - Use NFSv4.0 with the "migration" option
>>=20
>> - Use Kerberos (give the clients and server service
>>  principals) and fix the server to reject SETCLIENTID
>>  using a recognized client ID string but an unrecognized
>>  authentication flavor and principal
>>=20
>> And possible fixes might include:
>>=20
>> - Improve the Linux client's non-UCS format
>=20
> How about adding a MAC address to the string.

See above.

Ideally we could have a tool that generated a random UUID
and added it to /etc/grub/defaults on the kernel command
line. There is already at least one UUID there on all my
systems.


>> - Make "migration" the default behavior
>=20
> That would mean we totally scrap the use of
> nfs4_init_nonuniform_string().

Not at all. Making "migration" the default means that where
needed, an administrator can choose to use nonuniform.
There are other reasons why making "migration" the default
is not a real option.


> Spec suggestions that client ip, server
> ip, + others to be used in creation of the client ID.

The spec _suggests_ the use of these things. It does not
require any of them. A full analysis of the issues with
the spec's recommended client ID string is discussed here:

https://datatracker.ietf.org/doc/rfc7931/


> A uniform client
> string does not include client ip + server ip (+transport). We can't
> assume existence of the unique identifier, so the only thing that'll
> be there is a cl_nodename. Can it be assumed to always be configured
> correctly? Can't this value frequently be just "localhost.localhost"?

Yes. As I said before several times, the only way to address
this issue securely is to use Kerberos. We are not going to
get this hole closed 100% without the use of cryptography.


> How about instead of having uniform and non-uniform have just a single
> function that will include all of it client ip, server ip, transport,
> unique identifier (if present), and cl_nodename (and add a mac)? Of
> course all if it will have to fit into 1024 opaque limit size.

Have a look at RFC 7931 to understand why we have uniform and
non-uniform client ID strings.

Uniform client ID string can't have anything in it that's going
to be different depending on which server it's connected to.
The string is the same no matter which server is in use, so
that the client looks the same to two arbitrary servers
participating in a migration event.


>> I am still in favor of validating the clientaddr value,
>> but again, IMO that just papers over the real problem,
>> which is the current non-UCS client ID string format.
>=20
> I think at the nfs-utils, we can still check that supplied value is
> one of the network addresses machine has (do not allow 0.0.0.0 or also
> probably not 127.0.0.1 (or ipv6 equivalent)). I'm not sure if mac
> should be queried and passed into the kernel or the kernel acquires
> it.

Yes, mount.nfs should do some basic validation.

Not putting the client's local address in the client ID string
would be beneficial. But I think using a MAC address has
similar weaknesses as using the client's local address.

My preference is to put a random UUID on the kernel boot
command line; but to do that means the code that constructs
the non-uniform client ID string has to be fixed up.


--
Chuck Lever



