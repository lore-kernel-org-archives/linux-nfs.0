From: Steve Dickson <SteveD@redhat.com>
Subject: Re: connectathon special test failure in recent kernels
Date: Thu, 17 Aug 2006 11:10:43 -0400
Message-ID: <44E486F3.2020600@RedHat.com>
References: <76bd70e30608081220q75c6c0f2v18e5ebb309b1c201@mail.gmail.com>	<1155079971.5731.22.camel@localhost>
	<76bd70e30608081959g6a76d7bcr1d78323630462f7c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GDjWJ-0007dW-7l
	for nfs@lists.sourceforge.net; Thu, 17 Aug 2006 08:10:55 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GDjWI-00053r-EC
	for nfs@lists.sourceforge.net; Thu, 17 Aug 2006 08:10:55 -0700
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <76bd70e30608081959g6a76d7bcr1d78323630462f7c@mail.gmail.com>
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



Chuck Lever wrote:
> On 8/8/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
>>On Tue, 2006-08-08 at 15:20 -0400, Chuck Lever wrote:
>>
>>>Is the connectathon holey test failure going to be fixed before 2.6.18
>>>is finalized?
>>
>>Depends. Have you traced it in order to figure out what is wrong?
> 
> 
> Ah.  Bruce reported this problem a while back, and said that it goes
> away if one of your recent patches to fs/nfs/read.c is reverted.
> Bruce?
Well the patch in question is:

commit 1de3fc12ea085690547a54b6efa01c7348f1cebd
tree ea865786120cfcefac563c54693fef8d3d718f10
parent 128e6ced247cda88f96fa9f2e4ba8b2c4a681560
author Trond Myklebust <Trond.Myklebust@netapp.com> Thu, 25 May 2006
09:40:44 -0400
committer Trond Myklebust <Trond.Myklebust@netapp.com> Fri, 09 Jun 2006
17:34:03 -0400

NFS: Clean up and fix page zeroing when we have short reads

The code that is supposed to zero the uninitialised partial pages when
the server returns a short read is currently broken: it looks at the
nfs_page wb_pgbase and wb_bytes fields instead of the equivalent
nfs_read_data values when deciding where to start truncating the page.

Also ensure that we are more careful about setting PG_uptodate
before retrying a short read: the retry will change the nfs_read_data
args.pgbase and args.count.

I'm looking into now... but this patch definitely breaks the holy
test...

steved.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
