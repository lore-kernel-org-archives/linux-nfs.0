From: Dwight Marzolf <dwight.marzolf@analog.com>
Subject: udp ports not being released
Date: Mon, 22 Nov 2004 14:42:50 -0500
Message-ID: <41A2413A.9020800@analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWK5V-0003Gf-44
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 11:43:01 -0800
Received: from nwd2mail2.analog.com ([137.71.25.51])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWK5T-0000L7-Lt
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 11:43:00 -0800
Received: from nwd2mhb1.analog.com (nwd2mhb1.analog.com [137.71.5.12])
	by nwd2mail2.analog.com (8.12.10/8.12.10) with ESMTP id iAMJgrid002929
	for <nfs@lists.sourceforge.net>; Mon, 22 Nov 2004 14:42:53 -0500
Received: from titania.adsdesign.analog.com (titania.adsdesign.analog.com [10.66.62.63])
	by nwd2mhb1.analog.com (8.9.3 (PHNE_28810+JAGae91741)/8.9.3) with ESMTP id OAA19073
	for <nfs@lists.sourceforge.net>; Mon, 22 Nov 2004 14:42:50 -0500 (EST)
Received: from [10.66.22.21] (clapon [10.66.22.21])
	by titania.adsdesign.analog.com (8.10.2+Sun/8.10.2) with ESMTP id iAMJgsS17268
	for <nfs@lists.sourceforge.net>; Mon, 22 Nov 2004 14:42:54 -0500 (EST)
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

We are running RedHat 8, kernel 2.4.20-20.8smp and autofs 4.1.2.  We 
were having a variety of automount problems until a kernel patch was 
recommended.  We added this patch, recompiled our kernel, and 
distributed the patched kernel to all of our workstations.  About 90% of 
our problems disappeared.  But one problem seems to remain.

When /net is used to mount directories, most of the time the udp port 
used for that nfs mount operation is not released once the /net mount 
times out.   Depending on the level of activity on a machine, over the 
period of several days, all the available reserved ports are used up.  
At that point the user on the workstation cannot cd to any mount points 
in our automount maps except the ones already mounted.  In the 
/var/log/messages the following error occurs for attempted mounts:

RPC: Can't bind to reserved port

In my experiments I found that doing a "umount -l /net" releases all the 
udp ports immediately.  Our workaround has been to kill all the autofs 
processes, do a umount -l on all mount points in /etc/mtab, and them 
restart the autofs process.

My question is (1) is there any fix for this problem or some switch I 
need to turn on/off in order for these udp ports to be released when the 
mount point times out and (2) is there some command that I can use to 
release these ports rather than going through the multiple step process 
I described above to clean up a machine?

Dwight Marzolf




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
