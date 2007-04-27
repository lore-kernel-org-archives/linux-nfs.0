From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Fri, 27 Apr 2007 22:34:45 +0200
Message-ID: <20070427203444.GA28874@janus>
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
Cc: Christoph Hellwig <hch@infradead.org>, cluster-devel@redhat.com,
	Jeff Layton <jlayton@redhat.com>, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhX9R-00019U-UU
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 13:34:45 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhX9S-00027o-Qq
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 13:34:48 -0700
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
> > On Fri, Apr 27, 2007 at 03:17:10PM +0100, Christoph Hellwig wrote:
> >   
> >> In fact couldn't this be treated as a reexport with a NFSEXP_ flag
> >> meaning drop all locks to avoid creating new interfaces?
> >>     
> >
> > Off hand, I can't see any reason why that wouldn't work.  The code to
> > handle it would probably go in fs/nfsd/export.c:svc_export_parse().
> >
> >   
> Sign :( ... folks, we go back to the loop again. That *was* my first 
> proposal ...

I'm quite interested in _any_ patch which would allow me to drop
the locks obtained by NFS clients on a specific export, either by (1)
"exportfs -uh" or by (2) "echo /some/path > /proc/fs/nfsd/nlm_drop_lock"
as Neil mentioned.
I want to migrate virtual(*) NFS servers _including_ the locks without
having to tear down the whole machine. In my case "migration" is a sort
of scheduled failover: no HA or clusters involved.

At first, the "exportfs -uh" proposal (maybe fsid driven) seems "the
right thing" because after unexporting there's no valid case to preserve
the locks AFAICS. Unexport implies EACCES for subsequent NFS accesses
anyway and unexporting /cdrom for example is _required_ in order to be
able to umount and eject the thing. As it stands today, unexporting is
not even enough to be able to unmount it and that's not good. (the need
to having to unexport a /cdrom before being able to eject it is actually
a problem on its own -- a separate issue).

So why not drop the locks always upon unexport? Stupid question of course
because exporting anything will not send out any sm notifications so
that would break symmetry.


I'd prefer (2) "echo /some/path > /proc/fs/nfsd/nlm_drop_lock" because:

- Tying the -h (drop locks) option to -u (unexport) is too restrictive IMO.
  For one thing, there's a bug in the linux NFS client locking code (I
  reported this earlier) which results in locks not being removed from
  the server. It was not too difficult to reproduce and programs on the
  client will wait forever due to this. To handle these kind of situations
  I need (2) on the server.

- (2) may be useful for other NFS server setups: it is inherently more
  flexible.

- (2) does not depend on nfs-utils. It's simpler.


(*) virtual in this case means a UUID or IP based fsid= option and an
additional IP address on eth0 per export entry, such, that it becomes
possible to move an export entry + disk partition + local mount to
different hardware without needing to remount it on all <large number>
NFS clients.

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
