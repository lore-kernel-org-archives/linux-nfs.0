From: Leif Nixon <nixon@nsc.liu.se>
Subject: Re: Cache invalidation bug in v3
Date: Fri, 07 Oct 2005 14:32:31 +0200
Message-ID: <m3achlwlr4.fsf@nammatj.nsc.liu.se>
References: <m3vf0aerbj.fsf@nammatj.nsc.liu.se>
	<434598CC.3080604@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENrPQ-0007vB-Gf
	for nfs@lists.sourceforge.net; Fri, 07 Oct 2005 05:33:08 -0700
Received: from nammatj.nsc.liu.se ([130.236.101.75])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ENrOw-000247-AE
	for nfs@lists.sourceforge.net; Fri, 07 Oct 2005 05:33:08 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <434598CC.3080604@atmos.washington.edu> (David Warren's message
 of "Thu, 06 Oct 2005 14:36:12 -0700")
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

David Warren <warren@atmos.washington.edu> writes:

> This is the same thing I reported about a week and a half ago.

Yes, or at least similar.

> While you can't replicate it on a solaris server, I could replicate
> it with a solaris client.

I have failed to replicate my problem with two Solaris clients against
a 2.6.11 Linux server.

Trond, you thought David's problem might be caused by re-use of
inodes, but in this case, i.e.:

  NFS client n1                NFS client n2

  $ echo 1 > f
			       $ cat f
			       1
  $ touch .
  $ echo 2 > f
			       $ touch f
			       $ cat f
			       1

there is only a single inode involved.

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
