From: Chip Salzenberg <chip@pobox.com>
Subject: Re: Debian bug #165744 - 'Received erroneous SM_UNMON request'
Date: Sun, 14 Sep 2003 22:23:03 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030915022303.GB8188@perlsupport.com>
References: <200309132202.47195.aragorn@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	165744@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19yj0t-0004iu-00
	for <nfs@lists.sourceforge.net>; Sun, 14 Sep 2003 19:22:51 -0700
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19yj0s-0007wu-Ry
	for nfs@lists.sourceforge.net; Sun, 14 Sep 2003 19:22:50 -0700
To: Frans Pop <aragorn@tiscali.nl>
In-Reply-To: <200309132202.47195.aragorn@tiscali.nl>
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

According to Frans Pop:
> In monitor.c there is the statement
>    my_name = "127.0.0.1"
> when servicing SM_MON requests with secure-statd enabled.
> I think in my setup this causes the lookups in the run-time list (which use 
> my_name) to fail when servicing SM_UNMON requests if in my situation my_name 
> is equal to the real adresses of my boxes, causing the 'Received erroneous 
> SM_UNMON request' errors.

Interesting!

Neil, I'd seen the assignment to my_name but I figured it was just a
housekeeping variable for connections.  But if it's used in a later
lookup, assigning to my_name could be a Bad Thing.  I'm not sure
enough of my understanding of statd to answer this suggestion.

> I think this would also explain the 'notify_host: failed to notify 127.0.0.1' 
> errors. This second error occurs when I reboot the server while a 
> NFS-connection was up: after restarting the server tries to notify the client 
> it is back up, but can't because the client is not at localhost but at 
> 10.19.66.21 and there is no NFS-client running on the server itself.

You've lost me.

> I think the reason the error appears in my setup could be because I have NFS 
> kernel-support compiled in both server and clients. In Debian, this means 
> rpc.lockd is not run from the init scripts.

What does the timing of lockd have to do with it?  Because that's the
only difference between a user-space lockd and a kernel-thread lockd;
the kernel thread only starts up when something might need it, while
the user-space one starts up at boot time.
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
