From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Fri, 27 Apr 2007 09:42:48 -0400
Message-ID: <20070427134248.GB25126@salusa.poochiereds.net>
References: <4625204D.1030509@redhat.com>
	<17959.5245.635902.823441@notabene.brown>
	<462D79F0.4060800@redhat.com>
	<17965.39683.396108.623418@notabene.brown>
	<46302C01.2060500@redhat.com>
	<17968.15370.88587.653447@notabene.brown>
	<46315EED.9020103@redhat.com>
	<17969.37229.250000.895316@notabene.brown>
	<20070427111513.GA25126@salusa.poochiereds.net>
	<17969.61232.323762.29003@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>, Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhQip-00058y-Fk
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 06:42:51 -0700
Received: from ms-smtp-01.southeast.rr.com ([24.25.9.100])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhQip-0004dx-R3
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 06:42:54 -0700
In-Reply-To: <17969.61232.323762.29003@notabene.brown>
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

On Fri, Apr 27, 2007 at 10:40:16PM +1000, Neil Brown wrote:
> On Friday April 27, jlayton@poochiereds.net wrote:
> > On Fri, Apr 27, 2007 at 04:00:13PM +1000, Neil Brown wrote:
> > > 
> > > So if you need that, then I think it really must be implemented by
> > > something a lot like
> > >    echo -n /path/name > /proc/fs/nfs/nlm_unlock_filesystem
> > > 
> > > This is something that we could possible teach "fuser -k" about - so
> > > it can effectively 'kill' that part of lockd that is accessing a given
> > > filesystem.  It is useful to failover, but definitely useful beyond
> > > failover.
> > 
> > Just a note that I posted a patch ~ a year ago that did precisely that. The
> > interface was a little bit different. I had userspace echoing in a dev_t
> > number, but it wouldn't be too hard to change it to use a pathname instead.
> > 
> > Subject was:
> > 
> >     [PATCH] lockd: add procfs control to cue lockd to release all locks on a device   
> > 
> > ...if anyone is interested in having me resurrect it.
> > 
> > -- Jeff
> 
> http://lkml.org/lkml/2006/4/10/240
> 
> Looks like no-one ever replied.
> I probably didn't see it:  things on linux-kernel that don't have
> 'nfs' or 'raid' (or a few related strings) in the subject have at best
> an even chance of me seeing them.  I've just added 'lockd' to the list
> of important strings :-)
> 
> I would rather a path name, and would rather it came through the
> 'nfsd' filesystem, but those are fairly trivial changes.
> 
> nlm_traverse_files has changed a bit since then, but it should be
> easier to unlock based on filesystem with the current code
> (especially if we made the first arg a void*..).
> 
> NeilBrown
> 

Ok, I'll toss cleaning that patch up and reposting it on to my to-do list...

Wendy, it seems like you had some objection to this patch at the time, but
the nature of it escapes me. Do you recall what your concern with it was?

Thanks,
Jeff


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
