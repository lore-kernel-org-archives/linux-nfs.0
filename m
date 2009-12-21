From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: two exports on server, only one directory appears on client
Date: Mon, 21 Dec 2009 08:43:45 -0500
Message-ID: <4d569c330912210543y514a6dd4kd2fc3a9c666644a2@mail.gmail.com>
References: <94de02aa0912202033g1002f945o5a752606fead7215@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: f3ar007 <f3ar007@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:47318 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbZLUNnr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Dec 2009 08:43:47 -0500
Received: by bwz27 with SMTP id 27so3448245bwz.21
        for <linux-nfs@vger.kernel.org>; Mon, 21 Dec 2009 05:43:45 -0800 (PST)
In-Reply-To: <94de02aa0912202033g1002f945o5a752606fead7215-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 20, 2009 at 11:33 PM, f3ar007 <f3ar007@gmail.com> wrote:
> hi,
>
> i have a problem mounting two separate directories on the client. =A0=
the
> exports, on the server, are defined as two different directories. =A0=
and
> exportfs -rav outputs the correct ipaddr:/path/to/mount on the server=
=2E
> =A0when i mount the separate directories on the client "mount -t nfs
> ipaddr:/full/path /mnt/hd1" and "mount -t nfs ipaddr:/full/path
> /mnt/hd2" both directories on the client /mnt/hd1 and /mnt/hd2 list
> the contents of only hd2. =A0for example, on the client, ls /mnt/hd1
> outputs the same directories as ls /mnt/hd2. =A0the server has the
> correct mount points /dev/sda1 as /mnt/1tb and /dev/sdb1 as
> /mnt/320gb.
>
> here is the code to clarify:
>
> # server output of `mount | grep /dev/sd`
> /dev/sda1 =A0on =A0/mnt/1tb =A0 =A0 =A0type vfat =A0(rw,noexec,nosuid=
,nodev,umask=3D000)
> /dev/sdb1 =A0on =A0/mnt/320gb =A0type vfat =A0(rw,noexec,nosuid,nodev=
,umask=3D000)
> # notes two different harddrives here, so the directories in each are=
 different.
>
> # server output of `cat /etc/exports`
> /mnt/1tb =A0 =A0 client-ipaddress(rw,fsid=3D0,subtree_check,no_root_s=
quash,crossmnt,async)
> /mnt/320gb client-ipaddress(rw,fsid=3D0,subtree_check,no_root_squash,=
crossmnt,async)

I think the problem is that you have specified that both are fsid=3D0.
There should only be one export with fsid=3D0
