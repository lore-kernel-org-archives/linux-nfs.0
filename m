From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Race between rpciod() and rpciod_down() when shutting down
Date: Tue, 20 May 2003 14:07:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16074.6766.140044.669722@charged.uio.no>
References: <Pine.A41.4.44.0305151745370.28612-100000@forte.austin.ibm.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    trond.myklebust@fys.uio.no
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19I5uB-0007IF-00
	for <nfs@lists.sourceforge.net>; Tue, 20 May 2003 05:07:43 -0700
To: olof@austin.ibm.com
In-Reply-To: <Pine.A41.4.44.0305151745370.28612-100000@forte.austin.ibm.com>
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

>>>>> " " == olof  <olof@austin.ibm.com> writes:

     > Below patch removes a timing window during which rpciod_down()
     > will pass the while(rpciod_pid) test, but go to sleep after
     > rpciod() has woken up sleepers on the rpciod_killer queue.

     > Unfortunately, there's no
     > wait_for_completion_interruptible(). Instead of rolling my own
     > in the NFS code, I'll work on getting one added to the kernel.
     > The uninterruptible sleep is a temporary solution until then,
     > and I'll make sure to follow up here if/when the function is
     > added to kernel/sched.c.

Why not just ensure that the callers are holding the BKL?

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
