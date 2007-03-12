From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: NFS mount problem (2000 NFS filesystems) of linux clients
 to a solaris server
Date: Mon, 12 Mar 2007 08:35:14 -0400
Message-ID: <EXNANE0169aZbLAX3cf000000af@exnane01.hq.netapp.com>
References: <45F004BD.1070500@biochem.mpg.de> <45F15018.1060804@biochem.mpg.de>
	<EXNANE01VuMhvqgStMV00000097@exnane01.hq.netapp.com>
	<200703091546.19536.olaf.kirch@oracle.com>
	<EXNANE01okLQ8aZRhQd00000099@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQjkm-0003oo-L6
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 05:35:52 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQjkn-0005r6-Ev
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 05:35:54 -0700
Received: from svlexc02.hq.netapp.com (svlexc02.corp.netapp.com
	[10.57.157.136])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l2CCZlIr021636
	for <nfs@lists.sourceforge.net>; Mon, 12 Mar 2007 05:35:47 -0700 (PDT)
In-Reply-To: <EXNANE01okLQ8aZRhQd00000099@exnane01.hq.netapp.com>
References: <45F004BD.1070500@biochem.mpg.de> <45F15018.1060804@biochem.mpg.de>
	<EXNANE01VuMhvqgStMV00000097@exnane01.hq.netapp.com>
	<200703091546.19536.olaf.kirch@oracle.com>
	<EXNANE01okLQ8aZRhQd00000099@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 11:04 AM 3/9/2007, Talpey, Thomas wrote:
>At 09:46 AM 3/9/2007, Olaf Kirch wrote:
>>On Friday 09 March 2007 14:09, Talpey, Thomas wrote:
>>> The mount command creates and binds a socket in userspace, then
>>> passes it to the kernel for connecting to the server. Newer kernels
>>> don't use this socket however, and it is closed when the mount
>>> completes. However, it's a TCP socket and is bound to a privileged
>>> port, the socket isn't destroyed immediately, it sticks around for
>>> a short time.
>>
>>Why do we keep creating those at all?
>
>Good question! There's already some checking for kernel version in that
>code to handle ancient-kernel compat, it certainly could be extended
>to this. Or tossed altogether. It certainly makes no sense for IPv6 or
>RDMA or ...

I was going to volunteer a patch for this, but when I went and dug up
the last kernel to use the nfs_mount_data->fd, I discovered it was
2.1.31 (two dot *one* dot thirtyone) released on April 3 1997.

For its ten-year anniversary, is the better approach to delete this
support from nfs-utils altogether? It means that nfs-utils >1.0.12
won't work on early-to-mid 2.1 kernels. Which does not strike me
as a likely issue.

Or, would everyone prefer that the compatibility be retained?

I'll send the latter compatible patch if nobody has an opinion.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
