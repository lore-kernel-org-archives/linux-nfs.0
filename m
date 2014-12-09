Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f182.google.com ([209.85.160.182]:64707 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753793AbaLIW5z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Dec 2014 17:57:55 -0500
Received: by mail-yk0-f182.google.com with SMTP id 131so724967ykp.13
        for <linux-nfs@vger.kernel.org>; Tue, 09 Dec 2014 14:57:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSvofjOr2spSJZLMtjLgQt-BvOdxsewC8q-tVgvvRMGmQ@mail.gmail.com>
References: <1418159956-10853-1-git-send-email-Anna.Schumaker@Netapp.com> <CAHQdGtSvofjOr2spSJZLMtjLgQt-BvOdxsewC8q-tVgvvRMGmQ@mail.gmail.com>
From: Anna Schumaker <anna.schumaker@netapp.com>
Date: Tue, 9 Dec 2014 17:57:34 -0500
Message-ID: <CAFX2JfkL20odHMQBLA4q09ds6fjJmDE-EU9PEvOAHy2tbySW7A@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix use of nfs_attr_use_mounted_on_fileid()
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 9, 2014 at 5:01 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>
> On Tue, Dec 9, 2014 at 4:19 PM, Anna Schumaker
> <Anna.Schumaker@netapp.com> wrote:
> > This function call was being optimized out during nfs_fhget(), leading
> > to situations where we have a valid fileid but still want to use the
> > mounted_on_fileid.  For example, imagine we have our server configured
> > like this:
> >
> > server % df
> > Filesystem      Size  Used Avail Use% Mounted on
> > /dev/vda1       9.1G  6.5G  1.9G  78% /
> > /dev/vdb1       487M  2.3M  456M   1% /exports
> > /dev/vdc1       487M  2.3M  456M   1% /exports/vol1
> > /dev/vdd1       487M  2.3M  456M   1% /exports/vol2
> >
> > If our client mounts /exports and tries to do a "chown -R" across the
> > entire mountpoint, we will get a nasty message warning us about a circular
> > directory structure.  Running chown with strace tells me that each directory
> > has the same device and inode number:
> >
> > newfstatat(AT_FDCWD, "/nfs/", {st_dev=makedev(0, 38), st_ino=2, ...}) = 0
> > newfstatat(4, "vol1", {st_dev=makedev(0, 38), st_ino=2, ...}) = 0
> > newfstatat(4, "vol2", {st_dev=makedev(0, 38), st_ino=2, ...}) = 0
>
> So is the problem here that these are inodes that actually represent
> mountpoints? I.e. we've mounted /exports, but have not yet deferenced
> /exports/vol1 and /exports/vol2, but those will be automounted if we
> do something like a 'ls /exports/vol1/'?

Yes, the chown will work after automounting each directory.

Anna
>
>
> --
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
