From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Thu, 05 Feb 2004 09:59:07 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4021793B.2DB1D4AB@melbourne.sgi.com>
References: <40209B6D.56ED461E@melbourne.sgi.com> <20040204104225.GI20323@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
   Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoVzS-0003eQ-Cr
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 14:59:26 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoVzS-0001or-6E
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 14:59:26 -0800
To: Olaf Kirch <okir@suse.de>
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

Olaf Kirch wrote:
> 
> > VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...
> 
> Finally! This bug was driving me nuts. I wasn't even able to reproduce
> this under lab conditions :-/

I stumbled on it by running the Connectathon test suite inside a shell
wrapper which did a mount/umount for every test.  I also have a small
shellscript+C program which reproduces it reliably.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
