From: Miika Pekkarinen <miipekk@ihme.org>
Subject: Re: Using mmap result in data corruption
Date: Tue, 16 Nov 2004 12:07:13 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0411161206440.26094@ihme.ihme.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CU0FI-0001Ra-0Y
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 02:07:32 -0800
Received: from ihme.org ([212.226.113.138] ident=mail)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CU0FH-00013W-7K
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 02:07:31 -0800
Received: from miipekk (helo=localhost)
	by ihme.org with local-esmtp (Exim 4.24)
	id 1CU0Ez-0003P7-Dj
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 12:07:13 +0200
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

On Fri, 12 Nov 2004, Trond Myklebust wrote:

> > I have found a reproducable issue with NFS that will lead to file
> > corruption on server. When a file is created with O_TRUNC and data is
> > copied using mmap, the new file on the server will be filled with null bytes.
>
> mmap() offers absolutely NO guarantees that the file will be synced to
> disk on close. Use msync(MS_SYNC) if you want such a guarantee.

Hmm, with msync (right before munmap) the file gets synced to disk
correctly. However, I am
still wondering what is wrong with munmap. I checked the manual page
of msync and it said: "msync  flushes  changes  made  to  the in-core copy
of a file that was mapped into memory using mmap(2) back to disk. Without
use of this call there is no guarantee that changes are written back
before munmap(2) is called." So I understood that munmap should do the
same thing than msync but I doesn't sync the file. Probably I am missing
some point or there is a bug somewhere else (either in manual pages or in
some library)?

-- 
Miika Pekkarinen <miika at ihme.org>





-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
