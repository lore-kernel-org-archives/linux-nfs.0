From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Thu, 13 May 2004 17:00:45 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040513210045.GF20649@fieldses.org>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org> <20040506230055.GC26968@polop.usc.edu> <20040507182543.GA27341@fieldses.org> <20040507213811.GL30964@polop.usc.edu> <20040507223414.GQ30964@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BONJy-00066q-4F
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 14:00:50 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BONJx-0001y8-N8
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 14:00:49 -0700
Received: from bfields by pumpkin.fieldses.org with local (Exim 4.33)
	id 1BONJt-0005oX-NY
	for nfs@lists.sourceforge.net; Thu, 13 May 2004 17:00:45 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <20040507223414.GQ30964@polop.usc.edu>
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

On Fri, May 07, 2004 at 03:34:15PM -0700, Garrick Staples wrote:
> I'm looking at exportfs.c to see if I can add in a call to flush the caching
> when unmounting, does the following seem reasonable?

Small note--I think your mailer must be messing up your patches--the
patch you appended e.g. has all tabs changed to spaces, and doesn't
apply.

> Force a cache flush if unexporting, and don't reread rmtab if we're using the
> new cache.

Hm. I don't understand why unexporting is a special case here; what
about changing export options?  When I run exportfs, I expect any
changes to take place before it returns, so I don't understand why
there's a "force_flush" option at all--shouldn't the kernel's export
tables be flushed every time exportfs is run?

Can someone explaing what the reason was for adding the -f flag to
exportfs?

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
