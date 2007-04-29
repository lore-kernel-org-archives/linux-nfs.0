From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Sun, 29 Apr 2007 16:13:53 -0400
Message-ID: <20070429201353.GA23531@fieldses.org>
References: <46315EED.9020103@redhat.com>
	<17969.37229.250000.895316@notabene.brown>
	<20070427111513.GA25126@salusa.poochiereds.net>
	<17969.61232.323762.29003@notabene.brown>
	<20070427134248.GB25126@salusa.poochiereds.net>
	<20070427141710.GA11484@infradead.org>
	<20070427154259.GF32278@fieldses.org> <46321870.7000607@redhat.com>
	<20070427163129.GI32278@fieldses.org>
	<17970.30655.854497.849900@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, cluster-devel@redhat.com,
	nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiFmU-0006d2-Hj
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 13:14:02 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiFmV-00068f-Nj
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 13:14:05 -0700
In-Reply-To: <17970.30655.854497.849900@notabene.brown>
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

On Sat, Apr 28, 2007 at 08:22:55AM +1000, Neil Brown wrote:
> A flag to unexport cannot work because we don't call unexport - we
> just flush a kernel cache.
> 
> A flag to export is just .... weird.  All the other export flags are
> state flags.  This would be an action flag.  They are quite different
> things.   Setting a state flag again is a no-op.  Setting an action
> flag again has a very real effect.

In this case the second set shouldn't have any effect--whatever flag is
set should prevent further locks from being accepted, shouldn't it?  (If
it matters.)

> Also, each filesystem is potentially exported multiple times for
> different sets of clients.  If such a flag (whether on 'export' or
> 'unexport') just said "remove locks from this set of clients" it
> wouldn't meet the needs, and if it said "remove all locks" it would be
> a very irregular interface.

The same could be said of the "fsid=" option on exports.  It doesn't
make sense to provide different filehandle- or path- name spaces
depending on the IP address of a client.  If my laptop changes IP
address, then I can (grudgingly) accept the fact that the server may
have to deny me access that I had before--maybe it just can't trust the
network I moved to for whatever reason--but I'd really rather it didn't
suddenly start giving me paths, or different filehandles, or different
semantics (like sync vs. async).

So the export interface is already being used for stuff that's really
intended to be per-filesystem rather than per-(filesystem, client) pair.

> > So you're talking about this and followups?:
> > 
> > 	http://marc.info/?l=linux-nfs&m=115009204513790&w=2
> > 
> > I just took a look and couldn't find any complaints about that
> > approach.  Were they elsewhere?
> 
> https://www.redhat.com/archives/linux-cluster/2006-June/msg00101.html
> 
> Is where I said that I don't like the unexport flag.

Got it, thanks.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
