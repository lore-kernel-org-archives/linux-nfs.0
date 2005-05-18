From: "Henrik Schmiediche" <henrik@stat.tamu.edu>
Subject: RE: Extremely high load on NFS clients wen the NFS server is down...
Date: Wed, 18 May 2005 14:11:58 -0500
Message-ID: <200505181912.j4IJCS8v011808@s7.stat.tamu.edu>
References: <428B82EA.7050509@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYTy5-0002Pq-M5
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:12:33 -0700
Received: from s7.stat.tamu.edu ([165.91.117.61])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYTy4-0000WR-3D
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:12:33 -0700
To: "'Steve Dickson'" <SteveD@redhat.com>
In-Reply-To: <428B82EA.7050509@RedHat.com>
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

     Steve,
Thanks for your response. The command 'echo t > /proc/sysrq-trigger' does
nothing that I can tell. Is there something I need to do to enable this
feature?

Completely useless means that the load continues to increase on the server
that has the NFS file systems mounted to the point it become sluggish and
ultimately stops responding altogether. As the load increases the system (at
the beginning) is still responsive so I can monitor it. 'top' suggests there
is no process eating up a significant amount of CPU as the load is
increasing. I do not know if the load ever plateaus, the system stops
responding before that point.

The kernel is 2.6.11.4-20a-smp --- the latest one as far as I know.

There is a lot of network traffic on the server. I will get an ethereal dump
when I can.

Sincerely,

    - Henrik






-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Steve Dickson
Sent: Wednesday, May 18, 2005 1:01 PM
To: Henrik Schmiediche
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] Extremely high load on NFS clients wen the NFS server is
down...



Henrik Schmiediche wrote:
> I have two Redhat AS3 servers. One of them (among other things) serves NFS
> file systems to my other systems including to the other server. When my
NFS
> file server goes down or is restarted the load on the other AS3 server
> increases to the point it is completely useless (it goes to 50+ in a
minute
> or two). I never observed this behavior when I was serving NFS file
systems
> using a Solaris system.
> 
> Has anyone observed this phenomenon?  Any solution to it?
No... Please define "completely useless". Is there a ton of
network traffic? If so, please produce a bzip2 binary tethereal
trace of the traffic. If the cpu is pined or the system hangs please
produce a system trace (i.e. echo t > /proc/sysrq-trigger).
Also what is the exact kernel version (i.e. uname -r).

steved.


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
