From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Disabling NFS client caching
Date: Mon, 20 Nov 2006 23:54:24 -0500
Message-ID: <1164084864.6377.30.camel@lade.trondhjem.org>
References: <9c8209a10611201824h608c11f3s5bf9957c4ce0abd4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmNeg-00083B-Gw
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 20:54:46 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18KEJ1V9+rft7SjIzhSzZJLFSO9es4761Y=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GmNeg-0001pI-FH
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 20:54:47 -0800
To: Murali Bashyam <mbcoder@gmail.com>
In-Reply-To: <9c8209a10611201824h608c11f3s5bf9957c4ce0abd4@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2006-11-20 at 18:24 -0800, Murali Bashyam wrote:
> Hi
> 
> Is there a way to disable Linux NFS client data caching (NOT
> attributes)?

'man 2 open'. Read all about O_DIRECT.

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
