From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS writeback order when performing sequential writes
Date: Wed, 30 May 2007 15:54:34 -0400
Message-ID: <1180554874.6770.48.camel@heimdal.trondhjem.org>
References: <48FE8285C4566744A017E35783668EB304B088F6@MAIL12HQ.adic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Joe Habermann <joe.habermann@quantum.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HtUHt-0001Q0-NS
	for nfs@lists.sourceforge.net; Wed, 30 May 2007 12:56:54 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX188aOPGcbMOHCi7yR8YHZeKxqkPTjU94WI=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HtUFo-0001zw-L8
	for nfs@lists.sourceforge.net; Wed, 30 May 2007 12:54:46 -0700
In-Reply-To: <48FE8285C4566744A017E35783668EB304B088F6@MAIL12HQ.adic.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-05-30 at 11:54 -0700, Joe Habermann wrote:
> I've noticed that when writing a large file sequentially from a Linux
> (2.6) NFS client, the writebacks occur out of order.  Example:
> 	# lmdd of=foo bs=32k move=8g
> A network trace shows the resulting NFS WRITE requests start at offset 0
> and are sequential for a while but then become somewhat scattered.  I've
> tried this from several different Linux 2.6 clients running a variety of
> kernels and they all show similar behavior.  I'm using typical mount
> options: tcp,wsize=32768,rsize=32768,vers=3.
> 
> I assume this is related to how the NFS client works with the VM system.
> For some file systems and disk subsystems, this results in sub-optimal
> I/O performance and file fragmentation since NFS COMMITs also occur
> along the way and the file system back on the NFS server has no choice
> but to sync out whatever cached dirty data it has in its hands
> regardless of whether there are gaps, etc.
> 
> I don't see this this behavior with other NFS clients (Solaris 10, for
> one).  Are there any (VM? NFS?) tuning parameters that can force a Linux
> NFS client to perform writebacks in a FIFO manner?
> 
> Sorry in advance if this is a FAQ or a known issue.
> 
> Thanks, -Joe

In the very most recent kernels, the timing and ordering of NFS
asynchronous writebacks should be almost entirely determined by the VM,
as should the COMMIT time. Normally, the VM will attempt to order writes
sequentially.
The exception is if the client is writing partial pages, then reading
that data back into memory. That will be determined by the order in
which applications try to read the data.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
