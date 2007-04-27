From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Fri, 27 Apr 2007 12:31:29 -0400
Message-ID: <20070427163129.GI32278@fieldses.org>
References: <46302C01.2060500@redhat.com>
	<17968.15370.88587.653447@notabene.brown>
	<46315EED.9020103@redhat.com>
	<17969.37229.250000.895316@notabene.brown>
	<20070427111513.GA25126@salusa.poochiereds.net>
	<17969.61232.323762.29003@notabene.brown>
	<20070427134248.GB25126@salusa.poochiereds.net>
	<20070427141710.GA11484@infradead.org>
	<20070427154259.GF32278@fieldses.org> <46321870.7000607@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>,
	Neil Brown <neilb@suse.de>, cluster-devel@redhat.com,
	nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhTM7-0006qj-KG
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 09:31:35 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HhTM8-00011C-Qz
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 09:31:38 -0700
In-Reply-To: <46321870.7000607@redhat.com>
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

On Fri, Apr 27, 2007 at 11:36:16AM -0400, Wendy Cheng wrote:
> J. Bruce Fields wrote:
> >On Fri, Apr 27, 2007 at 03:17:10PM +0100, Christoph Hellwig wrote:
> >  
> >>In fact couldn't this be treated as a reexport with a NFSEXP_ flag
> >>meaning drop all locks to avoid creating new interfaces?
> >>    
> >
> >Off hand, I can't see any reason why that wouldn't work.  The code to
> >handle it would probably go in fs/nfsd/export.c:svc_export_parse().
> >
> >  
> Sign :( ... folks, we go back to the loop again. That *was* my first 
> proposal ...

So you're talking about this and followups?:

	http://marc.info/?l=linux-nfs&m=115009204513790&w=2

I just took a look and couldn't find any complaints about that
approach.  Were they elsewhere?

I understand the frustration.  There's a balance betweeen on the one
hand, being willing to throw out some hard work and start over if
someone comes up with a real objection, and, on the other hand, sticking
to a design when you're convinced it's right.

I *really* appreciate good review, but I also try to avoid doing
something I don't like just because it seems to be the only way to make
somebody else happy....  If they've got a real point then I should be
able to understand it.  If not, then I risk doing all the work to make
them happy just to throw it away because I can't defend the approach in
the end, or because I find out I misunderstood their original point.

(Then again, sometimes I do just have to trust somebody.  And sometimes
I guess learning who can be trusted about what is part of the process.)

In this case I think the complaint about requiring fsid's on everything
is legimate, and the original approach of using the export was sensible.
But I haven't been paying as much attention as I should have, and I
probably missed something.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
