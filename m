From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Mon, 7 Jun 2004 23:42:28 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040608034228.GA31761@fieldses.org>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org> <20040506230055.GC26968@polop.usc.edu> <20040507182543.GA27341@fieldses.org> <20040507213811.GL30964@polop.usc.edu> <20040507223414.GQ30964@polop.usc.edu> <16581.11543.342424.795946@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Garrick Staples <garrick@usc.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BXXVU-0005u8-OT
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 20:42:36 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BXXVU-0004Lq-7y
	for nfs@lists.sourceforge.net; Mon, 07 Jun 2004 20:42:36 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16581.11543.342424.795946@cse.unsw.edu.au>
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

On Tue, Jun 08, 2004 at 01:05:59PM +1000, Neil Brown wrote:
> > I'm looking at exportfs.c to see if I can add in a call to flush the caching
> > when unmounting, does the following seem reasonable?
> 
> The code already flushes the caches if anything has changed.
> 
> Towards the end of main() in exportfs.c there is:
> 
> 	xtab_export_write();
> 	if (new_cache)
> 		cache_flush(force_flush);

Ah!  I missed that.

> And to answer Bruce's subsequent question:
> > Can someone explaing what the reason was for adding the -f flag to
> > exportfs?
> Because it is useful for testing.  It should not be needed during
> normal running.

Got it, that makes more sense.  But if the only time "-f" is ever needed
is when there's a bug somewhere, then maybe it should just be removed,
or at least not documented?  Otherwise it seems like it's only likely to
cause confusion.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
