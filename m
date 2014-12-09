Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:53842 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbaLIWB2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Dec 2014 17:01:28 -0500
Received: by mail-vc0-f170.google.com with SMTP id hy4so783305vcb.29
        for <linux-nfs@vger.kernel.org>; Tue, 09 Dec 2014 14:01:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1418159956-10853-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1418159956-10853-1-git-send-email-Anna.Schumaker@Netapp.com>
Date: Tue, 9 Dec 2014 17:01:27 -0500
Message-ID: <CAHQdGtSvofjOr2spSJZLMtjLgQt-BvOdxsewC8q-tVgvvRMGmQ@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix use of nfs_attr_use_mounted_on_fileid()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 9, 2014 at 4:19 PM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> This function call was being optimized out during nfs_fhget(), leading
> to situations where we have a valid fileid but still want to use the
> mounted_on_fileid.  For example, imagine we have our server configured
> like this:
>
> server % df
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/vda1       9.1G  6.5G  1.9G  78% /
> /dev/vdb1       487M  2.3M  456M   1% /exports
> /dev/vdc1       487M  2.3M  456M   1% /exports/vol1
> /dev/vdd1       487M  2.3M  456M   1% /exports/vol2
>
> If our client mounts /exports and tries to do a "chown -R" across the
> entire mountpoint, we will get a nasty message warning us about a circular
> directory structure.  Running chown with strace tells me that each directory
> has the same device and inode number:
>
> newfstatat(AT_FDCWD, "/nfs/", {st_dev=makedev(0, 38), st_ino=2, ...}) = 0
> newfstatat(4, "vol1", {st_dev=makedev(0, 38), st_ino=2, ...}) = 0
> newfstatat(4, "vol2", {st_dev=makedev(0, 38), st_ino=2, ...}) = 0

So is the problem here that these are inodes that actually represent
mountpoints? I.e. we've mounted /exports, but have not yet deferenced
/exports/vol1 and /exports/vol2, but those will be automounted if we
do something like a 'ls /exports/vol1/'?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
