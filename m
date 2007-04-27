From: Neil Brown <neilb@suse.de>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Sat, 28 Apr 2007 08:22:55 +1000
Message-ID: <17970.30655.854497.849900@notabene.brown>
References: <46302C01.2060500@redhat.com>
	<17968.15370.88587.653447@notabene.brown>
	<46315EED.9020103@redhat.com>
	<17969.37229.250000.895316@notabene.brown>
	<20070427111513.GA25126@salusa.poochiereds.net>
	<17969.61232.323762.29003@notabene.brown>
	<20070427134248.GB25126@salusa.poochiereds.net>
	<20070427141710.GA11484@infradead.org>
	<20070427154259.GF32278@fieldses.org> <46321870.7000607@redhat.com>
	<20070427163129.GI32278@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, cluster-devel@redhat.com,
	nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhYqo-0003Q9-Tp
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 15:23:39 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HhYqo-0003Jm-OH
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 15:23:40 -0700
In-Reply-To: message from J. Bruce Fields on Friday April 27
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

On Friday April 27, bfields@fieldses.org wrote:
> On Fri, Apr 27, 2007 at 11:36:16AM -0400, Wendy Cheng wrote:
> > J. Bruce Fields wrote:
> > >On Fri, Apr 27, 2007 at 03:17:10PM +0100, Christoph Hellwig wrote:
> > >  
> > >>In fact couldn't this be treated as a reexport with a NFSEXP_ flag
> > >>meaning drop all locks to avoid creating new interfaces?
> > >>    
> > >
> > >Off hand, I can't see any reason why that wouldn't work.  The code to
> > >handle it would probably go in fs/nfsd/export.c:svc_export_parse().
> > >
> > >  
> > Sign :( ... folks, we go back to the loop again. That *was* my first 
> > proposal ...

Yes, I grinned when I saw it too.
Your first proposal was actually a flag to  "unexport", where as
Christoph seems to be a flag to "export".  So there is at least a
subtle difference.

A flag to unexport cannot work because we don't call unexport - we
just flush a kernel cache.

A flag to export is just .... weird.  All the other export flags are
state flags.  This would be an action flag.  They are quite different
things.   Setting a state flag again is a no-op.  Setting an action
flag again has a very real effect.

Also, each filesystem is potentially exported multiple times for
different sets of clients.  If such a flag (whether on 'export' or
'unexport') just said "remove locks from this set of clients" it
wouldn't meet the needs, and if it said "remove all locks" it would be
a very irregular interface.

> 
> So you're talking about this and followups?:
> 
> 	http://marc.info/?l=linux-nfs&m=115009204513790&w=2
> 
> I just took a look and couldn't find any complaints about that
> approach.  Were they elsewhere?

https://www.redhat.com/archives/linux-cluster/2006-June/msg00101.html

Is where I said that I don't like the unexport flag.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
