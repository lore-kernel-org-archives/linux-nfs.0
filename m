Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:48072 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbeFAVnL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2018 17:43:11 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH 1/1] nfs-utils: Add check of clientaddr argument
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <FA8C3ECA-948F-42B1-AC8B-1C257212DD59@oracle.com>
Date: Fri, 1 Jun 2018 17:42:48 -0400
Cc: trond.myklebust@hammerspace.com,
        Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <010D5261-BC69-41A0-BBF1-F72377BB6DE4@oracle.com>
References: <20180524200542.22685-1-kolga@netapp.com>
 <48E7EEA0-C804-4AB3-9C08-10A5B14B8976@oracle.com>
 <CAN-5tyHb4WDXqqeYxQm+kzjmSquaKZ3fqsVkMW1Hx5RCmdxb2Q@mail.gmail.com>
 <63AA3A00-6272-4D91-AC0A-30C9A169DBD1@oracle.com>
 <CAN-5tyHXpp1DgX4ULnnWmUoyPHFUOVWR0PiMhhaD89Gxn9Hf-g@mail.gmail.com>
 <CC64DAF4-5BE4-4433-8CF7-23B8E887E668@oracle.com>
 <0079153E-7153-4246-AFD6-864E53100D8E@oracle.com>
 <CAN-5tyFPDknZxR9XR28usGHAyTDKtnp5JpCOVhbB-bjBhND6dw@mail.gmail.com>
 <FA8C3ECA-948F-42B1-AC8B-1C257212DD59@oracle.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 29, 2018, at 4:53 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
>> On May 29, 2018, at 4:07 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>=20
>> On Fri, May 25, 2018 at 6:35 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>>=20
>>> I can think of legitimate cases where two unique NFSv4.0
>>> clients having the same IP address might mount the same
>>> server.
>>>=20
>>> - clientaddr=3D0.0.0.0, as mentioned above
>>=20
>> I think this should be prohibited. If this is used a way to signify =
to
>> the server to no give out delegations, then there could be other =
means
>> of doing so. Let's add a mount option 'nodeleg', client would send a
>> valid callback info to the server but if the option is set, then it
>> will not start a callback server. That would prevent the server from
>> being able to establish a callback path (which is the same thing as
>> sending 0.0.0.0).
>=20
> That introduces delays while the server is probing the client's
> callback server. The spec specifically allows a client to send
> 0.0.0.0 to signify that the server should not use callbacks.
>=20
> And mount.nfs has allowed that setting for a long time.
>=20
> IMO we have to continue to allow 0.0.0.0.

Still thinking about this.

Not using cl_ipaddr in the client ID string helps. I have a patch
that does this.

The question I've been wondering since the original post is "are there
any other use cases where mount.nfs can't properly guess which address
to provide?" That's why I was asking why your customer was using
clientaddr.

If we have confidence that mount.nfs is 100% reliable about choosing
a good local address, except in the NAT case where we should just be
disabling CB, then we could have mount.nfs strip off a user-supplied
clientaddr and construct its own in all cases but the "clientaddr=3D
0.0.0.0" case (and it's IPv6 equivalent).


--
Chuck Lever



