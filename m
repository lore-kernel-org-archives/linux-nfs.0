From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS Clients Increase
Date: Thu, 31 Mar 2005 11:32:54 -0500
Message-ID: <1112286774.12388.20.camel@lade.trondhjem.org>
References: <424C24C1.40808@wildcash.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DH2bZ-0002ER-U5
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 08:33:13 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DH2bY-00031o-3U
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 08:33:13 -0800
To: tech@wildcash.com
In-Reply-To: <424C24C1.40808@wildcash.com>
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

fr den 01.04.2005 Klokka 02:26 (+1000) skreiv Rudi Starcevic:

> I can find info and have increased the nfsd daemons to 16.
> This is a high as I can get it to go.
> Can I go higher?

Yes. "man rpc.nfsd"

> On the Linux client I have no been able to find how I can increase the max
> number of connecting client daemons.
> 
> Can anyone please advise on how to increase the limit for client 
> daemons, biod, with Linux?

There is no such thing as a "biod" on Linux. We use a single rpciod
daemon together with non-blocking I/O to drive all the asynchronous
requests.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
