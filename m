From: <nfsmailinglist@heessels.com>
Subject: RE: 'random' diskless clients hangs
Date: Mon, 8 Sep 2003 20:37:07 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <NEBBIHNAFKJAFOHBHGCOIEKLEFAA.nfsmailinglist@heessels.com>
References: <Pine.LNX.4.44.0309062025520.7182-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19wZvT-0007PX-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Sep 2003 21:16:23 -0700
Received: from smtp2.mail.be.easynet.net ([212.100.160.76])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19wVpi-0002gT-By
	for nfs@lists.sourceforge.net; Mon, 08 Sep 2003 16:54:10 -0700
Received: from 212-100-181-21.adsl.easynet.be ([212.100.181.21] helo=SHEPHERD)
	by smtp2.mail.be.easynet.net with smtp (Exim 4.22)
	id 19wQr1-00073Y-U6
	for nfs@lists.sourceforge.net; Mon, 08 Sep 2003 20:35:12 +0200
To: <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.44.0309062025520.7182-100000@kenzo.iwr.uni-heidelberg.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Help!! We're closing to giving up on NFS.

We have tried multiple NICS and drivers on both server and client (eepro100,
e100, e1000).
We have tries both UDP and TCP.
We have tried multiple versions of nfs-utils.
We have tried multiple versions of the kernel.
We have tried multiple clients.
We have tried multiple switches.

Clients keep crashing unless we use rsize&wsize<=2048, but the load on
server and clients then get very high.


-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net]On Behalf Of Bogdan Costescu
Sent: zaterdag 6 september 2003 20:27
To: nfsmailinglist@heessels.com
Cc: nfs@lists.sourceforge.net
Subject: RE: [NFS] 'random' diskless clients hangs


On Sat, 6 Sep 2003 nfsmailinglist@heessels.com wrote:

> Driver is the default from kernel linux-2.4.20-18.7:
> CONFIG_EEPRO100=y

Could you also try using the e100 driver ? eepro100 seems to be
unmaintained lately while the guys at Intel actively support e100.

-

Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
