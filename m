Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:34856 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750964AbeFBQex (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Jun 2018 12:34:53 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH 1/1] nfs-utils: Add check of clientaddr argument
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyFEDeXCjEcx_1EaaC0o_i-QBZGCB6gMLV0HVo8y8JOK1A@mail.gmail.com>
Date: Sat, 2 Jun 2018 12:34:26 -0400
Cc: trond.myklebust@hammerspace.com,
        Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FF4EFBD3-1FB5-4E48-98B3-1B35B925E2B3@oracle.com>
References: <20180524200542.22685-1-kolga@netapp.com>
 <48E7EEA0-C804-4AB3-9C08-10A5B14B8976@oracle.com>
 <CAN-5tyHb4WDXqqeYxQm+kzjmSquaKZ3fqsVkMW1Hx5RCmdxb2Q@mail.gmail.com>
 <63AA3A00-6272-4D91-AC0A-30C9A169DBD1@oracle.com>
 <CAN-5tyHXpp1DgX4ULnnWmUoyPHFUOVWR0PiMhhaD89Gxn9Hf-g@mail.gmail.com>
 <CC64DAF4-5BE4-4433-8CF7-23B8E887E668@oracle.com>
 <0079153E-7153-4246-AFD6-864E53100D8E@oracle.com>
 <CAN-5tyFPDknZxR9XR28usGHAyTDKtnp5JpCOVhbB-bjBhND6dw@mail.gmail.com>
 <FA8C3ECA-948F-42B1-AC8B-1C257212DD59@oracle.com>
 <010D5261-BC69-41A0-BBF1-F72377BB6DE4@oracle.com>
 <CAN-5tyFEDeXCjEcx_1EaaC0o_i-QBZGCB6gMLV0HVo8y8JOK1A@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 2, 2018, at 9:37 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Fri, Jun 1, 2018 at 5:42 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>> On May 29, 2018, at 4:53 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>>=20
>>>> On May 29, 2018, at 4:07 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>=20
>>>> On Fri, May 25, 2018 at 6:35 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>=20
>>>>> I can think of legitimate cases where two unique NFSv4.0
>>>>> clients having the same IP address might mount the same
>>>>> server.
>>>>>=20
>>>>> - clientaddr=3D0.0.0.0, as mentioned above
>>>>=20
>>>> I think this should be prohibited. If this is used a way to signify =
to
>>>> the server to no give out delegations, then there could be other =
means
>>>> of doing so. Let's add a mount option 'nodeleg', client would send =
a
>>>> valid callback info to the server but if the option is set, then it
>>>> will not start a callback server. That would prevent the server =
from
>>>> being able to establish a callback path (which is the same thing as
>>>> sending 0.0.0.0).
>>>=20
>>> That introduces delays while the server is probing the client's
>>> callback server. The spec specifically allows a client to send
>>> 0.0.0.0 to signify that the server should not use callbacks.
>>>=20
>>> And mount.nfs has allowed that setting for a long time.
>>>=20
>>> IMO we have to continue to allow 0.0.0.0.
>>=20
>> Still thinking about this.
>>=20
>> Not using cl_ipaddr in the client ID string helps. I have a patch
>> that does this.
>>=20
>> The question I've been wondering since the original post is "are =
there
>> any other use cases where mount.nfs can't properly guess which =
address
>> to provide?" That's why I was asking why your customer was using
>> clientaddr.
>>=20
>> If we have confidence that mount.nfs is 100% reliable about choosing
>> a good local address, except in the NAT case where we should just be
>> disabling CB, then we could have mount.nfs strip off a user-supplied
>> clientaddr and construct its own in all cases but the "clientaddr=3D
>> 0.0.0.0" case (and it's IPv6 equivalent).
>=20
> When you were saying that we want to enable the client to specify any
> address that's available to it, I was thinking you were considering a
> case of a multihome machine where the client wants to have normal nfs
> connection go over one network but have the callback able to go over
> another interface. I'm almost certain that was not the setup that the
> customer was using but I can ask. In general, I don't think we really
> know how the customers are using this because we only hear about
> issues and not when things are just working.
>=20
> So that I'm clear about what you saying: are you proposing two
> different approaches. First is to do away with cl_ipaddr in client ID.
> Then nothing is changed with the mount.nfs. Or second, we keep
> cl_ipaddr as is in client ID and then instead change mount.nfs to
> always choose the callback address for the user and only allow for
> clientaddr=3D0.0.0.0 user input case?
>=20
> Let me start with the 2nd one, I'm ok with it as long as we clearly
> document it in man pages. As is right now I'm disappointed that
> nowhere is the clientaddr=3D0.0.0.0 is documented (or even clearly
> talked about in the spec). However, if there is at all of value having
> a callback being on a different network, then I think instead, my
> original approach that does the checks would be a better way to do (i
> have a draft patch for it).
>=20
> If we are changing how the client Id is constructed and not using the
> cl_ipaddr, then I would like to know what would be used. But as long
> as you feel like such in my view a major change doesn't do anything
> bad, then I'm ok with it as it addresses the issue of user input to
> mount.nfs mistakenly or maliciously causing problems.

Some combination of both approaches is necessary. They are
complementary and can be applied together.

I believe we have to change the way the client ID string is
constructed. Even if mount.nfs is working perfectly, there are
use cases where the client's address is not a good addition to
the string; it can change over reboots, for example, which is
bad for a persistent client ID. My patch changes the non-UCS to
use the same raw components as the UCS (plus non-UCS still has
to include the server address).

I agree that we don't have a way of knowing how clientaddr=3D
can be used, and that's why mount.nfs has been left the way it
is for so long. I can't think of a reason clientaddr should
point to another machine. Thus restricting it to just local
addresses and ANY addresses seems like it would be OK to do.


--
Chuck Lever



