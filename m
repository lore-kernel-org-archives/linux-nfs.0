From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: mmap() and NFS server performance
Date: Mon, 16 Dec 2002 15:50:50 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15869.59466.167433.194706@charged.uio.no>
References: <3DFA4C9A.50101@geodev.com>
	<shsadj826bt.fsf@charged.uio.no>
	<3DFDE455.1000004@geodev.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18NwaC-0006t1-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 06:51:00 -0800
To: Matthew Mitchell <matthew@geodev.com>
In-Reply-To: <3DFDE455.1000004@geodev.com>
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

>>>>> " " == Matthew Mitchell <matthew@geodev.com> writes:

     > 1) What would you like to see, tcpdump/snoop wise, to verify
     >    this?

nfsstat on the client should normally tell you how often you are
seeing RPC retransmits.

     > 2) Could UDP service really be causing this order of magnitude
     >    slowdown?

Certainly: retransmissions follow an *exponential* backoff rule. For
that reason, it doesn't take a very high percentage of retransmissions
before you see a large impact.

     > 3) Is TCP server code "ready enough" for production use?  In
     >    our case we
     > don't mind some occasional bugs, but it needs to be able to
     > stay working under reasonable load for a day or so at a time
     > for us to get anything done ("Stale NFS file handle" is a
     > scourge...).

That is more of a question for Neil Brown, but I personally don't have
any particularly bad experiences to report.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
