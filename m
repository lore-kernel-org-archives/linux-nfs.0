From: "Eric S. Johnson" <esj@cs.fiu.edu>
Subject: Re: Extremely high load on NFS clients wen the NFS server is down...
Date: Wed, 18 May 2005 16:14:51 -0400
Message-ID: <20050518201451.62925312765@cheetah.cs.fiu.edu>
References: <henrik@stat.tamu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYUwQ-0000Pr-Pe
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 13:14:54 -0700
Received: from cheetah.cs.fiu.edu ([131.94.130.107])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DYUwP-0008Uo-CZ
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 13:14:54 -0700
To: "Henrik Schmiediche" <henrik@stat.tamu.edu>
In-Reply-To: Message from "Henrik Schmiediche" <henrik@stat.tamu.edu>
   of "Wed, 18 May 2005 09:28:38 CDT." <200505181429.j4IET8GK023074@s7.stat.tamu.edu>
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


Henrik,

Ive seen this behavior, somewhat... When a nfs server goes down a 
large number of processes go into uninterruptible sleep, waiting on 
unanswerable NFS rpc calls. This drives the load average up.. BUT does 
not really have any affect on response time *for processes that don't 
try to access NFS mounted files* The load is not real, its just a 
count of processes in uninterruptible sleep.. You can see all these 
processes with ps, the STAT column says D

kill -9  to the rpciod process will free up some of the processes
that are stuck in disk wait. Till they re-issue the nfs call...

I have not gone much more into the why of this... But sometimes
a root shell (with a local $HOME and no NFS mounted directories in 
the path) and a bunch of kill -9's to rpciod process will help you
regain control of things enough to do further diagnose and recovery
steps.

E



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
