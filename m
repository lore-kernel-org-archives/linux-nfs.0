From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 9 Dec 2004 14:41:59 +0100
Message-ID: <20041209134159.GA11998@suse.de>
References: <482A3FA0050D21419C269D13989C61130435EC70@lavender-fe.eng.netapp.com> <20041209112233.GC15055@suse.de> <1102599212.24133.30.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Charles Lever <Charles.Lever@netapp.com>,
	Mike Waychison <Michael.Waychison@sun.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcOYW-00069j-Bn
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 05:42:04 -0800
Received: from mail-ex.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CcOYV-0005ck-DN
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 05:42:04 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1102599212.24133.30.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Dec 09, 2004 at 08:33:32AM -0500, Trond Myklebust wrote:
> Seriously, though: we *already* have this serialization problem with the
> single client per transport case, and so there is nothing that needs to
> added to the locking in order to deal with multiple clients per
> transport. IOW contention today is at the per-request level and it would
> have to remain so for the shared transport case.

But two separate mounts with separate sockets do not serialize (at least
they shouldn't). And contention doesn't happen on the client only.
The server needs to serialize sending over TCP as well; the more
sockets you have the less likely it will step on its own toes.

> Note also that we could also create pools of several transport sockets
> per server: the current locking scheme allows for that too. That would
> improve per-request scalability at the same time as it allows us to
> limit the privileged port usage.

Yes, that would help scalability a lot.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
