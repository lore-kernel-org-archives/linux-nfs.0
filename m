From: db <db.pub.mail@gmail.com>
Subject: Re: svc: failed to register lockdv1 RPC service (errno 97).
Date: Mon, 29 Jun 2009 17:12:37 +1000
Message-ID: <25ae2d690906290012i17015bc6p7600f274b645c251@mail.gmail.com>
References: <200905110248.48695.elendil@planet.nl> <8054CA42-CAFC-4DFC-A3A9-107AF29284EE@oracle.com>
	<200905111639.43636.elendil@planet.nl> <62189277-05F4-4AC7-97EC-AFDE39F781E3@oracle.com>
	<25ae2d690906282333j7c9cb5b9nb954470e0694c3ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>, Netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f193.google.com ([209.85.221.193]:34435 "EHLO
	mail-qy0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbZF2HM5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 03:12:57 -0400
In-Reply-To: <25ae2d690906282333j7c9cb5b9nb954470e0694c3ce-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry a correction i am using nfs3 (according to network dumps).
+ AND the issue appears to exist in the 2.6.30 kernel on my e100
network card after i transfer a large amount of data.
**

2009/6/29 db <db.pub.mail@gmail.com>:
> I'm running arm 2.6.30 kernel and a 2.6.30 kernel on my desktop.
>
> I see this =C2=A0"[1257016.190000] nfsd: last server has exited, flus=
hing
> export cache
> [1257018.250000] svc: failed to register lockdv1 RPC service (errno 9=
7).
> ."
> On both ends. The arm is running debian lenny (armel). The desktop is
> debian lenny (32bit i368). When this error i cannot continue to
> transfer files.
>
> Here is the config of the /etc/exports and what i try to use
>
> "/media/nfs_shares/rsync/ =C2=A0*(rw,no_subtree_check)"
> i mount on the desktop with
>
> [root@desktop ]# mount 192.168.1.12:/media/Y/W/ =C2=A0/media/mount_po=
int/ -o soft
>
> and i try using rsync like this (from my desktop).
>
>
> rsync -av --progress /home/User_NAME/BACKUP/Y/W/X/ /media/mount_point=
/W/X
> and it just hangs. I then try to unmount it and i have problems doing
> so. so i need to force the umount
>
> "19051.391800] =C2=A0 =C2=A0 Performance counters on
> [319051.391804] =C2=A0 =C2=A0 input device check on
> [319051.391807] =C2=A0 =C2=A0 Actions configured
> [399843.223405] RPC: Registered udp transport module.
> [399843.223413] RPC: Registered tcp transport module.
> [399843.346956] svc: failed to register lockdv1 RPC service (errno 97=
).
> [401465.708049] device eth1 left promiscuous mode
> [401689.794716] svc: failed to register lockdv1 RPC service (errno 97=
).
> [402224.640535] svc: failed to register lockdv1 RPC service (errno 97=
).
> [402356.791524] svc: failed to register lockdv1 RPC service (errno 97=
).
> [402702.197491] svc: failed to register lockdv1 RPC service (errno 97=
).
> "
> I am only using nfs2. I am not using nfs4 / nfs3.
>
> This issue is most troublesome as it breaks my use of nfs.
>
>
>
> 2009/5/12 Chuck Lever <chuck.lever@oracle.com>:
>> On May 11, 2009, at 10:39 AM, Frans Pop wrote:
>>>
>>> On Monday 11 May 2009, you wrote:
>>>>
>>>> On May 10, 2009, at 8:48 PM, Frans Pop wrote:
>>>>>
>>>>> After switching from 2.6.29.2 to 2.6.30-rc5 I get this new messag=
e
>>>>> during boot of my home server:
>>>>> =C2=A0svc: failed to register lockdv1 RPC service (errno 97).
>>>>
>>>> Is this the only instance of this message, or do you see it severa=
l
>>>> times?
>>>
>>> It's the only one.
>>>
>>>>> This looks to be the result of the following commit:
>>>>> commit 363f724cdd3d2ae554e261be995abdeb15f7bdd9
>>>>> Author: Chuck Lever <chuck.lever@oracle.com>
>>>>> =C2=A0SUNRPC: rpcb_register() should handle errors silently
>>>>> =C2=A0Move error reporting for RPC registration to rpcb_register'=
s
>>>>> caller.
>>>>>
>>>>> Question is: do I really want to know this? I assume the "failure=
"
>>>>> happened with previous kernels too, but silently.
>>>>
>>>> The point of that commit was to report errors _less_ frequently.
>>>
>>> :-)
>>>
>>>> The server-side RPC code is attempting to be more automatic about
>>>> which address families are supported by kernel NFS services. =C2=A0=
This
>>>> message tells us that some particular case is not handled yet. =C2=
=A0I
>>>> suspect you weren't seeing this error in the past at all.
>>>
>>> Correct. Neither this exact error, nor anything remotely similar.
>>
>> No, I meant that whether or not you saw an error message, the underl=
ying
>> condition probably was not occurring before 2.6.30.
>>
>>>> Can you report more about your server configuration? =C2=A0What
>>>> distribution is this?
>>>
>>> Debian stable (Lenny).
>>> nfs-common and nfs-kernel-server (1.1.2)
>>>
>>> I'm using nfs4. rpc.statd is not running; rpc.mountd and rpc.idmapd=
 are.
