From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] SUNRPC connect timeout case network request delay
Date: Mon, 08 Mar 2010 10:40:32 -0500
Message-ID: <4B951A70.7080201@oracle.com>
References: <4B8F87A2.5080509@cn.fujitsu.com> <4B8FE6C7.2090207@oracle.com> <4B94CA73.90600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:58710 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412Ab0CHPlh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Mar 2010 10:41:37 -0500
In-Reply-To: <4B94CA73.90600@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/08/2010 04:59 AM, Mi Jinlong wrote:
> Hi chuck,
>
>   Thanks for your reply.
>
> Chuck Lever =E5=86=99=E9=81=93:
>> On 03/04/2010 05:12 AM, Mi Jinlong wrote:
>>> Hi,
>>> Step4: [22:42:16] Write data to file
>>>          [22:42:16] Write data success
>>> Step5: [22:42:16] Unlock file
>>>          [22:46:30] Unlock file success.
>>> Step6: [22:46:30] Close file /mnt/nfs/file
>>>          [22:46:30] Close fiel /mnt/nfs/file success
>>>
>>> The problem is at step5, unlock file takes 4 min, it's a long time
>>> than expected.
>>> When traceing the kernel, I find SUNRPC call call_connect timeout m=
any
>>> times,
>>> one timeout is 1min.
>>
>> The kernel's TCP reconnect logic will retry until it succeeds, witho=
ut
>> letting the upper level make progress.  For some reason, it is havin=
g
>> difficulty reconnecting with your server.
>>
>>> I think it's a problem of kernel, but i don't know why, can someone
>>> help me ?
>>
>> # sudo rpcdebug -m rpc -s xprt trans
>
>   After running this command, I got some important messages that I th=
ink.
>
>   RPC:       xs_connect delayed xprt  for 3 seconds
>   ...
>   RPC:       xs_connect delayed xprt  for 6 seconds
>   ...
>   RPC:       xs_connect delayed xprt  for 12 seconds
>   ...
>   RPC:       xs_connect delayed xprt  for 24 seconds
>   ...
>   ...
>   RPC:       xs_connect delayed xprt  for 300 seconds
>
> This message is printed at xs_connect, and the delay time is double t=
here.
> IMO, when some data translate over through a socket, the socket shoul=
d be released.
> But, it seems the socket isn't released through those messages above.
> Is it wrong, or there are some other reasons ?

The code is trying to connect, but the ->connect call isn't working=20
somehow.  The code backs off by doubling the timeout each time, so that=
=20
the connect attempts don't overload the server.

This tells us that the code is attempting to connect, but not why the=20
connect attempt is failing.

> At the latest kernel, this bug was fix by patch
>    "NFS/RPC: fix problems with reestablish_timeout and related code."
> But I don't sure about this.

--=20
chuck[dot]lever[at]oracle[dot]com
