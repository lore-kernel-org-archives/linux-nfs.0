From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: CVS tag "nfs-utils-1-0-6" looks wrong
Date: Thu, 30 Oct 2003 10:51:22 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16288.21114.700966.163986@notabene.cse.unsw.edu.au>
References: <20031029162516.GE29526@perlsupport.com>
	<20031029163302.GF29526@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AF063-0006aH-00
	for <nfs@lists.sourceforge.net>; Wed, 29 Oct 2003 15:51:27 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AF063-0002MV-7y
	for nfs@lists.sourceforge.net; Wed, 29 Oct 2003 15:51:27 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Thu, 30 Oct 2003 10:51:22 +1100
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Wednesday October 29
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

On Wednesday October 29, chip@pobox.com wrote:
> According to Chip Salzenberg:
> > Neil, do you know what went wrong with the CVS tags for 1.0.6?
> 
> BTW, the 1.0.6 tarball also omits debian/po/* adn includes the empty
> and obsolete directory etc/debian.

When I use CVS to checkout nfs-utils, I don't get debian/po, but I do
get etc/debian.

Did you
   cvs add debian/po
and
   cvs remove etc/debian
??

Could you do that (even if you think you did), then "cvs commit" and
let me know, and I will see what "cvs update" gives me.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
