Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:65300 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932439Ab2FGRXd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jun 2012 13:23:33 -0400
Message-ID: <4FD0E382.8050800@netapp.com>
Date: Thu, 07 Jun 2012 13:23:14 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Joerg Roedel <joro@8bytes.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS regression in v3.5-rc1: mount.nfs yells about incorrect mount
 option
References: <20120607150456.GO12795@8bytes.org> <4FD0C4C2.8020605@netapp.com> <20120607155006.GR12795@8bytes.org> <4FD0CEB0.9040804@netapp.com> <20120607160109.GS12795@8bytes.org>
In-Reply-To: <20120607160109.GS12795@8bytes.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/07/2012 12:01 PM, Joerg Roedel wrote:
> On Thu, Jun 07, 2012 at 11:54:24AM -0400, Bryan Schumaker wrote:
>> On 06/07/2012 11:50 AM, Joerg Roedel wrote:
>>> On Thu, Jun 07, 2012 at 11:12:02AM -0400, Bryan Schumaker wrote:
>>>
>>>> Can you use `mount -v` to get more output?
>>>
>>> Btw, it also works when I manually set the nfs-version at mount:
>>>
>>> mount -o nfsvers=3 ...
>>
>> What about `mount -o vers=4 ...`?  I'm compiling a kernel right now to
>> see if I can reproduce this, what NFS .config options do you have set?
>> (`cat .config | grep CONFIG_NFS_` should be good enough).
> 
> mount -o vers=2 and -o vers=3 works
> mount -o vers=4 fails with:
> 
> root@chrom:~# mount -o vers=4 lemmy:/data/repos/ /data/lemmy/
> mount.nfs: mounting lemmy:/data/repos/ failed, reason given by server:
>   No such file or directory

What does /etc/exports look like on the server?  You may have to mount it as "lemmy:/" when using NFS v4.

What distro are you using?  I haven't been able to get the incorrect mount option error you're seeing.
> 
> # grep CONFIG_NFS_ .config
> CONFIG_NFS_FS=y
> CONFIG_NFS_V2=y
> CONFIG_NFS_V3=y
> CONFIG_NFS_V3_ACL=y
> CONFIG_NFS_V4=y
> # CONFIG_NFS_V4_1 is not set
> CONFIG_NFS_FSCACHE=y
> # CONFIG_NFS_USE_LEGACY_DNS is not set
> CONFIG_NFS_USE_KERNEL_DNS=y
> CONFIG_NFS_ACL_SUPPORT=y
> CONFIG_NFS_COMMON=y
> 
> 
> 	Joerg
> 
> 