>>
>> The NFS client and server appear to start lockd listeners for NFSv4.=
 =C2=A0They
>> probably don't need to. =C2=A0But that's a separate issue.
>>
>>>> Does user space have portmapper or rpcbind?
>>>
>>> portmap (6.0)
>>>
>>>> Are you blacklisting ipv6.ko?
>>>
>>> No, the server has IPv6 enabled.
>>> I'm using NFS mainly from my laptop though, which does not have an =
IPv6
>>> address for my home network.
>>>
>>>> What's the output of "rpcinfo" on your server after it has started=
 NFSD?
>>>
>>> I guess you mean the -p option?
>>>
>>> $ rpcinfo -p
>>> =C2=A0program vers proto =C2=A0 port
>>> =C2=A0 100000 =C2=A0 =C2=A02 =C2=A0 tcp =C2=A0 =C2=A0111 =C2=A0port=
mapper
>>> =C2=A0 100000 =C2=A0 =C2=A02 =C2=A0 udp =C2=A0 =C2=A0111 =C2=A0port=
mapper
>>> =C2=A0 100003 =C2=A0 =C2=A02 =C2=A0 udp =C2=A0 2049 =C2=A0nfs
>>> =C2=A0 100003 =C2=A0 =C2=A03 =C2=A0 udp =C2=A0 2049 =C2=A0nfs
>>> =C2=A0 100003 =C2=A0 =C2=A04 =C2=A0 udp =C2=A0 2049 =C2=A0nfs
>>> =C2=A0 100021 =C2=A0 =C2=A01 =C2=A0 udp =C2=A047955 =C2=A0nlockmgr
>>> =C2=A0 100021 =C2=A0 =C2=A03 =C2=A0 udp =C2=A047955 =C2=A0nlockmgr
>>> =C2=A0 100021 =C2=A0 =C2=A04 =C2=A0 udp =C2=A047955 =C2=A0nlockmgr
>>> =C2=A0 100021 =C2=A0 =C2=A01 =C2=A0 tcp =C2=A041860 =C2=A0nlockmgr
>>> =C2=A0 100021 =C2=A0 =C2=A03 =C2=A0 tcp =C2=A041860 =C2=A0nlockmgr
>>> =C2=A0 100021 =C2=A0 =C2=A04 =C2=A0 tcp =C2=A041860 =C2=A0nlockmgr
>>> =C2=A0 100003 =C2=A0 =C2=A02 =C2=A0 tcp =C2=A0 2049 =C2=A0nfs
>>> =C2=A0 100003 =C2=A0 =C2=A03 =C2=A0 tcp =C2=A0 2049 =C2=A0nfs
>>> =C2=A0 100003 =C2=A0 =C2=A04 =C2=A0 tcp =C2=A0 2049 =C2=A0nfs
>>> =C2=A0 100005 =C2=A0 =C2=A01 =C2=A0 udp =C2=A040032 =C2=A0mountd
>>> =C2=A0 100005 =C2=A0 =C2=A01 =C2=A0 tcp =C2=A040623 =C2=A0mountd
>>> =C2=A0 100005 =C2=A0 =C2=A02 =C2=A0 udp =C2=A040032 =C2=A0mountd
>>> =C2=A0 100005 =C2=A0 =C2=A02 =C2=A0 tcp =C2=A040623 =C2=A0mountd
>>> =C2=A0 100005 =C2=A0 =C2=A03 =C2=A0 udp =C2=A040032 =C2=A0mountd
>>> =C2=A0 100005 =C2=A0 =C2=A03 =C2=A0 tcp =C2=A040623 =C2=A0mountd
>>> =C2=A0 391002 =C2=A0 =C2=A02 =C2=A0 tcp =C2=A0 =C2=A0792 =C2=A0sgi_=
fam
>>
>> In this case, it looks like the message can be treated as a notice. =
=C2=A0I think
>> in general we could safely make that a dprintk, but I'd like to wait=
 a bit
>> more to see if we catch any bad behavior.
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kern=
el" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.h=
tml
>> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>>
>
