From: Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
Subject: Re: Linux 2.2 client trouble after 2.4.18 server reboot
Date: Tue, 30 Jul 2002 17:14:24 +0930 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207300744.g6U7iOb17715@sprite.physics.adelaide.edu.au>
References: <15685.8544.339285.783217@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jwoithe@physics.adelaide.edu.au (Jonathan Woithe),
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adelphi.physics.adelaide.edu.au ([129.127.102.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ZRgI-0000hc-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Jul 2002 00:44:34 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <15685.8544.339285.783217@charged.uio.no> from "Trond Myklebust" at Jul 29, 2002 01:05:04 PM
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

Hi Trond and others

[ NFS client troubles after server rebooted ]

> >>>>> " " == Jonathan Woithe <jwoithe@physics.adelaide.edu.au> writes:
>      > The exported directory on the server is a ReiserFS filesystem,
>      > exported with only "rw" options.  The client mounts with
>      > "hard,intr,bg" options.  NFSv3 support is not compiled in on
>      > the 2.2.19 clients.  The server is a default slackware
>      > configuration (from the point of view of NFS):
> 
> Was that ReiserFS system created on a 2.2.x system? If so, it is a
> known bug in ReiserFS itself.  There is a mount option (can't remember
> the name in the spur of the moment, but you'll find it described on
> the 'mount' manpage in www.namesys.com and you'll find it described
> several times in the NFS lists archives) that updates the filesystem
> to the latest ReiserFS format.

A few more details from tests I've done today.  Under Slackware 8.1 (what
we're using), the nfs system is shutdown with a `exportfs -au' before a
reboot.  If I carry out a stop/start cycle on the NFS system, the clients
have no problem.  It seems it only occurs across reboots - not NFS server
restarts.

Furthermore, I've found that if I do a `exportfs -a' immediately after the
server reboot then the clients are able access the NFS volume again.  And
yes, exportfs is called before rpc.mountd under Slackware 8.1.  Before the
second exportfs invocation, the /var/lib/nfs/xtab file is empty whereas it
contains details of the exported filesystems after.  I don't know if this is
relevant - but it is the only file which changes as a result of the second
call.

Does this mean that an extra `exportfs -r' (or `exportfs -a') is required
during boot to resync this, or does it indicate another problem?

In regards to the ReiserFS version, `debugreiserfs <dev>' reports a
superblock of version 3.6.

Regards
  jonathan
-- 
* Jonathan Woithe    jwoithe@physics.adelaide.edu.au                        *
*                    http://www.physics.adelaide.edu.au/~jwoithe            *
***-----------------------------------------------------------------------***
** "Time is an illusion; lunchtime doubly so"                              **
*  "...you wouldn't recognize a subtle plan if it painted itself purple and *
*   danced naked on a harpsichord singing 'subtle plans are here again'"    *


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
