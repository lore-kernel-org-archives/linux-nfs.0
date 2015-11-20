Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mondschein.lichtvoll.de ([194.150.191.11]:60301 "EHLO
	mail.lichtvoll.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759269AbbKTQZO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Nov 2015 11:25:14 -0500
From: Martin Steigerwald <martin@lichtvoll.de>
To: David Howells <dhowells@redhat.com>
Cc: arnd@arndb.de, linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [RFC][PATCH 00/12] Enhanced file stat system call
Date: Fri, 20 Nov 2015 17:19:31 +0100
Message-ID: <1502878.QisWlqATFu@merkaba>
In-Reply-To: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Freitag, 20. November 2015, 14:54:22 CET schrieb David Howells:
> The seventh patch provides another new system call:
> 
>         long ret = fsinfo(int dfd,
>                           const char *filename,
>                           unsigned atflag,
>                           unsigned request,
>                           void *buffer);
> 
> This is an enhanced filesystem stat and information retrieval function that
> provides more information, in summary:
> 
>  (1) All the information provided by statfs() and more.  The fields are
>      made large.
> 
>  (2) Provides information about timestamp range and resolution to
>      complement statx().
> 
>  (3) Provides information about IOC flags supported in statx()'s return.
> 
>  (4) Provides volume binary IDs and UUIDs.
> 
>  (5) Provides the filesystem name according to the kernel as a string
>      (eg. "ext4" or "nfs3") in addition to the magic number.
> 
>  (6) Provides information obtained from network filesystems, such as volume
>      and domain names.
> 
>  (7) Has lots of spare space that can be used for future extenstions and a
>      bit mask indicating what was provided.

Any plans to add limitations of filesystem to the call like maximum file size? 
I know its mostly relevant for just for FAT32, but on any account rather than 
trying to write 4 GiB and then file, it would be good to at some time get a 
dialog at the beginning of the copy.

Well, but okay, maybe its use case is too limited as FAT32 is not an in any 
kind modern filesystem anymore and limits of modern filesystems are much 
higher.

But other limits like maximum amount of extended attributes, maximum amount of 
acls or symlinks on one directory may be nice to query. Symlinks for BTRFS 
without extended symlink support and acls maybe for XFS, I remember there at 
least has been a limit at some time that was quite low.

Thanks,
-- 
Martin
