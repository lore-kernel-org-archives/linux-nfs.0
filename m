From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: df hangs on down nfs server mounted with hard,intr,
	can't kill
Date: Mon, 15 Mar 2004 12:03:26 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1079370206.2776.2.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DD25@lavender-fe.eng.netapp.com>
	 <20040310080910.GA21031@suse.de>
	 <1078946326.1940.35.camel@nidelv.trondhjem.org>
	 <20040315052106.GB17106@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B2vUz-0000QZ-2f
	for nfs@lists.sourceforge.net; Mon, 15 Mar 2004 09:03:33 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B2vUy-0005Ax-ID
	for nfs@lists.sourceforge.net; Mon, 15 Mar 2004 09:03:32 -0800
To: Yusuf Goolamabbas <yusufg@outblaze.com>
In-Reply-To: <20040315052106.GB17106@outblaze.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

P=E5 m=E5 , 15/03/2004 klokka 00:21, skreiv Yusuf Goolamabbas:

> Trond, Looking at the latest bk/web it seems some of your NFS4_ALL
> patches got in to mainline whilst 2.6.4-mm2 has some patches which akpm
> calls
>=20
> - Some significant NFS client enhancements: reads smaller than PAGE_SIZE
>   are no longer synchronous, support for smaller-than-PAGE_SIZE reads,
>   etc.
>=20
> http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=3D107931425909684&w=3D2
>=20
> Are these going to mature in -mm for a while or are they going to be
> 2.6.5 also ?

That's up to Andrew to decide: I've pushed them to him, and as
maintainer of the 2.6. tree, he gets to decide when they go in...

> Also, what's the status with the nfszerostats patch from Steve Dickson
> of Redhat
>=20
> http://people.redhat.com/steved/NFS/nfszerostats/

Chuck is currently working on some enhanced NFS statistics patches. I
imagine he will take steps to include Steve's patches in his work, and
then push them to me.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
