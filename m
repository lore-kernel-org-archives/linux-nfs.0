From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSroot using NFSv4?
Date: Thu, 26 Oct 2006 22:48:47 -0700
Message-ID: <1161928127.6166.39.camel@lade.trondhjem.org>
References: <1161861313.454098c141626@stud.fbi.h-da.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GdKaV-0000ZW-Tc
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 22:49:03 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GdKaU-00066W-KO
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 22:49:05 -0700
To: glogow@fbihome.de
In-Reply-To: <1161861313.454098c141626@stud.fbi.h-da.de>
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

On Thu, 2006-10-26 at 13:15 +0200, glogow@fbihome.de wrote:
> Hi
> 
> I'm looking for some information on using Linux kernel NFSroot with NFSv4.
> 
> >From reading some documentation it seems that there are some additional daemons
> involved to mount NFSv4 exports on a client (idmapd, gssd (just for krb5?)).
> 
> Is it possible to run NFSv4 as a read-only NFSroot, without an initrd /
> initramfs, which would otherwise start these deamons and use a NFSv4 enabled
> mount and a pivot_root?

Not at this point. We may look into providing NFSroot support for NFSv4
if there is enough interest, but at the moment you will at least need an
idmapd in userland running before you attempt to mount the volume.

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
