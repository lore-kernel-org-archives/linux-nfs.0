From: Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
Subject: Linux 2.2 client trouble after 2.4.18 server reboot
Date: Mon, 29 Jul 2002 09:51:21 +0930 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207290021.g6T0LLL22541@sprite.physics.adelaide.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
        jwoithe@physics.adelaide.edu.au (Jonathan Woithe)
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adelphi.physics.adelaide.edu.au ([129.127.102.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17YyI4-0000Hp-00
	for <nfs@lists.sourceforge.net>; Sun, 28 Jul 2002 17:21:36 -0700
To: trond.myklebust@fys.uio.no
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi all

[Please CC me replies since I'm not subscribed to this list]

Recently I upgraded our NFS server to Linux 2.4.18.  This server provides
exported home directories for our user Linux boxes which are currently
running 2.2.19.

Most of the time everything seems to be going well.  However, if the server
is rebooted the clients seem unable to restore the NFS connection to a
usable state.  The logs note the server becoming unavailable and then
following the reboot they note that the server is now "ok".  However, any
attempt to then access the mounted volumes is greeted with a "permission
denied" error.  Even root can't access the drives.

If the NFS volumes are unmounted and remounted the problem (predictably)
goes away.  Of course such an unmount can't occur until people have logged
off, which makes it a little cumbersome.

The exported directory on the server is a ReiserFS filesystem, exported with
only "rw" options.  The client mounts with "hard,intr,bg" options.  NFSv3
support is not compiled in on the 2.2.19 clients.  The server is a default
slackware configuration (from the point of view of NFS): 
  CONFIG_NFS_FS=y
  CONFIG_NFS_V3=y
  # CONFIG_ROOT_NFS is not set
  CONFIG_NFSD=m
  CONFIG_NFSD_V3=y
  CONFIG_SUNRPC=y
  CONFIG_LOCKD=y
  CONFIG_LOCKD_V4=y
The server also has the lockd oops fix from Trond.

I would appreciate any pointers to ways to stop this from happening. 
Requiring that all users log out before a server reboot is rather
inconvenient.

Best regards
  jonathan
-- 
* Jonathan Woithe    jwoithe@physics.adelaide.edu.au                        *
*                    http://www.physics.adelaide.edu.au/~jwoithe            *
***-----------------------------------------------------------------------***
** "Time is an illusion; lunchtime doubly so"                              **
*  "...you wouldn't recognize a subtle plan if it painted itself purple and *
*   danced naked on a harpsichord singing 'subtle plans are here again'"    *


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
