From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: lockd GRANT_MSG RPC callback
Date: Fri, 10 Sep 2004 12:51:05 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094784664.19981.194.camel@hole.melbourne.sgi.com>
References: <OFEFF11E74.090F2AA4-ON88256F09.00709621-88256F09.00712392@us.ibm.com>
	 <1094676655.8363.47.camel@lade.trondhjem.org>
	 <1094699316.19981.79.camel@hole.melbourne.sgi.com>
	 <20040909125625.GC11991@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Marc Eshel <eshel@almaden.ibm.com>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5bTv-0002VF-SB
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 19:49:47 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C5bTb-0007Jk-Vv
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 19:49:31 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1C5bS5-0006jP-Ax
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 19:47:56 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040909125625.GC11991@fieldses.org>
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

On Thu, 2004-09-09 at 22:56, J. Bruce Fields wrote:
> On Thu, Sep 09, 2004 at 01:08:36PM +1000, Greg Banks wrote:
> > On Thu, 2004-09-09 at 06:50, Trond Myklebust wrote:
> > > OK. Bruce has promised to work on splitting out the "domain" code from
> > > the svcauth_unix code. Once that is done, we can fix up GRANT_MSG and
> > > NOTIFY as well as any other routines that do not need to be
> > > authenticated by rpc.mountd.
> > 
> > Any idea how long is this likely to take?
> 
> I'll try to have something out by early next week.

Cool.  I presume you'll be adding a field to the svc_procedure struct
to indicate whether an export is necessary and fiddling with the order
of code around the call to svc_authenticate() in svc_process() ?

> [...] So as a temporary workaround, lockd
> will work if the client lists the server in the exports file.

Ok, thanks.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
