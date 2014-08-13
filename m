Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail2.candelatech.com ([208.74.158.173]:36428 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929AbaHMPmg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2014 11:42:36 -0400
Message-ID: <53EB876A.4090705@candelatech.com>
Date: Wed, 13 Aug 2014 08:42:34 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Killing process in D state on mount to dead NFS server.
References: <53DA8443.407@candelatech.com> <20140801064217.01852788@notabene.brown> <53DAB307.2000206@candelatech.com>
In-Reply-To: <53DAB307.2000206@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello!

Did you get a chance to look at the stacks below?

Thanks,
Ben


On 07/31/2014 02:20 PM, Ben Greear wrote:
> On 07/31/2014 01:42 PM, NeilBrown wrote:
>> On Thu, 31 Jul 2014 11:00:35 -0700 Ben Greear <greearb@candelatech.com> wrote:
> 
>>> So, this has been asked all over the interweb for years and years, but the best answer I can find is to reboot the system or create a fake NFS server 
>>> somewhere with the same IP as the gone-away NFS server.
>>> 
>>> The problem is:
>>> 
>>> I have some mounts to an NFS server that no longer exists (crashed/powered down).
>>> 
>>> I have some processes stuck trying to write to files open on these mounts.
>>> 
>>> I want to kill the process and unmount.
>>> 
>>> umount -l will make the mount go a way, sort of.  But process is still hung. umount -f complains: umount2:  Device or resource busy umount.nfs:
>>> /mnt/foo: device is busy
>>> 
>>> kill -9 does not work on process.
> 
>> Kill -1 should work (since about 2.6.25 or so).
> 
> That is -[ONE], right?  Assuming so, it did not work for me.
> 
> Kernel is 3.14.4+, with some of extra patches, but probably nothing that influences this particular behaviour.
> 
> [root@lf1005-14010010 ~]# cat /proc/3805/stack [<ffffffff811371ba>] sleep_on_page+0x9/0xd [<ffffffff8113738e>] wait_on_page_bit+0x71/0x78 
> [<ffffffff8113769a>] filemap_fdatawait_range+0xa2/0x16d [<ffffffff8113780e>] filemap_write_and_wait_range+0x3b/0x77 [<ffffffffa0f04734>]
> nfs_file_fsync+0x37/0x83 [nfs] [<ffffffff811a8d32>] vfs_fsync_range+0x19/0x1b [<ffffffff811a8d4b>] vfs_fsync+0x17/0x19 [<ffffffffa0f05305>]
> nfs_file_flush+0x6b/0x6f [nfs] [<ffffffff81183e46>] filp_close+0x3f/0x71 [<ffffffff8119c8ae>] __close_fd+0x80/0x98 [<ffffffff81183de5>]
> SyS_close+0x1c/0x3e [<ffffffff815c55f9>] system_call_fastpath+0x16/0x1b [<ffffffffffffffff>] 0xffffffffffffffff [root@lf1005-14010010 ~]# kill -1 3805 
> [root@lf1005-14010010 ~]# cat /proc/3805/stack [<ffffffff811371ba>] sleep_on_page+0x9/0xd [<ffffffff8113738e>] wait_on_page_bit+0x71/0x78 
> [<ffffffff8113769a>] filemap_fdatawait_range+0xa2/0x16d [<ffffffff8113780e>] filemap_write_and_wait_range+0x3b/0x77 [<ffffffffa0f04734>]
> nfs_file_fsync+0x37/0x83 [nfs] [<ffffffff811a8d32>] vfs_fsync_range+0x19/0x1b [<ffffffff811a8d4b>] vfs_fsync+0x17/0x19 [<ffffffffa0f05305>]
> nfs_file_flush+0x6b/0x6f [nfs] [<ffffffff81183e46>] filp_close+0x3f/0x71 [<ffffffff8119c8ae>] __close_fd+0x80/0x98 [<ffffffff81183de5>]
> SyS_close+0x1c/0x3e [<ffffffff815c55f9>] system_call_fastpath+0x16/0x1b [<ffffffffffffffff>] 0xffffffffffffffff
> 
> Thanks, Ben
> 
>> If it doesn't please report the kernel version and cat /proc/$PID/stack
> 
>> for some processes that cannot be killed.
> 
>> NeilBrown
> 
>>> 
>>> 
>>> Aside from bringing a fake NFS server back up on the same IP, is there any other way to get these mounts unmounted and the processes killed without 
>>> rebooting?
>>> 
>>> Thanks, Ben
>>> 
> 
> 
> 
> -- To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
> 

- -- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJT64dqAAoJELbHqkYeJT4OHC0IAIRB2A8v5msRhXrdd+ybvkwD
NcOSYOhSsxCHIS5BR5CNLg89zipRuocVCbdLRdtbse8nspMq8PAiQJt3YOkGwzos
ifcsgxouMUKfmLcFHtJ0maIkWMPIrttPvHJuw67gt7LbHLPsFjlrdrKPv6aGa95m
7mCkY/bRniiJYCxrCqixzQpuWfIyVal6FPGtmpydTVh6lq0y05vDEVB8lP5xGyes
w+I/vJkGf9ddTIDasYJbLwUXECbN3makJxmHNAZf4slQMB5FNNnpeTOqL17u62cY
F/do8m/zxzztibTZqjKHIhHGDw/huTyQWfRsQ0AA9Exu8/RZKhJlL2EeYlFJWJQ=
=hNGY
-----END PGP SIGNATURE-----
