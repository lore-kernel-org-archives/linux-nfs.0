From: James Bottomley <James.Bottomley@steeleye.com>
Subject: Re: High Availability NFS Proposal
Date: Thu, 26 Sep 2002 12:13:48 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200209261613.g8QGDm807616@localhost.localdomain>
References: <neilb@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Bottomley <James.Bottomley@SteelEye.com>, nfs@lists.sourceforge.net,
        lmb@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host194.steeleye.com ([66.206.164.34] helo=pogo.mtv1.steeleye.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ubHJ-0002J0-00
	for <nfs@lists.sourceforge.net>; Thu, 26 Sep 2002 09:14:13 -0700
Received: (from root@localhost)
	by pogo.mtv1.steeleye.com (8.9.3/8.9.3) id JAA05444
	for <nfs@lists.sourceforge.net>; Thu, 26 Sep 2002 09:14:11 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: Message from Neil Brown <neilb@cse.unsw.edu.au>
   of "Tue, 24 Sep 2002 14:17:47 +1000." <15759.59243.99514.345924@notabene.cse.unsw.edu.au>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

neilb@cse.unsw.edu.au said:
> I haven't give a lot of thought to the exact changes to mountd, but
> basically it will do what it currently does, but also listen on a
> connection from the kernel. The kernel will say 
>   "I got a request from xx.yy.zz.ww, who is that?" and mountd will
> tell the kernel about client "fred" which has that IP address. Then
> the kernel will say
>   "I got a filehandle from fred with a 0xnnmmnnmm filesystem
>   identifier. Where is that" and mountd will tell the kernel about
> whichever export point for that client matches the filehandle. 

This is sort of the way our current HANFS authentication scheme works.  We 
have a daemon that sleeps on an NFS call.  When a request comes in the kernel 
doesn't recognise it sends the data up to the daemon which then gets mountd to 
authenticate or reject the request.

You're welcome to the code (its on http://licensing.steeleye.com/open_source/so
urcepage.php?prefix=nfs).  I'm afraid its not the best code I ever wrote, but 
it's GPL'd, take whatever you can salvage.

James




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
