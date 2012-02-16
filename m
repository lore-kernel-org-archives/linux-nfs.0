Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59856 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045Ab2BPQIq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 11:08:46 -0500
Date: Thu, 16 Feb 2012 11:08:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Nick Piggin <npiggin@gmail.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20120216160827.GB20762@fieldses.org>
References: <20110118204509.GA10903@fieldses.org>
 <AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
 <20110118220817.GF10903@fieldses.org>
 <20110308181320.GA15566@fieldses.org>
 <20110310105821.GE22723@ZenIV.linux.org.uk>
 <20110311150749.2fa2be66@notabene.brown>
 <20120214170300.GA4309@fieldses.org>
 <20120215165633.GE12490@fieldses.org>
 <20120216140603.08cb4900@notabene.brown>
 <20120216115133.GA20279@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120216115133.GA20279@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 16, 2012 at 06:51:33AM -0500, J. Bruce Fields wrote:
> I'm seeing something similar happening on an upstream kernel, so I'll
> try to figure out where that's coming from now....

After taking another look, actually this was something happening on
proc, not on an exported filesystem.

Running some tests on a kernel with this extra warning added to
__d_instantiate whenever it gives a directory a second alias:

Feb 15 14:43:07 pip1 kernel: __d_instantiate adding alias
ffff880037bf51c0(8) to dir ffff880035eaf048(4026532190) with existing alias(es) ffff880034037180(88)

The numbers after the dentry pointers are dentry flags in hex (8 ==
DCACHE_OP_DELETE, 88 == DCACHE_RCUACCESS|DCACHE_OP_DELETE), and after
the inode pointers is an inode number.

I don't know if it's a bug or not, though it seems suspicous.

--b.

Feb 15 14:43:07 pip1 kernel: ------------[ cut here ]------------
Feb 15 14:43:07 pip1 kernel: WARNING: at fs/dcache.c:1320 __d_instantiate+0x185/0x1d0()
Feb 15 14:43:07 pip1 kernel: Hardware name: Bochs
Feb 15 14:43:07 pip1 kernel: Modules linked in: nfsd lockd nfs_acl auth_rpcgss sunrpc [last unloaded: scsi_wait_scan]
Feb 15 14:43:07 pip1 kernel: Pid: 4810, comm: exportfs Not tainted 3.3.0-rc2-00517-g35ae270 #1070
Feb 15 14:43:07 pip1 kernel: Call Trace:
Feb 15 14:43:07 pip1 kernel: [<ffffffff8104040f>] warn_slowpath_common+0x7f/0xc0
Feb 15 14:43:07 pip1 kernel: [<ffffffff8104046a>] warn_slowpath_null+0x1a/0x20
Feb 15 14:43:07 pip1 kernel: [<ffffffff8113f885>] __d_instantiate+0x185/0x1d0
Feb 15 14:43:07 pip1 kernel: [<ffffffff8113face>] d_instantiate+0x4e/0x90
Feb 15 14:43:07 pip1 kernel: [<ffffffff81192d7b>] proc_lookup_de+0xab/0x110
Feb 15 14:43:07 pip1 kernel: [<ffffffff81196a90>] ?  proc_sys_poll_notify+0x30/0x30
Feb 15 14:43:07 pip1 kernel: [<ffffffff81196c1f>] proc_tgid_net_lookup+0x3f/0x50
Feb 15 14:43:07 pip1 kernel: [<ffffffff81133f55>] d_alloc_and_lookup+0x45/0x90
Feb 15 14:43:07 pip1 kernel: [<ffffffff8113e455>] ? d_lookup+0x35/0x60
Feb 15 14:43:07 pip1 kernel: [<ffffffff8113453a>] do_lookup+0x28a/0x3b0
Feb 15 14:43:07 pip1 kernel: [<ffffffff814c792c>] ?  security_inode_permission+0x1c/0x30
Feb 15 14:43:07 pip1 kernel: [<ffffffff81135337>] link_path_walk+0x157/0x940
Feb 15 14:43:07 pip1 kernel: [<ffffffff8113910c>] path_openat+0xbc/0x440
Feb 15 14:43:07 pip1 kernel: [<ffffffff81106243>] ?  might_fault+0x53/0xb0
Feb 15 14:43:07 pip1 kernel: [<ffffffff81106243>] ?  might_fault+0x53/0xb0
Feb 15 14:43:07 pip1 kernel: [<ffffffff81145aeb>] ? alloc_fd+0x3b/0x160
Feb 15 14:43:07 pip1 kernel: [<ffffffff811395a9>] do_filp_open+0x49/0xa0
Feb 15 14:43:07 pip1 kernel: [<ffffffff81145b5b>] ? alloc_fd+0xab/0x160
Feb 15 14:43:07 pip1 kernel: [<ffffffff81126328>] do_sys_open+0x108/0x1e0
Feb 15 14:43:07 pip1 kernel: [<ffffffff81126441>] sys_open+0x21/0x30
Feb 15 14:43:07 pip1 kernel: [<ffffffff81973252>] system_call_fastpath+0x16/0x1b
Feb 15 14:43:07 pip1 kernel: ---[ end trace 5714bb1463cb9b46 ]---



> 
> > I think that using __d_find_any_alias would just be papering over the
> > problem, and would trigger a BUG_ON when it returned a non-DISCONNECTED alias.
> 
> Right, I throw away that BUG_ON as well.  Tested on rhel5 only.
> 
> --b.
