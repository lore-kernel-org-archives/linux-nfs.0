From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: connectathon special test failure in recent kernels
Date: Thu, 17 Aug 2006 22:50:02 -0400
Message-ID: <20060818025001.GI6535@fieldses.org>
References: <76bd70e30608081220q75c6c0f2v18e5ebb309b1c201@mail.gmail.com>
	<1155079971.5731.22.camel@localhost>
	<76bd70e30608081959g6a76d7bcr1d78323630462f7c@mail.gmail.com>
	<44E486F3.2020600@RedHat.com>
	<76bd70e30608170938u4ddf999ah6d9fb718561e9982@mail.gmail.com>
	<44E4A24C.2080907@RedHat.com> <1155844468.5584.4.camel@localhost>
	<44E4D80C.7000101@RedHat.com> <1155854251.5594.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>, Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GDuR3-0008BG-DG
	for nfs@lists.sourceforge.net; Thu, 17 Aug 2006 19:50:13 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GDuR2-0005F8-4c
	for nfs@lists.sourceforge.net; Thu, 17 Aug 2006 19:50:13 -0700
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <1155854251.5594.3.camel@localhost>
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

On Thu, Aug 17, 2006 at 06:37:31PM -0400, Trond Myklebust wrote:
> On Thu, 2006-08-17 at 16:56 -0400, Steve Dickson wrote:
> > Trond Myklebust wrote:
> > > 
> > > Could you send us an example of 'fsx' output that demonstrates the
> > > problem?
> > hmmm... fsx? What does the fsx have to do with the special tests of
> > the connectathon failing... I guess I'm missing something...
> > anyways... I'll try to run some fsx test runs asaic...
> 
> fsx creates holes in files left, right and center, and then tests for
> correctness. If there is a problem with the read patch, and hole
> creation, then fsx should find it and provide you with a nice dump of
> what went wrong, where, and what sequence of events lead up to the
> problem.

The holey test run on its own also gives a pretty short simple test
case.--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
