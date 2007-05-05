From: Ian Kent <raven@themaw.net>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Sun, 06 May 2007 02:27:55 +0800
Message-ID: <1178389675.4559.29.camel@raven.themaw.net>
References: <46269362.5040608@amd.com>
	<1176948355.6422.72.camel@heimdal.trondhjem.org>
	<4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>
	<4627D303.8060009@amd.com>
	<1177020662.6628.30.camel@heimdal.trondhjem.org>
	<4627EBFC.2090704@amd.com>
	<462CFC92.2080201@amd.com>  <463B97E6.4030009@amd.com>
	<1178314889.6533.19.camel@heimdal.trondhjem.org>
	<1178379473.4559.24.camel@raven.themaw.net>
	<1178385472.6561.43.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Paul Krizak <paul.krizak@amd.com>, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HkOzA-0002zj-Ax
	for nfs@lists.sourceforge.net; Sat, 05 May 2007 11:28:00 -0700
Received: from out1.smtp.messagingengine.com ([66.111.4.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HkOzC-0006fU-Go
	for nfs@lists.sourceforge.net; Sat, 05 May 2007 11:28:03 -0700
In-Reply-To: <1178385472.6561.43.camel@heimdal.trondhjem.org>
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

On Sat, 2007-05-05 at 13:17 -0400, Trond Myklebust wrote:
> On Sat, 2007-05-05 at 23:37 +0800, Ian Kent wrote:
> > On Fri, 2007-05-04 at 17:41 -0400, Trond Myklebust wrote:
> > > On Fri, 2007-05-04 at 15:30 -0500, Gregory Baker wrote:
> > > > Are all NFS options from an export inherited by subsequent mounts since 
> > > > the upstream commit 54ceac4515986030c2502960be620198dd8fe25b?
> > 
> > I wish I'd payed more attention to the shared superblock patches but I
> > was consumed by autofs at the time. Even so I likely wouldn't have
> > realized the implications.
> > 
> > > > 
> > > > I'm pasting an email from a colleague at AMD that's also trying to gain 
> > > > an understanding of the new mount behavior (Paul Krizak)...
> > > > 
> > > > Thanks,
> > > > 
> > > > --Greg
> > > 
> > > If two mounts refer to the same _filesystem_ (i.e. the NFS server
> > > exports them with the same value for the 'fsid' attribute), then they
> > > will share the same options.
> > > 
> > > If you are trying to use different security models for different
> > > mountpoint, you should in any case be considering using different
> > > filesystems on the server: NFS filehandles are normally not tied to a
> > > pathname since they are required to remain the same after a
> > > cross-directory rename().
> > > The exception is if the file and the directory live on different
> > > filesystems (since then a cross-directory rename() is not permitted
> > > anyway) and so the filehandles will usually encode the fsid in some way
> > > or form.
> > > 
> > > IOW: if /foo and /bar refer to directories the same filesystem, then the
> > > server cannot figure out if the file baz.txt lives in one or the other
> > > directory. Giving /foo and /bar different security permissions is really
> > > the same as giving _both_ sets of permissions. Even if the server
> > > encodes the permissions in the filehandle (usually by recording the
> > > export point) then the client is free to spoof a filehandle for the same
> > > file with the other set of permissions.
> > 
> > I don't see how doing this on the client adds any security at all as the
> > spoofing issue is still present. It does prevent people from being able
> > to do read-only mounts for administrative purposes. Like when used to
> > guard against accidents rather than provide real security. But then I
> > see this isn't the only reason these patches were so important.
> 
> Why are people arguing that NFS should be working in a completely
> different fashion to all other filesystems? Fix the VFS to allow
> read-only bind mounts, and NFS will work just fine with that.

Sorry, I don't follow.
How does think affect a client doing two distinct mounts to a server.
Are you suggesting that such a bind mount should be done on the server
and then exported? I guess that would give us distinct super blocks.

> 
> The problem with the old behaviour was that it screwed people over by
> causing file caching to be inconsistent on the same client. IOW: if I
> wrote to the file on the read-write partition, then those changes would
> not be immediately guaranteed to be visible to a process that happened
> to read the file on the read-only partition.
> 
> > So is there "anything at all" we can do to change this behavior now,
> > apart from teaching mount to about it. Having the /etc/mtab
> > and /proc/mounts recording different mount options for a mount is wrong.
> > 
> > How should mount(8) handle the situation?
> 
> I'd rather like to have mount(2) handle the situation by returning an
> error if the mount options cannot be satisfied.
> 
> Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
