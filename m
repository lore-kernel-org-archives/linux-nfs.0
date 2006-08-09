From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 02/25] SUNRPC: Create a helper to tell whether
	a	transport is bound
Date: Wed, 09 Aug 2006 11:37:00 -0400
Message-ID: <1155137820.5731.92.camel@localhost>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
	<20060809145853.3914.64708.stgit@picasso.dsl.sfldmi.ameritech.net>
	<1155136792.5731.84.camel@localhost>
	<76bd70e30608090827i60102c94q1181550469de4af7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAq7t-00040z-6g
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:37:45 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GAq7t-0000Lv-8z
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:37:45 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30608090827i60102c94q1181550469de4af7@mail.gmail.com>
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

On Wed, 2006-08-09 at 11:27 -0400, Chuck Lever wrote:
> The portmapper can set the port number to zero in the case of an
> rpcbind error.  In that case, the transport should remain unbound.

Validating the results of the rpcbind operation is a different issue.
You can test for port == 0 first, then do a test_and_set_bit()...

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
