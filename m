From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Thread in red hat bugzilla about locking
Date: 13 Apr 2002 20:50:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs662vfn6h.fsf@charged.uio.no>
References: <1018675328.1594.79.camel@milo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16wSbQ-00012P-00
	for <nfs@lists.sourceforge.net>; Sat, 13 Apr 2002 11:50:24 -0700
To: seth vidal <skvidal@phy.duke.edu>
In-Reply-To: <1018675328.1594.79.camel@milo>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == seth vidal <skvidal@phy.duke.edu> writes:

     > Hey,
     >  has anyone here seen this bug:
     > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=59245

     > and seen if the stock kernels/nfs-utils suffer from this
     > problem?

     > I was going to test it but I figured I'd ask to see if its been
     > solved elsewhere already.

Never seen it... I thought we fixed all that code in 2.4.10.

Has somebody checked whether or not rpc.statd is notifying the server
that there has been a reboot?

Cheers,
   Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
