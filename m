From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] nfs-utils - 1 of 6 - statd - drop privs
Date: Wed, 2 Jul 2003 16:17:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16130.30992.260715.7114@gargle.gargle.HOWL>
References: <3EF0A283.5010206@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Xbo4-0002iT-00
	for <nfs@lists.sourceforge.net>; Wed, 02 Jul 2003 00:13:32 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24]:35993)
	by externalmx.vasoftware.com with smtp (Exim 4.20 #1 (Debian))
	id 19XawT-0001b6-Oq
	for <nfs@lists.sourceforge.net>; Tue, 01 Jul 2003 23:18:09 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <SteveD@redhat.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Wed, 2 Jul 2003 16:17:52 +1000
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: message from Steve Dickson on Wednesday June 18
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

On Wednesday June 18, SteveD@redhat.com wrote:
> The following 6 patches have been ported to the
> 1.0.3 release the nfs-utils package. I'm hopefully
> that Neil will incorate these so I no longer
> have to continue porting them... ;-)

Sorry for not looking at these sooner...

> 
> 
> This first patch allows statd to run as a non-root
> user. If there is not an rpcuser account (which
> there is in our world) it will try to use the
> nobody account.

An effect of this patch is that if someone does a 'make install',
statd won't work anymore without some chowning.

What would you think if just getting stat to run as whichever users
owns /var/lib/nfs, and printing a warning if it is root.

Also the patch makes references to 'chroot' but never actually uses
chroot.

The second patch uses:
   /var/run/rpc.statd/rpc.statd.pid
as a pid file, which doesn't seem like the right sort of name.
Either
   /var/run/rpc.statd.pid
or
   /var/run/nfs/rpc.statd.pid

would seem more appropriate, or is there some RedHat standard you are
following.

If we did do a chroot in statd we wouldn't be able to remove the pid
file any more.  We could if it went in /var/lib/nfs, but I don't think
that is the right place.

Maybe if we held a fd of the pid file open and used ftruncate to
remove the pid.  Would that work ok?

And I wish I knew why you thought mountd needed protection against
SIGPIPE, though I guess it cannot hurt.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
