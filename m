Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f172.google.com ([209.85.220.172]:48316 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758149AbaGOXym (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 19:54:42 -0400
Received: by mail-vc0-f172.google.com with SMTP id im17so263531vcb.17
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 16:54:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALtMJECLdEOsmuW4AOnNsAyY+OMr3MtFN9W71DRw3tpidKrU8A@mail.gmail.com>
References: <CALtMJECmW-yYgD3W5FUxQZJVZkb5NSJpQ5V9Q3ZE=1NKeCDtOA@mail.gmail.com>
	<20140710175136.GA26561@fieldses.org>
	<CALtMJECLdEOsmuW4AOnNsAyY+OMr3MtFN9W71DRw3tpidKrU8A@mail.gmail.com>
Date: Tue, 15 Jul 2014 16:54:40 -0700
Message-ID: <CAHQdGtQAgKyFgwp+6w64vXkcKkBQ=YVfiH0jgaonAMumHoTutg@mail.gmail.com>
Subject: Re: `ls` shows no files in mounted nfs folder, but ls 'file' works
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andreas Fenkart <afenkart@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Daniel Mack <zonque@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 13, 2014 at 11:44 PM, Andreas Fenkart <afenkart@gmail.com> wrote:
> 2014-07-10 19:51 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
>> On Mon, Jun 23, 2014 at 12:07:22PM +0200, Andreas Fenkart wrote:
>>> Found regression introduced by this patch
>>>
>>> 311324ad NFS: Be more aggressive in using readdirplus for 'ls -l' situations"
>>>
>>> # cd /bin
>>> -sh: cd: /bin: Not a directory
>>> root@192:/# pwd
>>> /
>>> root@192:/# ls /bin
>>> ls: /bin
>>> root@192:/# ls -l /bin/sh
>>> lrwxrwxrwx    1 root     root             9 Jun 16 13:59 /bin/sh -> /bin/bash
>>>
>>> the mount options of the client, an embedded system, mounting nfsroot:
>>> nfs(rw,relatime,vers=2,rsize=4096,wsize=4096,namlen=255,hard,nolock,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.xx.xx,mountvers=1,mountproto=udp,local_lock=all,addr=192.168.xx.xx)
>>> vers: 3.16.0-rc1
>>>
>>> the server exports:
>>> /exports/rootfs 192.168.xx.xx(rw,no_root_squash,subtree_check)
>>> vers: 3.14-1-amd64 #1 SMP Debian 3.14.4-1 (2014-05-13) x86_64 GNU/Linux
>>>
>>> reverting above patch, dir listing with 'ls /' works again
>>
>> Is this still happening?
>
> yes it is, I just reverted the aforementioned commit.

Can you reapply, and then do an "ls /" while recording the traffic to
the NFS server using wireshark, and then send us the resulting dump?

If the client is on an embedded system which can't run wireshark, then
it is fine to record it on the server, but please use something like

'tshark -w /var/tmp/dump.out host <client-ip>'

Cheers
  Trond


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
