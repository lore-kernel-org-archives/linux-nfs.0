From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: linux 2.4.18-5 nfs/rpc problem
Date: 10 Oct 2003 15:44:50 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsk77c27yl.fsf@charged.uio.no>
References: <6FF58CD33A029D458692432F07B85AB713FB9D@newmail>
	<1065805973.874.41.camel@blackmagic> <shsoewo2a4l.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Guzovsky, Eduard" <Edg@CROSSBEAMSYS.COM>,
	  "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A83CB-0006O2-00
	for <nfs@lists.sourceforge.net>; Fri, 10 Oct 2003 12:45:03 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A83CA-0008OY-TB
	for nfs@lists.sourceforge.net; Fri, 10 Oct 2003 12:45:03 -0700
To: David Jeffery <david_jeffery@adaptec.com>
In-Reply-To: <shsoewo2a4l.fsf@charged.uio.no>
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

>>>>> " " == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

     > There is indeed one case where this is not being done: in
     > page_launder() you only have a lock on the page. This means
     > that you may end up calling nfs_wait_on_request() in order to
     > flush out a page only to discover that it called iput() from
     > beneath you and is now waiting in clear_inode() on your page
     > lock.

Sorry. I meant 'shrink_cache()'. page_launder() probably disappeared
around 2.4.10 8-).

The point was that writepage() should be the only case where the above
is a problem. I believe readpage does not suffer from the same issue
since it can only be called while the file is still open...

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
