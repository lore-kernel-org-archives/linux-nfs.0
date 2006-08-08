From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Can we flush directory data when the ctime changes?
Date: Tue, 08 Aug 2006 10:35:02 -0400
Message-ID: <1155047702.5673.38.camel@localhost>
References: <17624.15554.514216.623190@cse.unsw.edu.au>
	<1155045918.5673.26.camel@localhost>  <44D89F4B.8080702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GASg8-0002SV-7h
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 07:35:32 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GASg7-0004u9-7D
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 07:35:32 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <44D89F4B.8080702@redhat.com>
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

On Tue, 2006-08-08 at 10:27 -0400, Peter Staubach wrote:
> This really does seem like a bug in the NetApp server.  With a change
> like this, a simple chmod(2) could cause the client to invalidate its
> caches...

Agreed.

Now what we could do to improve the client is to try to detect the loops
this sort of bug causes. I'll try to think a bit about that...

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
