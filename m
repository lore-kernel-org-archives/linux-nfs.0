From: Ion Badulescu <ionut@badula.org>
Subject: Re: oops in the 2.4.20-NFSALL sunrpc code
Date: Fri, 13 Dec 2002 12:05:09 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0212131152280.15305-100000@moisil.badula.org>
References: <15865.65520.122137.890996@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=buggy.badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MtFW-0003Bu-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Dec 2002 09:05:18 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15865.65520.122137.890996@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, 13 Dec 2002, Trond Myklebust wrote:

> >>>>> " " == Ion Badulescu <ionut@badula.org> writes:
> 
>      > It's caused, from what I can tell, by task->tk_client being
>      > NULL in xprt_timer() at the time it is dereferenced. Looks like
>      > a race condition, probably facilitated by the SMP kernel.
> 
> It's definitely not a race condition: Every new task is supposed to
> call rpc_init_task() prior to calling rpc_execute(). This
> again initializes task->tk_client once and for all. It is never
> allowed to change.
> There is only one exception to the above rule, namely nfs_flushd,
> (which can never stray into net/sunrpc/xprt.c).

Hmm... I can see two places where the NULL could be coming from. One is 
calling rpc_init_task() with clnt==NULL, which appears to be legal since 
the function checks clnt for NULL:

        if (clnt)
                atomic_inc(&clnt->cl_users);

The other one would be rpc_release_task() if somehow an xprt_timer is 
fired up, spins for a while on xprt->sock_lock, and in the meantime 
rpc_release_task() is called and it releases the client:

        if (task->tk_client) {
                rpc_release_client(task->tk_client);
                task->tk_client = NULL;
        }

I don't see anything in rpc_release_task() that waits for xprt->sock_lock,
but I don't know the code that well and maybe something else prevents this
race.

> All I can say about this one is that it doesn't look like anything
> I've come across on any other setups. Have you tried to reproduce it
> on an actual 2.4.20 kernel?

No, and in fact I only got this oops once across several dozen machines 
and several weeks of uptime. It doesn't seems to be easily reproducible, 
that's why I'm inclined to think it's an SMP race.

However, as I said, the diff between 2.4.20 + those patches and my kernel, 
in the nfs/nfsd/sunrpc areas (including headers) is empty...

Thanks,
Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
