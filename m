From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: klibc's nfsmount failure with 2.6.27.21, while 2.6.25.20 was fine
Date: Wed, 15 Apr 2009 16:52:26 -0400
Message-ID: <889BAE90-0719-4560-B4D3-34376B0FFC4C@oracle.com>
References: <200904152117.41367.hpj@urpla.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Hans-Peter Jansen <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:56872 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbZDOUwh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2009 16:52:37 -0400
In-Reply-To: <200904152117.41367.hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 15, 2009, at 3:17 PM, Hans-Peter Jansen wrote:
> Am Mittwoch, 15. April 2009 schrieb Chuck Lever:
>> On Apr 15, 2009, at 1:23 PM, Hans-Peter Jansen wrote:
>>> Am Mittwoch, 15. April 2009 schrieb Chuck Lever:
>>>> When using rpcbind instead of portmapper, what does the output of
>>>> "rpcinfo" look like on the server?
>>>
>>> It's dumped in the mail starting this thread.
>>
>> I don't see why the client's rpcbind attempt for the server's mountd
>> service should have failed.
>
> For completeness, here's the current rpcinfo view with portmap:
>
> # rpcinfo -p 172.16.23.110
>   Program Vers Proto   Port
>    100000    2   tcp    111  portmapper
>    100000    2   udp    111  portmapper
>    100005    1   udp  54838  mountd
>    100005    1   tcp  32772  mountd
>    100005    2   udp  54838  mountd
>    100005    2   tcp  32772  mountd
>    100005    3   udp  54838  mountd
>    100005    3   tcp  32772  mountd
>    100003    2   udp   2049  nfs
>    100003    3   udp   2049  nfs
>    100003    4   udp   2049  nfs
>    100021    1   udp  35501  nlockmgr
>    100021    3   udp  35501  nlockmgr
>    100021    4   udp  35501  nlockmgr
>    100003    2   tcp   2049  nfs
>    100003    3   tcp   2049  nfs
>    100003    4   tcp   2049  nfs
>    100021    1   tcp  54766  nlockmgr
>    100021    3   tcp  54766  nlockmgr
>    100021    4   tcp  54766  nlockmgr
>    100024    1   udp  44650  status
>    100024    1   tcp  39765  status
>
>
>> Would it be possible for you to capture a packet trace of the =20
>> client's
>> attempt to mount it's root file system?  (You will likely need to do
>> this for a bugzilla report, anyway).
>
> =C4hem, Chuck, may I ask you to look into the initial mail again. The=
 =20
> failing
> case is attached there. Here I've attached the good one. Since I =20
> couldn't
> locate any mount attempt in the dump, I've left a few more nfs
> transactions.

The client makes a PMAP_GETPORT request via TCP.  The server's rpcbind =
=20
drops the connection without replying after receiving the request.  I =20
didn't see anything immediately wrong with the request, although =20
wireshark didn't like it either.  I had to decode it by hand.

Restarting rpcbind usually means you lose all your rpc service =20
registrations until you restart those services, but it would be worth =20
trying this: stop the server's rpcbind service, then run rpcbind in a =20
terminal session with "-d" to see what it thinks the problem is when =20
it drops the connection.

Please attach a copy of your /etc/netconfig to reply.

>> Also let us know what's running on your clients (distribution, kerne=
l
>> version, etc).
>
> Hmm, sure. The client setup is a legacy SuSE 9.3 diskless environment
> (unfortunately Novell didn't manage to create a distribution with =20
> similar
> stability since then..., being a rpm junke, I will soon check Cent-OS
> (again)).
>
> Client (relevant) versions:
> Kernel: 2.6.11.4
> Udev (nfsmount): 053
>
> Let me know, what more I can provide, please.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com