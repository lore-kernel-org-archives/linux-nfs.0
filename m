From: jrc@skylon.demon.co.uk
Subject: Re: Strange serialisation with slow operations?
Date: Thu, 25 Sep 2003 17:45:18 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1A2ZF0-0009R7-0X@anchor-post-33.mail.demon.net>
References: <Pine.LNX.4.58.0309250723030.25332@glenfiddich.cse.ogi.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2ZF2-0003vU-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 09:45:20 -0700
Received: from anchor-post-33.mail.demon.net ([194.217.242.91])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2ZF1-0003lv-Uj
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 09:45:20 -0700
To: "Paul Heinlein" <heinlein@cse.ogi.edu> ,jrc@skylon.demon.co.uk
In-Reply-To: <Pine.LNX.4.58.0309250723030.25332@glenfiddich.cse.ogi.edu>
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

heinlein@cse.ogi.edu wrote:
> On Thu, 25 Sep 2003 jrc@skylon.demon.co.uk wrote:
> 
> > If there is any further information I can supply to diagnose this,
> > please let me know ...
> 
> The two standard tools (and forgive me if I repeating something you've
> already tried) would be strace and tcpdump. The former would see which
> system call is the sore spot, the latter would trace the network
> traffic between client and server.

Fair comment!

Using strace(1) to trace the system calls issued by the two processes
showed that "cat a" blocked in read() and "cat b" blocked in open().

Examining the NFS packet between client and server using Ethereal
shows that the connections from both processes used the same ports:
2049 (nfs) and 797.

I left the information off of the previous message just in case the
answer was obvious to those in the know ...

Thanks for the swift response
--
John Connett



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
