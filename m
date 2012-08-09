Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:49077 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755523Ab2HIRMl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 13:12:41 -0400
Received: by ghrr11 with SMTP id r11so690282ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Aug 2012 10:12:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120809152744.149360@gmx.net>
References: <20120808155829.177400@gmx.net> <20120808163916.GA24539@umich.edu>
 <20120808182622.177380@gmx.net> <20120809084236.177380@gmx.net>
 <5DFC6BE3BA248842867E85C73BF94B050B17B698CF@MX41A.corp.emc.com> <20120809152744.149360@gmx.net>
From: Peng Tao <tao.peng@emc.com>
Date: Fri, 10 Aug 2012 01:12:19 +0800
Message-ID: <CA+a=Yy7rH7kFKJvS3eOae+Mb0C1p+N01h+Zqz7jVzGE+HXHt9g@mail.gmail.com>
Subject: Re: RE: Blocklayout
To: Johannes Schild <JSchild@gmx.de>
Cc: rees@umich.edu, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 11:27 PM, Johannes Schild <JSchild@gmx.de> wrote:
>
> -------- Original-Nachricht --------
>> Datum: Thu, 9 Aug 2012 04:56:07 -0400
>> Von: "Peng, Tao" <tao.peng@emc.com>
>> An: Johannes Schild <JSchild@gmx.de>, "rees@umich.edu" <rees@umich.edu>
>> CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
>> Betreff: RE: Blocklayout
>
>>
>> > -----Original Message-----
>> > From: linux-nfs-owner@vger.kernel.org
>> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Johannes
>> > Schild
>> > Sent: Thursday, August 09, 2012 4:43 PM
>> > To: Johannes Schild; rees@umich.edu
>> > Cc: linux-nfs@vger.kernel.org
>> > Subject: Re: Blocklayout
>> >
>> > Hi Guys,
>> >
>> > some additional Information,
>> >
>> > [ 1644.874549] FS-Cache: Loaded
>> > [ 1644.895122] NFS: Registering the id_resolver key type
>> > [ 1644.895158] FS-Cache: Netfs 'nfs' registered for caching
>> > [ 1644.920204] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1644.920207] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1644.920208] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1644.920263] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1644.920264] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1644.920265] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1653.129460] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1653.129463] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1653.129464] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1653.129528] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1653.129530] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1653.129531] blkmapd: sending ioctl 2285 to a partition!
>> > [ 1653.136682] NFS: set_pnfs_layoutdriver: Error initializing pNFS
>> layout driver 3.
>> >
>> > someone any ideas whats going wrong? The above output is from dmesg.
>> > Iam using 3.4.7-1.fc16.x86_64 Kernel from Fedora. The utils are from
>> > http://steved.fedorapeople.org/repos/pnfs.
>> >
>> There is a regression about saving proper pnfs_blksize before setting
>> block layout driver by commit e38eb650 (NFS: set_pnfs_layoutdriver() from
>> nfs4_proc_fsinfo()).
>> If your client includes the specific commit (although I don't think the
>> commit is in 3.4 kernel), please retry after applying the fix at
>> http://www.spinics.net/lists/linux-nfs/msg31868.html
>
> The patch doesn't fit my kernel. My cliet.c looks a little bit different from the client.c in the patch:
>
Then you don't have the buggy commit.

<snip...>
> [  179.557893] FS-Cache: Loaded
> [  179.563310] NFS: Registering the id_resolver key type
> [  179.563339] FS-Cache: Netfs 'nfs' registered for caching
> [  207.222318] NFS: set_pnfs_layoutdriver: Error initializing pNFS layout driver 3.
This is the same log without nfs_debug. Please run
"echo 65535 > /proc/sys/sunrpc/nfs_debug"
and then mount, to get a verbose log output.

Thanks,
Tao
