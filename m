From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Disabling NFS client caching
Date: Tue, 21 Nov 2006 15:06:15 -0500
Message-ID: <1164139575.5310.46.camel@lade.trondhjem.org>
References: <9c8209a10611201824h608c11f3s5bf9957c4ce0abd4@mail.gmail.com>
	<1164084864.6377.30.camel@lade.trondhjem.org>
	<9c8209a10611211154p5091f0c2l5379989d611a31f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gmd5H-0002Kk-QK
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 13:23:15 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18fo+pFqhgTXp2CZy1OSGsJvjhMhlan/NE=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gmd5H-0003H2-RU
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 13:23:17 -0800
To: Murali Bashyam <mbcoder@gmail.com>
In-Reply-To: <9c8209a10611211154p5091f0c2l5379989d611a31f0@mail.gmail.com>
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

On Tue, 2006-11-21 at 11:54 -0800, Murali Bashyam wrote:
> 
> Thanks for the suggestion. I tried the O_DIRECT option with O_RDONLY,
> and i am still seeing a lot of reads not hitting the server, looks
> like they are being handled locally still. I've got the sizes and
> addresses page aligned. Is there anything else that needs to be done
> to bypass the caching? 

No. O_DIRECT will cause every read to be sent to the server.

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
