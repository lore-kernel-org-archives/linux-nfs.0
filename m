From: Martin Spott <Martin.Spott@uni-duisburg.de>
Subject: Re: 2.6.0-test3-bk10-final regression getting out of hand
Date: 1 Nov 2003 16:29:52 GMT
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <bo0n20$c3q$1@foehn.quickstep.oche.de>
References: <20031031214851.0d6e604b.lista2@comhem.se>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AFyeA-0003I0-00
	for <nfs@lists.sourceforge.net>; Sat, 01 Nov 2003 08:30:42 -0800
Received: from sundancer.oche.de ([212.42.235.194])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AFyeA-0000Ho-7T
	for nfs@lists.sourceforge.net; Sat, 01 Nov 2003 08:30:42 -0800
Received: from foehn.quickstep.oche.de (localhost [127.0.0.1])
	by foehn.quickstep.oche.de (8.12.10/8.12.8) with ESMTP id hA1GTsTL012665
	for <nfs@lists.sourceforge.net>; Sat, 1 Nov 2003 17:29:54 +0100 (CET)
Received: (from news@localhost)
	by foehn.quickstep.oche.de (8.12.10/8.12.8/Submit) id hA1GTr3r012664
	for nfs@lists.sourceforge.net; Sat, 1 Nov 2003 17:29:53 +0100 (CET)
To: nfs@lists.sourceforge.net
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

Voluspa <lista2@comhem.se> wrote:

> I'm experiencing a serious NFS regression since 2.6.0-test3-bk10-final
> (bk-set determined now). Since that, along the road to 2.6.0-test9,
> something has gotten completely out of hand.

I can second the experiences on heavy trouble with 2.6.0-test[8,9] as
NFS _client_ against 2.4.2[1,2] as a server. I didn't have different
servers for testing against but I pretty much _believe_ it's a client
issue.

I only sticked to 'official' 2.6.0-test patches and I'd like to
express, that beginning with 2.6.0-test8 the NFS client is absolutely
unsuable for me. Trying to copy (with 'cp') a file from a local
filesystem to the server over NFS.V2 or .V3 completely freezes _any_
NFS traffic with the same server.
Are there any significant changes to the NFS client I should back out
for the purpose of finding the 'bug' ?

Martin.
-- 
 Unix _IS_ user friendly - it's just selective about who its friends are !
--------------------------------------------------------------------------


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
