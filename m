From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] nfs-utils - 1 of 6 - statd - drop privs
Date: Fri, 4 Jul 2003 12:26:42 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16132.58850.179306.240803@gargle.gargle.HOWL>
References: <3EF0A283.5010206@RedHat.com>
	<16130.30992.260715.7114@gargle.gargle.HOWL>
	<3F0416A7.8020706@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19YGHy-0002u8-00
	for <nfs@lists.sourceforge.net>; Thu, 03 Jul 2003 19:27:06 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <SteveD@redhat.com>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Fri, 4 Jul 2003 12:26:59 +1000
To: Steve Dickson <SteveD@RedHat.com>
In-Reply-To: message from Steve Dickson on Thursday July 3
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thursday July 3, SteveD@RedHat.com wrote:
> >An effect of this patch is that if someone does a 'make install',
> >statd won't work anymore without some chowning.
> >
> True.... We do an adduser during the package installation...
> 
> >What would you think if just getting stat to run as whichever users
> >owns /var/lib/nfs, and printing a warning if it is root.
> >
> Looking around it appears root owns  /var/lib/nfs.. and the
> point of the patch is not to run a root..... I guess it all comes
> do to how secure you want statd.... security is never free.... :)
> Maybe you could add a compilation flag allowing people
> to control it that way...

I had assumed that /var/lib/nfs would need to be chowned to "rpcuser"
for statd to work, but I guess it doesn't. 
However "state", "sm" and "sm.bak" must already exist and be owned by
whoever state runs as.
So this is what I think I will do:

  If 'sm' exists, statd takes on the identity of the owner, otherwise
   it takes on the identity of the owner of /var/lib/nfs.
  The "make install" script creates state, sm, and sm.bak and chowns
   them to $SOMEUSER
  The configure script sets $SOMEUSER to rpcuser if that is in
   /etc/passwd, or nobody, but this setting can be over-ridden via a
   config option

  statd will create /var/run/rpc.statd.pid as root and will keep and
   open filehandle for it to ftruncate later.  Scripts which check 
   for this existance of the need to 
	[ -s /var/run/rpc.statd.pid ]

This allows for trouble free upgrading, a normal pid filename,
and still allows and even encourages good security.

> >And I wish I knew why you thought mountd needed protection against
> >SIGPIPE, though I guess it cannot hurt.
> >
> TCP aborts.... If a sender has a socket open and the receiver close()s the
> socket with data still unread, the sender gets a SIGPIPE.

Arh, that makes sense.  The patch has already gone in anyway.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
