From: "Henrik Schmiediche" <henrik@stat.tamu.edu>
Subject: RE: Extremely high load on NFS clients wen the NFS server is down...
Date: Wed, 18 May 2005 15:29:29 -0500
Message-ID: <200505182030.j4IKU0ss019011@s7.stat.tamu.edu>
References: <20050518201451.62925312765@cheetah.cs.fiu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYVB7-0001zc-F4
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 13:30:05 -0700
Received: from s7.stat.tamu.edu ([165.91.117.61])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYVB4-0003Ze-Gb
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 13:30:05 -0700
To: "'Eric S. Johnson'" <esj@cs.fiu.edu>
In-Reply-To: <20050518201451.62925312765@cheetah.cs.fiu.edu>
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


Thanks for this. I will experiment with your suggestion. The load may be
artificial, but my system definitively become sluggish (after a while) to
the point of non-responsiveness.

Sincerely,

   - Henrik


-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Eric S. Johnson
Sent: Wednesday, May 18, 2005 3:15 PM
To: Henrik Schmiediche
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] Extremely high load on NFS clients wen the NFS server is
down... 


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



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
