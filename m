From: Leif Nixon <nixon@nsc.liu.se>
Subject: Re: Cache invalidation bug in v3
Date: Thu, 06 Oct 2005 15:36:26 +0200
Message-ID: <m3fyreepid.fsf@nammatj.nsc.liu.se>
References: <m3vf0aerbj.fsf@nammatj.nsc.liu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENVvI-0005dt-Oo
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 06:36:36 -0700
Received: from nammatj.nsc.liu.se ([130.236.101.75])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ENVvI-0006Wx-C1
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 06:36:36 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <m3vf0aerbj.fsf@nammatj.nsc.liu.se> (Leif Nixon's message of
 "Thu, 06 Oct 2005 14:57:20 +0200")
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

Leif Nixon <nixon@nsc.liu.se> writes:

> Here's a minimal way to reproduce the error (there seems to be some
> timing issues involved, but this has worked at least 90% of the time):
>
>   NFS client n1                NFS client n2
>
>   $ echo 1 > f
> 			       $ cat f
> 			       1
>   $ touch .
>   $ echo 2 > f
> 			       $ touch f
> 			       $ cat f
> 			       1

Ah, yes, I forgot one strange point; the second write to the file must
not change the size of the file, else the bug doesn't appear. So if
you change "echo 2 > f" to "echo foo > f", everything works just
fine...

-- 
Leif Nixon                       -            Systems expert
------------------------------------------------------------
National Supercomputer Centre    -      Linkoping University
------------------------------------------------------------


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
