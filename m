From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] introduce version field to struct nfs_clone_mount
Date: Tue, 08 May 2007 10:53:27 -0400
Message-ID: <1178636007.25317.6.camel@heimdal.trondhjem.org>
References: <1178560513.3898.32.camel@dhcp59-235.rdu.redhat.com>
	<20070508094120.GA11417@infradead.org>
	<1178626229.10325.155.camel@moss-spartans.epoch.ncsc.mil>
	<20070508121406.GA16701@infradead.org>
	<1178629266.6056.35.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	Eric Paris <eparis@redhat.com>, selinux@tycho.nsa.gov,
	James Morris <jmorris@namei.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlR4L-0007UW-UT
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 07:53:41 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19H199Cqj86qtJy19iWOMvPTdSi40xvEVQ=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HlR4N-000086-0s
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 07:53:40 -0700
In-Reply-To: <1178629266.6056.35.camel@moss-spartans.epoch.ncsc.mil>
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

On Tue, 2007-05-08 at 09:01 -0400, Stephen Smalley wrote:
> On Tue, 2007-05-08 at 13:14 +0100, Christoph Hellwig wrote:
> > On Tue, May 08, 2007 at 08:10:29AM -0400, Stephen Smalley wrote:
> > > The context= mount support in selinux already deals with ascii mount
> > > options; it is only the binary ones that need special handling.  And
> > > this isn't new functionality in selinux - it went upstream in 2004.
> > > Eric's patch is just fixing this corner case, not introducing new
> > > functionality.
> > 
> > It's still conceptually broken.  Names for ascii mount options are
> > the filesystems business, and context= is a perfectly fine name for
> > the file systems to use.  This kind of half-assed aspect oriented
> > programming using the LSM hooks is a completely nightmare because
> > it breaks this concept of a central registry of mount options valid
> > for a filesystem.
> 
> Is it really better to modify all the filesystems to support a context=
> mount option, particularly when they in turn just have to call into the
> security module to do anything with that option?  It is somewhat similar
> to the vfs fallbacks for *xattr for security attributes, which likewise
> isn't entirely nice to look at, but seems better than patching all the
> filesystems when the goal is to provide uniform interface across them
> all and the security module has to do all of the real work anyway.

No, but the filesystems with binary structures could easily provide the
context= information via their own call into the LSM code. That is
conceptually much cleaner than having LSM poke its dirty nose into
private data...

The fact that you set up a broken interface in 2004 is no excuse for not
doing it right today.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
