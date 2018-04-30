Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33258 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755871AbeD3UQY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Apr 2018 16:16:24 -0400
Date: Mon, 30 Apr 2018 16:16:23 -0400
To: Lu Xinyu <luxy.fnst@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: SGID loss with nfsv3
Message-ID: <20180430201623.GA3207@fieldses.org>
References: <f9f2d605-b930-7db8-ad1e-fd189e074e9c@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <f9f2d605-b930-7db8-ad1e-fd189e074e9c@cn.fujitsu.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 25, 2018 at 02:03:20PM +0800, Lu Xinyu wrote:
> hi, folks
> 
> 
> I have client and server using nfsv3. The kernels are all 4.16-rc3.
> In client I mount a partition or a disk formatted in xfs/ext4 in
> /nfstest. It seems there is someting wrong with inheritance of sgid. I
> try the following operations in the client.
> > [root@localhost ]#id user1
> > uid=1003(user1) gid=1006(testgroup1)
> groups=1006(testgroup1),1007(testgroup2)
> > [root@localhost ]# mount -t nfs -o vers=3 -o noac
> 192.168.56.9:/data/nfstest /mnt/test/
> > [root@localhost ]# cd /mnt/test/
> > [root@localhost ]# mkdir mainsub
> > [root@localhost ]# setfacl -d -m u:user2:rwx mainsub/
> > [root@localhost ]# chown user1:testgroup1 mainsub/
> >                  # chmod 2775 mainsub/
> > [root@localhost ]# runuser -u user1 -g testgroup1 mkdir mainsub/subdir1
> > [root@localhost ]# runuser -u user1 -g testgroup2 mkdir mainsub/subdir2
> > [root@localhost ]# ls -l mainsub/
> > drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:50 subdir1
> > drwxrwxr-x+ 2 user1 testgroup1 4096 Mar  6 22:50 subdir2
> 
> 
> The subdir2 losts SGID. But if the same operations are applied in the
> xfs or ext4 directedly, the SGID could be interited normally.
> 
> > [root@localhost ]# ls -l mainsub/
> > drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:55 subdir1
> > drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:55 subdir2
> 
> Is this a bug of NFSv3?
> 
> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=073931017b49d9458aa351605b43a7e34598caef
> 
> 
> Clear SGID bit when setting file permissions
> 
> It seems this patch will clear the nfs sgid. Should we keep it?

Just searching for that commit id.... It looks like this was fixed by
ext4 by a3bb2d5587521eea6dab2d05326abb0afb460abd "ext4: Don't clear SGID
when inheriting ACLs".  And there are similar patches for a bunch of
other filesystems.

--b.

> 
> 
> Xinyu Lu
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
