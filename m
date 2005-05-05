From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: AIX NFS server and AIX client ->Error unlocking file :
	err=Invalid argument
Date: Thu, 05 May 2005 12:25:17 -0400
Message-ID: <1115310317.12780.33.camel@lade.trondhjem.org>
References: <20050505154843.61669.qmail@web51602.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTjAM-0006Ul-M9
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 09:25:34 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DTjAJ-000735-SO
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 09:25:34 -0700
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050505154843.61669.qmail@web51602.mail.yahoo.com>
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

to den 05.05.2005 Klokka 08:48 (-0700) skreiv mehta kiran:
> Hi  , 
>  I am trying to verify if nfs lock recovery works on 
>  AIX.
>  I have AIX 5.3 server and AIX 5.2 client.
>  Server export fs with rw,root=<client>
> 
>  Client mounts fs and locks a file.
>  Then i restarts nfs server and reexport fs.
>  Client tries to reclaim lock but it gets 
>  error ->Error unlocking file : err=Invalid argument
>  
>  Under normal condition(nfs server does not go down)
>  i dont get any error. 
>  
>  Please let me know if anybody has solution to this.
> thanks,

Err... The only solution I can see us providing would have to be to swap
your AIX boxes out for Linux. 8-)

This really sounds like a problem you should be reporting to the IBM AIX
team instead of a Linux NFS mailing list.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
