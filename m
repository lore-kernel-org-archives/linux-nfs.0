From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: File lock with multiple clients
Date: Fri, 21 Oct 2005 12:40:16 +0200
Message-ID: <200510211240.16468.vincent.roqueta@ext.bull.net>
References: <E1ESu5K-0007a8-1Z@mail.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESuHJ-0007R0-Dh
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 03:37:37 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ESuHF-0001u0-Nj
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 03:37:37 -0700
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 0617D19D90D
	for <nfs@lists.sourceforge.net>; Fri, 21 Oct 2005 12:36:51 +0200 (CEST)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 06820-06 for <nfs@lists.sourceforge.net>;
 Fri, 21 Oct 2005 12:36:49 +0200 (CEST)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 734A319D909
	for <nfs@lists.sourceforge.net>; Fri, 21 Oct 2005 12:36:49 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <E1ESu5K-0007a8-1Z@mail.sourceforge.net>
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

Le vendredi 21 Octobre 2005 12:25, petter.knutsen@cgi.no a =E9crit=A0:
> > Check the man page:  "man flock":
> >
> > Use fcntl or lockf (which is wrapper for fcntl) if you want to lock
> > over NFS.
>
> As Trond said, flock() seems to work by emulating fcntl(), but regardless
> of whether I'm using fcntl() directly or flock() with emulation, should my
> scenario  with two clients work, where one client locks and the other
> client honouring the lock?
>
> As I said, it works between processes on the same client, but not between
> processes on different clients.
I am going to test that on different clients.

> I would appreciate if someone could tell me if this is possible or not
That is possible. (advisory locking)
I have got some experiences of that the last weeks.

Here is for NFSv4.
http://nfsv4.bullopensource.org/tools/tests/page39.php

> , so I can either abandon NFS and look for alternatives or, if it should
> work, go back and look for flaws in my setup. :-)=20


Vincent


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
