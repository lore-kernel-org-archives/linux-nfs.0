From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: nfsd stuckage
Date: Thu, 08 Jan 2009 15:57:30 +0100
Message-ID: <1231426650.11687.459.camel@twins>
References: <20090106145612.d4d9948d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Christoph Hellwig <hch@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34880 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbZAHO5g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2009 09:57:36 -0500
In-Reply-To: <20090106145612.d4d9948d.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-06 at 14:56 -0800, Andrew Morton wrote:
> I just built current mainline plus the just-sent 266 -mm patches.
> 
> The machine failed to power off when hit with `halt -pfn'.  dmesg output:

> [  672.162677] INFO: task nfsd4:4324 blocked for more than 480 seconds.
> [  672.162706] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [  672.162725]  ffff880251df1d60 0000000000000046 ffff88025e1c0580 ffff8802488013d8
> [  672.162753]  ffff880251df1d20 ffff88024c49a7a0 ffff88025e088760 ffff88024c49ab18
> [  672.162834]  000000002807ee00 00000000ffff59ec ffff880251df1d50 0000000000000282
> [  672.162865] Call Trace:
> [  672.162880]  [<ffffffff8052a1d8>] __mutex_lock_slowpath+0x6a/0xac
> [  672.162895]  [<ffffffff8052a0c5>] mutex_lock+0x2c/0x30
> [  672.162908]  [<ffffffff802c4747>] vfs_fsync+0x63/0xa9
> [  672.162933]  [<ffffffffa048c74c>] nfsd_sync_dir+0x10/0x12 [nfsd]
> [  672.162960]  [<ffffffffa04a5427>] nfsd4_sync_rec_dir+0x27/0x40 [nfsd]
> [  672.162984]  [<ffffffffa04a592a>] nfsd4_recdir_purge_old+0x3d/0x6a [nfsd]
> [  672.163023]  [<ffffffffa04a1745>] laundromat_main+0x62/0x225 [nfsd]
> [  672.163049]  [<ffffffffa04a16e3>] ? laundromat_main+0x0/0x225 [nfsd]
> [  672.163064]  [<ffffffff8024b4a7>] run_workqueue+0x8d/0x124
> [  672.163076]  [<ffffffff8024b5e0>] ? worker_thread+0x0/0xe5
> [  672.163089]  [<ffffffff8024b6b8>] worker_thread+0xd8/0xe5
> [  672.163102]  [<ffffffff8024e8cc>] ? autoremove_wake_function+0x0/0x36
> [  672.163115]  [<ffffffff8024b5e0>] ? worker_thread+0x0/0xe5
> [  672.163127]  [<ffffffff8024e5e0>] kthread+0x44/0x6b
> [  672.163140]  [<ffffffff8020cfba>] child_rip+0xa/0x20
> [  672.163151]  [<ffffffff8024e59c>] ? kthread+0x0/0x6b
> [  672.163162]  [<ffffffff8020cfb0>] ? child_rip+0x0/0x20

FWIW lockdep seems to warn about this...

All I have to do to trigger this is boot the machine and let it sit for
a few minutes.

[  113.552497] =============================================
[  113.553289] [ INFO: possible recursive locking detected ]
[  113.553289] 2.6.28-tip #592                              
[  113.553289] ---------------------------------------------
[  113.553289] nfsd4/1914 is trying to acquire lock:        
[  113.553289]  (&type->i_mutex_dir_key#4){--..}, at: [<ffffffff802e7e5e>] vfs_fsync+0x6c/0xb1
[  113.553289]                                                                                
[  113.553289] but task is already holding lock:                                              
[  113.553289]  (&type->i_mutex_dir_key#4){--..}, at: [<ffffffffa0190727>] nfsd4_sync_rec_dir+0x22/0x47 [nfsd]                                                                                                        
[  113.553289]                                                                                             
[  113.553289] other info that might help us debug this:                                                   
[  113.553289] 4 locks held by nfsd4/1914:                                                                 
[  113.553289]  #0:  (nfsd4){--..}, at: [<ffffffff80252303>] run_workqueue+0xb6/0x21b                      
[  113.553289]  #1:  ((laundromat_work).work){--..}, at: [<ffffffff80252303>] run_workqueue+0xb6/0x21b     
[  113.553289]  #2:  (client_mutex){--..}, at: [<ffffffffa018bd05>] laundromat_main+0x33/0x24e [nfsd]      
[  113.553289]  #3:  (&type->i_mutex_dir_key#4){--..}, at: [<ffffffffa0190727>] nfsd4_sync_rec_dir+0x22/0x47 [nfsd]                                                                                                   
[  113.553289]                                                                                             
[  113.553289] stack backtrace:                                                                            
[  113.553289] Pid: 1914, comm: nfsd4 Not tainted 2.6.28-tip #592                                          
[  113.553289] Call Trace:                                                                                 
[  113.553289]  [<ffffffff80266987>] __lock_acquire+0xe42/0x161a                                           
[  113.553289]  [<ffffffff80288857>] ? __call_rcu+0x7a/0x107                                               
[  113.553289]  [<ffffffff802671b4>] lock_acquire+0x55/0x71                                                
[  113.553289]  [<ffffffff802e7e5e>] ? vfs_fsync+0x6c/0xb1                                                 
[  113.553289]  [<ffffffff805568d0>] mutex_lock_nested+0x4e/0x320                                          
[  113.553289]  [<ffffffff802e7e5e>] ? vfs_fsync+0x6c/0xb1                                                 
[  113.553289]  [<ffffffff8029bde0>] ? __filemap_fdatawrite_range+0x57/0x5f                                
[  113.553289]  [<ffffffff802e7e5e>] vfs_fsync+0x6c/0xb1                                                   
[  113.553289]  [<ffffffffa0176f8f>] nfsd_sync_dir+0x15/0x17 [nfsd]                                        
[  113.553289]  [<ffffffffa0190733>] nfsd4_sync_rec_dir+0x2e/0x47 [nfsd]                                   
[  113.553289]  [<ffffffffa0190791>] nfsd4_recdir_purge_old+0x45/0x73 [nfsd]                               
[  113.553289]  [<ffffffffa018bd44>] laundromat_main+0x72/0x24e [nfsd]                                     
[  113.553289]  [<ffffffff80252355>] run_workqueue+0x108/0x21b                                             
[  113.553289]  [<ffffffff80252303>] ? run_workqueue+0xb6/0x21b                                            
[  113.553289]  [<ffffffffa018bcd2>] ? laundromat_main+0x0/0x24e [nfsd]                                    
[  113.553289]  [<ffffffff8025254d>] worker_thread+0xe5/0xf6                                               
[  113.553289]  [<ffffffff80256615>] ? autoremove_wake_function+0x0/0x3d                                   
[  113.553289]  [<ffffffff80252468>] ? worker_thread+0x0/0xf6                                              
[  113.553289]  [<ffffffff80256200>] kthread+0x4e/0x7b                                                     
[  113.553289]  [<ffffffff8020d51a>] child_rip+0xa/0x20                                                    
[  113.553289]  [<ffffffff8020cec0>] ? restore_args+0x0/0x30                                               
[  113.553289]  [<ffffffff802561b2>] ? kthread+0x0/0x7b                                                    
[  113.553289]  [<ffffffff8020d510>] ? child_rip+0x0/0x20 


