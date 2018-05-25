Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:44306 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030394AbeEYWfd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 May 2018 18:35:33 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH 1/1] nfs-utils: Add check of clientaddr argument
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CC64DAF4-5BE4-4433-8CF7-23B8E887E668@oracle.com>
Date: Fri, 25 May 2018 15:35:25 -0700
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0079153E-7153-4246-AFD6-864E53100D8E@oracle.com>
References: <20180524200542.22685-1-kolga@netapp.com>
 <48E7EEA0-C804-4AB3-9C08-10A5B14B8976@oracle.com>
 <CAN-5tyHb4WDXqqeYxQm+kzjmSquaKZ3fqsVkMW1Hx5RCmdxb2Q@mail.gmail.com>
 <63AA3A00-6272-4D91-AC0A-30C9A169DBD1@oracle.com>
 <CAN-5tyHXpp1DgX4ULnnWmUoyPHFUOVWR0PiMhhaD89Gxn9Hf-g@mail.gmail.com>
 <CC64DAF4-5BE4-4433-8CF7-23B8E887E668@oracle.com>
To: Olga Kornievskaia <aglo@umich.edu>, trond.myklebust@hammerspace.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 25, 2018, at 10:04 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
>=20
>=20
>> On May 25, 2018, at 9:44 AM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>=20
>> On Fri, May 25, 2018 at 12:24 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>> Hi Olga-
>>>=20
>>>> On May 25, 2018, at 7:02 AM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>=20
>>>> Thank you for the comments. Will hopefully address them in the next =
version.
>>>>=20
>>>> On Thu, May 24, 2018 at 8:50 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>> Hi Olga-
>>>>>=20
>>>>>> On May 24, 2018, at 1:05 PM, Olga Kornievskaia <kolga@netapp.com> =
wrote:
>>>>>>=20
>>>>>> If the user supplies a clientaddr value,
>>>>>=20
>>>>> Please say "NFS client administrator" not "user". A
>>>>> "user" is any non-privileged user, so saying that a
>>>>> "user" can set this value is misleading.
>>>>=20
>>>> Ok will change it.
>>>>=20
>>>>>> it should be either
>>>>>> a special value of either IPV4/IPV6 any address or a local =
address
>>>>>> on the same network that the server being mounted.
>>>>>=20
>>>>> This option should allow any local address the client has,
>>>>> not just an address that is on the same network as the
>>>>> server. See below for further explanation.
>>>>=20
>>>> Ok, I added this to the comment specifically as I didn't know if =
this
>>>> would pose a problem. I didn't know if allowing any address was =
useful
>>>> as when it's not specified the address on the same network as the
>>>> server is chosen.
>>>=20
>>> Yep, any of the client's local addresses should be allowed.
>>>=20
>>>=20
>>>>>> Otherwise, we
>>>>>> disallow the client to use an arbitrary value of the clientaddr =
value.
>>>>>> This value is used to construct a client id of SETCLIENTID and
>>>>>> providing a false value can interfere with the real owner's =
mount.
>>>>>=20
>>>>> The patch description is misleading:
>>>>>=20
>>>>> Interference occurs only if the real owner's lease is
>>>>> not protected by Kerberos AND this client has the same
>>>>> client ID string as another client.
>>>>=20
>>>> Ok I will add this more explicit detail when the interference =
occurs
>>>> (when neither of the machines are using Kerberos and the other =
client
>>>> machine is not using a module parameter to add a unique identifier =
to
>>>> the client ID string). I think otherwise it is knowns that client =
ID
>>>> is created with the value of the clientaddr.
>>>=20
>>> The only way a problem occurs is if the clientaddr is the
>>> same AND the cl_nodename is the same. How is that happening?
>>=20
>> Client ID in the SETCLIENTID is constructed by
>> nfs4_init_nonuniform_client_string() function and it uses cl_ipaddr
>> and not cl_nodename.
>=20
> 5614         scnprintf(str, len, "Linux NFSv4.0 %s/%s %s",
> 5615                         clp->cl_ipaddr,
> 5616                         rpc_peeraddr2str(clp->cl_rpcclient, =
RPC_DISPLAY_ADDR),
> 5617                         rpc_peeraddr2str(clp->cl_rpcclient, =
RPC_DISPLAY_PROTO));
>=20
> So I get your point now: if two Linux NFSv4.0 clients mount the
> same server and specify the same callback address, and do not
> specify "migration", they will indeed present exactly the same
> client ID string to the server.
>=20
> I had remembered there was more in that string, but I guess I
> was thinking of the uniform client ID string.
>=20
> And it will break badly if several clients decide to use
> clientaddr=3D0.0.0.0. Trond, any thoughts? Why aren't the
> nodename or uniquifier available in this string?

I can think of legitimate cases where two unique NFSv4.0
clients having the same IP address might mount the same
server.

- clientaddr=3D0.0.0.0, as mentioned above

- clients behind NATs using a private subnet that happen
to be numbered the same (192.168.0.77, say).

Restricting the addresses allowed as the clientaddr=3D
value does not address these cases.


We already have some workarounds:

- Use NFSv4.1 or later

- Use NFSv4.0 with the "migration" option

- Use Kerberos (give the clients and server service
  principals) and fix the server to reject SETCLIENTID
  using a recognized client ID string but an unrecognized
  authentication flavor and principal

And possible fixes might include:

- Improve the Linux client's non-UCS format

- Make "migration" the default behavior

I am still in favor of validating the clientaddr value,
but again, IMO that just papers over the real problem,
which is the current non-UCS client ID string format.

Have a restful holiday weekend.


>>> Why are the cl_nodenames the same? If they are not the same,
>>> then it is not possible that the clients' leases are inter-
>>> fering with each other, and something else is going on.
>>>=20
>>>=20
>>>>> The Linux client's client ID string also contains the
>>>>> system's cl_nodename. Both the cl_nodename and the
>>>>> callback address have to be the same as some other
>>>>> client's, and they both have to be Linux, for this to
>>>>> be a problem.
>>>>>=20
>>>>> It's more likely that the customer's clients are all
>>>>> named the same (maybe they are copied from the same
>>>>> system image), and reverse DNS lookup is giving them
>>>>> all the same clientaddr=3D . That's an unsupported
>>>>> configuration and there are already ways to address
>>>>> this.
>>>>>=20
>>>>> Or perhaps I don't understand the use case that is
>>>>> causing the problem. Can the patch description explain
>>>>> why your customer is trying to set clientaddr=3D ?
>>>>=20
>>>> The customer case was a simple mistake of including the wrong =
address.
>>>=20
>>> But that doesn't answer the question. Why did the
>>> customer feel the need to set clientaddr=3D ?
>>=20
>> I don't know. In the end they decided they didn't need the clientaddr =
at all.
>>=20
>>>> Do you fundamentally disagree that there is a case for
>>>> denial-of-service here?
>>>=20
>>> The only service that is affected if the clientaddr is
>>> set incorrectly is on the client where the mistake
>>> occurs. If the cl_nodenames are all unique then other
>>> clients should not be affected by the mistake. If
>>> that is happening, that's a server bug.
>>>=20
>>> If the problem was that the customer set the wrong
>>> address, let's say that, rather than claiming that the
>>> patch prevents lease tampering.
>>=20
>> Ok I can change it to lease tampering (I really don't care that =
much).
>> But to just to discuss a bit further, how's lease tampering not a
>> denial-of-service? It interfere with a client's ability to make
>> progress.
>=20
>=20
> --
> Chuck Lever
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



