From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs4 hang
Date: Thu, 27 May 2010 13:08:30 -0400
Message-ID: <20100527170829.GA11559@fieldses.org>
References: <2212784.91274721147769.JavaMail.javamailuser@localhost> <18251062.111274721421458.JavaMail.javamailuser@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Christopher Hawkins <chawkins-eCVT+wl/HiBBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35351 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757497Ab0E0RIb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 May 2010 13:08:31 -0400
In-Reply-To: <18251062.111274721421458.JavaMail.javamailuser@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 24, 2010 at 01:17:01PM -0400, Christopher Hawkins wrote:
> Thanks Bruce, it does appear that idmapd is somehow related to this
> issue. However, I'm stumped because it does exist on the client, along
> with all the libraries it requires (according to ldd, anyway).

And /etc/passwd, and whatever other files it might decide it needs to
open to do its work?

> Is
> there an easy way to disable idmapd while still running nfs4 to
> determine if it is causing the hang?

Not that I know of.

--b.


> 
> Chris
> 
> ----- "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Sat, May 22, 2010 at 11:11:31AM -0400, Christopher Hawkins wrote:
> > > Actually this issue seems to be on the server side. I changed the
> > export to read only so the clients couldn't accidentally overwrite
> > anything... and the issue persists! Will keep testing.
> > 
> > Probably rpc.idmapd is trying to access a file on NFSv4.
> > 
> > (Which doesn't work because the NFSv4 client needs idmapd to respond
> > before it can continue, creating a deadlock.)
> > 
> > --b.
> > 
> > > 
> > > ----- "Christopher Hawkins" <chawkins-eCVT+wl/HiBBDgjK7y7TUQ@public.gmane.org> wrote:
> > > 
> > > > I managed to make it go a little further and now the nodes will
> > finish
> > > > booting, though they hang when I start other nodes and start
> > using
> > > > files. And this was captured in the syslog from one of the nodes
> > where
> > > > nfs4 goes unresponsive. Not familiar enough with nfs4 to read it,
> > > > however. Does this point to a culprit?
> > > > 
> > > > It's as if the nodes are writing all over each others
> > connections,
> > > > like maybe I have a shared directory where each node must have its
> > own
> > > > private directory. They each have their own /var/lib and
> > > > /var/lib/nfs/rpc_pipefs mounted. Anything else that nfs clients
> > write
> > > > to (aside from proc and dev)?
> > > > 
> > > > May 21 17:13:45 192.168.1.243 kernel: INFO: task rpciod/0:1297
> > blocked
> > > > for more than 120 seconds.
> > > > May 21 17:13:45 192.168.1.243 kernel: "echo 0 >
> > > > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > > May 21 17:13:45 192.168.1.243 kernel: rpciod/0      D 00000097 
> > 2580 
> > > > 1297      7          1306   340 (L-TLB)
> > > > May 21 17:13:45 192.168.1.243 kernel:        de89de40 00000046
> > > > 1dfa3ac0 00000097 de8ca3b4 c1984c78 00000001 0000000a
> > > > May 21 17:13:45 192.168.1.243 kernel:        de8ce000 1dfa3ac0
> > > > 00000097 00000000 00000000 de8ce10c c1787100 f54ebac0
> > > > May 21 17:13:45 192.168.1.243 kernel:        c041ebcc 00000000
> > > > 00000000 00000003 00000296 c1984b00 c17875bc de89de68
> > > > May 21 17:13:45 192.168.1.243 kernel: Call Trace:
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c041ebcc>]
> > > > __wake_up+0x2a/0x3d
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f8916155>]
> > > > rpc_queue_upcall+0x92/0x99 [sunrpc]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f8992b04>]
> > > > nfs_idmap_id+0x18b/0x1f6 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c041f7a7>]
> > > > default_wake_function+0x0/0xc
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f8992ba9>]
> > > > nfs_map_name_to_uid+0x1b/0x1f [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898d719>]
> > > > decode_getfattr+0x611/0xbbd [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898c0bd>]
> > > > decode_open+0xf3/0x25e [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898e47c>]
> > > > decode_getfh+0x61/0xa3 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898e4be>]
> > > > nfs4_xdr_dec_open+0x0/0xa2 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898e533>]
> > > > nfs4_xdr_dec_open+0x75/0xa2 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f890e755>]
> > > > rpcauth_unwrap_resp+0x5b/0x60 [sunrpc]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f89097e9>]
> > > > call_decode+0x437/0x47d [sunrpc]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898e4be>]
> > > > nfs4_xdr_dec_open+0x0/0xa2 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f890df54>]
> > > > __rpc_execute+0x7a/0x1f8 [sunrpc]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c0433276>]
> > > > run_workqueue+0x78/0xb5
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f890e0d2>]
> > > > rpc_async_schedule+0x0/0x5 [sunrpc]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c0433b2a>]
> > > > worker_thread+0xd9/0x10b
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c041f7a7>]
> > > > default_wake_function+0x0/0xc
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c0433a51>]
> > > > worker_thread+0x0/0x10b
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c0435f43>]
> > kthread+0xc0/0xed
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c0435e83>]
> > kthread+0x0/0xed
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c0405c53>]
> > > > kernel_thread_helper+0x7/0x10
> > > > May 21 17:13:45 192.168.1.243 kernel:  =======================
> > > > May 21 17:13:45 192.168.1.243 kernel: INFO: task java:13420
> > blocked
> > > > for more than 120 seconds.
> > > > May 21 17:13:45 192.168.1.243 kernel: "echo 0 >
> > > > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > > May 21 17:13:45 192.168.1.243 kernel: java          D 00000098 
> > 2068
> > > > 13420      1         13421 13386 (NOTLB)
> > > > May 21 17:13:45 192.168.1.243 kernel:        f6bbfab0 00000086
> > > > ada06900 00000098 00000000 c06ba340 dfc6d280 0000000a
> > > > May 21 17:13:45 192.168.1.243 kernel:        f5781000 ada06900
> > > > 00000098 00000000 00000000 f578110c c1787100 f649d3c0
> > > > May 21 17:13:45 192.168.1.243 kernel:        00000098 00000000
> > > > de7c6804 c1787100 de7c6800 f6bbfb1c c04ec500 ffffffff
> > > > May 21 17:13:45 192.168.1.243 kernel: Call Trace:
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c04ec500>]
> > > > __next_cpu+0x12/0x21
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c061cf25>]
> > > > __mutex_lock_slowpath+0x4d/0x7c
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c061cf63>]
> > > > .text.lock.mutex+0xf/0x14
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f89929f2>]
> > > > nfs_idmap_id+0x79/0x1f6 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c041f7a7>]
> > > > default_wake_function+0x0/0xc
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f8992ba9>]
> > > > nfs_map_name_to_uid+0x1b/0x1f [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898d719>]
> > > > decode_getfattr+0x611/0xbbd [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c042d5f5>]
> > > > lock_timer_base+0x15/0x2f
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898e025>]
> > > > nfs4_xdr_dec_getattr+0x0/0x45 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898e063>]
> > > > nfs4_xdr_dec_getattr+0x3e/0x45 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f890e755>]
> > > > rpcauth_unwrap_resp+0x5b/0x60 [sunrpc]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f89097e9>]
> > > > call_decode+0x437/0x47d [sunrpc]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898e025>]
> > > > nfs4_xdr_dec_getattr+0x0/0x45 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f890df54>]
> > > > __rpc_execute+0x7a/0x1f8 [sunrpc]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f8909951>]
> > > > rpc_call_sync+0x6b/0x91 [sunrpc]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f89879f9>]
> > > > nfs4_proc_getattr+0x6f/0x8b [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f897a157>]
> > > > __nfs_revalidate_inode+0x120/0x249 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c061c526>]
> > > > schedule+0xa22/0xa55
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f8975dbe>]
> > > > nfs_lookup_revalidate+0x1e8/0x3d7 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c042d5f5>]
> > > > lock_timer_base+0x15/0x2f
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898baea>]
> > > > decode_compound_hdr+0x35/0x72 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898b9da>]
> > > > decode_op_hdr+0xd/0x58 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f898bf3c>]
> > > > nfs4_xdr_dec_access+0x54/0x8d [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c042d5f5>]
> > > > lock_timer_base+0x15/0x2f
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c042d769>]
> > > > __mod_timer+0xda/0xe4
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f890e4f8>]
> > > > rpc_wake_up_next+0x11f/0x126 [sunrpc]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c042e0d2>]
> > > > recalc_sigpending+0xe/0x20
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c042e194>]
> > > > sigprocmask+0xb0/0xce
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f890996f>]
> > > > rpc_call_sync+0x89/0x91 [sunrpc]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f8986c9d>]
> > > > _nfs4_proc_access+0xa7/0xdb [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f8976912>]
> > > > nfs_access_add_cache+0xad/0x135 [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c048b233>]
> > dput+0x22/0xed
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<f897816c>]
> > > > nfs_open_revalidate+0x186/0x1da [nfs]
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c0481e46>]
> > > > do_lookup+0x135/0x174
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c0483652>]
> > > > __link_path_walk+0x314/0xd33
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c04840a9>]
> > > > link_path_walk+0x38/0x95
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c048446a>]
> > > > do_path_lookup+0x219/0x27f
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c0483652>]
> > > > __link_path_walk+0x314/0xd33
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c04840a9>]
> > > > link_path_walk+0x38/0x95
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c048446a>]
> > > > do_path_lookup+0x219/0x27f
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c0484bc4>]
> > > > __user_walk_fd+0x29/0x3a
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c047e380>]
> > > > vfs_stat_fd+0x15/0x3c
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c041f7a7>]
> > > > default_wake_function+0x0/0xc
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c047e434>]
> > > > sys_stat64+0xf/0x23
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c042c7a5>]
> > > > getnstimeofday+0x30/0xb6
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c04f0b41>]
> > > > copy_to_user+0x31/0x48
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c04356e7>]
> > > > sys_clock_gettime+0x58/0x7e
> > > > May 21 17:13:45 192.168.1.243 kernel:  [<c0404f17>]
> > > > syscall_call+0x7/0xb
> > > > May 21 17:13:45 192.168.1.243 kernel:  =======================
> > > > 
> > > > 
> > > > Christopher Hawkins
> > > > 
> > > > Cell: 315-882-2551
> > > > Fax:   716-662-0788
> > > > 
> > > > ----- "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > > > On Thu, May 20, 2010 at 03:54:28PM -0400, Christopher Hawkins
> > > > wrote:
> > > > > > Hello, 
> > > > > > 
> > > > > > I have a bash script that sets up a root filesystem over NFS.
> > The
> > > > > method works fine over NFS3 but hangs when using NFS4 as a
> > > > transport.
> > > > > Hoping someone can help me figure out why?
> > > > > > 
> > > > > > In a nutshell:
> > > > > > 
> > > > > > 1. The node boots into a ramdisk that has a few thousand files
> > in
> > > > it
> > > > > already
> > > > > > 2. connects to an NFS server exporting / and mounts that in a
> > tmp
> > > > > dir
> > > > > > 3. bash (on the booting node) loops through the local and
> > remote
> > > > > filesystem and creates a local symlink to anything in the nfs
> > root
> > > > > that it doesn't already have.
> > > > > 
> > > > > Wild.
> > > > > 
> > > > > > Export options are: /
> > > > > 192.168.1.0/24(rw,no_root_squash,no_subtree_check,fsid=0)
> > > > > > Mount options are: rw,sync,noatime,rsize=1024,wsize=1024
> > > > > > 
> > > > > > rpcidmapd, portmap, statd are running on server and client,
> > and
> > > > > rpc_pipefs is mounted on both as well. The script currently
> > makes
> > > > > about 6200 links, total. Nfs4 hangs about 90% of the way
> > through. I
> > > > > removed the directory it was hanging on (a simple, empty dir)
> > and
> > > > then
> > > > > it just hung on the next one.
> > > > > 
> > > > > Is it possible there's some idmap deadlock?  (If say an upcall
> > to
> > > > > idmapd
> > > > > is hanging because the mapping requires access to some file
> > that
> > > > > isn't
> > > > > there yet?)
> > > > > 
> > > > > A sysrq-T trace might help.
> > > > > 
> > > > > --b.
> > > > > 
> > > > > > Really appreciate any help or pointers on where to look for
> > more
> > > > > info. Thanks!
> > > > > > 
> > > > > > Chris
> > > > > > 
> > > > > > 
> > > > > >    
> > > > > > --
> > > > > > To unsubscribe from this list: send the line "unsubscribe
> > > > linux-nfs"
> > > > > in
> > > > > > the body of a message to majordomo@vger.kernel.org
> > > > > > More majordomo info at 
> > > > http://vger.kernel.org/majordomo-info.html
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe
> > linux-nfs"
> > > > in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at 
> > http://vger.kernel.org/majordomo-info.html
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> > in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
