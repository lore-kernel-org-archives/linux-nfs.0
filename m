From: Ian Kent <raven@themaw.net>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Mon, 14 May 2007 22:30:13 +0800
Message-ID: <1179153013.3811.51.camel@raven.themaw.net>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Paul Krizak <paul.krizak@amd.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Karel Zak <kzak@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnbZ6-0004Wf-12
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 07:30:20 -0700
Received: from out1.smtp.messagingengine.com ([66.111.4.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HnbZ8-0007tX-J1
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 07:30:22 -0700
In-Reply-To: <20070514131743.GG31764@petra.dvoda.cz>
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

On Mon, 2007-05-14 at 15:17 +0200, Karel Zak wrote:
> On Sat, May 05, 2007 at 01:17:52PM -0400, Trond Myklebust wrote:
> > On Sat, 2007-05-05 at 23:37 +0800, Ian Kent wrote:
> > > On Fri, 2007-05-04 at 17:41 -0400, Trond Myklebust wrote:
> > > So is there "anything at all" we can do to change this behavior now,
> > > apart from teaching mount to about it. Having the /etc/mtab
> > > and /proc/mounts recording different mount options for a mount is wrong.
> > > 
> > > How should mount(8) handle the situation?
> > 
> > I'd rather like to have mount(2) handle the situation by returning an
> > error if the mount options cannot be satisfied.
> 
>  Agree, that makes sense. Unfortuantely this change is probably not
>  backwardly compatible. Maybe add a new mount(2) flag MS_STRICT which
>  disable a mount when the mount options cannot be satisfied.

I really don't think that failing mounts in this case will get us any
relief from people that need to be able to remotely mount an exported
filesystem with different options. We already have several that will
incur significant ongoing maintenance overhead due to this.

The VFS read-only bind mount patches need to be completed as a matter of
urgency and we can consider what we need to do to mount in parallel as a
secondary priority.

If anyone can provide input regarding the status of those patches that
would be great. I haven't got any word back from Dave Hansen (the
author) at this stage.

Ian



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
