From: Didier CONTIS <didier@ece.gatech.edu>
Subject: Re: Pb of optimization for a Cluster under Gigabit
Date: Wed, 07 Apr 2004 22:17:28 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4074B638.2050206@ece.gatech.edu>
References: <482A3FA0050D21419C269D13989C61130435DEAA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBP6t-0000As-D4
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 19:17:43 -0700
Received: from mail.ee.gatech.edu ([130.207.225.105])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BBP6t-000653-0s
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 19:17:43 -0700
Received: from localhost (k4.ece.gatech.edu [130.207.226.168])
	by mail.ee.gatech.edu (8.12.10/8.12.10) with ESMTP id i382HfZo022900
	for <nfs@lists.sourceforge.net>; Wed, 7 Apr 2004 22:17:41 -0400 (EDT)
Received: from mail.ee.gatech.edu ([130.207.225.105])
 by localhost (k4.ece.gatech.edu [130.207.226.168]) (amavisd-new, port 10024)
 with LMTP id 32603-05 for <nfs@lists.sourceforge.net>;
 Wed,  7 Apr 2004 22:17:40 -0400 (EDT)
Received: from ece.gatech.edu (adsl-211-40-35.asm.bellsouth.net [68.211.40.35])
	(authenticated bits=0)
	by mail.ee.gatech.edu (8.12.10/8.12.10) with ESMTP id i382HaLQ022878
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <nfs@lists.sourceforge.net>; Wed, 7 Apr 2004 22:17:40 -0400 (EDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DEAA@lavender-fe.eng.netapp.com>
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


> that may be completely normal.
> i don't think the load average is a good indication of
> how hard your server is working.  is your application
> throughput reasonable?  any response time problems?

I had some timeos until I reboot the server
(before sending my e-mail to the mailing list) + high load.

Currently I have just a high load (I update the RH AS 2.1 kernel to the
latest rev). I thought it was odd considering
the hardware and in comparison of the load I had with older Linux file
server of other clusters.

I did look at the section 5 of the HOWTO before e-mailing the list
(even though I confused myself in using the sync option on the server
and client side). I just did not want to keep playing increasing
my number of NFSD / increasing the rsize + wsize before asking.

To answer someone else, the options as shown from the cat /proc/mount
are:

rw,v3,rsize=8192,wsize=8192,hard,intr,udp,lock,addr=xnfs1...

Something weird I noticed -> I switched the file server exports
from sync to async. Of course I got better performance in terms of 
response time on the client side (up to 50s saved on some linking
operations during compilation).
In addition the load on the file server got divided
by 2 (need to do a better and longuer monitoring with ganglia for 
example). Can such a load decrease be expected ? I am surprised.

Too side question

1) Is the Kernel of Redhat AS 2.1 broken NFS wise and I should speed-up
    the upgrade of the file server to AS 3.0 ? Please note that using RH
    on the file server was imposed by Dell + EMC for the PowerPath
    install (redundant pathing)

2) Has anyone of the list any experience on running an NFS server
    connected to an EMC Clariion SAN with their PowerPath software ?

Thanks - Didier.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
