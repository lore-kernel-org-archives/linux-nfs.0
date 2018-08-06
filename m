Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:47000 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728671AbeHFWR0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Aug 2018 18:17:26 -0400
Received: by mail-ua0-f169.google.com with SMTP id u11-v6so13555309uan.13
        for <linux-nfs@vger.kernel.org>; Mon, 06 Aug 2018 13:06:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <542A2763-0F02-41DA-964E-EBA5DAF7592D@oracle.com>
References: <CAN-5tyERJVoiUR3ub8yjMor3YYN5ksdd93dpKoW=4OkGw6OPpg@mail.gmail.com>
 <CAN-5tyGeq11izA3J6mfiCnEzg1NE_9z13unx6PDy8SNK_ahASg@mail.gmail.com>
 <9B79CDF3-838E-4E81-BE9C-0BB47E2FC404@oracle.com> <CAN-5tyG-CDdR4JLJ2SS8TnUugh8ZbtH_fuZVAqp0WiiORcdn4Q@mail.gmail.com>
 <6A214429-6CBB-4EED-8327-AAD93F70C93C@oracle.com> <542A2763-0F02-41DA-964E-EBA5DAF7592D@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 6 Aug 2018 16:06:44 -0400
Message-ID: <CAN-5tyEP4iFJNgq6ipwxGjOrXLFnzgxLeVeKpmWvz33VFFsDQA@mail.gmail.com>
Subject: Re: noresvport and port re-use
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 6, 2018 at 2:01 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On Aug 6, 2018, at 1:49 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>
>>
>>> On Aug 6, 2018, at 12:06 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>
>>> On Mon, Aug 6, 2018 at 10:46 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>
>>>>
>>>>> On Aug 2, 2018, at 12:42 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>
>>>>> On Thu, Aug 2, 2018 at 11:14 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>> Hi folks,
>>>>>>
>>>>>> There is no documentation of this behavior but when "noresvport" is
>>>>>> specified, the client will not try to re-use the port upon connection
>>>>>> re-establishement. Is this an oversight or a desired behavior (ie.,
>>>>>> client doesn't need to be conservative and re-use ports)?
>>>>>>
>>>>>> Thank you.
>>>>>
>>>>> I'm going to speculate on the reason myself and would like to hear
>>>>> some folks thoughts.
>>>>>
>>>>> When we specify "noresvport" we use port=0 value that tells the kernel
>>>>> - use any port. When connection is re-established port=0 so NFS has no
>>>>> control over which port the kernel will choose.
>>>>>
>>>>> When client re-establishes the connection with a different port, that
>>>>> has an effect on the server's replay cache. Any thoughts on that?
>>>>>
>>>>> Should the client remember which non-privileged port it used and then
>>>>> the next time request a specific port?
>>>>
>>>> The basic constraint is that:
>>>>
>>>> If the client actively disconnects, or if the client is using an NFSv4
>>>> session, then for a fresh connection the client is free to use any
>>>> available source port in the range selected by the "resvport" mount
>>>> option.
>>>>
>>>> If there is no NFSv4 session and the server or the network transport
>>>> actively disconnects (say, due to a keep-alive timeout), the client
>>>> should attempt to use the same source port as the previous connection
>>>> in order to preserve DRC content on the server.
>>>
>>> Hi Chuck,
>>>
>>> Thanks for the reply. I'm considering your 2nd case where the server
>>> reset the connection and client is re-establishing it and this is a v3
>>> mount (this DRC is important). When "noresvport" is specified, then
>>> the kernel makes no attempts at re-use the same non-reserved port.
>>> However, I'm not sure it is possible to re-use a non-reserved port.
>>
>> Why do you believe that?
>
> That was terse. What I mean is, I don't know whether it is possible or
> not to re-use an ephemeral port. I don't know of a reason why it would
> not be possible to re-use one. Do you?
>

I'm thinking the way the API works is that we set port=0 when we setup
the socket which tells the kernel to use any non-privilege port. I'm
hazy on the details of how the reconnection is happening. So I'm
thinking kernel tells us the connection got closed and we call into
kernel to re-connect. I think the port at the reconnect time is again
just 0 which tells the kernel "use any port". To make it possible to
re-use the port, I think we(NFS) need to save the port from the
"original" connection and then connecting again instead of the 0
specify the saved port? That's my hand wavy explanation of port
re-use.

>>> Given this behavior, shouldn't we be discouraging folks to mount with
>>> v3 and "noresvport" option?
>
> --
> Chuck Lever
>
>
>
