From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Thu, 26 Feb 2004 14:20:10 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0402261415410.24606-100000@kenzo.iwr.uni-heidelberg.de>
References: <32895.207.214.87.84.1077799785.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: Olaf Kirch <okir@suse.de>, Greg Banks <gnb@melbourne.sgi.com>,
        Shantanu Goel <sgoel01@yahoo.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwLSt-0007ke-CN
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 05:22:11 -0800
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AwLR3-0002Gp-Tt
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 05:20:18 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <32895.207.214.87.84.1077799785.squirrel@webmail.uio.no>
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

On Thu, 26 Feb 2004 trond.myklebust@fys.uio.no wrote:

> P=E5 to , 26/02/2004 klokka 00:41, skreiv Olaf Kirch:
> > What about modifying __rpc_sleep_on to put sync tasks always
> > at the head of the queue? This way sync tasks get priority when
> > it comes to call reservation.
>=20
> How do you avoid the inverse problem that async tasks end up never maki=
ng
> any progress?

How about having a ratio (that can be changed from userland) between
sync and async operations ? Let's say that you move 3 sync ops at the
head of the queue then let 1 async one go through. However, for this
to be done efficiently it's probably better to not have only one queue
but more and then take one or more ops from the head of each queue
corresponding to the ratio.

--=20
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De




-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
