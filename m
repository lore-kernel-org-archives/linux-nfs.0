From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Lock recovery doesn't work in debian statd/lockd ordering
Date: Thu, 12 Sep 2002 14:49:27 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15744.7383.324897.912595@notabene.cse.unsw.edu.au>
References: <15743.63908.531152.357021@notabene.cse.unsw.edu.au>
	<wv1y7z6en4.fsf@freeze.oslo.dnmi.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pLv8-0006pT-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 21:49:38 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.132] == wireless-132.wireless.cse.unsw.EDU.AU)
	(for <a.phillips@met.no>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Thu, 12 Sep 2002 14:49:27 +1000
To: Adrian Phillips <a.phillips@met.no>
In-Reply-To: message from Adrian Phillips on  September 12
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

On  September 12, a.phillips@met.no wrote:
> >>>>> "Neil" == Neil Brown <neilb@cse.unsw.edu.au> writes:
> 
>     Neil>  I just noticed that lock recovery doesn't work with a
>     Neil> Debian NFS server.  i.e.  server shuts down, restarts, and
>     Neil> the client *Doesn't* reclaim the locks.
> 
> Um, which version ? On my woody box lockd is started in nfs-common
> after statd still though :-

/sbin/rpc.lockd is an aberation that only applies to a small range of
kernels, about 2.2.14 to 2.2.17 I think.

In all other kernels, lockd is started on demand, either when nfsd
starts or when an nfs filesystem is mounted (without -o nolocks).

NeilBrown


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
