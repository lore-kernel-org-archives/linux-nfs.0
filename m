From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 8/9] SUNRPC: Store formatted addresses in private
	data	structure
Date: Wed, 18 Oct 2006 16:59:41 -0400
Message-ID: <1161205181.6095.153.camel@lade.trondhjem.org>
References: <20061012211247.8734.23147.stgit@ingres.dsl.sfldmi.ameritech.net>
	<20061012211521.8734.29674.stgit@ingres.dsl.sfldmi.ameritech.net>
	<1161203761.6095.137.camel@lade.trondhjem.org>
	<76bd70e30610181341i1da2eeadw70e5098f9f421973@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaIW9-0006cx-0u
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 14:00:01 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaIW4-0005bQ-0q
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 14:00:02 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30610181341i1da2eeadw70e5098f9f421973@mail.gmail.com>
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

On Wed, 2006-10-18 at 16:41 -0400, Chuck Lever wrote:
> On 10/18/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > On Thu, 2006-10-12 at 17:15 -0400, Chuck Lever wrote:
> > > Hide buffers that store formatted IP addresses in a private data structure
> > > maintained in net/sunrpc/xprtsock.c.
> >
> > Why? Aren't those generic?
> 
> Not necessarily.  A transport may choose to use a dynamic algorithm to
> generate the addresses, for example; in which case, it would have no
> need for such buffers.

Do we have such a user today, or do we expect to have one in the near
future? AFAIK the infiniband folks will be using standard IP addresses
too.

Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
