From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.21 NFSv3 performance graph
Date: Fri, 21 Jan 2005 12:45:37 -0500
Message-ID: <1106329537.9849.68.camel@lade.trondhjem.org>
References: <41E816B3.4030702@mitre.org>
	 <1105747170.28849.22.camel@lade.trondhjem.org>
	 <41F13749.4090900@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jeff Blaine <jblaine@mitre.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cs2r9-0002H4-R0
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 09:45:59 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cs2r8-0005h7-4c
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 09:45:59 -0800
To: Jehan PROCACCIA <Jehan.Procaccia@int-evry.fr>
In-Reply-To: <41F13749.4090900@int-evry.fr>
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

fr den 21.01.2005 Klokka 18:09 (+0100) skreiv Jehan PROCACCIA:

> more generaly, what tool do you recommand to bench NFS ?
> I tried bonnie, bonnie++ and iozone.
> for the latest here's the kind of command I ran (so that it doesn't 
> takes hours to run the test!):
> /opt/iozone/bin/iozone -p -s 10k -s 100k -s 1m -s 5m -s 10m -s 100m -i 
> 0  -i 1 -r 4 -r 64 -r 256 -r 512 -r 1024 -r 4096 -r8192 -r 16384 -c -U 
> /mnt/cobra3 -f /mnt/cobra3/iozone.nagiostux > iozone-result
> 
> My problem is that my NFS server has 4Go of ram, and bench programs 
> always recommand to use filesize for tests higher than RAM size and even 
> double size of the RAM so that it is not messuring cache activities !

For tests of reading, this is undoubtedly true. For tests of writing
over NFS, this may be false: see the discussions of the iozone "-c" and
"-e" flags below.

Note that bonnie and bonnie++ lack the equivalent of the "-e", "-c"
flags, and so are indeed not good for testing wire speeds unless you use
very large files.

> Can you give me a sample of the iozone arguments you used ?
> Any other tools ?

It depends on what I want to test 8-)


Something like "iozone -c -a" should be fine for a basic test of the
generic read/write code functionality.
Note the "-c" which *is* usually necessary under NFS since any cached
writes are going to be flushed to disk by the "close()" (or when the
process exits). This means that close() will normally end up dominating
your write timings for files < memory size.

If you want to test mmap(), something like "iozone -e -B -a". I believe
that "-e" should normally ensure that any writes are flushed to disk
using the fsync() command, and that this is timed.
Note that if you don't care about knowing how long it takes for the
writes to be flushed to disk then you can drop the "-e": unlike ordinary
read/write, mmap() does not guarantee that writes are flushed to disk
after the file is closed.

For direct IO, "iozone -I -a" suffices. Since direct IO is uncached, all
write operations are synchronous, so "-c" and "-e" are unnecessary.


Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
