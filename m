From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS client bug in 2.6.8-2.6.11
Date: Tue, 08 Mar 2005 01:47:55 -0500
Message-ID: <1110264475.11712.30.camel@lade.trondhjem.org>
References: <422D2FDE.2090104@develer.com>
	 <1110259831.11712.1.camel@lade.trondhjem.org>
	 <422D485F.5060709@develer.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: lkml <linux-kernel@vger.kernel.org>,
	Neil Conway <nconway_kernel@yahoo.co.uk>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8YVt-00046O-Pi
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:48:17 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D8YVs-0002hL-8x
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:48:17 -0800
To: Bernardo Innocenti <bernie@develer.com>
In-Reply-To: <422D485F.5060709@develer.com>
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

ty den 08.03.2005 Klokka 07:38 (+0100) skreiv Bernardo Innocenti:
> Trond Myklebust wrote:
> > ty den 08.03.2005 Klokka 05:53 (+0100) skreiv Bernardo Innocenti:
> > 
> >>Appears to be a client bug.
> > 
> > Why?
> 
> Two clients started showing the problem after
> being upgraded from FC2 to FC3, while the server
> remained unchanged.

Can you produce tcpdumps to back that up?

Neil's problem appeared rather to be server-related. Neither of us could
reproduce his problem when the server was exporting an XFS partition.

The other thing to try is to turn off subtree checking on the server.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
