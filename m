From: Chip Salzenberg <chip@pobox.com>
Subject: Re: CVS tag "nfs-utils-1-0-6" looks wrong
Date: Wed, 29 Oct 2003 19:07:13 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031030000713.GT29526@perlsupport.com>
References: <20031029162516.GE29526@perlsupport.com> <20031029163302.GF29526@perlsupport.com> <16288.21114.700966.163986@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AF0L7-0001Af-00
	for <nfs@lists.sourceforge.net>; Wed, 29 Oct 2003 16:07:01 -0800
Received: from topaz.cx
	([66.220.6.227] helo=mail.topaz.cx ident=mail)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AF0L7-0004rx-5I
	for nfs@lists.sourceforge.net; Wed, 29 Oct 2003 16:07:01 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16288.21114.700966.163986@notabene.cse.unsw.edu.au>
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

According to Neil Brown:
> When I use CVS to checkout nfs-utils, I don't get debian/po, but I do
> get etc/debian.

That's probably because your "cvs update" is missing the "-d" and "-P"
flags.

>    cvs add debian/po

Did it.

>    cvs remove etc/debian

Can't do it -- not the way you mean, anyway.  You can't really remove
a directory in CVS.  That's why there's a "-P" option to "cvs update".
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
