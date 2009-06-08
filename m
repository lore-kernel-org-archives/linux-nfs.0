From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/5] sunrpc/auth_gss: Call rcu_barrier() on module
	unload.
Date: Mon, 8 Jun 2009 14:13:48 -0700
Message-ID: <20090608211348.GI6961@linux.vnet.ibm.com>
References: <20090608130959.10052.54590.stgit@localhost> <20090608131148.10052.39869.stgit@localhost> <20090608162656.GF6961@linux.vnet.ibm.com> <1244480449.5040.4.camel@heimdal.trondhjem.org> <Pine.LNX.4.64.0906082128240.1180@ask.diku.dk>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0906082128240.1180@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 08, 2009 at 09:48:54PM +0200, Jesper Dangaard Brouer wrote:
>
> (trimmed Cc)
>
> On Mon, 8 Jun 2009, Trond Myklebust wrote:
>
>> Hmm... If this is about ensuring that all the call_rcu() callbacks
>> complete before we remove the module, then don't we also need similar
>> barriers in
>
> Well, Trond that was a hard question, as I don't know this code... but if 
> it uses call_rcu() callbacks its most likely.
>
> I have not done a complete sweep of the tree, I have only looked at the 
> netdev parts, as this is where I usually snoop around.  So there is 
> probably plenty of work for some kernel-janitors (Cc'ing the list ;-))
>
>> net/sunrpc/sunrpc_syms.c:cleanup_sunrpc()
>
> Looking at the code that end up in sunrpc.ko, I see that both 
> net/sunrpc/auth_unix.c and net/sunrpc/auth_generic.c uses call_rcu() 
> callbacks.
>
>> and in fs/nfs/inode.c:exit_nfs_fs()?
>
> Looking at the code which end up into nfs.ko (which includes 
> fs/nfs/inode.c) I see that the fs/nfs/delegation.c uses call_rcu() 
> callbacks.
>
> But its hard for me to figure out how this code interacts.  Don't know if 
> we need to document a code path that can occur fast enough, before we add 
> this safe guard?  It should be Paul's saying...

Unless there is some other mechanism to ensure that all the RCU
callbacks have been invoked before the module exit, there needs to be
code in the module-exit function that does the following:

o	Prevent any new RCU callbacks from being posted.  In other
	words, make sure that no future call_rcu() invocations happen
	from this module -unless- those call_rcu() invocations touch
	only functions and data that outlive this module.

o	Invoke rcu_barrier().

o	Of course, if the module uses call_rcu_sched() instead of
	call_rcu(), then it should invoke rcu_barrier_sched() instead
	of rcu_barrier().  Similarly, if it uses call_rcu_bh() instead
	of call_rcu(), then it should invoke rcu_barrier_bh() instead of
	rcu_barrier().	If the module uses more than one of call_rcu(),
	call_rcu_sched(), and call_rcu_bh(), then it must invoke more than
	one of rcu_barrier(), rcu_barrier_sched(), and rcu_barrier_bh().

What other mechanism could be used?  I cannot think of one that it safe.
For example, a module that tried to count the number of RCU callbacks in
flight would be vulnerable to races as follows:

1.	CPU 0: RCU callback decrements the counter.

2.	CPU 1: module-exit function notices that the counter is zero,
	so removes the module.

3.	CPU 0: attempts to execute the code returning from the RCU
	callback, and dies horribly due to that code no longer being
	in memory.

If there was an easy solution (or even a hard solution) to this problem,
then I do not believe that Nikita Danilov would have asked Dipankar Sarma
for rcu_barrier().  Therefore, I do not expect anyone to be able to come
up with an alternative to rcu_barrier() and friends.  Always happy to
learn something by being proven wrong, of course!!!

So unless someone can show me some other safe mechanism, every unloadable
module that uses call_rcu(), call_rcu_sched(), or call_rcu_bh() must use
rcu_barrier(), rcu_barrier_sched(), and/or rcu_barrier_bh() in its
module-exit function.

							Thanx, Paul
