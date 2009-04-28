From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Bug] NFSv4 fails to work without ipv6 kernel module
Date: Tue, 28 Apr 2009 12:16:52 -0400
Message-ID: <E3A82BE4-E39C-4E4E-9CBA-4CD182E73CBB@oracle.com>
References: <200904271903.36379.bircoph@gmail.com> <1810FE6E-D2AF-4ED3-BE34-F6117A8D9B46@oracle.com> <200904280444.00206.bircoph@gmail.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Andrew Savchenko <bircoph@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:60275 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932342AbZD1QRD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 12:17:03 -0400
In-Reply-To: <200904280444.00206.bircoph@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 27, 2009, at 8:43 PM, Andrew Savchenko wrote:
> Hello,
>
> On Monday 27 April 2009, Chuck Lever wrote:
>> On Apr 27, 2009, at 11:03 AM, Andrew Savchenko wrote:
>>> Hello,
>>>
>>> I have ipv6 support as a module (it may be needed in the
>>> recent future), but currently I want ipv6 to be disabled on my
>>> system, so I blacklisted this module. And here problems
>>> begin...
>>>
>>> NFSv3 works flawlessly:
>>> # mount 172.19.0.1:/home/ftp /mnt/nfs/
>>>
>>> but NFSv4 fails:
>>> # mount -t nfs4 172.19.0.1:/ /mnt/nfs/
>>> mount.nfs4: Cannot allocate memory
>>>
>>> After modprobe ipv6 it works:
>>> # mount -t nfs4 172.19.0.1:/ /mnt/nfs/
>>>
>>> I recompiled nfs-utils without ipv6 support, but this doesn't
>>> help.
>>>
>>> Here is my /etc/exports:
>>> /home/ftp 172.16.0.0/12
>>> (ro,async,crossmnt,no_subtree_check,fsid=0,all_squash) \
>>>       127.0.0.1/32
>>> (ro,async,crossmnt,no_subtree_check,fsid=0,all_squash)
>>>
>>> I use nfs-utils-1.1.5, I tested this on both vanilla linux
>>> kernels 2.6.28.7 and 2.6.28.9.
>>
>> Have you tried this with 2.6.29?
>
> I just tried with vanilla 2.6.29.1. Things became even worse. Now
> not only NFSv4 fails to mount as usual, but NFSv3 fails too:
>
> # mount 172.19.0.1:/home/ftp /mnt/orionis
> mount.nfs: Address family not supported by protocol
>
> And following error appears in kernel log multiple times:
> RPC: failed to contact local rpcbind server (errno 5).
>
> I attached strace -f for both mount attempts. The problem is in
> mount() syscall in both cases, thus somewhere inside the kernel...
>
> With ipv6 module loaded all works fine.

Right, this isn't an nfs-utils problem, it's an issue in the kernel  
(so the strace isn't terribly informative).  2.6.29 is supposed to  
have addressed this problem, but maybe you are hitting a new way that  
not having ipv6.ko loaded is buggering us.

If you're building these kernels yourself, why not disable CONFIG_IPV6?

>> You can also try building 2.6.28 with CONFIG_SUNRPC_REGISTER_V4
>> disabled.
>
> With this option disabled errno 5 (see above) disappeared from
> logs, but mount fails with the same errors. Yet again, with ipv6
> module loaded it works ok.

I can't reproduce here on 2.6.30-rc2, so it may be just an issue with  
2.6.29.  You can enable debug printks to see what the kernel thinks is  
going on.  Try this as root:

   # rpcdebug -m nfs -s mount
   # mount ....
   # rpcdebug -m nfs -c

Then look in your kernel log.  "rpcdebug -vh" will list the full set  
of flags you can enable.

Since rpcbind also seems to be an issue, you can try this also:

   # rpcdebug -m rpc -s bind
   # mount ....
   # rpcdebug -m rpc -c

What type of server are you attempting to mount?  Linux?  Solaris?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
