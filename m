Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33674 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752021AbeEOUlr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 May 2018 16:41:47 -0400
Date: Tue, 15 May 2018 16:41:47 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Lu Xinyu <luxy.fnst@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org, fnst-xmlinux@cn.fujitsu.com,
        agreunba@redhat.com
Subject: Re: SGID loss with nfsv3
Message-ID: <20180515204147.GA8178@fieldses.org>
References: <f9f2d605-b930-7db8-ad1e-fd189e074e9c@cn.fujitsu.com>
 <20180430201623.GA3207@fieldses.org>
 <060c9d41-8772-80e1-e938-21ec7b6315ef@cn.fujitsu.com>
 <20180514143222.GA7160@fieldses.org>
 <5b6540f4-f744-5e51-c32f-c8809fbfed81@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5b6540f4-f744-5e51-c32f-c8809fbfed81@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looking at the problem more closely....

So the desired behavior is that the SGID bit gets cleared on an explicit
set of the acl, but not when the acl is merely inherited as part of file
creation?

If I understand correctly, in the NFSv3 case default acl inheritance is
done manually by the client, which queries the default acl, calculates
the inherited acl itself, and applies the result to the new file using a
setacl call to the server.

The server isn't capable of distinguishing this setacl call from any
other setacl call, so can't know that it should skip clearing the SGID
bit.

Andreas, do I have that right?  Is this fixable?

--b.

On Tue, May 15, 2018 at 09:56:13AM +0800, Lu Xinyu wrote:
> On 20180514 22:32, J. Bruce Fields wrote:
> > On Mon, May 14, 2018 at 02:43:49PM +0800, Lu Xinyu wrote:
> >> Hi,Bruce
> >>
> >> On 20180501 04:16, J. Bruce Fields wrote:
> >>> On Wed, Apr 25, 2018 at 02:03:20PM +0800, Lu Xinyu wrote:
> >>>> hi, folks
> >>>>
> >>>>
> >>>> I have client and server using nfsv3. The kernels are all 4.16-rc3.
> >>>> In client I mount a partition or a disk formatted in xfs/ext4 in
> >>>> /nfstest. It seems there is someting wrong with inheritance of sgid. I
> >>>> try the following operations in the client.
> >>>>> [root@localhost ]#id user1
> >>>>> uid=1003(user1) gid=1006(testgroup1)
> >>>> groups=1006(testgroup1),1007(testgroup2)
> >>>>> [root@localhost ]# mount -t nfs -o vers=3 -o noac
> >>>> 192.168.56.9:/data/nfstest /mnt/test/
> >>>>> [root@localhost ]# cd /mnt/test/
> >>>>> [root@localhost ]# mkdir mainsub
> >>>>> [root@localhost ]# setfacl -d -m u:user2:rwx mainsub/
> >>>>> [root@localhost ]# chown user1:testgroup1 mainsub/
> >>>>>                  # chmod 2775 mainsub/
> >>>>> [root@localhost ]# runuser -u user1 -g testgroup1 mkdir mainsub/subdir1
> >>>>> [root@localhost ]# runuser -u user1 -g testgroup2 mkdir mainsub/subdir2
> >>>>> [root@localhost ]# ls -l mainsub/
> >>>>> drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:50 subdir1
> >>>>> drwxrwxr-x+ 2 user1 testgroup1 4096 Mar  6 22:50 subdir2
> >>>>
> >>>>
> >>>> The subdir2 losts SGID. But if the same operations are applied in the
> >>>> xfs or ext4 directedly, the SGID could be interited normally.
> >>>>
> >>>>> [root@localhost ]# ls -l mainsub/
> >>>>> drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:55 subdir1
> >>>>> drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:55 subdir2
> >>>>
> >>>> Is this a bug of NFSv3?
> >>>>
> >>>>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=073931017b49d9458aa351605b43a7e34598caef
> >>>>
> >>>>
> >>>> Clear SGID bit when setting file permissions
> >>>>
> >>>> It seems this patch will clear the nfs sgid. Should we keep it?
> >>>
> >>> Just searching for that commit id.... It looks like this was fixed by
> >>> ext4 by a3bb2d5587521eea6dab2d05326abb0afb460abd "ext4: Don't clear SGID
> >>> when inheriting ACLs".  And there are similar patches for a bunch of
> >>> other filesystems.
> >>>
> >>> --b.
> >>>
> >> Thanks for reply.
> >> The SGID will not be cleared on the xfs. However, when it mounts a nfs
> >> the SGID will get lost. I think it is a NFS bug.
> > 
> > Also, I should have noticed that the fixes I mentioned are already in
> > the kernel you're testing.
> > 
> > Maybe nfs or knfsd needed a corresponding fix.  I can't remember if you
> > posted a network trace--that would help assign blame to the client or
> > the server side.
> 
> > 1031	86.468126816	192.168.56.2	192.168.56.4	NFS	222	V3 MKDIR Call (Reply In 1032), DH: 0x7918716d/subdir2
> > 1032	86.468825412	192.168.56.4	192.168.56.2	NFS	330	V3 MKDIR Reply (Call In 1031)
> > 1033	86.469002409	192.168.56.2	192.168.56.4	NFS	182	V3 GETATTR Call (Reply In 1034), FH: 0x7918716d
> > 1034	86.469185213	192.168.56.4	192.168.56.2	NFS	182	V3 GETATTR Reply (Call In 1033)  Directory mode: 2775 uid: 1001 gid: 1002
> > 1035	86.469267903	192.168.56.2	192.168.56.4	NFSACL	186	V3 GETACL Call (Reply In 1036)
> > 1036	86.469520107	192.168.56.4	192.168.56.2	NFSACL	314	V3 GETACL Reply (Call In 1035)
> attr  Directory mode: 2775 uid: 1001 gid: 1002
> > 1037	86.469584940	192.168.56.2	192.168.56.4	NFSACL	322	V3 SETACL Call (Reply In 1038)
> > 1038	86.469837540	192.168.56.4	192.168.56.2	NFSACL	186	V3 SETACL Reply (Call In 1037)
> attr  Directory mode: 0775 uid: 1001 gid: 1002
> The SGID gets lost here. It occurs on server side.
