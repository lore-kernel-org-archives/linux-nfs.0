From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: RE: 'random' diskless clients hangs
Date: Sat, 6 Sep 2003 20:27:20 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0309062025520.7182-100000@kenzo.iwr.uni-heidelberg.de>
References: <NEBBIHNAFKJAFOHBHGCOCEJMEFAA.nfsmailinglist@heessels.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19vhmU-0002Ta-00
	for <nfs@lists.sourceforge.net>; Sat, 06 Sep 2003 11:27:30 -0700
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19vhmT-0003Su-O7
	for nfs@lists.sourceforge.net; Sat, 06 Sep 2003 11:27:29 -0700
To: nfsmailinglist@heessels.com
In-Reply-To: <NEBBIHNAFKJAFOHBHGCOCEJMEFAA.nfsmailinglist@heessels.com>
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
