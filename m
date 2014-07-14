Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:43481 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbaGNGoX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jul 2014 02:44:23 -0400
Received: by mail-qa0-f51.google.com with SMTP id k15so2885131qaq.24
        for <linux-nfs@vger.kernel.org>; Sun, 13 Jul 2014 23:44:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140710175136.GA26561@fieldses.org>
References: <CALtMJECmW-yYgD3W5FUxQZJVZkb5NSJpQ5V9Q3ZE=1NKeCDtOA@mail.gmail.com>
	<20140710175136.GA26561@fieldses.org>
Date: Mon, 14 Jul 2014 08:44:22 +0200
Message-ID: <CALtMJECLdEOsmuW4AOnNsAyY+OMr3MtFN9W71DRw3tpidKrU8A@mail.gmail.com>
Subject: Re: `ls` shows no files in mounted nfs folder, but ls 'file' works
From: Andreas Fenkart <afenkart@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: rond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, Daniel Mack <zonque@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2014-07-10 19:51 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> On Mon, Jun 23, 2014 at 12:07:22PM +0200, Andreas Fenkart wrote:
>> Found regression introduced by this patch
>>
>> 311324ad NFS: Be more aggressive in using readdirplus for 'ls -l' situations"
>>
>> # cd /bin
>> -sh: cd: /bin: Not a directory
>> root@192:/# pwd
>> /
>> root@192:/# ls /bin
>> ls: /bin
>> root@192:/# ls -l /bin/sh
>> lrwxrwxrwx    1 root     root             9 Jun 16 13:59 /bin/sh -> /bin/bash
>>
>> the mount options of the client, an embedded system, mounting nfsroot:
>> nfs(rw,relatime,vers=2,rsize=4096,wsize=4096,namlen=255,hard,nolock,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.xx.xx,mountvers=1,mountproto=udp,local_lock=all,addr=192.168.xx.xx)
>> vers: 3.16.0-rc1
>>
>> the server exports:
>> /exports/rootfs 192.168.xx.xx(rw,no_root_squash,subtree_check)
>> vers: 3.14-1-amd64 #1 SMP Debian 3.14.4-1 (2014-05-13) x86_64 GNU/Linux
>>
>> reverting above patch, dir listing with 'ls /' works again
>
> Is this still happening?

yes it is, I just reverted the aforementioned commit.
