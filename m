Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.pictura-hosting.nl ([195.93.224.144]:38765 "EHLO
	mail.pictura-dp.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883AbaAFQUp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2014 11:20:45 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Mon, 06 Jan 2014 17:20:12 +0100
From: Sander Klein <roedie@roedie.nl>
To: Karel Zak <kzak@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org
Subject: Re: rpc.mountd high cpu usage
In-Reply-To: <20140106111805.GF4435@x2.net.home>
References: <889b64df295ba04d47f941762ebe0bac@roedie.nl>
 <20131212154642.GA11521@fieldses.org> <20140106111805.GF4435@x2.net.home>
Message-ID: <e62c2d1848074f60fbfb2fb1136d6ca6@roedie.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On 06.01.2014 12:18, Karel Zak wrote:
>> > statfs("/some/export", {f_type=0x2fc12fc1, f_bsize=131072,
>> > f_blocks=50331648, f_bfree=8355553, f_bavail=8355553,
>> > f_files=2139121087, f_ffree=2139021753, f_fsid={1912623216,
>> > 10933642}, f_namelen=255, f_frsize=131072}) = 0
>> > stat("/some/export", {st_mode=S_IFDIR|0775, st_size=15, ...}) = 0
>> > lstat("/some/export", {st_mode=S_IFDIR|0775, st_size=15, ...}) = 0
>> > lstat("/some/export/..", {st_mode=S_IFDIR|0755, st_size=12288, ...}) = 0
>> > stat("/some/export", {st_mode=S_IFDIR|0775, st_size=15, ...}) = 0
>> > open("/sys/dev/block/0:187", O_RDONLY)  = -1 ENOENT (No such file or
>> > directory)
> 
> This is blkid_devno_to_devname(), the first attempt is /sys, but it
> failed, then it tries to scan /dev (which is pretty expensive method).
> 
> BTW, what is device 0:187?
> 
> It seems like btrfs... maybe we can  optimize the code to ignore such
> devices especially when get_uuid_blkdev() filters out btrfs :-)

This machine is running ZFS On Linux with 180 multipathed disks. I 
wouldn't be amazed if ZFS and BTRFS suffer from the same problem because 
they are both volume managers and filesystems in one.

> The another problem is poorly designed relationship between 
> match_fsid()
> and uuid_by_path().  The function uuid_by_path() is called in loop and
> blkid is *always* requested, but the blkid_val is used when type==0.
> It would be better to call get_uuid_blkdev() only when type==0.
> 
> The patch below is just untested suggestion :-)

Should/Would ZFS_SUPER_MAGIC 0x2fc12fc1 be added to make this untested 
suggestion theoretically work with ZFS? I got this from the ZFS On Linux 
source code 
(https://github.com/zfsonlinux/zfs/blob/master/include/sys/zfs_vfsops.h). 
Oh, and I just noticed it is also in the f_type above :-)

Greets,

Sander


