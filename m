From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: NFS mount problem (2000 NFS filesystems) of linux clients
 to a solaris server
Date: Fri, 09 Mar 2007 10:04:59 -0500
Message-ID: <EXNANE01okLQ8aZRhQd00000099@exnane01.hq.netapp.com>
References: <45F004BD.1070500@biochem.mpg.de> <45F15018.1060804@biochem.mpg.de>
	<EXNANE01VuMhvqgStMV00000097@exnane01.hq.netapp.com>
	<200703091546.19536.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPgey-0002kp-T4
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 07:05:33 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPgez-0006tH-SL
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 07:05:35 -0800
In-Reply-To: <200703091546.19536.olaf.kirch@oracle.com>
References: <45F004BD.1070500@biochem.mpg.de> <45F15018.1060804@biochem.mpg.de>
	<EXNANE01VuMhvqgStMV00000097@exnane01.hq.netapp.com>
	<200703091546.19536.olaf.kirch@oracle.com>
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

At 09:46 AM 3/9/2007, Olaf Kirch wrote:
>On Friday 09 March 2007 14:09, Talpey, Thomas wrote:
>> The mount command creates and binds a socket in userspace, then
>> passes it to the kernel for connecting to the server. Newer kernels
>> don't use this socket however, and it is closed when the mount
>> completes. However, it's a TCP socket and is bound to a privileged
>> port, the socket isn't destroyed immediately, it sticks around for
>> a short time.
>
>Why do we keep creating those at all?

Good question! There's already some checking for kernel version in that
code to handle ancient-kernel compat, it certainly could be extended
to this. Or tossed altogether. It certainly makes no sense for IPv6 or
RDMA or ...

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
