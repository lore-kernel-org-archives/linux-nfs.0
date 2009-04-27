From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Bug] NFSv4 fails to work without ipv6 kernel module
Date: Mon, 27 Apr 2009 12:04:10 -0400
Message-ID: <1810FE6E-D2AF-4ED3-BE34-F6117A8D9B46@oracle.com>
References: <200904271903.36379.bircoph@gmail.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Andrew Savchenko <bircoph@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:41962 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900AbZD0QEU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2009 12:04:20 -0400
In-Reply-To: <200904271903.36379.bircoph@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 27, 2009, at 11:03 AM, Andrew Savchenko wrote:
> Hello,
>
> I have ipv6 support as a module (it may be needed in the recent
> future), but currently I want ipv6 to be disabled on my system, so
> I blacklisted this module. And here problems begin...
>
> NFSv3 works flawlessly:
> # mount 172.19.0.1:/home/ftp /mnt/nfs/
>
> but NFSv4 fails:
> # mount -t nfs4 172.19.0.1:/ /mnt/nfs/
> mount.nfs4: Cannot allocate memory
>
> After modprobe ipv6 it works:
> # mount -t nfs4 172.19.0.1:/ /mnt/nfs/
>
> I recompiled nfs-utils without ipv6 support, but this doesn't help.
>
> Here is my /etc/exports:
> /home/ftp 172.16.0.0/12
> (ro,async,crossmnt,no_subtree_check,fsid=0,all_squash) \
>        127.0.0.1/32
> (ro,async,crossmnt,no_subtree_check,fsid=0,all_squash)
>
> I use nfs-utils-1.1.5, I tested this on both vanilla linux kernels
> 2.6.28.7 and 2.6.28.9.

Have you tried this with 2.6.29?

You can also try building 2.6.28 with CONFIG_SUNRPC_REGISTER_V4  
disabled.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
