Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:43273 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728626AbeHFSQi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Aug 2018 14:16:38 -0400
Received: by mail-ua0-f169.google.com with SMTP id f4-v6so9608701uao.10
        for <linux-nfs@vger.kernel.org>; Mon, 06 Aug 2018 09:06:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9B79CDF3-838E-4E81-BE9C-0BB47E2FC404@oracle.com>
References: <CAN-5tyERJVoiUR3ub8yjMor3YYN5ksdd93dpKoW=4OkGw6OPpg@mail.gmail.com>
 <CAN-5tyGeq11izA3J6mfiCnEzg1NE_9z13unx6PDy8SNK_ahASg@mail.gmail.com> <9B79CDF3-838E-4E81-BE9C-0BB47E2FC404@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 6 Aug 2018 12:06:50 -0400
Message-ID: <CAN-5tyG-CDdR4JLJ2SS8TnUugh8ZbtH_fuZVAqp0WiiORcdn4Q@mail.gmail.com>
Subject: Re: noresvport and port re-use
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 6, 2018 at 10:46 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On Aug 2, 2018, at 12:42 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Thu, Aug 2, 2018 at 11:14 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>> Hi folks,
>>>
>>> There is no documentation of this behavior but when "noresvport" is
>>> specified, the client will not try to re-use the port upon connection
>>> re-establishement. Is this an oversight or a desired behavior (ie.,
>>> client doesn't need to be conservative and re-use ports)?
>>>
>>> Thank you.
>>
>> I'm going to speculate on the reason myself and would like to hear
>> some folks thoughts.
>>
>> When we specify "noresvport" we use port=0 value that tells the kernel
>> - use any port. When connection is re-established port=0 so NFS has no
>> control over which port the kernel will choose.
>>
>> When client re-establishes the connection with a different port, that
>> has an effect on the server's replay cache. Any thoughts on that?
>>
>> Should the client remember which non-privileged port it used and then
>> the next time request a specific port?
>
> The basic constraint is that:
>
> If the client actively disconnects, or if the client is using an NFSv4
> session, then for a fresh connection the client is free to use any
> available source port in the range selected by the "resvport" mount
> option.
>
> If there is no NFSv4 session and the server or the network transport
> actively disconnects (say, due to a keep-alive timeout), the client
> should attempt to use the same source port as the previous connection
> in order to preserve DRC content on the server.

Hi Chuck,

Thanks for the reply. I'm considering your 2nd case where the server
reset the connection and client is re-establishing it and this is a v3
mount (this DRC is important). When "noresvport" is specified, then
the kernel makes no attempts at re-use the same non-reserved port.
However, I'm not sure it is possible to re-use a non-reserved port.
Given this behavior, shouldn't we be discouraging folks to mount with
v3 and "noresvport" option?

>
>
>> Is that possible?
>
>
> --
> Chuck Lever
>
>
>
