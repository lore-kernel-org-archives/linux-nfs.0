From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: permission bits for group not honoured on directory
	creation
Date: Thu, 02 Sep 2004 16:54:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094158472.21922.27.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0409022203580.17829-100000@hikjos.fzk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C2ybO-0000yw-KK
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 13:54:38 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C2ybO-0007lx-1o
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 13:54:38 -0700
To: Jos van Wezel <jvw@iwr.fzk.de>
In-Reply-To: <Pine.LNX.4.44.0409022203580.17829-100000@hikjos.fzk.de>
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

P=E5 to , 02/09/2004 klokka 16:08, skreiv Jos van Wezel:

> # umask
> 0002
> # mkdir d
> # ls -ld d
> drwxr-xr-x    2 root     root         8192 Sep  2  2004 d/
> #
>=20
> note the write bit is not set for group. The ability to create group
> writable directories is important for our applications. A fix for
> this, or a pointer to a solution would be greatly appreciated.

You've checked that the setgid bit is not set on the parent directory
and that the filesystem has not been mounted with the grpid/bsdgroups
option on the server?

What is a "linux client and server" btw?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
