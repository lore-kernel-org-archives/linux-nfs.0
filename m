From: Chip Salzenberg <chip@pobox.com>
Subject: [chip@debian.org: Debian Bug#203918 - statd request on eth interface, not localhost?]
Date: Tue, 12 Aug 2003 11:21:54 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030812152154.GQ24349@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jordi Mallach <jordi@debian.org>, 203918-quiet@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19maxr-0005Sl-00
	for <nfs@lists.sourceforge.net>; Tue, 12 Aug 2003 08:21:35 -0700
To: nfs@lists.sourceforge.net
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

HEY NEIL.  HEY EVERYBODY ELSE TOO.

Could you please give me some reply to this issue?  The beginning of
the bug report looks boring but it's actually weird.  To me anyway.  :-/


----- Forwarded message from Chip Salzenberg <chip@debian.org> -----

Subject: [NFS] Debian Bug#203918 - statd request on eth interface, not localhost?
From: Chip Salzenberg <chip@debian.org>
To: nfs@lists.sourceforge.net
Cc: 
Date: Mon, 4 Aug 2003 20:48:53 -0400

OK, guys, I've got an interesting bug here.  The server kernel is
2.4.20, the client is 2.6.0 (I think test2).  The first mount attempt
succeeds, and things seem to work.  But unmount requests fail.  And
there's a statd anomaly along the way.

The server is "natura" (213.96.69.115) and the client is "nubol" (IP
unknown).

Here's the /etc/exports:
> /var/cache/apt/archives *.int.oskuro.net(rw,async,no_root_squash)
> /home *.int.oskuro.net(rw,async,no_root_squash)

And here's the intriguing server log message:

> Aug  3 18:22:42 natura rpc.statd[467]: Call to statd from non-local host 213.96.69.115
> Aug  3 18:22:42 natura rpc.statd[467]: STAT_FAIL to natura for SM_MON of 192.168.1.3
> 
> This is the first mount. If you remember, it worked ok the first time I
> apt-get'ed. 213.96.69.115 is the public ip of the nfs server.

So let's get this straight.  The server's kernel is apparently sending
an SM_MON request to its own statd, but not using the loopback address,
but rather the public ethernet address.

Can I get a "Huh?!" from the congregation?  How does that even happen?

Subsequent trouble is perhaps a result of the first problem, somehow?

> Bah, now it won't umount.
> Aug  3 18:29:58 nubol automount[457]: shutdown failed: filesystem still busy
> 
> But nothing is using it.
> 65567:jordi@nubol:~$ sudo lsof |grep autofs
> zsh: done       sudo lsof | 
> zsh: exit 1     grep autofs
> 65568:jordi@nubol:~$ sudo umount  /var/autofs/natura/archives
> umount: /var/autofs/natura/archives: device is busy
> 
> So I can't umount right now. Now, it stays mounted, and it works, but
> it'd be nice if I could get rid of it too :)
> 
> The other day, it would umount and I got the connection refused error.

adTHANKSvance for debugging info.
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs



----- End forwarded message -----

-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
