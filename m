From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Strange behavior of executable bit
Date: Wed, 26 May 2004 12:11:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085587915.3763.12.camel@lade.trondhjem.org>
References: <40B44FE7.6010601@byggmek.lth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT10c-00017O-4O
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 09:12:02 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BT10b-0005Ja-Qt
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 09:12:01 -0700
To: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
In-Reply-To: <40B44FE7.6010601@byggmek.lth.se>
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

P=E5 on , 26/05/2004 klokka 04:05, skreiv Jonas Lindemann:
> Hi!
>=20
> We have an file server runninng RHEL3 and NFS. Clients are RHEL3 and=20
> FC1. We are having problems with an service that want's to change the=20
> executable bit on a file located on the NFS exported filesystem. The=20
> service is running on RHEL3.

So basically, you are changing the executable bit on the server, and
wondering why that changes isn't propagated instantly to the client?

It's 'cos NFS client poll the server for attribute changes. The mount
options that govern the polling period is documented in the "nfs"
manpage (see the ac* flags).

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
