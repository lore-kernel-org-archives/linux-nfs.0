From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Debian, SIGPIPE, "libnfsidmap", and init.d vs. umount
Date: Mon, 6 Dec 2004 13:29:15 +1100
Message-ID: <16819.50171.937537.667604@cse.unsw.edu.au>
References: <20041204221504.GD6146@perlsupport.com>
	<16819.43303.95619.661063@cse.unsw.edu.au>
	<20041206020506.GJ6146@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cb8dT-0007uv-4B
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 18:29:59 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cb8dM-0004wj-Q9
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 18:29:56 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Sunday December 5
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

On Sunday December 5, chip@pobox.com wrote:
> According to Neil Brown:
> > On Saturday December 4, chip@pobox.com wrote:
> > > Debian needs a bugfix release of nfs-utils, because of the SIGPIPE
> > > bug.  This being my job, I figured I could grab the HEAD version of
> > > nfs-utils.  And since the Debian sarge release is coming up soon (no,
> > > really), I hoped I'd find something unlikely to crash; instead I'm
> > > having difficulty with the build.
> > 
> > I use "./configure --disable-nfsv4 --disable-gss"  but you might not
> > want to...
> 
> Well, that could work, actually.  Do you think that the changes since
> March 24 -- other than GSS and NFSv4 -- are valuable and safe?

Well... there is also the "high availability" (ha) statd/mountd stuff,
but I think that becomes a no-op if you don't use the "-H" flag to the
respective programs.
Apart from that there are a couple of bug fixes that could be
significant in some circumstances.

I think "I think so" is about the best I can do, as I personally
haven't done a lot of testing, and testing makes a big difference to
confidence levels.

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
