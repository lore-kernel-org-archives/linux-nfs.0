From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RedHat Rawhide Kernels
Date: 08 Aug 2002 22:21:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs1y99m78u.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ctmv-0006CM-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 13:21:42 -0700
To: Jeremy Sanders <jss@ast.cam.ac.uk>
In-Reply-To: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk>
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

>>>>> " " == Jeremy Sanders <jss@ast.cam.ac.uk> writes:

     > Just to let you guys know (as it's close to the current
     > thread), I'm getting very bad lock-ups using the current
     > rawhide kernel (2.4.18-7.94).  When I connet with a machine

I don't know about the server stuff, but the version of the client
patches that they appear to have included in 2.4.18-7.94 contains one
pretty nasty race in the RPC code that can cause significant
corruption.
I've already notified RH of this, and provided them with details on
how to fix it...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
