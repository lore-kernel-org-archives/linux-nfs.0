From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: Re: NFS as a Cluster File System.
Date: Fri, 10 Jan 2003 09:38:20 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030110173820.GA3066@wumpus.attbi.com>
References: <F155FnqdR2xuRoAnbsZ00020983@hotmail.com> <shs3co1kq1e.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 12-234-28-98.client.attbi.com ([12.234.28.98] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18X33l-0002QI-00
	for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 09:35:09 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs3co1kq1e.fsf@charged.uio.no>
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

>      > I think this can be resolved with the "noac" mount option
>      > (prior to V4).
> 
> Nope. It can only be resolved using file locking.

There are 2 consistency problems: metadata and data.

Metadata is solved by noac. And yes, some MPI programs do things like
"node 0 writes out a bunch of files, then tells all the other nodes to
read one file each." This means that you have about 1/100 of a second
window between creation on one client and reading on a different client.

Data consistency is solved by file locking.

-- greg




-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
