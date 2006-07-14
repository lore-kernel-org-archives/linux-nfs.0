From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [nfsv4] Native NFSv4 ACLs on Linux
Date: Fri, 14 Jul 2006 10:49:46 -0400
Message-ID: <1152888586.14027.18.camel@lade.trondhjem.org>
References: <200607141637.32246.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@ietf.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1OzY-0008RQ-6f
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 07:50:08 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G1OzX-0000wx-9Q
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 07:50:08 -0700
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <200607141637.32246.agruen@suse.de>
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

On Fri, 2006-07-14 at 16:37 +0200, Andreas Gruenbacher wrote:
> Hello,
> 
> This is to announce a prototype that implements NFSv4 ACLs natively on Linux. 
> So far, the implementation supports NFSv4 ACLs on Ext3 filesystems. The code 
> is functional, but hasn't seen a whole lot of testing so far.

Ooh. Interesting...

Are you planning on encoding the acl model that is being used directly
in the on-disk filesystem flags instead of relying on a mount option?
The incompatibilities between the two models is bound to cause trouble
if some administrator messes up the mount command line.

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
