From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: linux 2.4.20 oops
Date: Tue, 29 Apr 2003 19:04:49 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16046.45233.640294.228310@charged.uio.no>
References: <6440EA1A6AA1D5118C6900902745938E07D55598@black.eng.netapp.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AYXI-0001ij-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 10:04:56 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D55598@black.eng.netapp.com>
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

>>>>> " " == Charles Lever <Lever> writes:

     > the fix appears in 2.4.21-pre7, but was removed from
     > 2.4.21-rc1.  trond?

Huh? From the latest BK pull linux/net/sunrpc/sched.c

/*
 * Delete any timer for the current task. Because we use
   del_timer_sync(),
 * this function should never be called while holding rpc_queue_lock.
 */
static inline void
rpc_delete_timer(struct rpc_task *task)
{
        dprintk("RPC: %4d deleting timer\n", task->tk_pid);
        del_timer_sync(&task->tk_timer);
}

So AFAICS it is still there. I certainly have no quarrel with that
patch. I hit upon the same problem + fix in a different bug-report at
~ the same time.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
