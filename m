From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: rpc.idmapd oops with latest NFS bits from your web site
Date: Thu, 10 Aug 2006 15:50:26 -0400
Message-ID: <20060810195026.GA29260@fieldses.org>
References: <76bd70e30608101221se9d6fb6l8bb50e93109c7a5b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GBGY8-0000Qz-8a
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 12:50:36 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GBGY7-0005rF-Gh
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 12:50:36 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30608101221se9d6fb6l8bb50e93109c7a5b@mail.gmail.com>
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

On Thu, Aug 10, 2006 at 03:21:41PM -0400, Chuck Lever wrote:
> I ran connectathon basic tests 20 times against a Linux NFSv3 server.
> At the end of the test I got this oops.  This is repeatable, but not
> 100% of the time.

The oops is from the client?

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
