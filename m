From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Bug] NFSv4 fails to work without ipv6 kernel module
Date: Thu, 30 Apr 2009 12:48:22 -0400
Message-ID: <E45F6848-3C1A-42C2-898C-6E51C1AB0B8A@oracle.com>
References: <200904271903.36379.bircoph@gmail.com> <1810FE6E-D2AF-4ED3-BE34-F6117A8D9B46@oracle.com> <200904280444.00206.bircoph@gmail.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: multipart/mixed; boundary=Apple-Mail-3-809897133
Cc: linux-nfs@vger.kernel.org
To: Andrew Savchenko <bircoph@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:52086 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661AbZD3Qsd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 12:48:33 -0400
In-Reply-To: <200904280444.00206.bircoph@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail-3-809897133
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

Hi Andrew-

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
>
>> You can also try building 2.6.28 with CONFIG_SUNRPC_REGISTER_V4
>> disabled.
>
> With this option disabled errno 5 (see above) disappeared from
> logs, but mount fails with the same errors. Yet again, with ipv6
> module loaded it works ok.

Reproduced here.  A patch is attached.  (I usually send patches  
inline, but to test 2.6.29-stable I'm working outside of git, using  
old-fashioned tools like "diff").

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com


--Apple-Mail-3-809897133
Content-Disposition: attachment;
	filename=ipv6-nfs4-callback-2.6.29.diff
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="ipv6-nfs4-callback-2.6.29.diff"
Content-Transfer-Encoding: 7bit

NFS: Disable AF_INET6 callback service if SUNRPC_REGISTER_V4 is disabled

This works around a problem (fixed in 2.6.30) where unloading the
ipv6.ko module causes mount.nfs4 to fail with "Cannot allocate memory."

SUNRPC_REGISTER_V4 is required for AF_INET6 support in NFS and lockd.
If V4 rpcbind registration support isn't available in the kernel, lockd
uses AF_INET only.  NFSv4 callback does not register with rpcbind, so it
doesn't care what flavor of rpcbind registration is available in the
kernel.

For 2.6.29 we decided to use SUNRPC_REGISTER_V4 to disable IPv6 support
in NFS and lockd to work around the requirement that ipv6.ko be loaded.
But I forgot that the NFSv4 callback service would still try to start an
AF_INET6 listener even if SUNRPC_REGISTER_V4 is disabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

diff -Naurp linux-2.6.29.1/fs/nfs/callback.c linux-2.6.29.1-fixed/fs/nfs/callback.c
--- linux-2.6.29.1/fs/nfs/callback.c	2009-04-02 16:55:27.000000000 -0400
+++ linux-2.6.29.1-fixed/fs/nfs/callback.c	2009-04-30 12:30:12.579781562 -0400
@@ -45,7 +45,8 @@ static const int nfs_set_port_max = 6553
  * If the kernel has IPv6 support available, always listen for
  * both AF_INET and AF_INET6 requests.
  */
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#if (defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) && \
+	defined(CONFIG_SUNRPC_REGISTER_V4)
 static const sa_family_t	nfs_callback_family = AF_INET6;
 #else
 static const sa_family_t	nfs_callback_family = AF_INET;

--Apple-Mail-3-809897133
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7bit



--Apple-Mail-3-809897133--
