From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Debian, SIGPIPE, "libnfsidmap", and init.d vs. umount
Date: Sun, 5 Dec 2004 19:45:57 -0500
Message-ID: <20041206004557.GA14863@fieldses.org>
References: <20041204221504.GD6146@perlsupport.com> <16819.43303.95619.661063@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cb70k-0007Jv-O3
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 16:45:54 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1Cb70i-0003Tw-VK
	for nfs@lists.sourceforge.net; Sun, 05 Dec 2004 16:45:53 -0800
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

On Mon, Dec 06, 2004 at 11:34:47AM +1100, Neil Brown wrote:
> On Saturday December 4, chip@pobox.com wrote:
> > I gather that "libnfsidmap" is what I'll find in:
> > 
> >   http://www.citi.umich.edu/projects/nfsv4/linux/libnfsidmap/
> > 
> > Is there some reason this hasn't been made part of Debian already,
> > seeing as how it already contains Debian build infrastructure?
> 
> Probably just the lack of a certified debian developer to do it, but
> I'll let Bruce Fields answer further..

Yes, I've thrown together .deb's, which you should be able to get via
apt from http://www.citi.umich.edu/projects/nfsv4/debian.  I'm happy to
maintain them but need a debian developer to sponsor.

I sent Chip a number of messages about this, and he was cc:'d on some
messages about this to debian-mentors, so I'm a little suprised that
this is news.  Chip, am I getting lost in some spam filter or something?

> > Also, is it a bug or a feature that the NFS startup scripts know how
> > to mount special-purpose filesystems, but not unmount them?
> 
> A feature(?).
> 
> There is a need to mount, but no need to unmount.
> 
> It is a lot like there being a "modprobe" but no "rmmod".

Yes, I don't see any reason to unmount.--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
