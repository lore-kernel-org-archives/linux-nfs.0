From: Jan Sanislo <oystr@cs.washington.edu>
Subject: Bug in nfs client handling of EJUKEBOX
Date: 22 Feb 2005 11:46 PST
Message-ID: <1109101592/oystr@hugh.cs.washington.edu>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D3g1E-0001nC-3A
	for nfs@lists.sourceforge.net; Tue, 22 Feb 2005 11:48:28 -0800
Received: from hugh.cs.washington.edu ([128.208.2.43])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D3g1B-0006jn-Lf
	for nfs@lists.sourceforge.net; Tue, 22 Feb 2005 11:48:28 -0800
Received: from hugh.cs.washington.edu (localhost [127.0.0.1])
	by hugh.cs.washington.edu (8.13.1/8.13.1/1.5) with ESMTP id j1MJmO5j018389
	for <nfs@lists.sourceforge.net>; Tue, 22 Feb 2005 11:48:24 -0800
	(envelope-from oystr@cs.washington.edu)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

There seems to be a bug in the 2.6.11-rc code related to the handling
of nfsd's EJUNKBOX error return.  The code for __rpc_execute in
net/sunrpc/sched.c looks like:

=============================

static int __rpc_execute(struct rpc_task *task)
{
	int		status = 0;

	dprintk("RPC: %4d rpc_execute flgs %x\n",
				task->tk_pid, task->tk_flags);

	BUG_ON(RPC_IS_QUEUED(task));

 restarted:
	while (1) {
		/*
		 * Garbage collection of pending timers...
		 */
		rpc_delete_timer(task);

 .....

	if (task->tk_exit) {
		lock_kernel();
>>>>		task->tk_exit(task);
		unlock_kernel();
		/* If tk_action is non-null, the user wants us to restart */
		if (task->tk_action) {
			if (!RPC_ASSASSINATED(task)) {
				/* Release RPC slot and buffer memory */
				if (task->tk_rqstp)
					xprt_release(task);
				rpc_free(task);
				goto restarted;
			}
			printk(KERN_ERR "RPC: dead task tries to walk away.\n");
		}
	}

=============================

If the tk_exit procedure (e.g., nfs_read_done) called at ">>>>" above
detects EJUKEBOX as the result of the call, it will attempt to do
an rpc_restart and rpc_delay on the task.  The rpc_delay will set a timer.
However, when the main loop is re-entered via the "goto restarted",
the first thing that happens is that all timers for the task are removed.
This results in the RPC task hanging in an uninterruptible wait.

Am I missing something here or is this really a problem?



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
