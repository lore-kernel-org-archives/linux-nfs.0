From: David Warren <warren@atmos.washington.edu>
Subject: Re: Cache invalidation bug in v3
Date: Thu, 06 Oct 2005 14:36:12 -0700
Message-ID: <434598CC.3080604@atmos.washington.edu>
References: <m3vf0aerbj.fsf@nammatj.nsc.liu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENdPY-0006qW-N3
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 14:36:20 -0700
Received: from dew1.atmos.washington.edu ([128.95.89.41])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ENdPX-0000im-2x
	for nfs@lists.sourceforge.net; Thu, 06 Oct 2005 14:36:20 -0700
To: Leif Nixon <nixon@nsc.liu.se>
In-Reply-To: <m3vf0aerbj.fsf@nammatj.nsc.liu.se>
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

This is the same thing I reported about a week and a half ago. While you 
can't replicate it on a solaris server, I could replicate it with a 
solaris client. I also can not replicate it with NFSv4. I had several 
configuration suggestions sent to me. None of them changed anything.

Leif Nixon wrote:

>Hi,
>
>We have come across a bug where a v3 client fails to invalidate its
>data cache for a file even though it realizes that the file attributes
>have changed. We have been able to recreate the bug on a range of
>kernel versions and different underlying file systems.
>
>Here's a minimal way to reproduce the error (there seems to be some
>timing issues involved, but this has worked at least 90% of the time):
>
>  NFS client n1                NFS client n2
>
>  $ echo 1 > f
>			       $ cat f
>			       1
>  $ touch .
>  $ echo 2 > f
>			       $ touch f
>			       $ cat f
>			       1
>
>Now client n2 is stuck in a state where it uses its old cached data
>forever (or at least for several hours):
>
>  NFS client n1                NFS client n2
>
>  $ cat f
>  2
>			       $ cat f
>			       1
>
>However, stat(1) gives the same output on both clients. "touch f" on
>either machine corrects the situation; n2 invalidates its data cache.
>
>We have seen this on a range of kernels between 2.6.9 and 2.6.13.2 on
>Debian, CentOS, RHEL, Fedora and vanilla kernel.org, on both clients
>and server. We have *not* been able to reproduce the bug with a
>Solaris server. Underlying file systems have been ext3 and xfs (and
>Solaris ufs). We have tried varying mount options, but to no avail;
>the bug persists, even with "noac".
>
>
>Hypothesis:
>
>When n2 does "touch f" and wants to do SETATTR, it first has to do a
>LOOKUP (because n1 has updated the attributes on cwd with "touch .").
>It seems that when n2 receives the updated attributes for f as a part
>of the LOOKUP reply, it updates its attribute cache without
>invalidating its data cache, leading to the anomalous situation.
>
>If the "touch ." is omitted, n2 receives the updated file attributes
>via an explicit GETATTR on f, and then everything works properly.
>
>  
>


-- 
David Warren 		INTERNET: warren@atmos.washington.edu
(206) 543-0945		Fax: (206) 543-0308
University of Washington
Dept of Atmospheric Sciences, Box 351640
Seattle, WA 98195-1640
-------------------------------------------------------------------------------
DECUS E-PUBS Library Committee representative
SeaLUG DECUS Chair



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
