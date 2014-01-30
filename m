Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:36085 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbaA3Opr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 09:45:47 -0500
Received: by mail-ie0-f179.google.com with SMTP id ar20so3265374iec.24
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jan 2014 06:45:47 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: NFS client broken in Linus' tip
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140130143054.GY15937@n2100.arm.linux.org.uk>
Date: Thu, 30 Jan 2014 09:45:44 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>, Christoph Hellwig <hch@lst.de>,
        Viro Alexander <viro@zeniv.linux.org.uk>,
        linux-arm-kernel@lists.infradead.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Message-Id: <88DBB0A6-218A-40C5-94EA-295406E5E20E@primarydata.com>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk> <960A8F94-BDD4-4ED0-95EC-0D71D4AC27E7@primarydata.com> <20140130143054.GY15937@n2100.arm.linux.org.uk>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 30, 2014, at 9:30, Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:

> On Thu, Jan 30, 2014 at 09:17:00AM -0500, Trond Myklebust wrote:
>> 
>> On Jan 30, 2014, at 9:08, Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
>> 
>>> I just booted Linus' tip (plus a few other patches to imx-drm and imx
>>> code), and stumbled into this interesting scenario:
>>> 
>>> # touch test
>>> touch: cannot touch `test': Operation not supported
>>> 
>>> I also tried mkdir and mknod, all result in the same error.  Hard and
>>> symlinks links are creatable.
>>> 
>>> However, I can chmod existing files and rename them.  Files can also be
>>> deleted, and the combination of this has left me without a /etc/mtab !
>>> 
>>> The machine is a iMX6 based ARM, running root-nfs, which was mounted via
>>> ubuntu's initramfs (so not using the kernel's built-in root-nfs.)
>>> 
>>> /proc/mounts for the root mount gives:
>>> 192.168.1.123:/var/boot/ci / nfs rw,relatime,vers=3,rsize=65536,wsize=65536,namlen=255,hard,nolock,proto=tcp,port=2049,timeo=7,retrans=10,sec=sys,local_lock=all,addr=192.168.1.123 0 0
>>> 
>>> CONFIG_NFS_FS=y
>>> CONFIG_NFS_V2=y
>>> CONFIG_NFS_V3=y
>>> CONFIG_NFS_V3_ACL=y
>>> CONFIG_NFS_V4=y
>>> # CONFIG_NFS_SWAP is not set
>>> # CONFIG_NFS_V4_1 is not set
>>> CONFIG_ROOT_NFS=y
>>> # CONFIG_NFS_USE_LEGACY_DNS is not set
>>> CONFIG_NFS_USE_KERNEL_DNS=y
>>> # CONFIG_NFSD is not set
>>> CONFIG_LOCKD=y
>>> CONFIG_LOCKD_V4=y
>>> CONFIG_NFS_ACL_SUPPORT=y
>>> CONFIG_NFS_COMMON=y
>>> CONFIG_SUNRPC=y
>>> CONFIG_SUNRPC_GSS=y
>>> 
>>> tcpdumping, I see:
>>> 
>>> 13:59:51.713523 IP 192.168.1.252.1341245608 > 192.168.1.123.2049: 132 lookup fh Unknown/010007011040840000000000CC238FC8FBA0475D9D9F8356B4C44166CDC38700 "test"
>>> 13:59:51.714345 IP 192.168.1.123.2049 > 192.168.1.252.1341245608: reply ok 120 lookup ERROR: No such file or directory
>>> 13:59:51.751303 IP 192.168.1.252.797 > 192.168.1.123.nfs: . ack 3381 win 2625 <nop,nop,timestamp 474136 3431312924>
>>> 
>>> which is the only NFS packet(s) I see which mention "test".
>>> 
>>> and stracing touch:
>>> 
>>> open("test", O_WRONLY|O_CREAT|O_NOCTTY|O_NONBLOCK|O_LARGEFILE, 0666) = -1 EOPNOTSUPP (Operation not supported)
>>> utimensat(AT_FDCWD, "test", NULL, 0)    = -1 ENOENT (No such file or directory)
>>> write(2, "touch: ", 7touch: )                  = 7
>>> write(2, "cannot touch `test'", 19cannot touch `test')     = 19
>>> write(2, ": Operation not supported", 25: Operation not supported) = 25
>>> write(2, "\n", 1
>>> )                       = 1
>>> 
>>> I think it's down to this:
>>> 
>>> commit 013cdf1088d7235da9477a2375654921d9b9ba9f
>>> Author: Christoph Hellwig <hch@infradead.org>
>>> Date:   Fri Dec 20 05:16:53 2013 -0800
>>> 
>>>   nfs: use generic posix ACL infrastructure for v3 Posix ACLs
>>> 
>>>   This causes a small behaviour change in that we don't bother to set
>>>   ACLs on file creation if the mode bit can express the access permissions
>>>   fully, and thus behaving identical to local filesystems.
>>> 
>>>   Signed-off-by: Christoph Hellwig <hch@lst.de>
>>>   Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
>>> 
>>> which adds:
>>> 
>>> +       status = posix_acl_create(dir, &sattr->ia_mode, &default_acl, &acl);
>>> +       if (status)
>>> +               goto out;
>> 
>> Right, this should clearly not cause nfs4_proc_create to fail if it
>> returns EOPNOTSUPP.
> 
> NFS3 :)

Sorry. I fat fingered that one. I intended to write nfs3_...

>>> into nfs3_proc_create(), but this ends up calling down into nfs3_get_acl(),
>>> which does this:
>>> 
>>>       if (!nfs_server_capable(inode, NFS_CAP_ACLS))
>>>               return ERR_PTR(-EOPNOTSUPP);
>> 
>> Just for completeness sake: is the server you were running against supposed to support POSIX acls?
> 
> The server is an old 3.1.8 kernel with this NFS config:
> 
> CONFIG_NFS_FS=m
> CONFIG_NFS_V3=y
> # CONFIG_NFS_V3_ACL is not set
> # CONFIG_NFS_V4 is not set
> # CONFIG_NFS_FSCACHE is not set
> CONFIG_NFSD=m
> CONFIG_NFSD_V3=y
> # CONFIG_NFSD_V3_ACL is not set
> # CONFIG_NFSD_V4 is not set
> CONFIG_LOCKD=m
> CONFIG_LOCKD_V4=y
> CONFIG_NFS_COMMON=y
> 
> which has worked fine with NFS clients for the last 1800 odd days... until
> now.
> 

OK. I’m guessing that you’re hitting the auto-probing code further down in nfs3_get_acl(), which also returns EOPNOTSUPP in those cases. Those probably need to return NULL too, then…

However, there seems to be an inconsistency in the whole API here: posix_acl_create() and posix_acl_chmod() seem to want to return ‘0’ both when acls are not supported and when they are not set, however posix_acl_xattr_get() wants to return EOPNOTSUPP in the first case, and ENODATA in the second. How is the filesystem supposed to know what to return?

--
Trond Myklebust
Linux NFS client maintainer

