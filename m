From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: executable but not readable
Date: Thu, 25 Mar 2004 13:37:36 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080239856.2584.18.camel@lade.trondhjem.org>
References: <40631E32.1020707@gsi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6ZjY-000120-Em
	for nfs@lists.sourceforge.net; Thu, 25 Mar 2004 10:37:40 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B6ZjY-0007DZ-6w
	for nfs@lists.sourceforge.net; Thu, 25 Mar 2004 10:37:40 -0800
To: Christopher Huhn <C.Huhn@gsi.de>
In-Reply-To: <40631E32.1020707@gsi.de>
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

P=E5 to , 25/03/2004 klokka 13:00, skreiv Christopher Huhn:

> The clients are able to run these scripts with server kernel version 2.4.=
20.
> Now we switched the server to 2.4.25 and get "permission denied" on=20
> execution.

On page 99, RFC1813 states explicitly that

   A similar problem has to do with paging in an executable
   program over the network. The operating system usually checks
   for execute permission before opening a file for demand
   paging, and then reads blocks from the open file. In a local
   UNIX file system, an executable file does not need read
   permission to execute (pagein). An NFS version 3 protocol
   server can not tell the difference between a normal file read
   (where the read permission bit is meaningful) and a demand
   pagein read (where the server should allow access to the
   executable file if the execute bit is set for that user or
   group or public). To make this work, the server allows
   reading of files if the uid given in the call has either
   execute or read permission on the file, through ownership,
   group membership or public access. Again, this departs from
   correct local file system semantics.

So if the server is denying read access in 2.4.25, then someone must
have introduced a bug...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
