From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Linux 2.2 client trouble after 2.4.18 server reboot
Date: Mon, 29 Jul 2002 13:05:04 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15685.8544.339285.783217@charged.uio.no>
References: <200207290021.g6T0LLL22541@sprite.physics.adelaide.edu.au>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Z8L9-0005Nc-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Jul 2002 04:05:27 -0700
To: Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
In-Reply-To: <200207290021.g6T0LLL22541@sprite.physics.adelaide.edu.au>
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

>>>>> " " == Jonathan Woithe <jwoithe@physics.adelaide.edu.au> writes:

     > The exported directory on the server is a ReiserFS filesystem,
     > exported with only "rw" options.  The client mounts with
     > "hard,intr,bg" options.  NFSv3 support is not compiled in on
     > the 2.2.19 clients.  The server is a default slackware
     > configuration (from the point of view of NFS):

Was that ReiserFS system created on a 2.2.x system? If so, it is a
known bug in ReiserFS itself.  There is a mount option (can't remember
the name in the spur of the moment, but you'll find it described on
the 'mount' manpage in www.namesys.com and you'll find it described
several times in the NFS lists archives) that updates the filesystem
to the latest ReiserFS format.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
