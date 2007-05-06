From: Ian Kent <raven@themaw.net>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Sun, 06 May 2007 12:51:58 +0800
Message-ID: <1178427118.3773.15.camel@raven.themaw.net>
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
	<1178389675.4559.29.camel@raven.themaw.net>
	<1178390960.6561.61.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Paul Krizak <paul.krizak@amd.com>, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HkYj5-0000vi-9f
	for nfs@lists.sourceforge.net; Sat, 05 May 2007 21:52:03 -0700
Received: from out1.smtp.messagingengine.com ([66.111.4.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HkYj7-0002iH-OW
	for nfs@lists.sourceforge.net; Sat, 05 May 2007 21:52:06 -0700
In-Reply-To: <1178390960.6561.61.camel@heimdal.trondhjem.org>
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

On Sat, 2007-05-05 at 14:49 -0400, Trond Myklebust wrote:
> On Sun, 2007-05-06 at 02:27 +0800, Ian Kent wrote:
> > On Sat, 2007-05-05 at 13:17 -0400, Trond Myklebust wrote:
> > > Why are people arguing that NFS should be working in a completely
> > > different fashion to all other filesystems? Fix the VFS to allow
> > > read-only bind mounts, and NFS will work just fine with that.
> > 
> > Sorry, I don't follow.
> > How does think affect a client doing two distinct mounts to a server.
> > Are you suggesting that such a bind mount should be done on the server
> > and then exported? I guess that would give us distinct super blocks.
> 
> No. People are arguing that the client should allow the _same_
> filesystem to be mounted both read-only and read-write. That is not
> currently permitted for any other filesystem. The reason is that the
> read-only flag acts on a per-superblock basis, and hence on a
> per-filesystem basis. This is why you cannot do
> 
>         mount --bind -oro /foo /bar
> 
> If you fix the VFS to allow the above by making the read-only flag a
> per-mountpoint flag instead of a per-superblock flag, then NFS can
> happily do the same.

When this work is completed is there anything that needs to be done in
the NFS client or won't you know until you see the patches for it?

Ian



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
