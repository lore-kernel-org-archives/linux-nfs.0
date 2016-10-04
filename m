Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35168 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751969AbcJDPw7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Oct 2016 11:52:59 -0400
Date: Tue, 4 Oct 2016 17:52:57 +0200
From: Artem Savkov <asavkov@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Fix suspicious RCU usage in nfs_idmap_get_key.
Message-ID: <20161004155257.GB19785@shodan.usersys.redhat.com>
References: <1475588260-10838-1-git-send-email-asavkov@redhat.com>
 <7960.1475595914@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <7960.1475595914@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 04, 2016 at 04:45:14PM +0100, David Howells wrote:
> Artem Savkov <asavkov@redhat.com> wrote:
> 
> > nfs_idmap_get_key doesn't hold rkey->sem when calling user_key_payload
> > resulting in a "suspicious RCU usage" lockdep splat. It does, however hold
> > rcu_read_lock, so it either needs to use unprotected rcu_dereference, or take
> > rkey->sem instead of rcu_read_lock.
> 
> This shouldn't be using rkey->sem.  user_key_payload() should do sufficient
> RCU magic that rcu_read_lock() is sufficient.  Can you please include the RCU
> splat?  It's possible user_key_payload() is wrong.

Below is the splat I get sometimes while running nfs connectathon
testsuite:

