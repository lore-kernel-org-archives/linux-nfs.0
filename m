Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f175.google.com ([209.85.213.175]:33609 "EHLO
        mail-yb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751903AbeC1N5K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2018 09:57:10 -0400
MIME-Version: 1.0
In-Reply-To: <1522235739.18706.13.camel@kernel.org>
References: <20180327182450.38D9.733CD922@clustertech.com> <CAOQ4uxgtD1F_S_tGoAKo7egqbXRGa-sM6SL-Ab7K62LN0FYBSA@mail.gmail.com>
 <20180328091413.38DF.733CD922@clustertech.com> <CAOQ4uxgZd7qC2xW3pYNYKqrpVJYBDRovyeAkeySWLjM4+WhGxw@mail.gmail.com>
 <1522235739.18706.13.camel@kernel.org>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 28 Mar 2018 16:57:08 +0300
Message-ID: <CAOQ4uxia00m5+=0RmZzMWFLpsW+iyZ3TnNU64QObG4XGYBVNQQ@mail.gmail.com>
Subject: Re: client side see wrong directory entries with nfs_export on overlayfs
To: Jeff Layton <jlayton@kernel.org>
Cc: Dai Qizhi <qzdai@clustertech.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2018 at 2:15 PM, Jeff Layton <jlayton@kernel.org> wrote:
> On Wed, 2018-03-28 at 07:45 +0300, Amir Goldstein wrote:
>> On Wed, Mar 28, 2018 at 4:14 AM, Dai Qizhi <qzdai@clustertech.com>
>> wrote:
>> [...]
>> > >
>> > > > I tested overlayfs with nfs_export feature , the kernel is
>> > > > built by
>> > > > ubuntu , 4.16.0-041600rc7, http://kernel.ubuntu.com/~kernel-ppa
>> > > > /mainline/v4.16-rc7/
>> > > >
>> > > > the problem is , when i export two different overlay mount
>> > > > points on
>> > > > server side, then mount them use nfs on the client side, the
>> > > > client side
>> > > > views the two differnet mount points as the same.
>> > > >
>> > > >
>> > > > on server side:
>> > > >
>> > > > none on /mnt/m1 type overlay
>> > > > (rw,relatime,lowerdir=m1/ro,upperdir=m1/rw,workdir=
>> > > > m1/w,index=on,nfs_export=on)
>> > > > none on /mnt/m2 type overlay
>> > > > (rw,relatime,lowerdir=m2/ro,upperdir=m2/rw,workdir=
>> > > > m2/w,index=on,nfs_export=on)
>> > > > [root@localhost data]# exportfs -rv
>> > > > exporting *:/mnt/m4
>> > > > exporting *:/mnt/m3
>> > > > exporting *:/mnt/m2
>> > > > exporting *:/mnt/m1
>> > > > [root@localhost data]# ls /mnt/m1
>> > > > this_is_m1
>> > > > [root@localhost data]# ls /mnt/m2
>> > > > this_is_m2
>> > > >
>> > > >
>> > > > on client side:
>> > > >
>> > > > [root@localhost mnt]# mount 192.168.0.1:/mnt/m1 m1
>> > > > [root@localhost mnt]# mount 192.168.0.1:/mnt/m2 m2
>> > > > [root@localhost mnt]# mount |grep 192
>> > > > 192.168.0.1:/mnt/m1 on /mnt/m1 type nfs
>> > > > (rw,relatime,vers=3,rsize=524288,wsize=5
>> > > > 24288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mou
>> > > > ntaddr=192.168.0.
>> > > > 1,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,ad
>> > > > dr=192.168.0.1)
>> > > > 192.168.0.1:/mnt/m1 on /mnt/m2 type nfs
>> > > > (rw,relatime,vers=3,rsize=524288,wsize=5
>> > > > 24288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mou
>> > > > ntaddr=192.168.0.
>> > > > 1,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,ad
>> > > > dr=192.168.0.1)
>> > > >
>> > > > [root@localhost mnt]# ls /mnt/m1
>> > > > this_is_m1
>> > > > [root@localhost mnt]# ls /mnt/m2
>> > > > this_is_m1
>> > > > [root@localhost mnt]#
>> > >
>> > >
>> > > Please refer to the man page of exports(5), the section about
>> > > 'fsid' describes
>> > > this problem related to exporting file systems that are not on a
>> > > block device,
>> > > such as overlayfs.
>> >
>> > yes, export different mount point with different fsid= option works
>> > as
>> > expected.
>> >
>> >
>> > >
>> > > If you are interested to know if there is a way to fix this that
>> > > does
>> > > not involve manually
>> > > configuring different fsid per export, I will have to consult
>> > > with the
>> > > NFS experts, so please
>> > > reply to this message with CC to <linux-unionfs@vger.kernel.org>
>> > > and
>> > > <linux-nfs@vger.kernel.org>
>> >
>> > when exporting parent directory with crossmnt option and mount
>> > differnet overlayfs
>> > under that directory, we encounter the same problem on client
>> > side..
>> >
>>
>> I see. Jeff, Bruce, is there a school book solution to this issue?
>>
>> Is there a way for a non blockdev export to automatically identify
>> itself
>> to knfsd? After all, the tuple ("overlayfs";<overlay root file
>> handle>) should
>> be unique on the server. <overlay root file handle> contains (struct
>> ovl_fh)
>> the upper fs UUID and the upper root dir file handle.
>>
>> Technically, if there is no out of tree fs on the system that is
>> using the
>> value OVL_FILEID  (0xfb) for file handle type <overlay root file
>> handle>
>> itself would be unique.
>>
>> Thanks,
>> Amir.
>
> tl;dr: not currently, which is why when I did the reexport patches a
> few years ago, they _required_ that you manually set the fsid= export
> option.
>
> Longer story:
>
> Long, long ago, the fsid for the export was almost always determined by
> the device major/minor tuple. That became really problematic whenever
> devices got reordered after adding a disk to the system and rebooting.
> So, Neil Brown added the ability to determine the fsid from the
> libblkdev uuid (see nfs-utils commit e91ff0175602c, and kernel commits
> from around that time).
>
> In principle, you could do something similar for overlayfs: add a new
> FSID_* type for overlayfs that can reliably determine a unique fsid for
> different overlays. That would require kernel and userland patches, of
> course...
>

That's good to know, but I guess I won't be doing any of that anytime soon.
Thanks!
Amir.
