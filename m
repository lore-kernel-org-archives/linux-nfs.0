From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: statd for NFSv4 does not create file
Date: Thu, 14 Jul 2005 09:21:22 -0400
Message-ID: <1121347282.8202.49.camel@lade.trondhjem.org>
References: <20050714125536.788.qmail@web51609.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt3eo-0007X9-4Y
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 06:21:42 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dt3em-00039Q-MV
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 06:21:42 -0700
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050714125536.788.qmail@web51609.mail.yahoo.com>
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

to den 14.07.2005 Klokka 05:55 (-0700) skreiv mehta kiran:
> Hi , 
>         I have observed the following.
>         RHEL4 GA and U1 
>         client accesses filesystem exported
>         by server using nfsv4 .
> 
>         It takes lock  on a file.
>         Other clients on "different" systems
>         get NFSERR_DENIED and they retry to acquire
>         lock.
> 
>         When first client release lock , other client
>         gets the lock.
>         But when i see in /var/lib/nfs/statd/sm 
>         directory , i cannot see any file with
>         name = server's name.

An NFSv4 client has no use for statd. The NFSv4 protocol has its own
methods for tracking client and server reboots.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
