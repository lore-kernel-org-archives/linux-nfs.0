From: David Chinner <dgc@sgi.com>
Subject: Re: review: don't block non-blocking writes when frozen
Date: Tue, 24 Apr 2007 09:13:37 +1000
Message-ID: <20070423231337.GN32602149@melbourne.sgi.com>
References: <20070423002616.GY32602149@melbourne.sgi.com>
	<20070423212715.GF13572@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Chinner <dgc@sgi.com>, nfs@lists.sourceforge.net,
	gnb@sgi.com, xfs-oss <xfs@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg7jN-0001YM-K4
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 16:14:01 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Hg7jP-0007gE-UJ
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 16:14:04 -0700
In-Reply-To: <20070423212715.GF13572@infradead.org>
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

On Mon, Apr 23, 2007 at 10:27:15PM +0100, Christoph Hellwig wrote:
> On Mon, Apr 23, 2007 at 10:26:16AM +1000, David Chinner wrote:
> > 
> > Prevent nfsds for blocking trying to write to a frozen filesystem
> > or a filesystem in the process of freezing.
> 
> Looks good for trees actually having support for non-blocking file
> I/O, which doesn't include mainline.  (So please don't send this
> upstead)

Yeah - you NACKed that a year ago based on the fact it would never
get used by mainline code:

http://marc.info/?l=linux-nfs&m=114683005119982&w=2

So, given the catch-22 you've just presented us can we revisit the
nfsd non-blocking I/O issue again?  This affects anyone using DM
snapshots on their NFS servers and has nothing to do with HSMs
or DMAPI...

FWIW, you can still do non-blocking userspace I/O to a file, so this
XFS patch is still valid for mainline (that's how I tested it).

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
