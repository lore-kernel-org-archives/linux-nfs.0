From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: CVS tag "nfs-utils-1-0-6" looks wrong
Date: Thu, 30 Oct 2003 11:16:15 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16288.22607.450095.672518@notabene.cse.unsw.edu.au>
References: <20031029162516.GE29526@perlsupport.com>
	<20031029163302.GF29526@perlsupport.com>
	<16288.21114.700966.163986@notabene.cse.unsw.edu.au>
	<20031030000713.GT29526@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AF0UB-0002pY-00
	for <nfs@lists.sourceforge.net>; Wed, 29 Oct 2003 16:16:23 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AF0UB-00016C-24
	for nfs@lists.sourceforge.net; Wed, 29 Oct 2003 16:16:23 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Thu, 30 Oct 2003 11:16:15 +1100
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
> According to Neil Brown:
> > When I use CVS to checkout nfs-utils, I don't get debian/po, but I do
> > get etc/debian.
> 
> That's probably because your "cvs update" is missing the "-d" and "-P"
> flags.
> 

Ahhh.  Thanks.  "You learn something new every day".

I guess there is some reason why the whole thing isn't more
transparent....

The next release will have all the right bits in it.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
