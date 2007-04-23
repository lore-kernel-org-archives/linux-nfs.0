From: Neil Brown <neilb@suse.de>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Mon, 23 Apr 2007 16:31:50 +1000
Message-ID: <17964.21206.435402.157895@notabene.brown>
References: <17958.48121.280256.493824@notabene.brown>
	<20070419012154.GB19063@javifsp.no-ip.org>
	<17960.11704.321124.641669@notabene.brown>
	<4629120C.60803@RedHat.com>
	<17964.12324.307985.65596@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Steve Dickson <SteveD@redhat.com>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <olaf.kirch@oracle.com>,
	=?ISO-8859-1?Q?Javier_Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hfs5r-0001Xt-Ap
	for nfs@lists.sourceforge.net; Sun, 22 Apr 2007 23:32:11 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hfs5r-0001oi-KW
	for nfs@lists.sourceforge.net; Sun, 22 Apr 2007 23:32:14 -0700
In-Reply-To: message from Neil Brown on Monday April 23
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

On Monday April 23, neilb@suse.de wrote:
> I think I'll add -u/-g flags
> I might even include the Redhat code in #ifdef, so if compile with
>  make RPCUSER=rpc
> it will do the getpwnam..

I have added both compile-time and run-time setting of the uid and
gid, and allowed a username to be set at compile time.  I have also
made it possible to compile in host-name lookups.  The man-page
auto-adjusts to match the compile options.

  make RPCUSER=rpc DAEMON_UID=4 DAEMON_GID=100 USE_DNS=yes

I think it is now should do all that I want, and should be a slot-in
replacement for any distro that wants it (providing they choose
appropriate Make options).

NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
