From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] SUNRPC connect timeout case network request delay
Date: Fri, 12 Mar 2010 17:55:24 +0800
Message-ID: <4B9A0F8C.5030900@cn.fujitsu.com>
References: <4B8F87A2.5080509@cn.fujitsu.com> <4B8FE6C7.2090207@oracle.com> <4B94CA73.90600@cn.fujitsu.com> <4B951A70.7080201@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51846 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752233Ab0CLJyH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Mar 2010 04:54:07 -0500
In-Reply-To: <4B951A70.7080201@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

  Thanks for your reply.

Chuck Lever =E5=86=99=E9=81=93:
> On 03/08/2010 04:59 AM, Mi Jinlong wrote:
>> Hi chuck,
>>
>>   Thanks for your reply.
>>
>> Chuck Lever =E5=86=99=E9=81=93:
>>> On 03/04/2010 05:12 AM, Mi Jinlong wrote:
>>>> Hi,
>>>> Step4: [22:42:16] Write data to file
>>>>          [22:42:16] Write data success
>>>> Step5: [22:42:16] Unlock file
>>>>          [22:46:30] Unlock file success.
>>>> Step6: [22:46:30] Close file /mnt/nfs/file
>>>>          [22:46:30] Close fiel /mnt/nfs/file success
>>>>
>>>> The problem is at step5, unlock file takes 4 min, it's a long time
>>>> than expected.
>>>> When traceing the kernel, I find SUNRPC call call_connect timeout =
many
>>>> times,
>>>> one timeout is 1min.
>>>
>>> The kernel's TCP reconnect logic will retry until it succeeds, with=
out
>>> letting the upper level make progress.  For some reason, it is havi=
ng
>>> difficulty reconnecting with your server.
>>>
>>>> I think it's a problem of kernel, but i don't know why, can someon=
e
>>>> help me ?
>>>
>>> # sudo rpcdebug -m rpc -s xprt trans
>>
>>   After running this command, I got some important messages that I t=
hink.
>>
>>   RPC:       xs_connect delayed xprt  for 3 seconds
>>   ...
>>   RPC:       xs_connect delayed xprt  for 6 seconds
>>   ...
>>   RPC:       xs_connect delayed xprt  for 12 seconds
>>   ...
>>   RPC:       xs_connect delayed xprt  for 24 seconds
>>   ...
>>   ...
>>   RPC:       xs_connect delayed xprt  for 300 seconds
>>
>> This message is printed at xs_connect, and the delay time is double
>> there.
>> IMO, when some data translate over through a socket, the socket shou=
ld
>> be released.
>> But, it seems the socket isn't released through those messages above=
=2E
>> Is it wrong, or there are some other reasons ?
>=20
> The code is trying to connect, but the ->connect call isn't working
> somehow.  The code backs off by doubling the timeout each time, so th=
at
> the connect attempts don't overload the server.
>=20
> This tells us that the code is attempting to connect, but not why the
> connect attempt is failing.

  When reading the kernel codes, I find a problem at function xs_tcp_cl=
ose.
    ....
    772 static void xs_tcp_close(struct rpc_xprt *xprt)
    773 {
    774         if (test_and_clear_bit(XPRT_CONNECTION_CLOSE, &xprt->st=
ate))
    775                 xs_close(xprt);
    776         else
    777                 xs_tcp_shutdown(xprt);
    778 }
     ...
  If a task call xs_tcp_close to close the xprt's sock, many times it o=
nly call=20
  xs_tcp_shutdown to using the next layer's close function to close the=
 socket
  connection.
  But after close the socket connection, the socket also exist, so the =
socket may
  be reused. Is it a problem ? I think after xs_tcp_shutdown, the socke=
t should
  be released.
 =20
thanks,
Mi Jinlong

