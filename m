From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Extremely high load on NFS clients wen the NFS server is
 down...
Date: Wed, 18 May 2005 14:01:14 -0400
Message-ID: <428B82EA.7050509@RedHat.com>
References: <200505181429.j4IET8GK023074@s7.stat.tamu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYSrD-0002B8-T9
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 11:01:23 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYSrD-0004nk-DQ
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 11:01:23 -0700
To: Henrik Schmiediche <henrik@stat.tamu.edu>
In-Reply-To: <200505181429.j4IET8GK023074@s7.stat.tamu.edu>
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



Henrik Schmiediche wrote:
> I have two Redhat AS3 servers. One of them (among other things) serves NFS
> file systems to my other systems including to the other server. When my NFS
> file server goes down or is restarted the load on the other AS3 server
> increases to the point it is completely useless (it goes to 50+ in a minute
> or two). I never observed this behavior when I was serving NFS file systems
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
