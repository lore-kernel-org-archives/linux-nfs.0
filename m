From: Neil Brown <neilb@suse.de>
Subject: Re: [patch] see also exports(5) in nfsd(8)
Date: Mon, 21 Aug 2006 12:54:39 +1000
Message-ID: <17641.8303.913975.382508@cse.unsw.edu.au>
References: <200606101130.06312.vapier@gentoo.org>
	<200608051441.48286.vapier@gentoo.org>
	<17641.7237.545442.579048@cse.unsw.edu.au>
	<200608202246.49410.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GEzw8-0002oB-7u
	for nfs@lists.sourceforge.net; Sun, 20 Aug 2006 19:54:48 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GEzw6-0007Ys-Bg
	for nfs@lists.sourceforge.net; Sun, 20 Aug 2006 19:54:48 -0700
To: Mike Frysinger <vapier@gentoo.org>
In-Reply-To: message from Mike Frysinger on Sunday August 20
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

On Sunday August 20, vapier@gentoo.org wrote:
> On Sunday 20 August 2006 22:36, Neil Brown wrote:
> > On Saturday August 5, vapier@gentoo.org wrote:
> > > On Saturday 10 June 2006 11:30, Mike Frysinger wrote:
> > > > simple patch to add exports(5) to the SEE ALSO list in the nfsd(8) man
> > > > page
> > >
> > > ping ?
> >
> > Yes, email is a bit of a lossy transport...
> >
> > Send the patch again.  It might get through this  time:-)
> 
> attached, cheers

http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=commitdiff;h=257c0b18c81671335ae7b6864ed94845b4a917ec

Thanks.

NeilBrown

> -mike
> --- utils/nfsd/nfsd.man
> +++ utils/nfsd/nfsd.man
> @@ -38,6 +38,7 @@ the
>  program.
>  .SH SEE ALSO
>  .BR rpc.mountd (8),
> +.BR exports (5),
>  .BR exportfs (8),
>  .BR rpc.rquotad (8),
>  .BR nfsstat (8).

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
