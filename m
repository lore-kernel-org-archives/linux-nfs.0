From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: Random UDP port assignment for rpc.statd
Date: Sun, 20 Feb 2005 18:21:31 +0100
Message-ID: <20050220172131.GA19800@s>
References: <20050220111312.GA3974@s>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D2umA-0000XT-GQ
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 09:21:46 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D2um8-000650-I6
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 09:21:46 -0800
Received: from mail-mx3.uio.no ([129.240.10.44] ident=[U2FsdGVkX1+iDzTKz9GgOESoGwnLY3Gd5zGuZmAiPfc=])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1D2um3-0002vS-Rg
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 18:21:39 +0100
Received: from 160.80-203-48.nextgentel.com ([80.203.48.160] helo=s.hn.org)
	by mail-mx3.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1D2um0-0000vI-A0
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 18:21:36 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <20050220111312.GA3974@s>
Sender: nfs-admin@lists.sourceforge.net
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

> Btw, there's also a similar problem with nfsd:  In addition to
> the standard listening port at 2049, it always opens a random
> port in the high port range (32000-32768 or something like that).

I almost forgot this one.  Does nfsd's mystery UDP port have the
same purpose as the one from statd, i.e. communication with the
portmapper?

-- 
 Haakon


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
