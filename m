From: Luis Cano <Luis.Cano@noaa.gov>
Subject: nfsd problem?
Date: Thu, 28 Mar 2002 16:15:01 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CA387D5.6050709@noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Received: from mx1.wwb.noaa.gov ([140.90.193.27] helo=mx1.ncep.noaa.gov)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16qhHP-0002WL-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Mar 2002 13:17:56 -0800
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello,

Here is my configuration:

- One Raizone, dual processors PIII, 1.5g RAM, running 2.4.16-12smp, 
servicing as a NFS server, exporting a reiser filesystem.

- Five Dells 2450, dual processors PIII, 1g RAM, running 2.4.3-12smp, 
nfs-utils 0.3.1,  mounting the raidzone reiser filesystem via NFS:

rzdm:/home/ftp on /var/ftp/pub type nfs 
(ro,noatime,rsize=8192,wsize=8192,hard,intr,nolock,addr=x.x.x.x)

rzdm:/home/www on /var/www type nfs 
(rw,sync,noatime,rsize=8192,wsize=8192,hard,intr,nolock,addr=x.x.x.x)

where x.x.x.x is the ip of the raidzone.

The five dell servers are serving as ftp/web servers and front ended 
with a load balancer for  ftp and http traffic. During peak periods, the 
dell server load average climbs to over 400 and ftp throughput 
progressively drops from 7.6Mbytes per second to 1.5Mbytes per second. 
If we restart NFSD on the raidzone,  the dell servers load average drops 
to less than 2.5 and ftp throughput increases to the normal 7.6Mbytes 
per second. It takes about a day for the load average to climb up again 
and ftp throughput to decrease.

Is this a NFSD problem with 2.4.16? Is there something I can look at or 
other information needed to determine the problem?

Thank you and appreciate any help.

Luis Cano


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
