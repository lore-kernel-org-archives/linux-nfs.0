Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:63397 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbaJFPTt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Oct 2014 11:19:49 -0400
Received: by mail-vc0-f179.google.com with SMTP id im17so3235783vcb.24
        for <linux-nfs@vger.kernel.org>; Mon, 06 Oct 2014 08:19:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5432B2C1.7090901@gmail.com>
References: <54131DFE.9020708@gmail.com>
	<CAHQdGtRVfNQs7bBDbY8yH2Fzq3MyFyBBxbuTDH63w6WTqs4zPQ@mail.gmail.com>
	<5432B2C1.7090901@gmail.com>
Date: Mon, 6 Oct 2014 11:19:48 -0400
Message-ID: <CAHQdGtRcbBwYceKuEYLRXGi9RxGt0Y76MZcSSY=nQmdBVKreJA@mail.gmail.com>
Subject: Re: NFSv4 O_DIRECT with 3.16.2 kernel issue (qemu kvm cache=none /
 RHEL5 guest)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Zdenek Kaspar <zkaspar82@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 6, 2014 at 11:18 AM, Zdenek Kaspar <zkaspar82@gmail.com> wrote:
> On 09/12/2014 06:31 PM, Trond Myklebust wrote:
>> On Fri, Sep 12, 2014 at 12:23 PM, Zdenek Kaspar <zkaspar82@gmail.com> wrote:
>>> Hello everyone, got this specific problem with RHEL5 guest under KVM
>>> hypervisor.
>>>
>>> client/server kernel version: 3.16.2
>>>
>>> /etc/exports: rw,async,no_subtree_check,no_root_squash
>>> /proc/mounts: nfs4 rw,relatime,vers=4.0,rsize=524288,wsize=524288,
>>>               namlen=255,hard,proto=tcp,port=0,
>>>               timeo=600,retrans=2,sec=sys,clientaddr=xxx.xxx.xxx.xxx,
>>>               local_lock=none,addr=xxx.xxx.xxx.yyy 0 0
>>>
>>> CONFIG_NFS_FS=m
>>> # CONFIG_NFS_V2 is not set
>>> CONFIG_NFS_V3=m
>>> # CONFIG_NFS_V3_ACL is not set
>>> CONFIG_NFS_V4=m
>>> # CONFIG_NFS_SWAP is not set
>>> # CONFIG_NFS_V4_1 is not set
>>> # CONFIG_NFS_USE_LEGACY_DNS is not set
>>> CONFIG_NFS_USE_KERNEL_DNS=y
>>> CONFIG_NFSD=m
>>> CONFIG_NFSD_V3=y
>>> # CONFIG_NFSD_V3_ACL is not set
>>> CONFIG_NFSD_V4=y
>>> # CONFIG_NFSD_FAULT_INJECTION is not set
>>> CONFIG_NFS_COMMON=y
>>>
>>> CentOS-5.10-i386-bin-1of8.iso -- did not test everything on centos,
>>> behaved same as RHEL5. So let's use it as VM reproducer:
>>>
>>> dd if=/dev/zero of=kvm-test1.img bs=1M count=2048
>>>
>>> start VM using:
>>> file=kvm-test1.img,cache=writeback,aio=native,if=virtio,boot=on
>>>
>>> create custom layout: /dev/vda1 / ext3 max size primary
>>> unselect Desktop-Gnome, select Customize now
>>> use only: Base System/Base and install it..
>>>
>>> [root@test1 ~]# find / >/dev/null
>>> everything works as expected with writeback
>>>
>>> shutdown, backup kvm-test1.img (fs will explode)
>>> start VM using:
>>> file=kvm-test1.img,cache=none,aio=native,if=virtio,boot=on
>>>
>>> [root@test1 ~]# find / >/dev/null
>>> and check dmesg, reboot etc, ie:
>>> EXT3-fs error (device vda1): htree_dirblock_to_tree: bad entry in
>>> directory #460317: rec_len is smaller than minimal - offset=0, inode=0,
>>> rec_len=0, name_len=0
>>> EXT3-fs error (device vda1): htree_dirblock_to_tree: bad entry in
>>> directory #98503: rec_len is smaller than minimal - offset=0, inode=0,
>>> rec_len=0, name_len=0
>>>
>>> Tested locally on ext4, xfs          - WORK
>>> Tested on NFSv4 share with ext4, xfs - FAIL
>>> Tested NFSv4 share sync, async       - FAIL
>>> Tested on NFSv3 share with xfs       - WORK
>>> KVM with qemu rhel-6.5, 2.1.1        - SAME RESULTS
>>>
>>> NOTE: it seems just the rhel5 guest triggers it easily..
>>>
>>> HTH, Z.
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> Don't use 3.16.x kernels with NFS yet. There are known bugs in the
>> read/write code that need a stable backport of a set of fixes that are
>> in 3.17-rc.
>>
>>
>
> Hi Trond, noticed big nfs update that got into -stable, running 3.16.4
> on both sides and problem is fixed, thx!
>
> Z.

Cool! Thanks for having tested and for confirming.

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
