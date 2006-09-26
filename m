From: Stephane Doyon <sdoyon@max-t.com>
Subject: Long sleep with i_mutex in xfs_flush_device(),
	affects NFS service
Date: Tue, 26 Sep 2006 14:51:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609191533240.25914@madrid.max-t.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSI4f-0004vS-Hr
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 11:54:33 -0700
Received: from h216-18-124-229.gtcust.grouptelecom.net ([216.18.124.229]
	helo=mail.max-t.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GSI4g-0006NJ-0h
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 11:54:34 -0700
To: xfs@oss.sgi.com, nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

I'm seeing an unpleasant behavior when an XFS file system becomes full, 
particularly when accessed over NFS. Both XFS and the linux NFS client 
appear to be contributing to the problem.

When the file system becomes nearly full, we eventually call down to 
xfs_flush_device(), which sleeps for 0.5seconds, waiting for xfssyncd to 
do some work.

xfs_flush_space()does
         xfs_iunlock(ip, XFS_ILOCK_EXCL);
before calling xfs_flush_device(), but i_mutex is still held, at least 
when we're being called from under xfs_write(). It seems like a fairly 
long time to hold a mutex. And I wonder whether it's really necessary to 
keep going through that again and again for every new request after we've 
hit NOSPC.

In particular this can cause a pileup when several threads are writing 
concurrently to the same file. Some specialized apps might do that, and 
nfsd threads do it all the time.

To reproduce locally, on a full file system:
#!/bin/sh
for i in `seq 30`; do
   dd if=/dev/zero of=f bs=1 count=1 &
done
wait
time that, it takes nearly exactly 15s.

The linux NFS client typically sends bunches of 16 requests, and so if the 
client is writing a single file, some NFS requests are therefore delayed 
by up to 8seconds, which is kind of long for NFS.

What's worse, when my linux NFS client writes out a file's pages, it does 
not react immediately on receiving a NOSPC error. It will remember and 
report the error later on close(), but it still tries and issues write 
requests for each page of the file. So even if there isn't a pileup on the 
i_mutex on the server, the NFS client still waits 0.5s for each 32K 
(typically) request. So on an NFS client on a gigabit network, on an 
already full filesystem, if I open and write a 10M file and close() it, it 
takes 2m40.083s for it to issue all the requests, get an NOSPC for each, 
and finally have my close() call return ENOSPC. That can stretch to 
several hours for gigabyte-sized files, which is how I noticed the 
problem.

I'm not too familiar with the NFS client code, but would it not be 
possible for it to give up when it encounters NOSPC? Or is there some 
reason why this wouldn't be desirable?

The rough workaround I have come up with for the problem is to have 
xfs_flush_space() skip calling xfs_flush_device() if we are within 2secs 
of having returned ENOSPC. I have verified that this workaround is 
effective, but I imagine there might be a cleaner solution.

Thanks

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
