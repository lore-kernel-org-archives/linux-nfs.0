From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS client] NFS locks not released on abnormal process termination
Date: 09 Dec 2003 03:42:02 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsekvetmat.fsf@guts.uio.no>
References: <20031208033933.16136.qmail@web20024.mail.yahoo.com>
	<shszne3risb.fsf@charged.uio.no> <877k17rzai.fsf@ceramic.fifi.org>
	<1070913367.2941.137.camel@nidelv.trondhjem.org>
	<87llpms8yr.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kenny Simpson <theonetruekenny@yahoo.com>,
	  linux-kernel@vger.kernel.org,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATdRi-0008OM-7P
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 00:42:18 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATdRh-0003KQ-Qb
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 00:42:18 -0800
To: Philippe Troin <phil@fifi.org>
In-Reply-To: <87llpms8yr.fsf@ceramic.fifi.org>
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

>>>>> " " == Philippe Troin <phil@fifi.org> writes:

     > From my reading of the patch, it supersedes the old patch, and
     > is only
     > necessary on the client. Is also does not compile :-)

Yeah, I admit I didn't test it out...

     > Here's an updated patch which does compile.

Thanks.

     > I am still running tests, but so far it looks good (that is all
     > locks are freed when a process with locks running on a NFS
     > client is killed).

Good...

There are still 2 other issues with the generic POSIX locking code.
Both issues have to do with CLONE_VM and have been raised on
linux-kernel & linux-fsdevel. Unfortunately they met with no response,
so I'm unable to pursue...

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
