From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: fix memory leak in nfs_get_sb with CONFIG_NFS_V4
Date: Fri, 23 Apr 2010 11:24:31 -0400
Message-ID: <4BD1BBAF.6040608@oracle.com>
References: <1271933777-26244-1-git-send-email-dfeng@redhat.com> <4BD074D2.8070300@oracle.com> <4BD10603.7060404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Andy Adamson <andros@netapp.com>
To: Xiaotian Feng <dfeng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:18221 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754834Ab0DWP0Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Apr 2010 11:26:24 -0400
In-Reply-To: <4BD10603.7060404@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/22/2010 10:29 PM, Xiaotian Feng wrote:
> On 04/23/2010 12:09 AM, Chuck Lever wrote:
>> On 04/22/2010 06:56 AM, Xiaotian Feng wrote:
>>> With CONFIG_NFS_V4 and data version 4, nfs_get_sb will allocate
>>> memory for
>>> export_path in nfs4_validate_text_mount_data, so we need to free it
>>> then.
>>> This is addressed in following kmemleak report:
>>>
>>> unreferenced object 0xffff88016bf48a50 (size 16):
>>> comm "mount.nfs", pid 22567, jiffies 4651574704 (age 175471.200s)
>>> hex dump (first 16 bytes):
>>> 2f 6f 70 74 2f 77 6f 72 6b 00 6b 6b 6b 6b 6b a5 /opt/work.kkkkk.
>>> backtrace:
>>> [<ffffffff814b34f9>] kmemleak_alloc+0x60/0xa7
>>> [<ffffffff81102c76>] kmemleak_alloc_recursive.clone.5+0x1b/0x1d
>>> [<ffffffff811046b3>] __kmalloc_track_caller+0x18f/0x1b7
>>> [<ffffffff810e1b08>] kstrndup+0x37/0x54
>>> [<ffffffffa0336971>] nfs_parse_devname+0x152/0x204 [nfs]
>>> [<ffffffffa0336af3>] nfs4_validate_text_mount_data+0xd0/0xdc [nfs]
>>> [<ffffffffa0338deb>] nfs_get_sb+0x325/0x736 [nfs]
>>> [<ffffffff81113671>] vfs_kern_mount+0xbd/0x17c
>>> [<ffffffff81113798>] do_kern_mount+0x4d/0xed
>>> [<ffffffff81129a87>] do_mount+0x787/0x7fe
>>> [<ffffffff81129b86>] sys_mount+0x88/0xc2
>>> [<ffffffff81009b42>] system_call_fastpath+0x16/0x1b
>>>
>>> Signed-off-by: Xiaotian Feng<dfeng@redhat.com>
>>> Cc: Trond Myklebust<Trond.Myklebust@netapp.com>
>>> Cc: Chuck Lever<chuck.lever@oracle.com>
>>> Cc: Benny Halevy<bhalevy@panasas.com>
>>> Cc: Al Viro<viro@ZenIV.linux.org.uk>
>>> Cc: Andy Adamson<andros@netapp.com>
>>> ---
>>> fs/nfs/super.c | 1 +
>>> 1 files changed, 1 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index e016372..44e6567 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -2187,6 +2187,7 @@ static int nfs_get_sb(struct file_system_type
>>> *fs_type,
>>> if (data->version == 4) {
>>> error = nfs4_try_mount(flags, dev_name, data, mnt);
>>> kfree(data->client_address);
>>> + kfree(data->nfs_server.export_path);
>>
>> nfs4_try_mount's other call site in fs/nfs/super.c also frees
>> data->nfs_server.hostname and data->fscache_uniq. Does that need to
>> happen here too?
>
> I don't think we need to free data->nfs_server.hostname and
> data->fscache_uniq, they were freed in the out label ;-)

Oy.  Eventually, the NFSv2/3 and NFSv4 mount paths need to be made 
simpler and more consistent with each other.

Since there can be potentially many dynamically allocated strings 
hanging off of "data," it might be cleaner and safer to create a partner 
for nfs_alloc_parsed_mount_data() that properly manages the deallocation 
of the parsed mount data.  Both nfs_get_sb() and nfs4_get_sb() can use that.

>>
>>> goto out;
>>> }
>
> out:
> kfree(data->nfs_server.hostname);
> kfree(data->mount_server.hostname);
> kfree(data->fscache_uniq);
> security_free_mnt_opts(&data->lsm_opts);
>>> #endif /* CONFIG_NFS_V4 */
>>
>>

-- 
chuck[dot]lever[at]oracle[dot]com
