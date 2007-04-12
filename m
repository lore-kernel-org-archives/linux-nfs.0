From: David Liontooth <liontooth@cogweb.net>
Subject: /etc/exports continue line
Date: Thu, 12 Apr 2007 14:17:00 -0700
Message-ID: <461EA1CC.2050102@cogweb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hc6f8-0007os-0f
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 14:17:02 -0700
Received: from smtp-2.smtp.ucla.edu ([169.232.47.136])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hc6f8-0001lc-6n
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 14:17:04 -0700
Received: from mail.ucla.edu (mail.ucla.edu [169.232.47.145])
	by smtp-2.smtp.ucla.edu (8.13.8/8.13.8) with ESMTP id l3CLH11J003360
	for <nfs@lists.sourceforge.net>; Thu, 12 Apr 2007 14:17:01 -0700
Received: from [128.97.221.35] (clitunno.sscnet.ucla.edu [128.97.221.35])
	(authenticated bits=0)
	by mail.ucla.edu (8.13.8/8.13.8) with ESMTP id l3CLH0Mx011523
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Thu, 12 Apr 2007 14:17:01 -0700
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


I've been using \ to continue a line in /etc/exports, and ran into an
odd problem -- if you accidentally hit the TAB key after the continue
line and save, the entry becomes invalid. Since the TAB key is
invisible, it can be difficult to figure out what's going on.

I reported it as Debian bug 418491 to nfs-kernel-server, and the
maintainer responded by saying \ isn't a valid continue character.
Comments? I routinely do this sort of thing:

/spare \
        165.97.21.130(rw,no_root_squash,no_subtree_check,async) \
        165.97.21.132(rw,no_subtree_check,async) \
        165.97.21.133(rw,no_subtree_check,async) \
        165.97.21.134(rw,no_subtree_check,async) \
        165.97.21.135(rw,no_root_squash,no_subtree_check,async) \
        165.97.21.136(rw,no_subtree_check,async) \
        165.97.85.112(rw,no_subtree_check,async) \
        165.97.85.117(rw,no_subtree_check,async)

A lot easier to maintain that a single line. Is there an alternative way
to continue the line?

Cheers,
Dave


-------- Original Message --------
Subject: 	Re: Bug#418491: nfs-kernel-server: Lots of misleading error
messages if there's a TAB in /etc/exports
Date: 	Thu, 12 Apr 2007 16:06:27 +0200
From: 	Steinar H. Gunderson <sgunderson@bigfoot.com>
To: 	David Liontooth <liontooth@cogweb.net>, 418491-done@bugs.debian.org
References:
<20070410023140.32254.14380.reportbug@localhost.localdomain>
<20070411002242.GD8811@uio.no>



On Wed, Apr 11, 2007 at 02:22:42AM +0200, Steinar H. Gunderson wrote:
>> Try this: edit /etc/exports and add a TAB after a \ (continue line). For instance, mine uses
> \ isn't supported as continue line, TTBOMK.

Thus, closing this one; forgot to do so last time.

/* Steinar */
-- 
Homepage: http://www.sesse.net/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
