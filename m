From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Can't callback server
Date: Fri, 08 Apr 2005 13:41:53 -0400
Message-ID: <1112982113.9974.47.camel@lade.trondhjem.org>
References: <BB1F4EFD574E9F409035BDA71C961250023B38@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJxUm-0002h7-F5
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 10:42:16 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DJxUl-0005Yo-QL
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 10:42:16 -0700
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
In-Reply-To: <BB1F4EFD574E9F409035BDA71C961250023B38@exchange.i-bn>
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

fr den 08.04.2005 Klokka 17:36 (+0200) skreiv Beschorner Daniel:
> After some tests it seems to be 2.6.11 related (when clients reboot), with
> 2.6.10 the message doesn't appear.
> Has anyone an idea?
> Are there a any NFS patches from .10 to .11 causing this I can revert for
> testing purposes?
> 
> Thank you
> Daniel
> 
> Apr  8 03:05:46 server rpc.statd[3203]: recv_rply: [127.0.0.1] RPC status 1
> Apr  8 03:06:04 server last message repeated 3 times
> Apr  8 03:06:10 server rpc.statd[3203]: Can't callback server (100021,4),
> giving up.

"RPC status 1" just translates as MSG_DENIED. In other words the
client's copy of rpc.statd is refusing to talk to the server. Could you
perhaps give us some details about your setup?

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
