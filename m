From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Debian bug #165744 - 'Received erroneous SM_UNMON request'
Date: Mon, 22 Sep 2003 13:24:40 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16238.27512.629502.79085@notabene.cse.unsw.edu.au>
References: <200309132202.47195.aragorn@tiscali.nl>
	<20030915022303.GB8188@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Pop <aragorn@tiscali.nl>,
    nfs@lists.sourceforge.net,
    165744@bugs.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1HJm-0007UA-00
	for <nfs@lists.sourceforge.net>; Sun, 21 Sep 2003 20:24:54 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A1HJk-0008RX-I0
	for nfs@lists.sourceforge.net; Sun, 21 Sep 2003 20:24:52 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <aragorn@tiscali.nl>)
	(for <nfs@lists.sourceforge.net>) (for <165744@bugs.debian.org>) By
	note With Smtp ; Mon, 22 Sep 2003 13:24:42 +1000
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Sunday September 14
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

On Sunday September 14, chip@pobox.com wrote:
> According to Frans Pop:
> > In monitor.c there is the statement
> >    my_name = "127.0.0.1"
> > when servicing SM_MON requests with secure-statd enabled.
> > I think in my setup this causes the lookups in the run-time list (which use 
> > my_name) to fail when servicing SM_UNMON requests if in my situation my_name 
> > is equal to the real adresses of my boxes, causing the 'Received erroneous 
> > SM_UNMON request' errors.
> 
> Interesting!
> 
> Neil, I'd seen the assignment to my_name but I figured it was just a
> housekeeping variable for connections.  But if it's used in a later
> lookup, assigning to my_name could be a Bad Thing.  I'm not sure
> enough of my understanding of statd to answer this suggestion.

There is definately something wrong here.
If my_name is forced to "127.0.0.1" in sm_mon_1_svc, then it should
also be force to that value in sm_unmon_1_svc.
However it is not clear to me that it needs to be forced to 127.0.0.1.
I guess it wouldn't hurt though.

I would suggest putting code in sm_unmon_1_svc to roughly match what
sm_mon_1_svc does in the RESTRICTED_STATD case.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
