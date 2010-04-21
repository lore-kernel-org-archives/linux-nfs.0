Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:64972 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930Ab0DURJV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:09:21 -0400
In-Reply-To: <20100421204819.b86ee3f7.stealth@sourcemage.org>
References: <20100417195747.5fae8834.stealth@sourcemage.org>
	 <4BCF2A2C.7070407@maine.edu>
	 <20100421204819.b86ee3f7.stealth@sourcemage.org>
Date: Wed, 21 Apr 2010 12:09:20 -0500
Message-ID: <q2zd3da20d01004211009jccd81479v83e2ef4b6d5db7bf@mail.gmail.com>
Subject: Re: NFS and /dev/mdXpY
From: Roger Heflin <rogerheflin@gmail.com>
To: Vlad Glagolev <stealth@sourcemage.org>
Cc: Steve Cousins <steve.cousins@maine.edu>, linux-nfs@vger.kernel.org,
        linux-raid@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 21, 2010 at 11:48 AM, Vlad Glagolev <stealth@sourcemage.org> wrote:
> Thanks for reply, Steve!
>
> parameters are pretty trivial, (rw,insecure) for exports, and defaults while mounting via ``mount host:/path /path'' command.
>
> Yes. That sounds interesting, since XFS works fine with there partitions.
> Also, I must say it's WD20EARS drives (with 4kb sector size, though parted says it's 512b).
>
> I also tried another NFS daemon implementation (cvs version, not .22) -- unfsd (unfs3).
> It mounts ok, but when I try to write any file to the server -- I get the same error (Stale NFS file handle).
>
> And on the server side in dmesg I see this:
>
> --
> NFS: server 172.17.2.2 error: fileid changed
> fsid 0:f: expected fileid 0x2033, got 0xb6d1e05fa150ce09
> NFS: server 172.17.2.2 error: fileid changed
> fsid 0:f: expected fileid 0x2033, got 0x26550b0132c0b1
> NFS: server 172.17.2.2 error: fileid changed
> fsid 0:f: expected fileid 0x2033, got 0x8202a60053000020
> NFS: server 172.17.2.2 error: fileid changed
> fsid 0:f: expected fileid 0x2033, got 0xe542f93ebc8fe157
> NFS: server 172.17.2.2 error: fileid changed
> fsid 0:f: expected fileid 0x2033, got 0xc00cd74ea904301
> --
>
> looks like NFS protocol doesn't like something in partitioned software RAID.
>


Try manually setting the fsid=something in the exports file and
reexport and remount on the target system, if there was a fsid
collision of some sort then nfs would be hitting the wrong fs...

NFS generates the fsid automatically based on the devices major minor,
and it is possible there is something odd about the major minor
numbers that make them not unique...and collide with someone else
major minor.
