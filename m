From: <trond.myklebust@fys.uio.no>
Subject: Re: NFS, Berkley mailboxes, locking, and corruption
Date: Sun, 1 Feb 2004 22:35:31 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <34505.80.213.3.64.1075671331.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AnPFn-0003KV-BH
	for nfs@lists.sourceforge.net; Sun, 01 Feb 2004 13:35:43 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AnPFj-0003bV-Rp
	for nfs@lists.sourceforge.net; Sun, 01 Feb 2004 13:35:40 -0800
To: <listuser@numbnuts.net>
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

På su , 01/02/2004 klokka 04:23, skreiv Justin:
> At this point and time it looks like NFS is what they planned on using
> when they came up with this design.  I know it will "appear" to work.
> I also know that it will silently lose mail.  Making all involved
> understand this very important fact is important and possibly
> difficult.  The mail system currently handles 30-50k pieces of mail a
> day, not counting spam.   This is busy enough to lose a lot of mail.
>
> How badly will NFS and this type of setup lose mail or corrupt mail
> spools?  We can't afford to risk the integity of our mail system,
> period.   What other solutions might there be if NFS isn't a viable
> solution?  How do larger institutions handle grand amounts of mail?
> SAN?  Many thanks

Are you *sure* that you are using POSIX (a.k.a. byte range, a.k.a.
lockf(), a.k.a. fcntl(), a.k.a "NOT BSD or flock()") style locks?

'cos that's all that's guaranteed to work...

Cheers,
  Trond





-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
