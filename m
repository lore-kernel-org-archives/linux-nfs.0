From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: very strange nfs errors with nfsroot
Date: Tue, 24 Aug 2004 12:08:11 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093363691.5745.64.camel@lade.trondhjem.org>
References: <412B5B3A.6070600@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BzdqP-0006C2-8d
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 09:08:21 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BzdqN-0003d1-TX
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 09:08:21 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <412B5B3A.6070600@bio.ifi.lmu.de>
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

P=E5 ty , 24/08/2004 klokka 11:14, skreiv Frank Steiner:

> Here are the symptoms:
> - It all started when on about every third boot, the clients
>    complained
>    "ln: /etc/local/printcap: File exists
>     Error: Could not link shared file /etc/local/printcap"
>=20
>    That was caused by a piece of code:
>=20
>    for name in $SHARES
>    do
>      if ! ( rm -f $name && ln -s $COMMON/$name $name )
>      then
>        exitstatus=3D1
>        echo "Error: Could not link shared file $name"
>      fi
>    done

Is the /etc/local shared by all clients? If so, your script is buggy
since it assumes that some other client cannot come in and ln before you
do (this is a prime example of what is known as a "race condition").

As for the ESTALE error. Again, if some other client is screwing with
deleting and recreating the soft link on the server, then ESTALE is
entirely expected behaviour. I suggest you read up on the NFS cache
consistency promises.

Cheers,
  Trond


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
