From: Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
Subject: Re: Linux 2.2 client trouble after 2.4.18 server reboot
Date: Tue, 30 Jul 2002 09:00:19 +0930 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207292330.g6TNUJg01674@sprite.physics.adelaide.edu.au>
References: <15685.8544.339285.783217@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jwoithe@physics.adelaide.edu.au (Jonathan Woithe),
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adelphi.physics.adelaide.edu.au ([129.127.102.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ZJy9-0002it-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Jul 2002 16:30:30 -0700
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

Hi Trond

> >>>>> " " == Jonathan Woithe <jwoithe@physics.adelaide.edu.au> writes:
>      > The exported directory on the server is a ReiserFS filesystem,
>      > exported with only "rw" options.  The client mounts with
>      > "hard,intr,bg" options.  NFSv3 support is not compiled in on
>      > the 2.2.19 clients.  The server is a default slackware
>      > configuration (from the point of view of NFS):
> 
> Was that ReiserFS system created on a 2.2.x system? If so, it is a
> known bug in ReiserFS itself.

No.  The ReiserFS system was freshly created under 2.4.18.

> There is a mount option ... that updates the filesystem to the latest
> ReiserFS format.

I'll look at this and give it a go anyway ... in the absence of any other
ideas.

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
