From: Stephen Carville <stephen@totalflood.com>
Subject: Re: NFS3 in RHEL3
Date: Fri, 14 Apr 2006 14:20:31 -0700
Message-ID: <4440121F.5020704@totalflood.com>
References: <443F37FA.2060402@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUViU-0008Or-Bj
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 14:20:34 -0700
Received: from [208.57.204.2] (helo=mail.totalflood.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FUViT-0001sI-N2
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 14:20:34 -0700
Received: from [192.168.124.232] (pellucidar.totalflood.com [192.168.124.232])
	by mail.totalflood.com (Un-Exchange Mail Version 9.7.2.4) with ESMTP id D1340540A8
	for <nfs@lists.sourceforge.net>; Fri, 14 Apr 2006 14:20:31 -0700 (PDT)
To: NFS List <nfs@lists.sourceforge.net>
In-Reply-To: <443F37FA.2060402@oracle.com>
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

shashi wrote:
> Hi
> 
> A small doubt about NFS3 in Linux . If i mount a NFS share (From NetApp
>  , ONTAP 6.5 ) on a Linux machine with only ro,nolock options , then
> still the NFS mount options like
> bg,intr,hard,timeo,wsize,rsize,nfsvers,tcp are still applied ? If they
> are applied , how can i check is those are applied or not ?
> 
> In my Linux box , after mounting with only ro,nolock options .....
> 
> [root@<hostname>]# mount | grep < Mount point>
> <NFS server> on < Mount point >  type nfs (ro,nolock,addr=144.20.129.248)
> 
> In this case , is other other options like
> bg,intr,hard,timeo,wsize,rsize,nfsvers,tcp are applied ? if they are
> applied , what are the default values ?
> 
> Please answer to my question.
> 

"man nfs" lists the options and their defaults

-- 
Stephen Carville <stephen@totalflood.com>
Unix and Network Admin
Nationwide Totalflood
6033 W. Century Blvd
Los Angeles, CA 90045
310-342-3602


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
