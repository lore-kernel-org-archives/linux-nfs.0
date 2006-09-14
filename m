From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Q] Why is my NFSv4 client trying to contact
	the	portmapper?
Date: Thu, 14 Sep 2006 13:46:54 -0400
Message-ID: <1158256014.5879.18.camel@lade.trondhjem.org>
References: <mailman.63002.1155542509.19399.nfs@lists.sourceforge.net>
	<a06240411c12deeab9cb6@[129.98.90.227]>
	<1158241846.5308.18.camel@lade.trondhjem.org>
	<a06240417c12f34ab04be@[129.98.90.227]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GNvIn-0000vU-RB
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 10:47:06 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GNvIo-0002Gm-7d
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 10:47:06 -0700
To: Maurice Volaski <mvolaski@aecom.yu.edu>
In-Reply-To: <a06240417c12f34ab04be@[129.98.90.227]>
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

On Thu, 2006-09-14 at 13:07 -0400, Maurice Volaski wrote:
> >  > So it appears the portmapper and TCP 111 is required after all.
> >>  What's going on?
> >
> >Are you using rpcsec_gss? The rpc.gssd daemon appears to never set the
> 
> No, neither computer even has the rpcsec_gss stuff installed.

All I can say, then, is that this works for me. The portmapper does
still need to be installed in order to let the servers register, but
that only means that you need to allow access from the loopback address:
127.0.0.1.

Note that the client needs a portmapper to be listening on 127.0.0.1
too, since it will attempt to register the NFSv4 callback channel as an
RPC service. This rather unnecessary requirement will hopefully
disappear when we fix the kernel RPC server code.

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
