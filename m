From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] 64 bit ino support for NFS server
Date: Wed, 8 Aug 2007 17:01:04 -0400
Message-ID: <20070808210104.GO16171@fieldses.org>
References: <46B37DE6.80706@redhat.com> <46B38206.6050504@redhat.com>
	<20070804223256.GA1155@fieldses.org> <46BA2289.5060902@redhat.com>
	<20070808203555.GL16171@fieldses.org> <46BA2C3C.6040504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIseP-0005zw-Vq
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 14:01:05 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIseS-0001zg-Ne
	for nfs@lists.sourceforge.net; Wed, 08 Aug 2007 14:01:10 -0700
In-Reply-To: <46BA2C3C.6040504@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, Aug 08, 2007 at 04:49:00PM -0400, Peter Staubach wrote:
> J. Bruce Fields wrote:
> > So Samba is holding a write lease on the file on behalf of one of its
> > clients.  We never see an open from our NFSv2/v3 client--if it doesn't
> > have data cached, we may never even see a read, just access and
> > getattr--so we don't know to break that lease.
> >
> > (Actually, if a write lease, like an NFSv4 write delegation, is meant to
> > cover file attributes as well as data, then perhaps stat should break
> > write leases.  That sounds painful.)
> >
> > Anyway, the delay between the time the Samba client makes a change and
> > the time the NFS client sees it could be unbounded.  Whereas with
> > lease_get_mtime() the client will invalidate its cache and perform a
> > read, which *does* break the lease (in nfsd_open).
> >
> > But I agree that this is a strange compromise, and I'd like to
> > understand better what the semantics for sharing with a Samba client are
> > supposed to be.
> 
> Yes.

There's a similar problem in the case of, say, a server with both a v3
and a v4 client.  If the v4 client has a write delegation, then we break
close-to-open semantics if the v3 client doesn't see change attribute
updates from the v4 client's local modifications.  So that's what we
have cb_getattr for.  And if you don't want to do cb_getattr calls then
I guess you should be breaking the lease.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
