From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] SUNRPC connect timeout case network request delay
Date: Mon, 08 Mar 2010 17:59:15 +0800
Message-ID: <4B94CA73.90600@cn.fujitsu.com>
References: <4B8F87A2.5080509@cn.fujitsu.com> <4B8FE6C7.2090207@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54101 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753153Ab0CHJ6D convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Mar 2010 04:58:03 -0500
In-Reply-To: <4B8FE6C7.2090207@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi chuck,

 Thanks for your reply.

Chuck Lever =E5=86=99=E9=81=93:
> On 03/04/2010 05:12 AM, Mi Jinlong wrote:
>> Hi,
>> Step4: [22:42:16] Write data to file
>>         [22:42:16] Write data success
>> Step5: [22:42:16] Unlock file
>>         [22:46:30] Unlock file success.
>> Step6: [22:46:30] Close file /mnt/nfs/file
>>         [22:46:30] Close fiel /mnt/nfs/file success
>>
>> The problem is at step5, unlock file takes 4 min, it's a long time
>> than expected.
>> When traceing the kernel, I find SUNRPC call call_connect timeout ma=
ny
>> times,
>> one timeout is 1min.
>=20
> The kernel's TCP reconnect logic will retry until it succeeds, withou=
t
> letting the upper level make progress.  For some reason, it is having
> difficulty reconnecting with your server.
>=20
>> I think it's a problem of kernel, but i don't know why, can someone
>> help me ?
>=20
> # sudo rpcdebug -m rpc -s xprt trans

 After running this command, I got some important messages that I think=
=2E

 RPC:       xs_connect delayed xprt  for 3 seconds
 ...
 RPC:       xs_connect delayed xprt  for 6 seconds
 ...
 RPC:       xs_connect delayed xprt  for 12 seconds
 ...
 RPC:       xs_connect delayed xprt  for 24 seconds
 ...
 ...
 RPC:       xs_connect delayed xprt  for 300 seconds
=20
This message is printed at xs_connect, and the delay time is double the=
re.
IMO, when some data translate over through a socket, the socket should =
be released.
But, it seems the socket isn't released through those messages above.=20
Is it wrong, or there are some other reasons ?

At the latest kernel, this bug was fix by patch
  "NFS/RPC: fix problems with reestablish_timeout and related code."
But I don't sure about this.

thanks,
Mi Jinlong

