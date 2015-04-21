Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:16661 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbbDUPYv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2015 11:24:51 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: nfsroot protocol version
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55366287.6020105@free.fr>
Date: Tue, 21 Apr 2015 11:16:18 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Message-Id: <A18103B0-EB7B-4336-95D6-4519F1279779@oracle.com>
References: <551BC077.1030402@free.fr> <55360C4C.4010100@free.fr> <5EF1E689-1388-49A8-9DAD-F0078FC820DB@oracle.com> <55366287.6020105@free.fr>
To: Mason <slash.tmp@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 21, 2015, at 10:45 AM, Mason <slash.tmp@free.fr> wrote:

> Hello Chuck,
> 
> On 21/04/2015 16:07, Chuck Lever wrote:
> 
>> On Apr 21, 2015, at 4:37 AM, Mason wrote:
>> 
>>> Hello,
>>> 
>>> On 01/04/2015 11:55, Mason wrote:
>>> 
>>>> My embedded system is supposed to mount the rootfs via NFS.
>>>> https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
>>>> 
>>>> So I set these options in my kernel .config
>>>> 
>>>> CONFIG_IP_PNP=y
>>>> CONFIG_IP_PNP_DHCP=y
>>>> CONFIG_ROOT_NFS=y
>>>> CONFIG_NFS_V4=y
>>>> 
>>>> But it didn't work, the system would panic after a long time out
>>>> (around 95 seconds)
>>>> 
>>>> [   98.567037] VFS: Unable to mount root fs via NFS, trying floppy.
>>>> [   98.573238] Freeing unused kernel memory: 144K (c0332000 - c0356000)
>>>> [   98.579698] Kernel panic - not syncing: No working init found.
>>>>     Try passing init= option to kernel. See Linux Documentation/init.txt for guidance.
>>>> 
>>>> I then enabled NFSv2 and NFSv3, and then it worked.
>>>> 
>>>> When I was debugging the problem, I ran across NFS_DEF_OPTIONS
>>>> in fs/nfs/nfsroot.c
>>>> 
>>>> #define NFS_DEF_OPTIONS        "vers=2,udp,rsize=4096,wsize=4096"
>>>> 
>>>> IIUC, we are explicitly requesting NFSv2?
>>>> 
>>>> Would that explain why it fails when NFSv2 support is not compiled in?
>>>> 
>>>> Would it make sense to use version 3?
>>>> (So NFSv2 is not needed just to load the rootfs.)
>>> 
>>> I saw commit 4251c94833aa (NFS: Revert NFSROOT default mount options)
>>> which states:
>>> 
>>>    Last fall we removed the ad hoc mount option parser in
>>>    fs/nfs/nfsroot.c in favor of using the main parser in fs/nfs/super.c
>>>    (see commit 56463e50 "NFS: Use super.c for NFSROOT mount option
>>>    parsing").  That commit changed the default NFSROOT mount options to
>>>    be the same as those employed by user space mounts.
>>>        As it turns out, these new default mount options are not tolerated by
>>>    many embedded systems.  So far these problems have been due to
>>>    specific behavior of certain embedded NICs.  The NFS community does
>>>    not have such hardware on hand for running tests.
>>>        Commit 53d47375 recently introduced a clean way to specify default
>>>    mount options for NFSROOT, so we can now easily restore the
>>>    traditional defaults for NFSROOT:
>>>           vers=2,udp,rsize=4096,wsize=4096
>>>        This should revert the new default NFSROOT mount options introduced
>>>    with commit 56463e50.
>>> 
>>> I guess this explains why vers=3 is not the default?
>>> 
>>> I'm now wondering how to override the mount options on the boot command
>>> line. Looking more closely at commit 53d473758053 (NFS: NFSROOT should
>>> default to "proto=udp") nothing jumps out at me.
>>> 
>>> My current boot command line is
>>> "root=/dev/nfs ip=:::::eth0:dhcp rdinit=/none console=ttyS0,115200 mem=512M earlyprintk"
>>> 
>>> Looking at the documentation
>>> https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
>>> I don't see where the protocol version is specified.
>>> 
>>> Where am I supposed to add the vers=3 option?
>> 
>> Let's try that again.
>> 
>> Specifying “vers=3” in the nfs-options section of the nfsroot= boot
>> parameter should work.
> 
> Hmmm, I don't have nfsroot= in my boot command line.
> nfsroot=[<server-ip>:]<root-dir>[,<nfs-options>]

nfsroot= is the way that NFSROOT mount options are specified. Without
that kernel boot parameter, NFSROOT won’t work.

> In U-Boot, DHCP sets a root-path environment variable to
> "172.27.64.1:/export/roots/6_2_0_8756"
> 
> Is root-path an alias for nfsroot?

RFC 2132 Section 3.19 defines Root Path as option 17, which provides
a DHCP client with the location of it’s root disk.

root-path is the API on your DHCP server that lets you specify the
contents of option 17. DHCP clients use the contents of option 17
to construct a kernel boot command line.

> I tried
> root-path = "172.27.64.1:/export/roots/6_2_0_8756,vers=3"
> root-path = "172.27.64.1:/export/roots/6_2_0_8756,v3"
> (second form suggested in the link below)
> but neither worked :-(
> 
> This page mentions root-path
> http://developer.toradex.com/software-resources/arm-family/linux/linux-booting
> option root-path "192.168.10.1:/srv/nfs/rootfs,wsize=1024,rsize=1024,v3”;

You might have better luck with this:

 http://wiki.emacinc.com/wiki/Booting_with_an_NFS_Root_Filesystem

It explains how to specify client kernel boot commandline parameters
on your DHCP server that will make NFSROOT work.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



