From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Data coherency trouble with multiple clients, on
	2.6.14-rc5
Date: Wed, 26 Oct 2005 02:23:34 -0400
Message-ID: <1130307814.8979.5.camel@lade.trondhjem.org>
References: <ef97ar3j.yzmpka2thm8d@a1g2zg0c>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUehW-0003cu-77
	for nfs@lists.sourceforge.net; Tue, 25 Oct 2005 23:23:54 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EUehU-0001Wz-Pp
	for nfs@lists.sourceforge.net; Tue, 25 Oct 2005 23:23:54 -0700
To: Charles Duffy <ccd@mailcall.com.au>
In-Reply-To: <ef97ar3j.yzmpka2thm8d@a1g2zg0c>
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

on den 26.10.2005 klokka 16:01 (+1000) skreiv Charles Duffy:
> Hi all,
> 
> I'm hoping someone can shed some light on this problem I'm having.
> 
> I have 2 NFS client machines (CentOS 4, kernel 2.6.14-rc5+latest 'NFS_ALL' patch, nfsutils 1.0.6) who each mount the same export from an NFS server (WBEL3, kernel 2.4.21-20, nfsutils 1.0.6).
> 
> These client machines are supposed to run an in-house database application - multiple processes on different clients often have the same datafile open simultaneously (via NFS).
> 
> Previously, we had these client machines running 2.2.21 kernels. The old (pre-CTO) behaviour would see writes from any of the clients becoming immediately 'visible' in any of the others. This is no longer the case, even with 'nocto' specified as a mount option.

"nocto" gives you stronger caching than close-to-open. It is designed
for the case where a single client has sole access to the files.

> Currently, if a process on client1 has the file open while it is written to by another process (on client2), the changes made to the file are never reflected in the data available to the process on client1 unless:
> 
> a) client1's NFS filesystem is unmounted and re-mounted
> b) The file is 'touched' on the server or on client2 after both processes have closed the file
> c) The process on client1 writes to the file (note 'touching' the file on client1 has no effect, either while or after the process has the file open).
> 
> It doesn't matter if both processes subsequently close the file and exit, then re-open the file from scratch - the discrepancy remains until either (a), (b) or (c) occurs. Client1 and client2 are identical systems, and the problem works both ways. In the event of (c), the previous write becomes visible to client1, but the write by client1 is not visible to client2.
> 
> 'stat' run on the datafile from either client always gives the same output.
> 
> I've also tried adding O_SYNC to the flags in the call to 'open()' in the application itself. Makes no difference.  fsync()ing after every write similarly makes no difference to the problem.
> 
> This problem appears similar to that which the linux-2.6.14-01-fix_attrcache patch was posted in response to, but it can't be reproduced with the procedure outlined in that post.
> 
> The client mount options are: noac,nocto,sync,hard,intr,rw,nfsvers=3
> The server exports flags are: (rw,no_root_squash,sync,no_wdelay,insecure)
> 
> Various combinations of the above mount options make no difference.
> I've also tried with a 2.6.14-rc5 server, and the problem persists.

It sounds like you are really looking for the O_DIRECT (i.e. uncached)
file I/O mode.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
