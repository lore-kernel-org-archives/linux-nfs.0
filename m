From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: lockd GRANT_MSG RPC callback
Date: Thu, 9 Sep 2004 14:50:14 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040909185014.GA14863@fieldses.org>
References: <20040909125625.GC11991@fieldses.org> <OFB813A46E.D2D0BEF5-ON88256F0A.00644E81-88256F0A.0064C59E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5Tzt-0001OD-3a
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 11:50:17 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C5Tzs-0007G4-HI
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 11:50:17 -0700
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OFB813A46E.D2D0BEF5-ON88256F0A.00644E81-88256F0A.0064C59E@us.ibm.com>
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

On Thu, Sep 09, 2004 at 11:20:41AM -0700, Marc Eshel wrote:
> "J. Bruce Fields" <bfields@fieldses.org> wrote on 09/09/2004 05:56:25 AM:
> 
> > On Thu, Sep 09, 2004 at 01:08:36PM +1000, Greg Banks wrote:
> > > On Thu, 2004-09-09 at 06:50, Trond Myklebust wrote:
> > > > OK. Bruce has promised to work on splitting out the "domain" code
> from
> > > > the svcauth_unix code. Once that is done, we can fix up GRANT_MSG and
> > > > NOTIFY as well as any other routines that do not need to be
> > > > authenticated by rpc.mountd.
> > >
> > > Any idea how long is this likely to take?
> 
> > I'll try to have something out by early next week.
> 
> > The problem is that the server-side rpc code is checking *all* incoming
> > auth_unix and auth_null requests (whether for nfsd or for some other
> > service) against the exports table.  So as a temporary workaround, lockd
> > will work if the client lists the server in the exports file.  Or
> > something like
> 
> It worked only after I mounted a client export on the server side.
> 
> > echo nfsd server.ip.address.here 0x7FFFFFFF server.name.here \
> > >/proc/net/rpc/auth.unix.ip/content
> >
> > may also work, though the entry you add to the auth.unix.ip cache by
> > doing this may end up getting purged next time you run exportfs.
> 
> It doesn't look like you can write to /proc/net/rpc/auth.unix.ip/content.

Have you mounted the nfsd filesystem at /proc/fs/nfs/?  (See the
exportfs(8) man page.)

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
