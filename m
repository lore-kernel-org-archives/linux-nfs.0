From: Philippe Troin <phil@fifi.org>
Subject: Re: Lock recovery doesn't work in debian statd/lockd ordering
Date: 13 Sep 2002 12:22:20 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87elbxsnir.fsf@ceramic.fifi.org>
References: <15743.63908.531152.357021@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chip Salzenberg <chip@debian.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tantale.fifi.org ([216.27.190.146])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pw1P-0000BN-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Sep 2002 12:22:31 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15743.63908.531152.357021@notabene.cse.unsw.edu.au>
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

Neil Brown <neilb@cse.unsw.edu.au> writes:

> Hi Chip and NFSers.
> 
>  I just noticed that lock recovery doesn't work with a Debian NFS
>  server.
>  i.e.  server shuts down, restarts, and the client *Doesn't* reclaim
>  the locks.
> 
>  The problem is that statd starts before lockd.
> 
>  What happens is that:
>     statd starts
>       it moves everything from /var/lib/nfs/sm to /var/lib/nfs/sm.bak
>       it notifies each host listed in /var/lib/nfs/sm.bak that the
>         server has restarted
>     statd on the client gets the notification and tells it's local
>         lockd to reclaim locks.
>     lockd on client asked portmap on server for port number for lockd,
>         but lockd hasn't started on the server so there isn't one.  So
>         lockd on the client gives up (maybe it should persist, I'm not
>         sure).
>     Finally lockd on the server starts, but it is too late.
> 
> 
>  I fixed this for myself by moving /etc/rc2.d/S19nfs-common to S21 so
>  that it starts after nfsd and lockd which are started in
>  S20nfs-kernel-server.
> 
>  There should be no problem with statd starting after lockd and lockd
>  doesn't try to talk to statd until it gets the first lock request.

I've opened a debian bug (# 160800) about this.

  -> http://bugs.debian.org/160800

Phil.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
