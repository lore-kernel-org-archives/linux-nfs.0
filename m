From: Chip Salzenberg <chip@pobox.com>
Subject: Re: Debian, SIGPIPE, "libnfsidmap", and init.d vs. umount
Date: Sun, 5 Dec 2004 21:05:07 -0500
Message-ID: <20041206020506.GJ6146@perlsupport.com>
References: <20041204221504.GD6146@perlsupport.com> <16819.43303.95619.661063@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cb8Ff-0006gT-1g
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 18:05:23 -0800
Received: from perlsupport.com
	([66.220.6.226] helo=mail.perlsupport.com ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1Cb8Fc-0002VS-Pp
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 18:05:21 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16819.43303.95619.661063@cse.unsw.edu.au>
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

According to Neil Brown:
> On Saturday December 4, chip@pobox.com wrote:
> > Debian needs a bugfix release of nfs-utils, because of the SIGPIPE
> > bug.  This being my job, I figured I could grab the HEAD version of
> > nfs-utils.  And since the Debian sarge release is coming up soon (no,
> > really), I hoped I'd find something unlikely to crash; instead I'm
> > having difficulty with the build.
> 
> I use "./configure --disable-nfsv4 --disable-gss"  but you might not
> want to...

Well, that could work, actually.  Do you think that the changes since
March 24 -- other than GSS and NFSv4 -- are valuable and safe?
-- 
Chip Salzenberg              - a.k.a. -           <chip@pobox.com>
People are supposed to die for freedom.  Not the other way around.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
