From: Patrick Boutilier <boutilpj@ednet.ns.ca>
Subject: Cpu usuage baloons to 100% on both CPUs
Date: Mon, 22 Apr 2002 10:41:16 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CC412FC.20601@ednet.ns.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from trademart-1.ednet.ns.ca ([142.227.51.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16ze4F-0004DO-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 06:41:19 -0700
Received: from trademart-4.ednet.ns.ca ([142.227.51.51] helo=ednet.ns.ca)
	by Trademart-1.ednet.ns.ca with esmtp (Exim 3.35 #1)
	id 16ze4D-0001Ef-00
	for nfs@lists.sourceforge.net; Mon, 22 Apr 2002 10:41:17 -0300
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

Hi,

I am trying to replace a tape library with NFS mounted disk storage for 
an ADSM server solution. We have a 3Ware 7850 storage switch with 8 160G 
Maxtor's connected to it. I have created a 1.1T nfs export under 
/var/adsm which is nfs mounted by an AIX 4.3 machine ADSM server).

The ADSM server needs to format volumes on the NFS server. I setup a 
perl script to do so, attempting to create 1000 1 Gig volumes at the 
root of the nfs mount point. After the 79th volume was created the CPU 
usage on both AMD 1800+ CPUs went to 100% and the creation of the 
voulmes slowed down drastically from a steady 2 minutes per 1 Gig volume 
to over 10 minutes per 1 Gig volume. The times kept increasing so a 
stopped the script. I noticed that I could create a volume in a 
subdirectory of the nfs mount in 2 minutes (25-30% CPU usuage on both 
CPUs) at this point so I decided to switch my strategy and create 20 
1Gig volumes under 50 seperate directories called backup1 , backup2 , 
etc.. for a total of 50 subdirectories each containing 20 1 Gig volumes.

This strategy appeared to be working until the creation of the 750th or 
so (can't remember the exact number) volume when once again the CPU 
usuage went to 100% and poerformance dropped. Figuring I had hit a file 
number limit or something I restarted once again creating 20 2Gig 
volumes in 25 subdirectories. Once again the CPU usuage went up to 100% 
after the 327 volume was created.

Thinking this might be an ADSM/AIX problem I nfs mounted the same nfs 
export from my linux box and tried to rsync an ISO image to the 
directory (backup17) where the problem occured. Same thing. CPU usuage 
went to 100%. However rsyncing the ISO image through ssh instead of 
through the nfs mount didn't cause the problem to occur so it doesn't 
appear to ba filesystem problem. Now for the really weird part. I can 
rsync through nfs an ISO image into backup16 (which contains 20 2Gig 
volumes) and backup18 which is empty and the problem doesn't occur. I am 
now creating more ADSM volumes in backup18 - backup25 and the peformance 
is fine. I am waiting to see if I hit another performance snag. :-)

So what is so special about the subdirectory backup17 at this point?


I am using Redhat 7.3 beta with a 2.4.19pre6 kernel. The machine is a 
dual CPU Athalon 1800+ with 512Meg of RAM. I will try RedHat 7.2 on 
another machine later to see if the problem is related to the 7.3 beta.




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
