From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Kernel paging dump on 2.4.18
Date: 23 Apr 2002 11:03:25 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy9fedbxe.fsf@charged.uio.no>
References: <GKEPJBFFKGJCJDOINKHJMELHCFAA.rcd@amherst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nfs" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zwD8-0007pc-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 02:03:42 -0700
To: "Rob Dege" <rcd@amherst.com>
In-Reply-To: <GKEPJBFFKGJCJDOINKHJMELHCFAA.rcd@amherst.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Rob Dege <rcd@amherst.com> writes:

     > I'm running RedHat 7.2 w/2.4.18 as a dedicated file server
     > prmailily for Linux & alpha machines.  I've been getting kernel
     > paging faults, and don't know what's causing it.  The odd thing
     > is that the kernel error only affects NFS.  Everything else is
     > stable, and usable.  here's the dump from /var/log/messages:

That looks like a bug I fixed a long time ago in 2.2.x. Does the
following patch help?

Cheers,
  Trond

diff -u --recursive --new-file linux-2.4.18/fs/lockd/svc4proc.c linux-2.4.18-fix_lock/fs/lockd/svc4proc.c
--- linux-2.4.18/fs/lockd/svc4proc.c	Mon Oct  1 22:45:47 2001
+++ linux-2.4.18-fix_lock/fs/lockd/svc4proc.c	Tue Apr 23 11:00:59 2002
@@ -254,6 +254,7 @@
 
 	dprintk("lockd: TEST_MSG      called\n");
 
+	memset(&res, 0, sizeof(res));
 	if ((stat = nlm4svc_proc_test(rqstp, argp, &res)) == 0)
 		stat = nlm4svc_callback(rqstp, NLMPROC_TEST_RES, &res);
 	return stat;
diff -u --recursive --new-file linux-2.4.18/fs/lockd/svcproc.c linux-2.4.18-fix_lock/fs/lockd/svcproc.c
--- linux-2.4.18/fs/lockd/svcproc.c	Thu Oct 11 16:52:18 2001
+++ linux-2.4.18-fix_lock/fs/lockd/svcproc.c	Tue Apr 23 11:01:10 2002
@@ -282,6 +282,7 @@
 
 	dprintk("lockd: TEST_MSG      called\n");
 
+	memset(&res, 0, sizeof(res));
 	if ((stat = nlmsvc_proc_test(rqstp, argp, &res)) == 0)
 		stat = nlmsvc_callback(rqstp, NLMPROC_TEST_RES, &res);
 	return stat;

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
