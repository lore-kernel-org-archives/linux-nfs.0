From: Jim Mostek <Jim.Mostek@adic.com>
Subject: -ENOMEM from server file system leaves dentry held
Date: 29 Oct 2002 11:49:04 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1035913752.17023.13.camel@bike>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.81.117.28] (helo=penguin.adic.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186abG-00087Q-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Oct 2002 09:56:22 -0800
To: nfs-devel@linux.kernel.org, nfs@lists.sourceforge.net
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


We are running on 2.4.17 on the server. I think the client had
2.4.13.

Anyway, I traced the code and found a way that the dentry is left
held through one iteration of a server write. I did this with kdb.

The code path starts in net/sunrpc/svc.c:svc_process()
which alls nfsd_dispatch().

nfsd_dispatch() calls nfsd3_proc_write() at:

        nfserr = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
        if (nfserr == nfserr_dropit) {
            dprintk("nfsd: Dropping request due to malloc failure!\n");
            nfsd_cache_update(rqstp, RC_NOCACHE, NULL);
            return 0;
        }

nfsd3_proc_write calls nfsd_write()
nfsd_write() calls nfsd_open() works (and does the fh_verify() which
holds the dentry).

nfsd_write calls the underlying file system and let's say it returns
-ENOMEM. nfserrno() will convert this to nfserr_dropit.

This gets returned up to nfs3_proc_write() which then returns
nfserr_dropit to nfsd_dispatch(). The above code return's 0 to
svc_process().

svc_process drops the packet without calling the release function so
the handle is never released.

Not sure what the appropriate fix is, but one could call the release
function in nfsd_write if it is about to return "drop it" and the
nfsd_open succeeded.

Or is a file system never supposed to return -ENOMEM when the
write file op is called?

Tnanks,

-- 
Jim.Mostek@adic.com
952-882-0616
952-221-1183 cell



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
