From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: debugging hanging locks
Date: Mon, 16 Aug 2004 20:22:39 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092702159.11722.77.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0408161741020.5649@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bwrms-0001QL-Vn
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 17:25:14 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bwrks-0001ZE-Pr
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 17:25:14 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0408161741020.5649@harp.ngdc.noaa.gov>
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

P=E5 m=E5 , 16/08/2004 klokka 19:47, skreiv Ara.T.Howard:

> which, i imagine, leaves some phantom process/lock hanging around with th=
e old
> file handle.  my questions are
>=20
>    - what could cause this type of random hanging

a client that fails to clean up after itself.

>    - how does one tell, on server, who has what locks

Not much you can do beyond 'cat /proc/locks'. That will tell you whether
or not a lock is held, and will also give you the pid of the remote
process that holds the lock (in the 4th column).

Cheers
  Trond


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
