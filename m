From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS corruption in 2.6.18.2?
Date: Thu, 16 Nov 2006 11:09:11 -0500
Message-ID: <1163693351.9593.14.camel@lade.trondhjem.org>
References: <50e235a50d0f2b4fb34eed1c840565e3@swip.net>
	<20061115172947.GM10830@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gkjo4-0004G9-W7
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 08:09:41 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18HDttE+wX+7aZbnBu+ScoyMA2JExN38PA=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gkjo3-0003dK-TU
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 08:09:42 -0800
To: Kasparek Tomas <kasparek@fit.vutbr.cz>
In-Reply-To: <20061115172947.GM10830@fit.vutbr.cz>
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

On Wed, 2006-11-15 at 18:29 +0100, Kasparek Tomas wrote:
> I have seen this behaviour with kernel 2.6.18 and above up to 19-rc4.
> Reported this, but no response.
> 
> http://lkml.org/lkml/2006/9/28/89

Your test script doesn't use any form of locking. How are you ensuring
that only one client has the file open at a time?

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
