Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:63047 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044AbaDGXHj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2014 19:07:39 -0400
Received: by mail-ig0-f175.google.com with SMTP id ur14so4348574igb.14
        for <linux-nfs@vger.kernel.org>; Mon, 07 Apr 2014 16:07:38 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: NFS deadlock between 'sync' and commit after unmount....
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140407223541.GB1125@quack.suse.cz>
Date: Mon, 7 Apr 2014 19:07:35 -0400
Cc: Brown Neil <neilb@suse.de>, Viro Alexander <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>
Message-Id: <6664F8BA-1598-467A-824B-C59729B29E00@primarydata.com>
References: <20140407135001.56ef9f36@notabene.brown> <F59673DE-8047-4FE0-AFF9-6A3DC37348A5@primarydata.com> <20140407202750.GE23670@quack.suse.cz> <1396908136.5563.9.camel@leira.trondhjem.org> <20140407223541.GB1125@quack.suse.cz>
To: Jan Kara <jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 7, 2014, at 18:35, Jan Kara <jack@suse.cz> wrote:

> On Mon 07-04-14 18:02:16, Trond Myklebust wrote:
>> On Mon, 2014-04-07 at 22:27 +0200, Jan Kara wrote:
>>> On Mon 07-04-14 10:10:27, Trond Myklebust wrote:
>>>> On Apr 6, 2014, at 23:50, NeilBrown <neilb@suse.de> wrote:
>>>>> I've just hit a deadlock in NFS that seems very strange.
>>>>> The kernel is 3.14-rc8 which some local changes which shouldn't affect the
>>>>> deadlocking code.
>>>>> 
>>>>> Shortly after umounting the NFS filesystem with "umount -f" (though I don't
>>>>> think the -f is important), I ran "sync".
>>>>> 
>>>>> The sync is now stuck in
>>>>> 
>>>>> [<ffffffff81197fc1>] sync_inodes_sb+0xa1/0x1c0
>>>>> [<ffffffff8119cd99>] sync_inodes_one_sb+0x19/0x20
>>>>> [<ffffffff81173372>] iterate_supers+0xb2/0x110
>>>>> [<ffffffff8119cfd0>] sys_sync+0x30/0x90
>>>>> [<ffffffff81aa4622>] system_call_fastpath+0x16/0x1b
>>>>> [<ffffffffffffffff>] 0xffffffffffffffff
>>>>> 
>>>>> while kworker/u16:1 is stuck:
>>>>> 
>>>>> [<ffffffff815420b3>] call_rwsem_down_write_failed+0x13/0x20
>>>>> [<ffffffff81172889>] deactivate_super+0x39/0x60
>>>>> [<ffffffff812d56f1>] nfs_sb_deactive+0x21/0x30
>>>>> [<ffffffff812d2ef9>] __put_nfs_open_context+0xc9/0x100
>>>>> [<ffffffff812d2f3b>] put_nfs_open_context+0xb/0x10
>>>>> [<ffffffff812ddd14>] nfs_commitdata_release+0x14/0x30
>>>>> [<ffffffff812ddd4a>] nfs_commit_release+0x1a/0x20
>>>>> [<ffffffff81a45a05>] rpc_free_task+0x25/0x70
>>>>> [<ffffffff81a45fd8>] rpc_do_put_task+0x78/0x80
>>>>> [<ffffffff81a45feb>] rpc_put_task+0xb/0x10
>>>>> [<ffffffff812de3fe>] nfs_initiate_commit+0xce/0x110
>>>>> [<ffffffff812df112>] nfs_commit_list+0x62/0x90
>>>>> [<ffffffff812dfd26>] nfs_commit_inode+0xa6/0x170
>>>>> [<ffffffff812dfe4d>] nfs_write_inode+0x5d/0xa0
>>>>> [<ffffffff81300d69>] nfs4_write_inode+0x9/0x10
>>>>> [<ffffffff811978ec>] __writeback_single_inode+0x10c/0x2c0
>>>>> [<ffffffff811987ea>] writeback_sb_inodes+0x2ca/0x450
>>>>> [<ffffffff81198b2c>] wb_writeback+0xec/0x320
>>>>> [<ffffffff81199365>] bdi_writeback_workfn+0x115/0x4c0
>>>>> [<ffffffff810a595b>] process_one_work+0x16b/0x430
>>>>> [<ffffffff810a6619>] worker_thread+0x119/0x3a0
>>>>> [<ffffffff810ac2bd>] kthread+0xcd/0xf0
>>>>> [<ffffffff81aa457c>] ret_from_fork+0x7c/0xb0
>>>>> [<ffffffffffffffff>] 0xffffffffffffffff
>>>>> 
>>>>> 
>>>>> So sync is holding sb->s_umount, queued some bdi work on the filesystem
>>>>> and is waiting for it to complete.  Mean while, that work has (I think)
>>>>> submitted a 'commit' (via ->write_inode) and that commit wants to
>>>>> deactivate_super and so needs to get ->s_umount.
>>>>> 
>>>>> I suspect this could happen even more easily with a lazy unmount.
>>>>> 
>>>>> It seems that this commit request is that last thing that is keeping
>>>>> ->s_active elevated and it deadlocks trying to drop the last s_active.
>>>>> 
>>>>> I have no idea how to fix it....  help?
>>>>> 
>>>> 
>>>> The problem seems to be the use of iterate_supers(), which grabs a
>>>> passive reference, and conflicts with our use of an active reference in
>>>> the open context.
>>>  Yeah, we cannot really do otherwise in iterate_supers() - we have to grab
>>> some superblock reference and we don't really want to get an active one
>>> since that would result in spurious EBUSY returns from umount.
>>> 
>>> Cannot we just punt the deactivate_super() call to a workqueue to avoid
>>> this deadlock? It's a bit ugly but it should do the trick. Or is
>>> nfs_sb_deactive() called too often and we'd see some adverse effects for
>>> that? We could also offload it to workqueue only in the special case where
>>> sb->s_active == 1. That should be really rare then but it's a bit ugly
>>> poking in VFS internals.
>> 
>> The activate/deactivate super is basically there to save our bacon when
>> NFS file state extends beyond the usual VFS path walk, open() and
>> close(). Examples include sillyrename and NFSv4 delegations. Even
>> ordinary read and write state can extend beyond close() if the user
>> decides to 'kill -9' in the wrong places.
>> In most of these situations, we need to keep a dentry around until we're
>> finished, which means that we want to keep the super block alive too.
>  Yeah, that makes sense. But offloading dropping of sb reference to a
> workqueue would work then, wouldn't it?

Could we perhaps have a helper in the VFS that can optimise away the case where s->s_active > 1?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

