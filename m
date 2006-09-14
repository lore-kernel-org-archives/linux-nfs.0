From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Q] Why is my NFSv4 client trying to contact
	the	portmapper?
Date: Thu, 14 Sep 2006 09:50:46 -0400
Message-ID: <1158241846.5308.18.camel@lade.trondhjem.org>
References: <mailman.63002.1155542509.19399.nfs@lists.sourceforge.net>
	<a06240411c12deeab9cb6@[129.98.90.227]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GNrcV-00037l-2q
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 06:51:11 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GNrcU-000352-G9
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 06:51:11 -0700
To: Maurice Volaski <mvolaski@aecom.yu.edu>
In-Reply-To: <a06240411c12deeab9cb6@[129.98.90.227]>
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

On Wed, 2006-09-13 at 13:44 -0400, Maurice Volaski wrote:
>  From where I can find documentation on NFSv4, it seems that only one 
> TCP port 2049 should be being used and the portmapper is no longer 
> used. Examples include
> 
> http://www.vanemery.com/Linux/NFSv4/NFSv4-no-rpcsec.html
> and
> http://nfsv4.bullopensource.org/doc/NFS3_NFS4_migration.pdf
> 
> But that doesn't seem to be the reality. I'm trying to mount a Gentoo 
> Linux server from a Gentoo Linux client (sudo mount -t nfs4 
> thewarehouse:/ /mnt/thewarehouse) and I even recompiled the client's 
> kernel to support only NFSv4 and I'm seeing this message on the 
> server end:
> 
> [portmap] connect from 129.98.90.163 to getport(nfs): request from 
> unauthorized host
> 
> So it appears the portmapper and TCP 111 is required after all. 
> What's going on?

Are you using rpcsec_gss? The rpc.gssd daemon appears to never set the
port in create_auth_rpc_client(). It therefore will require a portmap
lookup.

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
