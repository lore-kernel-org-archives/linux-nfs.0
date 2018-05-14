Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:4475 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751626AbeENGnD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 May 2018 02:43:03 -0400
Subject: Re: SGID loss with nfsv3
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <f9f2d605-b930-7db8-ad1e-fd189e074e9c@cn.fujitsu.com>
 <20180430201623.GA3207@fieldses.org>
From: Lu Xinyu <luxy.fnst@cn.fujitsu.com>
CC: <linux-nfs@vger.kernel.org>
Message-ID: <060c9d41-8772-80e1-e938-21ec7b6315ef@cn.fujitsu.com>
Date: Mon, 14 May 2018 14:43:49 +0800
MIME-Version: 1.0
In-Reply-To: <20180430201623.GA3207@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,Bruce

On 20180501 04:16, J. Bruce Fields wrote:
> On Wed, Apr 25, 2018 at 02:03:20PM +0800, Lu Xinyu wrote:
>> hi, folks
>>
>>
>> I have client and server using nfsv3. The kernels are all 4.16-rc3.
>> In client I mount a partition or a disk formatted in xfs/ext4 in
>> /nfstest. It seems there is someting wrong with inheritance of sgid. I
>> try the following operations in the client.
>>> [root@localhost ]#id user1
>>> uid=1003(user1) gid=1006(testgroup1)
>> groups=1006(testgroup1),1007(testgroup2)
>>> [root@localhost ]# mount -t nfs -o vers=3 -o noac
>> 192.168.56.9:/data/nfstest /mnt/test/
>>> [root@localhost ]# cd /mnt/test/
>>> [root@localhost ]# mkdir mainsub
>>> [root@localhost ]# setfacl -d -m u:user2:rwx mainsub/
>>> [root@localhost ]# chown user1:testgroup1 mainsub/
>>>                  # chmod 2775 mainsub/
>>> [root@localhost ]# runuser -u user1 -g testgroup1 mkdir mainsub/subdir1
>>> [root@localhost ]# runuser -u user1 -g testgroup2 mkdir mainsub/subdir2
>>> [root@localhost ]# ls -l mainsub/
>>> drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:50 subdir1
>>> drwxrwxr-x+ 2 user1 testgroup1 4096 Mar  6 22:50 subdir2
>>
>>
>> The subdir2 losts SGID. But if the same operations are applied in the
>> xfs or ext4 directedly, the SGID could be interited normally.
>>
>>> [root@localhost ]# ls -l mainsub/
>>> drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:55 subdir1
>>> drwxrwsr-x+ 2 user1 testgroup1 4096 Mar  6 22:55 subdir2
>>
>> Is this a bug of NFSv3?
>>
>>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=073931017b49d9458aa351605b43a7e34598caef
>>
>>
>> Clear SGID bit when setting file permissions
>>
>> It seems this patch will clear the nfs sgid. Should we keep it?
> 
> Just searching for that commit id.... It looks like this was fixed by
> ext4 by a3bb2d5587521eea6dab2d05326abb0afb460abd "ext4: Don't clear SGID
> when inheriting ACLs".  And there are similar patches for a bunch of
> other filesystems.
> 
> --b.
> 
Thanks for reply.
The SGID will not be cleared on the xfs. However, when it mounts a nfs
the SGID will get lost. I think it is a NFS bug.


Xinyu Lu


