From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: suspicious rcu_dereference_check()
Date: Mon, 29 Mar 2010 08:25:57 -0700
Message-ID: <20100329152557.GD2569@linux.vnet.ibm.com>
References: <c4e36d111003250348q678eb2e6w4f3e8133e7fd6e58@mail.gmail.com>
 <1269531400.3648.1.camel@localhost.localdomain>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:37337 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312Ab0C2P0O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Mar 2010 11:26:14 -0400
In-Reply-To: <1269531400.3648.1.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 25, 2010 at 11:36:40AM -0400, Trond Myklebust wrote:
> On Thu, 2010-03-25 at 11:48 +0100, Zdenek Kabelac wrote: 
> > Hi
> > 
> > I've enabled rcu correctness for my  todays 2.6.34-rc2 kernel.
> > 
> > I'm getting this INFO: from my kvm guest (which uses host's nfs
> > exported directory.)
> > This
> > 
> > ===================================================
> > [ INFO: suspicious rcu_dereference_check() usage. ]
> > ---------------------------------------------------
> > fs/nfs/delegation.c:348 invoked rcu_dereference_check() without protection!
> > 
> > other info that might help us debug this:
> > 
> > 
> > rcu_scheduler_active = 1, debug_locks = 0
> > 2 locks held by rm/1820:
> >  #0:  (&sb->s_type->i_mutex_key#13/1){+.+.+.}, at:
> > [<ffffffff81138e1b>] do_unlinkat+0x9b/0x1c0
> >  #1:  (&sb->s_type->i_mutex_key#13){+.+.+.}, at: [<ffffffff81136a76>]
> > vfs_unlink+0x56/0xf0
> > 
> > stack backtrace:
> > Pid: 1820, comm: rm Not tainted 2.6.34-rc2-00186-ge79a302 #60
> > Call Trace:
> >  [<ffffffff810819fb>] lockdep_rcu_dereference+0xbb/0xc0
> >  [<ffffffffa0228351>] nfs_inode_return_delegation+0x101/0x110 [nfs]
> >  [<ffffffffa01fd58d>] nfs_unlink+0xad/0x2a0 [nfs]
> >  [<ffffffff81136aba>] vfs_unlink+0x9a/0xf0
> >  [<ffffffff81148365>] ? mnt_want_write+0x65/0xb0
> >  [<ffffffff81138f03>] do_unlinkat+0x183/0x1c0
> >  [<ffffffff8142b66d>] ? retint_swapgs+0xe/0x13
> >  [<ffffffff81083985>] ? trace_hardirqs_on_caller+0x155/0x1a0
> >  [<ffffffff8142a232>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> >  [<ffffffff811390a2>] sys_unlinkat+0x22/0x40
> >  [<ffffffff81031dc8>] sysenter_dispatch+0x7/0x2c
> > 
> 
> It is a 100% bogus warning. There are tentative patches floating around
> to fix the above warning, but they haven't been merged yet.
> 
> In the meantime, please ignore...

Did you want to carry these patches, or would you rather that I do so?

(And sorry for the slow response, was on holiday last week.)

							Thanx, Paul
