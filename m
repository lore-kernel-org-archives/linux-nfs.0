From: petter.knutsen@cgi.no
Subject: Re: File lock with multiple clients
Date: Fri, 21 Oct 2005 12:25:07 +0200
Message-ID: <E1ESu5K-0007a8-1Z@mail.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESu5L-0006yx-SR
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 03:25:15 -0700
Received: from mail09.webhuset.no ([81.27.32.116] helo=mx.webhuset.no)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ESu5K-0007a8-1Z
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 03:25:15 -0700
To: nfs@lists.sourceforge.net, neilb@suse.de
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

> Check the man page:  "man flock":
>=20
> Use fcntl or lockf (which is wrapper for fcntl) if you want to lock
> over NFS.

As Trond said, flock() seems to work by emulating fcntl(), but regardless of
whether I'm using fcntl() directly or flock() with emulation, should my
scenario  with two clients work, where one client locks and the other client
honouring the lock?

As I said, it works between processes on the same client, but not between
processes on different clients.

I would appreciate if someone could tell me if this is possible or not, so I
can either abandon NFS and look for alternatives or, if it should work, go
back and look for flaws in my setup. :-)

--
Petter=


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
