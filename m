From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: oops in the 2.4.20-NFSALL sunrpc code
Date: Fri, 13 Dec 2002 16:42:40 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15865.65520.122137.890996@charged.uio.no>
References: <Pine.LNX.4.44.0212131002500.15305-100000@moisil.badula.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Mrxj-0007WP-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Dec 2002 07:42:51 -0800
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <Pine.LNX.4.44.0212131002500.15305-100000@moisil.badula.org>
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

>>>>> " " == Ion Badulescu <ionut@badula.org> writes:

     > It's caused, from what I can tell, by task->tk_client being
     > NULL in xprt_timer() at the time it is dereferenced. Looks like
     > a race condition, probably facilitated by the SMP kernel.

It's definitely not a race condition: Every new task is supposed to
call rpc_init_task() prior to calling rpc_execute(). This
again initializes task->tk_client once and for all. It is never
allowed to change.
There is only one exception to the above rule, namely nfs_flushd,
(which can never stray into net/sunrpc/xprt.c).


All I can say about this one is that it doesn't look like anything
I've come across on any other setups. Have you tried to reproduce it
on an actual 2.4.20 kernel?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
