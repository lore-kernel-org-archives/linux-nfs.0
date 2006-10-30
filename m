From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: rdma mount support
Date: Sun, 29 Oct 2006 21:54:38 -0500
Message-ID: <1162176878.5545.92.camel@lade.trondhjem.org>
References: <4545403B.8050500@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GeNIk-0002ux-5N
	for nfs@lists.sourceforge.net; Sun, 29 Oct 2006 18:55:02 -0800
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GeNIi-0000FX-Jo
	for nfs@lists.sourceforge.net; Sun, 29 Oct 2006 18:55:03 -0800
To: Brett Jon Grandbois <brettg@sgi.com>
In-Reply-To: <4545403B.8050500@sgi.com>
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

On Mon, 2006-10-30 at 10:58 +1100, Brett Jon Grandbois wrote:
> Hi,
> 
> Are there any plans on the horizon for including NFS/RDMA support in
> nfs-utils?  We're using the NFS/RDMA ONC Transport but that currently
> requires the use of a separate nfsrdmamount binary and we'd eventually
> like to just call standard mount(8).  Are there any plans for adding
> RDMA support in mount.nfs?  Or maybe adding a whole separate
> mount.nfsrdma?  There are a few ways to go with this and we'd like to
> find out if there's a direction everyone is leaning towards so we don't
> end up taking the wrong one.

I suppose we will eventually put RDMA support into mount.nfs, but given
that there is no support for NFS/RDMA in the kernel itself yet, there
should be no hurry.

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
