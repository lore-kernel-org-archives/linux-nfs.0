From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: [PATCH] nfs-utils - 1 of 6 - statd - drop privs
Date: Thu, 03 Jul 2003 07:42:31 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F0416A7.8020706@RedHat.com>
References: <3EF0A283.5010206@RedHat.com> <16130.30992.260715.7114@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Y2UD-0007uC-00
	for <nfs@lists.sourceforge.net>; Thu, 03 Jul 2003 04:42:49 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16130.30992.260715.7114@gargle.gargle.HOWL>
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

Hello,

Neil Brown wrote:

>>This first patch allows statd to run as a non-root
>>user. If there is not an rpcuser account (which
>>there is in our world) it will try to use the
>>nobody account.
>>    
>>
>
>An effect of this patch is that if someone does a 'make install',
>statd won't work anymore without some chowning.
>
True.... We do an adduser during the package installation...

>What would you think if just getting stat to run as whichever users
>owns /var/lib/nfs, and printing a warning if it is root.
>
Looking around it appears root owns  /var/lib/nfs.. and the
point of the patch is not to run a root..... I guess it all comes
do to how secure you want statd.... security is never free.... :)
Maybe you could add a compilation flag allowing people
to control it that way...

>The second patch uses:
>   /var/run/rpc.statd/rpc.statd.pid
>as a pid file, which doesn't seem like the right sort of name.
>Either
>   /var/run/rpc.statd.pid
>or
>   /var/run/nfs/rpc.statd.pid
>
>would seem more appropriate, or is there some RedHat standard you are
>following.
>
I had to make it a directory so the pid file could be removed
after the privs have been dropped (i.e. not longer running as root).

>If we did do a chroot in statd we wouldn't be able to remove the pid
>file any more.  We could if it went in /var/lib/nfs, but I don't think
>that is the right place.
>
>Maybe if we held a fd of the pid file open and used ftruncate to
>remove the pid.  Would that work ok?
>
The privs dropping patch (i.e the first patch) makes the chroot no longer
necessary... but holding might work but how would the unlink occur?

>And I wish I knew why you thought mountd needed protection against
>SIGPIPE, though I guess it cannot hurt.
>
TCP aborts.... If a sender has a socket open and the receiver close()s the
socket with data still unread, the sender gets a SIGPIPE.

SteveD.



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
