From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: NFS3 in RHEL3
Date: Fri, 14 Apr 2006 10:54:58 -0400
Message-ID: <443FB7C2.6060600@citi.umich.edu>
References: <443F37FA.2060402@oracle.com>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUPhS-0001Fz-3o
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 07:55:06 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FUPhQ-0001kH-Vr
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 07:55:06 -0700
To: shashi <shashi.boddula@oracle.com>
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

You can examine /proc/mounts to find out the other mount options, but 
most of them are not displayed unless you set them explicitly.  The only 
way to tell exactly what is going on is to capture a network trace.

I highly recommend that you do not rely on the defaults.  They change 
over time, and most of the default settings in many distributions are 
not very good.

-- 
corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
