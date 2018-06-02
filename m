Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:37334 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750886AbeFBNhh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Jun 2018 09:37:37 -0400
Received: by mail-ua0-f194.google.com with SMTP id i3-v6so19220067uad.4
        for <linux-nfs@vger.kernel.org>; Sat, 02 Jun 2018 06:37:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <010D5261-BC69-41A0-BBF1-F72377BB6DE4@oracle.com>
References: <20180524200542.22685-1-kolga@netapp.com> <48E7EEA0-C804-4AB3-9C08-10A5B14B8976@oracle.com>
 <CAN-5tyHb4WDXqqeYxQm+kzjmSquaKZ3fqsVkMW1Hx5RCmdxb2Q@mail.gmail.com>
 <63AA3A00-6272-4D91-AC0A-30C9A169DBD1@oracle.com> <CAN-5tyHXpp1DgX4ULnnWmUoyPHFUOVWR0PiMhhaD89Gxn9Hf-g@mail.gmail.com>
 <CC64DAF4-5BE4-4433-8CF7-23B8E887E668@oracle.com> <0079153E-7153-4246-AFD6-864E53100D8E@oracle.com>
 <CAN-5tyFPDknZxR9XR28usGHAyTDKtnp5JpCOVhbB-bjBhND6dw@mail.gmail.com>
 <FA8C3ECA-948F-42B1-AC8B-1C257212DD59@oracle.com> <010D5261-BC69-41A0-BBF1-F72377BB6DE4@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Sat, 2 Jun 2018 09:37:35 -0400
Message-ID: <CAN-5tyFEDeXCjEcx_1EaaC0o_i-QBZGCB6gMLV0HVo8y8JOK1A@mail.gmail.com>
Subject: Re: [PATCH 1/1] nfs-utils: Add check of clientaddr argument
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@hammerspace.com,
        Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 1, 2018 at 5:42 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On May 29, 2018, at 4:53 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>> On May 29, 2018, at 4:07 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>
>>> On Fri, May 25, 2018 at 6:35 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>
>>>> I can think of legitimate cases where two unique NFSv4.0
>>>> clients having the same IP address might mount the same
>>>> server.
>>>>
>>>> - clientaddr=0.0.0.0, as mentioned above
>>>
>>> I think this should be prohibited. If this is used a way to signify to
>>> the server to no give out delegations, then there could be other means
>>> of doing so. Let's add a mount option 'nodeleg', client would send a
>>> valid callback info to the server but if the option is set, then it
>>> will not start a callback server. That would prevent the server from
>>> being able to establish a callback path (which is the same thing as
>>> sending 0.0.0.0).
>>
>> That introduces delays while the server is probing the client's
>> callback server. The spec specifically allows a client to send
>> 0.0.0.0 to signify that the server should not use callbacks.
>>
>> And mount.nfs has allowed that setting for a long time.
>>
>> IMO we have to continue to allow 0.0.0.0.
>
> Still thinking about this.
>
> Not using cl_ipaddr in the client ID string helps. I have a patch
> that does this.
>
> The question I've been wondering since the original post is "are there
> any other use cases where mount.nfs can't properly guess which address
> to provide?" That's why I was asking why your customer was using
> clientaddr.
>
> If we have confidence that mount.nfs is 100% reliable about choosing
> a good local address, except in the NAT case where we should just be
> disabling CB, then we could have mount.nfs strip off a user-supplied
> clientaddr and construct its own in all cases but the "clientaddr=
> 0.0.0.0" case (and it's IPv6 equivalent).

When you were saying that we want to enable the client to specify any
address that's available to it, I was thinking you were considering a
case of a multihome machine where the client wants to have normal nfs
connection go over one network but have the callback able to go over
another interface. I'm almost certain that was not the setup that the
customer was using but I can ask. In general, I don't think we really
know how the customers are using this because we only hear about
issues and not when things are just working.

So that I'm clear about what you saying: are you proposing two
different approaches. First is to do away with cl_ipaddr in client ID.
Then nothing is changed with the mount.nfs. Or second, we keep
cl_ipaddr as is in client ID and then instead change mount.nfs to
always choose the callback address for the user and only allow for
clientaddr=0.0.0.0 user input case?

Let me start with the 2nd one, I'm ok with it as long as we clearly
document it in man pages. As is right now I'm disappointed that
nowhere is the clientaddr=0.0.0.0 is documented (or even clearly
talked about in the spec). However, if there is at all of value having
a callback being on a different network, then I think instead, my
original approach that does the checks would be a better way to do (i
have a draft patch for it).

If we are changing how the client Id is constructed and not using the
cl_ipaddr, then I would like to know what would be used. But as long
as you feel like such in my view a major change doesn't do anything
bad, then I'm ok with it as it addresses the issue of user input to
mount.nfs mistakenly or maliciously causing problems.
