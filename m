Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:39926 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907Ab0IOJje convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Sep 2010 05:39:34 -0400
Received: by iwn5 with SMTP id 5so1418iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Sep 2010 02:39:34 -0700 (PDT)
In-Reply-To: <4C9091A7.7030502@cn.fujitsu.com>
References: <AANLkTima6ASRztdzgm413VaBKLPEFt2SSa4JUkKQ9TqV@mail.gmail.com>
	<4C9091A7.7030502@cn.fujitsu.com>
Date: Wed, 15 Sep 2010 17:39:32 +0800
Message-ID: <AANLkTimVTFNo3i2td=tcORTg0-yaLhM0dEXsXhku5khR@mail.gmail.com>
Subject: Re: pNFS: trouble test with fscache
From: =?UTF-8?B?5a6r5YuQ?= <shadowinlife@gmail.com>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thank you

I have checked the memory ( 12G.)  and  sometimes memory is only 512M
(I set it in grub.conf)

fscache works well  I have sent /proc/fs/fscache/states to David
(RedHat who write fscache)

ENOBUFS is just normal infor

But  once fscache detect a ENOBUFS  It can't alloc more buff   Then
no more data can be write to disk

nfs_readpages_to_fscache   __nfs_readpages_from_fscache may report ENOBUF

After that  no buff will be alloc

Thank you for replaying this mail

yours
GongMeng



On Wed, Sep 15, 2010 at 5:28 PM, Bian Naimeng <biannm@cn.fujitsu.com> wrote:
>> S:
>>
>> I want to get benchmark from pNFS+ fscache with iozone
>>
>> But  iozone can't work well
>> /proc/fs/nfsfs/volumes   show that  the fsc is YES
>>
>> I have open cachefiled and mount a ssd (ext3/user_xattr) on /var/fscache
>>
>> When I use iozone to test read/re-read   it can't write page to the SSD DISK
>>
>> /var/log/messages  show that  first it can write 4 pages successfully
>>
>> after NFS: nfs_getpages_from_fscache: no page: -105
>
>  Please confirm whether do you have enough memory when get this error,
>  i guess iozone eats lot of memory.
>
>  And, maybe the information of /proc/fs/fscache/states is useful, please
>  puts it.
>
> --
> Regards
> Bian Naimeng
>
>
