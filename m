From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd GRANT_MSG RPC callback
Date: Fri, 10 Sep 2004 12:22:47 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094833367.8605.23.camel@lade.trondhjem.org>
References: <OFEFF11E74.090F2AA4-ON88256F09.00709621-88256F09.00712392@us.ibm.com>
	 <1094676655.8363.47.camel@lade.trondhjem.org>
	 <1094699316.19981.79.camel@hole.melbourne.sgi.com>
	 <20040909125625.GC11991@fieldses.org>
	 <1094784664.19981.194.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Marc Eshel <eshel@almaden.ibm.com>, Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5oEG-0003TN-Mz
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 09:26:28 -0700
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C5oE7-0004O0-Kb
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 09:26:25 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1094784664.19981.194.camel@hole.melbourne.sgi.com>
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

P=E5 to , 09/09/2004 klokka 22:51, skreiv Greg Banks:

> Cool.  I presume you'll be adding a field to the svc_procedure struct
> to indicate whether an export is necessary and fiddling with the order
> of code around the call to svc_authenticate() in svc_process() ?

I have already added pg_authenticate() into svc_program for this very
purpose.

The NFSv4 delegation callback makes use of it to provide its own
AUTH_UNIX authentication (for as long as the common one remains borken)
and to check for whether or not we've got an NFSv4 mount for this
server. The lockd GRANTED stuff, which wants exactly the same type of
check, can just reuse this.

nfsd and the remaining lockd code can use that same hook to add domain
checking to its AUTH_UNIX stuff.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
