From: bob@proulx.com (Bob Proulx)
Subject: Re: Annoying rename() problem
Date: Tue, 24 Oct 2006 10:09:32 -0600
Message-ID: <20061024160932.GB17308@dementia.proulx.com>
References: <003f01c6f54a$90506250$020010ac@athlon64>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcPEX-0003Ur-IK
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 09:34:33 -0700
Received: from joseki.proulx.com ([216.17.153.58])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GcPER-0007dn-1W
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 09:34:34 -0700
To: Antoniu-George SAVU <antoniu-george.savu@linux-expert.eu>
In-Reply-To: <003f01c6f54a$90506250$020010ac@athlon64>
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

Antoniu-George SAVU wrote:
> Now, when a user has more than 50 files inside the new/ directory and 
> Courier IMAP rename those files to cur/ directory, I get strange errors 
> inside the Courier log complaining that the rename() has failed with the 
> errno=ENOENT (no such file or directory). The most amazing part is that the 
> files are moved just fine from new/ to cur/ and I just can not understand 
> why I keep getting those rename() errors and most important, how can I fix 
> this.

+1

I ran across this message while trying to understand other rename over
NFS failures.  On a company software project a test framework would
sporadically show test failures where the application would fail
reporting rename failures of NFS.  But debugging would always show
that the rename had actually happened.  This seems to need fairly
heavy activity load in order to trigger this problem.  I cannot
reproduce it on demand.

The application replaces an existing file on disk by writing a new
file off to the side in a temporary file and then after successfully
close() operation rename()s the file to the final name, replacing the
file that is already on disk.  The rename() returns a failure.
Subsequent inspection showed that the new file was renamed okay.

> My setup follows:
> 
> The NFS server runs under Debian Sarge with custom 2.6.18 kernel, NFSv4 
> support with NFSv3 support. The psyhical machine is an AMD Opteron 64 and 
> the NFS exports are stored on a RAID-5 array.

My NFS client is a Debian Sarge system with custom 2.6.12 kernel and
the server is an HP-UX 11.23 host.

> My problem perfectly fits this description: 
> http://lists.freebsd.org/pipermail/freebsd-bugs/2003-October/003461.html but 
> the bug reports dates from 2003.

In my case the new temporary file and the previously existing file are
both in the same directory.  Here would be the pseudo-code for my
case.  The application is a compiled C program.

  touch foo.d~
  mv foo.d~ foo.db

> Anyone has a suggestion of what I could try or do ? I've searched the NFS 
> mailinglist, nothing, nada. Any suggestion is more than welcome.

To work around this problem we have stopped checking the return code
of rename()!  Instead we now stat() the file before and after the
rename to verify the operation.  This is less efficient but avoided
the spurious error message.

Bob

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
