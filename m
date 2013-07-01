Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51534 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752681Ab3GATMm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 15:12:42 -0400
Date: Mon, 1 Jul 2013 15:12:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [patch/rfc] allow exported (and *not* exported) filesystems to
 be unmounted.
Message-ID: <20130701191238.GD19945@fieldses.org>
References: <20130605130541.5968d5c2@notabene.brown>
 <20130605034115.GD13110@ZenIV.linux.org.uk>
 <20130605161934.59ab6804@notabene.brown>
 <20130605133658.GE24193@fieldses.org>
 <20130606100512.1c701a64@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130606100512.1c701a64@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 06, 2013 at 10:05:12AM +1000, NeilBrown wrote:
> On Wed, 5 Jun 2013 09:36:58 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Wed, Jun 05, 2013 at 04:19:34PM +1000, NeilBrown wrote:
> > > On Wed, 5 Jun 2013 04:41:15 +0100 Al Viro <viro@ZenIV.linux.org.uk> wrote:
> > > 
> > > > On Wed, Jun 05, 2013 at 01:05:41PM +1000, NeilBrown wrote:
> > > > > 
> > > > > Hi Bruce,
> > > > >  this is a little issue that seems to keep coming up so I thought it might be
> > > > >  time to fix it.
> > > > > 
> > > > >  As you know, a filesystem that is exported cannot be unmounted as the export
> > > > >  cache holds a reference to it.  Though if it hasn't been accessed for a
> > > > >  while then it can.
> > > > > 
> > > > >  As I hadn't realised before sometimes *non* exported filesystems can be
> > > > >  pinned to.  A negative entry in the cache can pin a filesystem just as
> > > > >  easily as a positive entry.
> > > > >  An amusing, if somewhat contrived, example is that if you export '/' with
> > > > >  crossmnt and:
> > > > > 
> > > > >     mount localhost:/ /mnt
> > > > >     ls -l /
> > > > >     umount /mnt
> > > > > 
> > > > >  the umount might fail.  This is because the "ls -l" tried to export every
> > > > >  filesystem found mounted in '/'.  The export of "/mnt" failed of course
> > > > >  because you cannot re-export an NFS filesystem.  But it is still in the
> > > > >  cache.
> > > > >  An 'exportfs -f' fixes this, but shouldn't be necessary.
> > 
> > Yeah, ugh.  As a less contrived example, can the default v4 root export
> > lead to arbitrary filesystems being pinned just because a client tried
> > to mount the wrong path?
> 
> I think it can only pin filesystems that are exported, either explicitly or
> via a parent being exported with 'crossmnt'.

But see utils/mountd/v4root.c, and:

	[root@server ~]# exportfs -v
	/export <world>(rw,...)
	[root@server ~]# mount /mnt

		[root@pip4 ~]# mount pip4:/ /mnt/
		[root@pip4 ~]# ls -l /mnt/
		total 4
		drwxrwxrwt 3 root root 4096 Jun  7 10:34 export
		[root@pip4 ~]# 

	[root@server ~]# umount /mnt/
	umount: /mnt: target is busy.
	...
	[root@server ~]# grep /mnt /proc/net/rpc/nfsd.export/content 
	# /mnt	*()

> > Could the export cache be indexed on a path string instead of a struct
> > path?
> 
> Yes.  It would mean lots of extra pathname lookups and possibly lots of
> "d_path()" calls.

Right.  Ugh.  Still, struct path seems wrong as it's not something gssd
knows about, and there's not really a 1-1 mapping between the two (see
e.g. the recent complaint about the case where the struct path
represents a lazy-unmounted export
http://mid.gmane.org/<20130625191008.GA20277@us.ibm.com> ).

--b.
