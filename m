From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Mon, 14 May 2007 11:47:11 -0400
Message-ID: <1179157631.6474.8.camel@heimdal.trondhjem.org>
References: <4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>
	<4627D303.8060009@amd.com>
	<1177020662.6628.30.camel@heimdal.trondhjem.org>
	<4627EBFC.2090704@amd.com>
	<462CFC92.2080201@amd.com> <463B97E6.4030009@amd.com>
	<1178314889.6533.19.camel@heimdal.trondhjem.org>
	<1178379473.4559.24.camel@raven.themaw.net>
	<1178385472.6561.43.camel@heimdal.trondhjem.org>
	<20070514131743.GG31764@petra.dvoda.cz>
	<1179149048.6858.5.camel@heimdal.trondhjem.org>
	<1179153555.3811.57.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Paul Krizak <paul.krizak@amd.com>, nfs@lists.sourceforge.net
To: Ian Kent <raven@themaw.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnclZ-0005B5-Jl
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 08:47:17 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hncla-0000TT-7d
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 08:47:20 -0700
In-Reply-To: <1179153555.3811.57.camel@raven.themaw.net>
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

On Mon, 2007-05-14 at 22:39 +0800, Ian Kent wrote:
> On Mon, 2007-05-14 at 09:24 -0400, Trond Myklebust wrote:
> > On Mon, 2007-05-14 at 15:17 +0200, Karel Zak wrote:
> > > On Sat, May 05, 2007 at 01:17:52PM -0400, Trond Myklebust wrote:
> > > > On Sat, 2007-05-05 at 23:37 +0800, Ian Kent wrote:
> > > > > On Fri, 2007-05-04 at 17:41 -0400, Trond Myklebust wrote:
> > > > > So is there "anything at all" we can do to change this behavior now,
> > > > > apart from teaching mount to about it. Having the /etc/mtab
> > > > > and /proc/mounts recording different mount options for a mount is wrong.
> > > > > 
> > > > > How should mount(8) handle the situation?
> > > > 
> > > > I'd rather like to have mount(2) handle the situation by returning an
> > > > error if the mount options cannot be satisfied.
> > > 
> > >  Agree, that makes sense. Unfortuantely this change is probably not
> > >  backwardly compatible. Maybe add a new mount(2) flag MS_STRICT which
> > >  disable a mount when the mount options cannot be satisfied.
> > 
> > The kernel would be sending the error to the mount program when it
> > cannot satisfy the request. There is no backwards compatibilty issue.
> 
> I guess that depends on how you interpret backwardly compatible.
> 
> Deciding to now fail mounts in this case would turn an unfortunate side
> effect of an urgently needed change into a disaster for some users. I
> think it's best to leave it as it is and push on with the needed VFS
> changes.

No. It would alert people who think they are mounting with different
mount options to the reality that they are not.

We might then be able to add an '--unshared-cache' option (any
suggestions for a better name?) to mount in order to allow those people
who fully understand the consequences to override, and hence to mount
the same filesystem with different mount options, but no sharing of the
page cache with the original filesystem.

Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
