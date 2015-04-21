Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:11201 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106AbbDUOpf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Apr 2015 10:45:35 -0400
Message-ID: <55366287.6020105@free.fr>
Date: Tue, 21 Apr 2015 16:45:27 +0200
From: Mason <slash.tmp@free.fr>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: nfsroot protocol version
References: <551BC077.1030402@free.fr> <55360C4C.4010100@free.fr> <5EF1E689-1388-49A8-9DAD-F0078FC820DB@oracle.com>
In-Reply-To: <5EF1E689-1388-49A8-9DAD-F0078FC820DB@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Chuck,

On 21/04/2015 16:07, Chuck Lever wrote:

> On Apr 21, 2015, at 4:37 AM, Mason wrote:
>
>> Hello,
>>
>> On 01/04/2015 11:55, Mason wrote:
>>
>>> My embedded system is supposed to mount the rootfs via NFS.
>>> https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
>>>
>>> So I set these options in my kernel .config
>>>
>>> CONFIG_IP_PNP=y
>>> CONFIG_IP_PNP_DHCP=y
>>> CONFIG_ROOT_NFS=y
>>> CONFIG_NFS_V4=y
>>>
>>> But it didn't work, the system would panic after a long time out
>>> (around 95 seconds)
>>>
>>> [   98.567037] VFS: Unable to mount root fs via NFS, trying floppy.
>>> [   98.573238] Freeing unused kernel memory: 144K (c0332000 - c0356000)
>>> [   98.579698] Kernel panic - not syncing: No working init found.
>>>      Try passing init= option to kernel. See Linux Documentation/init.txt for guidance.
>>>
>>> I then enabled NFSv2 and NFSv3, and then it worked.
>>>
>>> When I was debugging the problem, I ran across NFS_DEF_OPTIONS
>>> in fs/nfs/nfsroot.c
>>>
>>> #define NFS_DEF_OPTIONS        "vers=2,udp,rsize=4096,wsize=4096"
>>>
>>> IIUC, we are explicitly requesting NFSv2?
>>>
>>> Would that explain why it fails when NFSv2 support is not compiled in?
>>>
>>> Would it make sense to use version 3?
>>> (So NFSv2 is not needed just to load the rootfs.)
>>
>> I saw commit 4251c94833aa (NFS: Revert NFSROOT default mount options)
>> which states:
>>
>>     Last fall we removed the ad hoc mount option parser in
>>     fs/nfs/nfsroot.c in favor of using the main parser in fs/nfs/super.c
>>     (see commit 56463e50 "NFS: Use super.c for NFSROOT mount option
>>     parsing").  That commit changed the default NFSROOT mount options to
>>     be the same as those employed by user space mounts.
>>         As it turns out, these new default mount options are not tolerated by
>>     many embedded systems.  So far these problems have been due to
>>     specific behavior of certain embedded NICs.  The NFS community does
>>     not have such hardware on hand for running tests.
>>         Commit 53d47375 recently introduced a clean way to specify default
>>     mount options for NFSROOT, so we can now easily restore the
>>     traditional defaults for NFSROOT:
>>            vers=2,udp,rsize=4096,wsize=4096
>>         This should revert the new default NFSROOT mount options introduced
>>     with commit 56463e50.
>>
>> I guess this explains why vers=3 is not the default?
>>
>> I'm now wondering how to override the mount options on the boot command
>> line. Looking more closely at commit 53d473758053 (NFS: NFSROOT should
>> default to "proto=udp") nothing jumps out at me.
>>
>> My current boot command line is
>> "root=/dev/nfs ip=:::::eth0:dhcp rdinit=/none console=ttyS0,115200 mem=512M earlyprintk"
>>
>> Looking at the documentation
>> https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
>> I don't see where the protocol version is specified.
>>
>> Where am I supposed to add the vers=3 option?
>
> Let's try that again.
>
> Specifying “vers=3” in the nfs-options section of the nfsroot= boot
> parameter should work.

Hmmm, I don't have nfsroot= in my boot command line.
nfsroot=[<server-ip>:]<root-dir>[,<nfs-options>]

In U-Boot, DHCP sets a root-path environment variable to
"172.27.64.1:/export/roots/6_2_0_8756"

Is root-path an alias for nfsroot?

I tried
root-path = "172.27.64.1:/export/roots/6_2_0_8756,vers=3"
root-path = "172.27.64.1:/export/roots/6_2_0_8756,v3"
(second form suggested in the link below)
but neither worked :-(

This page mentions root-path
http://developer.toradex.com/software-resources/arm-family/linux/linux-booting
option root-path "192.168.10.1:/srv/nfs/rootfs,wsize=1024,rsize=1024,v3";

Regards.