[  711.360321] ===============================                                     
[  711.364658] [ INFO: suspicious RCU usage. ]                                     
[  711.369065] 4.8.0-9.el7.upstream.x86_64.debug #1 Not tainted                    
[  711.374930] -------------------------------                                     
[  711.379271] ./include/keys/user-type.h:53 suspicious rcu_dereference_protected() usage! 
[  711.387669]                                                                     
[  711.387669] other info that might help us debug this:                           
[  711.387669]                                                                     
[  711.396058]                                                                     
[  711.396058] rcu_scheduler_active = 1, debug_locks = 0                           
[  711.402838] 1 lock held by mount.nfs4/29135:                                    
[  711.407272]  #0:  (rcu_read_lock){......}, at: [<ffffffffa0a88558>] nfs_idmap_get_key+0xe8/0x2f0 [nfsv4] 
[  711.417187]                                                                     
[  711.417187] stack backtrace:                                                    
[  711.421712] CPU: 3 PID: 29135 Comm: mount.nfs4 Not tainted 4.8.0-9.el7.upstream.x86_64.debug #1  
[  711.430848] Hardware name: Dell Inc. PowerEdge T310/0P673K, BIOS 1.12.0 09/06/2013 
[  711.438702]  0000000000000286 000000005a15e544 ffff880800e4f4c0 ffffffff813e95cc 
[  711.446458]  ffff8807f5e70000 0000000000000001 ffff880800e4f4f0 ffffffff811023b7 
[  711.454197]  0000000000000000 ffff8808137fd040 ffff8807d1383383 ffff8808137fd040 
[  711.461920] Call Trace:                                                         
[  711.464445]  [<ffffffff813e95cc>] dump_stack+0x85/0xc9                          
[  711.469825]  [<ffffffff811023b7>] lockdep_rcu_suspicious+0xe7/0x120             
[  711.476356]  [<ffffffffa0a885ed>] nfs_idmap_get_key+0x17d/0x2f0 [nfsv4]         
[  711.483273]  [<ffffffffa0a88558>] ? nfs_idmap_get_key+0xe8/0x2f0 [nfsv4]        
[  711.490275]  [<ffffffffa0a88dfe>] nfs_map_name_to_uid+0x18e/0x2a0 [nfsv4]    
[  711.497357]  [<ffffffff810edef2>] ? pick_next_task_fair+0x1b2/0x7c0             
[  711.503917]  [<ffffffff81041399>] ? sched_clock+0x9/0x10                        
[  711.509471]  [<ffffffffa0a7e43c>] decode_getfattr_attrs+0xdcc/0x1500 [nfsv4] 
[  711.516844]  [<ffffffffa0a7ec0b>] decode_getfattr_generic.constprop.111+0x9b/0x100 [nfsv4] 
[  711.525467]  [<ffffffffa0a7f550>] ? nfs4_xdr_dec_lookup+0xc0/0xc0 [nfsv4]    
[  711.532532]  [<ffffffffa0a7f5ee>] nfs4_xdr_dec_lookup_root+0x9e/0xb0 [nfsv4] 
[  711.539987]  [<ffffffffa0486d47>] rpcauth_unwrap_resp+0xa7/0xe0 [sunrpc]        
[  711.547041]  [<ffffffffa0a7f550>] ? nfs4_xdr_dec_lookup+0xc0/0xc0 [nfsv4]    
[  711.554102]  [<ffffffffa0472f13>] call_decode+0x1f3/0x870 [sunrpc]              
[  711.560566]  [<ffffffffa0472d20>] ? call_refreshresult+0x140/0x140 [sunrpc]  
[  711.567869]  [<ffffffffa0472d20>] ? call_refreshresult+0x140/0x140 [sunrpc]  
[  711.575127]  [<ffffffffa0484ac5>] __rpc_execute+0xc5/0x6a0 [sunrpc]             
[  711.581613]  [<ffffffff810f64d5>] ? wake_up_bit+0x25/0x30                       
[  711.587269]  [<ffffffffa04853f1>] rpc_execute+0x91/0x200 [sunrpc]               
[  711.593646]  [<ffffffffa0476d49>] rpc_run_task+0x109/0x150 [sunrpc]             
[  711.600180]  [<ffffffffa0a5e393>] nfs4_call_sync_sequence+0x63/0xa0 [nfsv4]  
[  711.607478]  [<ffffffffa0a6164d>] _nfs4_lookup_root.isra.68+0xdd/0x100 [nfsv4] 
[  711.615055]  [<ffffffffa04868d6>] ? rpcauth_create+0xb6/0x110 [sunrpc]          
[  711.621870]  [<ffffffffa0a6b639>] nfs4_lookup_root+0x99/0x260 [nfsv4]           
[  711.628528]  [<ffffffffa0a6b860>] nfs4_lookup_root_sec+0x60/0x90 [nfsv4]        
[  711.635582]  [<ffffffffa0a6b8cc>] nfs4_find_root_sec+0x3c/0xb0 [nfsv4]          
[  711.642437]  [<ffffffffa0a70661>] nfs4_proc_get_rootfh+0x31/0x80 [nfsv4]        
[  711.649477]  [<ffffffffa0a8e42f>] nfs4_get_rootfh+0x5f/0x130 [nfsv4]            
[  711.656120]  [<ffffffff811249e3>] ? rcu_read_lock_sched_held+0x93/0xa0          
[  711.662951]  [<ffffffff8125ea68>] ? kmem_cache_alloc_trace+0x298/0x340          
[  711.669748]  [<ffffffffa09fdb7f>] ? nfs_alloc_fattr+0x1f/0x70 [nfs]             
[  711.676292]  [<ffffffffa0a8e82f>] nfs4_server_common_setup+0x9f/0x1d0 [nfsv4] 
[  711.683737]  [<ffffffffa0a9049a>] nfs4_create_server+0x24a/0x390 [nfsv4]        
[  711.690731]  [<ffffffffa0a84d7e>] nfs4_remote_mount+0x2e/0x60 [nfsv4]           
[  711.697432]  [<ffffffff81297959>] mount_fs+0x39/0x170                           
[  711.702700]  [<ffffffff812b90ab>] vfs_kern_mount+0x6b/0x150                     
[  711.708557]  [<ffffffffa0a84ca6>] nfs_do_root_mount+0x86/0xc0 [nfsv4]           
[  711.715263]  [<ffffffffa0a85084>] nfs4_try_mount+0x44/0xc0 [nfsv4]              
[  711.721735]  [<ffffffffa09f4497>] ? get_nfs_version+0x27/0x90 [nfs]             
[  711.728298]  [<ffffffffa0a0497c>] nfs_fs_mount+0x4ac/0xd80 [nfs]                
[  711.734524]  [<ffffffff81101162>] ? lockdep_init_map+0x92/0x200                 
[  711.740699]  [<ffffffffa0a054b0>] ? nfs_clone_super+0x130/0x130 [nfs]           
[  711.747441]  [<ffffffffa0a02bd0>] ? param_set_portnr+0x70/0x70 [nfs]            
[  711.754092]  [<ffffffff81297959>] mount_fs+0x39/0x170                           
[  711.759344]  [<ffffffff812b90ab>] vfs_kern_mount+0x6b/0x150                     
[  711.765176]  [<ffffffff812bbcb1>] do_mount+0x1f1/0xd10                          
[  711.770523]  [<ffffffff811249e3>] ? rcu_read_lock_sched_held+0x93/0xa0          
[  711.777352]  [<ffffffff812bcae3>] SyS_mount+0x83/0xd0                           
[  711.782640]  [<ffffffff81003c4c>] do_syscall_64+0x6c/0x1e0                      
[  711.788351]  [<ffffffff817e45bf>] entry_SYSCALL64_slow_path+0x25/0x25           

-- 
Regards,
  Artem
