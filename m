From: Eiwe Lingefors <eiwe@jhu.edu>
Subject: More Stale NFS handles
Date: Thu, 23 Jun 2005 16:55:36 -0400
Message-ID: <449CA531-2B73-458E-B632-B1E159637115@jhu.edu>
Mime-Version: 1.0 (Apple Message framework v730)
Content-Type: text/plain; format=flowed; delsp=yes; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DlYjg-0005MV-P8
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 13:55:44 -0700
Received: from ipex1.johnshopkins.edu ([162.129.8.141])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DlYjf-0005Xv-A1
	for nfs@lists.sourceforge.net; Thu, 23 Jun 2005 13:55:44 -0700
Received: from [10.0.15.48] (dingo.clsp.jhu.edu [128.220.117.40])
 by jhuml3.jhu.edu (PMDF V6.2-X20 #30840)
 with ESMTPS id <0IIK00GW424PSM@jhuml3.jhu.edu> for nfs@lists.sourceforge.net;
 Thu, 23 Jun 2005 16:55:37 -0400 (EDT)
To: nfs@lists.sourceforge.net
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

I have trawled the nfs mailing list archives a bit and judging by  
recent posts there is undoubtedly several others with the same  
problem.   The problems started happening when I installed a new  
Fedora Core 3 server and migrated home directories to it. Like Jim  
Farley mentioned in a recent thread on the list, our environment has  
been stable for years prior.

The server:
Dell PowerEdge 2850
1 x PowerVault 220S 14x300GB SCSI
Fedora Core 3
Kernel 2.6.9-1.667smp
Several exported LVM volumes all formatted with reiserfs v3.6

The clients:
64 x IBM x335 cluster nodes
RedHat 7.3
Kernel 2.4.26

40 x Sun Blade 150
Solaris 9

Things I have done:
x Upgraded automount on all linux clients to 4.1.4
x Tuned rsize,wsize,timeo,retrans
x Increased number of nfsd processes to 128

So far nothing I have done has helped reduce the amount of stale NFS  
file handles.

I'm not sure what additional information might be helpful. The  
problems I'm having essentially mirror those of others who have  
posted regarding stale NFS handles in the past few months on this  
list. I'm at my wits end after having fought with this problem for  
weeks. Any insight or pointers would be deeply appreciated. I'll be  
happy to provide additional information if needed.

Thanks,
Eiwe Lingefors

PS. I have quoted Jim Farley's message below since the problems are  
essentially identical to mine.

Jim Farley wrote:

 > Hi,
 >
 > We have been running an nfs environment for a couple of years now  
without
 > difficulties. Unfortunately when we upgraded the nfs server from  
RedHat9 to Fedora
 > Core 3 (2.6.9-1.667smp), clients (10 RedHat 9 systems,  
2.4.20-8smp) started getting
 > stale NFS file handles. I used tcpdump and verified that the  
messages are exchanged
 > between the server and client without delay which would indicate  
the network is not a
 > problem. I have also verified that the server is not under heavy  
load (cpu, memory,
 > network), nor are the clients.
 > We basically take the defaults on the client and on the server:
 >
 > Client:
 > cat /proc/mounts:
 > 192.168.11.10:/home /home nfs
 > rw,v3,rsize=4096,wsize=4096,hard,intr,udp,lock,addr=192.168.11.10 0 0
 >
 > Server:
 > cat /etc/exports
 > /home 192.168.11.0/255.255.255.0(rw,no_subtree_check)
 >
 > What I have done:
 > - increase number of nfsd's to 32
 > - disabled caching on one client (noac)
 > - reverted the server from the ext3 filesystem to ext2
 >
 > None of this has helped. Is there anything else I can try?
 >
 > Thanks,
 > Jimmy



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
