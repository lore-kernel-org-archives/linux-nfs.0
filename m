From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: Random UDP port assignment for rpc.statd
Date: Sun, 20 Feb 2005 19:01:20 +0100
Message-ID: <20050220180120.GA702@s>
References: <20050220111312.GA3974@s> <20050220172131.GA19800@s> <1108921114.27120.51.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D2vOh-00028f-5w
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 10:01:35 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D2vOf-0001JW-Ev
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 10:01:35 -0800
Received: from mail-mx3.uio.no ([129.240.10.44] ident=[U2FsdGVkX19BJvs+pFWQhkkdVlhjFgIL76RNsAs/x8o=])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1D2vOa-00025p-Vy
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 19:01:29 +0100
Received: from 160.80-203-48.nextgentel.com ([80.203.48.160] helo=s.hn.org)
	by mail-mx3.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1D2vOX-0004zu-Sv
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 19:01:25 +0100
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1108921114.27120.51.camel@lade.trondhjem.org>
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

[Trond Myklebust]

> su den 20.02.2005 Klokka 18:21 (+0100) skreiv Haakon Riiser:

>> I almost forgot this one.  Does nfsd's mystery UDP port have
>> the same purpose as the one from statd, i.e. communication
>> with the portmapper?

> [...]
> The lockd daemon needs an extra port, but you can control that
> (and this control mechanism _should_ work) using the pseudofiles
> in /proc/sys/fs/nfs, or the kernel parameters lockd.udpport
> and lockd.tcpport.

Thanks, this works when I prefix udpport and tcpport with "nlm_".
But I see you already know that: :-)
http://www.ussg.iu.edu/hypermail/linux/kernel/0403.3/1915.html

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
