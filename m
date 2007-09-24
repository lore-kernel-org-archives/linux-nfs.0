From: James Lentini <jlentini@netapp.com>
Subject: Re: [PATCH] NFS: initialize default port in kernel mount
	client
Date: Mon, 24 Sep 2007 19:53:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0709241942430.32008@jlentini-linux.nane.netapp.com>
References: <Pine.LNX.4.64.0709241731560.32008@jlentini-linux.nane.netapp.com>
	<46F83B09.2090202@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZxjr-0002CR-J4
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 16:53:19 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZxjv-0003Ea-Bg
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 16:53:24 -0700
In-Reply-To: <46F83B09.2090202@oracle.com>
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



On Mon, 24 Sep 2007, Chuck Lever wrote:

> Hi James-
> 
> James Lentini wrote:
> > If no mount server port number is specified, this change to the kernel mount
> > client
> > 
> > http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-2.6.git;a=commitdiff;h=209ce98
> > 06996537eceaf07d95def0e9300316c84
> > 
> > inadvertently allows the NFS server's port number to be the used as the
> > mount server's port number. If the user specifies an NFS server port (-o
> > port=x), the mount will fail.
> > 
> > The fix below sets the mount server's port to 0 if no mount server port is
> > specified by the user.
> > 
> > Signed-off-by: James Lentini <jlentini@netapp.com>
> > --
> > 
> >  super.c |    2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > Index: nfs-2.6/fs/nfs/super.c
> > ===================================================================
> > --- nfs-2.6/fs/nfs/super.c
> > +++ nfs-2.6/fs/nfs/super.c
> > @@ -1006,6 +1006,8 @@ static int nfs_try_mount(struct nfs_pars
> >  		sin = args->nfs_server.address;
> >  	if (args->mount_server.port != 0)
> >  		sin.sin_port = htons(args->mount_server.port);
> > +	else
> > +		sin.sin_port = htons(0);
> 
> Why not just set sin.sin_port = args->mount_server.port unconditionally?

Good observation. Something like this perhaps?

Signed-off-by: James Lentini <jlentini@netapp.com>

Index: nfs-2.6/fs/nfs/super.c
===================================================================
--- nfs-2.6/fs/nfs/super.c
+++ nfs-2.6/fs/nfs/super.c
@@ -1004,8 +1004,10 @@ static int nfs_try_mount(struct nfs_pars
 		sin = args->mount_server.address;
 	else
 		sin = args->nfs_server.address;
-	if (args->mount_server.port != 0)
-		sin.sin_port = htons(args->mount_server.port);
+	/* 
+ 	 * autobind will be used if mount_server.port == 0
+ 	 */
+	sin.sin_port = htons(args->mount_server.port);
 
 	/*
 	 * Now ask the mount server to map our export path

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
