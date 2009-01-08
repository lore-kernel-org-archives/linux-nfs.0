From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd stuckage
Date: Thu, 8 Jan 2009 11:05:33 -0500
Message-ID: <20090108160533.GA15690@fieldses.org>
References: <20090106145612.d4d9948d.akpm@linux-foundation.org> <1231426650.11687.459.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:55385 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752600AbZAHQFi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 11:05:38 -0500
In-Reply-To: <1231426650.11687.459.camel@twins>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2009 at 03:57:30PM +0100, Peter Zijlstra wrote:
> FWIW lockdep seems to warn about this...
> 
> All I have to do to trigger this is boot the machine and let it sit for
> a few minutes.

Linus merged a fix (9a8d248e2d2 "nfsd: fix double-locks of directory
mutex") last night.  If you still see warnings after that, let us know.

--b.

> 
> [  113.552497] =============================================
> [  113.553289] [ INFO: possible recursive locking detected ]
> [  113.553289] 2.6.28-tip #592                              
> [  113.553289] ---------------------------------------------
> [  113.553289] nfsd4/1914 is trying to acquire lock:        
> [  113.553289]  (&type->i_mutex_dir_key#4){--..}, at: [<ffffffff802e7e5e>] vfs_fsync+0x6c/0xb1
> [  113.553289]                                                                                
> [  113.553289] but task is already holding lock:                                              
> [  113.553289]  (&type->i_mutex_dir_key#4){--..}, at: [<ffffffffa0190727>] nfsd4_sync_rec_dir+0x22/0x47 [nfsd]                                                                                                        
> [  113.553289]                                                                                             
> [  113.553289] other info that might help us debug this:                                                   
> [  113.553289] 4 locks held by nfsd4/1914:                                                                 
> [  113.553289]  #0:  (nfsd4){--..}, at: [<ffffffff80252303>] run_workqueue+0xb6/0x21b                      
> [  113.553289]  #1:  ((laundromat_work).work){--..}, at: [<ffffffff80252303>] run_workqueue+0xb6/0x21b     
> [  113.553289]  #2:  (client_mutex){--..}, at: [<ffffffffa018bd05>] laundromat_main+0x33/0x24e [nfsd]      
> [  113.553289]  #3:  (&type->i_mutex_dir_key#4){--..}, at: [<ffffffffa0190727>] nfsd4_sync_rec_dir+0x22/0x47 [nfsd]                                                                                                   
> [  113.553289]                                                                                             
> [  113.553289] stack backtrace:                                                                            
> [  113.553289] Pid: 1914, comm: nfsd4 Not tainted 2.6.28-tip #592                                          
> [  113.553289] Call Trace:                                                                                 
> [  113.553289]  [<ffffffff80266987>] __lock_acquire+0xe42/0x161a                                           
> [  113.553289]  [<ffffffff80288857>] ? __call_rcu+0x7a/0x107                                               
> [  113.553289]  [<ffffffff802671b4>] lock_acquire+0x55/0x71                                                
> [  113.553289]  [<ffffffff802e7e5e>] ? vfs_fsync+0x6c/0xb1                                                 
> [  113.553289]  [<ffffffff805568d0>] mutex_lock_nested+0x4e/0x320                                          
> [  113.553289]  [<ffffffff802e7e5e>] ? vfs_fsync+0x6c/0xb1                                                 
> [  113.553289]  [<ffffffff8029bde0>] ? __filemap_fdatawrite_range+0x57/0x5f                                
> [  113.553289]  [<ffffffff802e7e5e>] vfs_fsync+0x6c/0xb1                                                   
> [  113.553289]  [<ffffffffa0176f8f>] nfsd_sync_dir+0x15/0x17 [nfsd]                                        
> [  113.553289]  [<ffffffffa0190733>] nfsd4_sync_rec_dir+0x2e/0x47 [nfsd]                                   
> [  113.553289]  [<ffffffffa0190791>] nfsd4_recdir_purge_old+0x45/0x73 [nfsd]                               
> [  113.553289]  [<ffffffffa018bd44>] laundromat_main+0x72/0x24e [nfsd]                                     
> [  113.553289]  [<ffffffff80252355>] run_workqueue+0x108/0x21b                                             
> [  113.553289]  [<ffffffff80252303>] ? run_workqueue+0xb6/0x21b                                            
> [  113.553289]  [<ffffffffa018bcd2>] ? laundromat_main+0x0/0x24e [nfsd]                                    
> [  113.553289]  [<ffffffff8025254d>] worker_thread+0xe5/0xf6                                               
> [  113.553289]  [<ffffffff80256615>] ? autoremove_wake_function+0x0/0x3d                                   
> [  113.553289]  [<ffffffff80252468>] ? worker_thread+0x0/0xf6                                              
> [  113.553289]  [<ffffffff80256200>] kthread+0x4e/0x7b                                                     
> [  113.553289]  [<ffffffff8020d51a>] child_rip+0xa/0x20                                                    
> [  113.553289]  [<ffffffff8020cec0>] ? restore_args+0x0/0x30                                               
> [  113.553289]  [<ffffffff802561b2>] ? kthread+0x0/0x7b                                                    
> [  113.553289]  [<ffffffff8020d510>] ? child_rip+0x0/0x20 
> 
> 
