From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: [PATCH] NFS mount hang fix
Date: Thu, 25 Nov 2004 13:29:02 +0100
Message-ID: <20041125122902.GE27939@fi.muni.cz>
References: <20041026141148.GM6408@fi.muni.cz> <20041026150640.GA24881@fieldses.org> <20041027121543.GH4724@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
   trond.myklebust@fys.uio.no, neilb@cse.unsw.edu.au, torvalds@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CXIkX-0006Eh-QE
	for nfs@lists.sourceforge.net; Thu, 25 Nov 2004 04:29:25 -0800
Received: from anor.ics.muni.cz ([147.251.4.35] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CXIkW-0007XL-RH
	for nfs@lists.sourceforge.net; Thu, 25 Nov 2004 04:29:25 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20041027121543.GH4724@fi.muni.cz>
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

Jan Kasprzak wrote:
: J. Bruce Fields wrote:
: : Changing those buffers to static strikes me as potentially dangerous--we
: : currently call the ->parse() methods under a semaphore, so it's safe for
: : now, but that might change some day and then there'll be an ugly race
: : condition.
: : 
: : Could you check whether the following fixes your problem?--b.
: : 
: 	Yes, it is OK with this patch. Thanks,
: 
	It seems this patch did not make it into Linus' tree
(at least it is not in 2.6.10-rc2). Can you resend it to Linus, please?

	Thanks,

-Yenya

-- 
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
| http://www.fi.muni.cz/~kas/   Czech Linux Homepage: http://www.linux.cz/ |
> Whatever the Java applications and desktop dances may lead to, Unix will <
> still be pushing the packets around for a quite a while.      --Rob Pike <


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
