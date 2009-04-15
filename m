From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: klibc's nfsmount failure with 2.6.27.21, while 2.6.25.20 was fine
Date: Wed, 15 Apr 2009 10:36:46 -0400
Message-ID: <0D024344-54E3-4A09-BE78-3E67667E05E7@oracle.com>
References: <200904151250.49372.hpj@urpla.net> <1239799114.5177.4.camel@heimdal.trondhjem.org> <200904151548.12291.hpj@urpla.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Hans-Peter Jansen <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:37906 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777AbZDOOhE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2009 10:37:04 -0400
In-Reply-To: <200904151548.12291.hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 15, 2009, at 9:48 AM, Hans-Peter Jansen wrote:
> Am Mittwoch, 15. April 2009 schrieb Trond Myklebust:
>> On Wed, 2009-04-15 at 12:50 +0200, Hans-Peter Jansen wrote:
>>> Hi,
>>>
>>> I suffer from a problem, where my diskless environment doesn't work
>>> anymore after upgrading the server from openSUSE 11.0 (2.6.25.20) to
>>> openSUSE 11.1 (2.6.27.21).
>>>
>>> The diskless environment gets set up with an customized initrd via
>>> pxelinux. The initrd uses klibc's nfsmount, and I've tried both
>>> protocols: udp and tcp. It's not an iptables issue, since I can  
>>> mount
>>> these directories from other (fully booted) systems just fine.
>>>
>>> Using the debug version of klibc's nfsmount prints these messages:
>>> short read: 0 < 28
>>> Port for 100003/3[udp]: 0
>>> short read: 0 < 28
>>> Port for 100005/3[udp]: 0
>>> NFS params:
>>>  server = xxx.xx.xx.xx, path = "/roroot", version = 3, proto = udp,
>>>  mount_port = 627, nfs_port = 2049, flags = 00010282,
>>
>>    ^^^^^^^^^^^^^^^^
>>
>>>  rsize = 0, wsize = 0, timeo = 7, retrans = 3,
>>>  acreg (min,max) = (3,60), acdir (min,max) = (30,60),
>>>  soft = 0, intr = 1, posix = 0, nocto = 0, noac = 0
>>>
>>> tcpdumping the communication shows, that for whatever reason, the
>>> client sends the mount request from source port 798 to destination  
>>> port
>>> 627, but the server doesn't listen on 627:
>>
>> The question is why is klibc specifying mount port = 627?

nfs_root_ports() (in fs/nfs/nfsroot.c) sets the default mountd port to  
627, I think only if the rpcbind doesn't work.

> Well, this is exactly my problem. That's the mount port, but this  
> one cannot
> be set to a manual value, thus the rpc stuff infront of it must have  
> gone
> wrong.
>
> [Update]
> Issue solved. It was that silly rpcbind package  
> (0.1.6+git20080930-5.2),
> that has gone wrong. Replacing it with portmap  
> (6.0+git20070716-31.37) did
> it. Looks like this deserves a new bugzilla record.

When using rpcbind instead of portmapper, what does the output of  
"rpcinfo" look like on the server?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
