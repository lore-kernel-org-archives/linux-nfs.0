Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:37310 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730195AbeHFULc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Aug 2018 16:11:32 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: noresvport and port re-use
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <6A214429-6CBB-4EED-8327-AAD93F70C93C@oracle.com>
Date: Mon, 6 Aug 2018 14:01:11 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <542A2763-0F02-41DA-964E-EBA5DAF7592D@oracle.com>
References: <CAN-5tyERJVoiUR3ub8yjMor3YYN5ksdd93dpKoW=4OkGw6OPpg@mail.gmail.com>
 <CAN-5tyGeq11izA3J6mfiCnEzg1NE_9z13unx6PDy8SNK_ahASg@mail.gmail.com>
 <9B79CDF3-838E-4E81-BE9C-0BB47E2FC404@oracle.com>
 <CAN-5tyG-CDdR4JLJ2SS8TnUugh8ZbtH_fuZVAqp0WiiORcdn4Q@mail.gmail.com>
 <6A214429-6CBB-4EED-8327-AAD93F70C93C@oracle.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Aug 6, 2018, at 1:49 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
>=20
>=20
>> On Aug 6, 2018, at 12:06 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>=20
>> On Mon, Aug 6, 2018 at 10:46 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>>=20
>>>=20
>>>> On Aug 2, 2018, at 12:42 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>=20
>>>> On Thu, Aug 2, 2018 at 11:14 AM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>> Hi folks,
>>>>>=20
>>>>> There is no documentation of this behavior but when "noresvport" =
is
>>>>> specified, the client will not try to re-use the port upon =
connection
>>>>> re-establishement. Is this an oversight or a desired behavior =
(ie.,
>>>>> client doesn't need to be conservative and re-use ports)?
>>>>>=20
>>>>> Thank you.
>>>>=20
>>>> I'm going to speculate on the reason myself and would like to hear
>>>> some folks thoughts.
>>>>=20
>>>> When we specify "noresvport" we use port=3D0 value that tells the =
kernel
>>>> - use any port. When connection is re-established port=3D0 so NFS =
has no
>>>> control over which port the kernel will choose.
>>>>=20
>>>> When client re-establishes the connection with a different port, =
that
>>>> has an effect on the server's replay cache. Any thoughts on that?
>>>>=20
>>>> Should the client remember which non-privileged port it used and =
then
>>>> the next time request a specific port?
>>>=20
>>> The basic constraint is that:
>>>=20
>>> If the client actively disconnects, or if the client is using an =
NFSv4
>>> session, then for a fresh connection the client is free to use any
>>> available source port in the range selected by the "resvport" mount
>>> option.
>>>=20
>>> If there is no NFSv4 session and the server or the network transport
>>> actively disconnects (say, due to a keep-alive timeout), the client
>>> should attempt to use the same source port as the previous =
connection
>>> in order to preserve DRC content on the server.
>>=20
>> Hi Chuck,
>>=20
>> Thanks for the reply. I'm considering your 2nd case where the server
>> reset the connection and client is re-establishing it and this is a =
v3
>> mount (this DRC is important). When "noresvport" is specified, then
>> the kernel makes no attempts at re-use the same non-reserved port.
>> However, I'm not sure it is possible to re-use a non-reserved port.
>=20
> Why do you believe that?

That was terse. What I mean is, I don't know whether it is possible or
not to re-use an ephemeral port. I don't know of a reason why it would
not be possible to re-use one. Do you?


>> Given this behavior, shouldn't we be discouraging folks to mount with
>> v3 and "noresvport" option?

--
Chuck Lever



