From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Mailbox corruption on The NFS server
Date: 02 Dec 2003 14:35:14 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs65gzvwr1.fsf@guts.uio.no>
References: <Pine.LNX.4.44.0312011235290.23297-100000@kenzo.iwr.uni-heidelberg.de>
	<Pine.GSO.4.44.0312021646390.9111-100000@bhairav.ee.iitb.ac.in>
	<news2mail-bqimv5$onp$1@cartman.spoiled.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARGIz-00046J-3A
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 11:35:29 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARGIy-00022J-NM
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 11:35:28 -0800
Received: from mail-mx6.uio.no ([129.240.10.47])
	by pat.uio.no with esmtp (Exim 4.20)
	id 1ARGIu-0001JJ-U4
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 20:35:24 +0100
Received: from ulrik.uio.no ([129.240.12.4])
	by mail-mx6.uio.no with esmtp (Exim 4.14)
	id 1ARGIl-0000sW-59
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 20:35:15 +0100
Received: from guts.uio.no ([129.240.87.181])
	by ulrik.uio.no with esmtp (Exim 2.12 #7)
	id 1ARGIk-0003Fh-00
	for nfs@lists.sourceforge.net; Tue, 2 Dec 2003 20:35:14 +0100
Received: from trondmy by guts.uio.no with local (Exim 4.22)
	id 1ARGIk-0000st-RF
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 13:35:14 -0600
To: nfs@lists.sourceforge.net
In-Reply-To: <news2mail-bqimv5$onp$1@cartman.spoiled.org>
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

>>>>> " " == Juri Haberland <list-linux.nfs@spoiled.org> writes:

     > It's considered a bad idea to put mailboxes on a NFS share as
     > there might be locking issues if two applications simultanously
     > acces the same mailbox. Either use the maildir format or don't
     > export your mailboxes via NFS.

Sort of. It can be made to work *provided* that you can guarantee that
your mail programs all agree to support the same file locking scheme.
Currently that means they must chose one (or both) of the following
schemes:

  - fcntl() (a.k.a. POSIX, a.k.a. lockf()) locking

  - dotlocking (a.k.a. creating a lock file using something like 'ln
    mailbox .mailbox.locked')

Note that the BSD flock() and use of O_EXCL in a dotlocking scheme are
not considered to be reliable within Linux NFS.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
