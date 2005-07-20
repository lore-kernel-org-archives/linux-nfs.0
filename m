From: Brett Petrusek <brettp@aspsys.com>
Subject: IA64 Server / IA32 Client Problem
Date: Wed, 20 Jul 2005 16:37:18 -0600
Message-ID: <42DED21E.4010608@aspsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DvN9T-0003rT-AD
	for nfs@lists.sourceforge.net; Wed, 20 Jul 2005 15:34:55 -0700
Received: from [216.150.199.16] (helo=mail.aspsys.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DvN9T-0007bl-5n
	for nfs@lists.sourceforge.net; Wed, 20 Jul 2005 15:34:55 -0700
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.aspsys.com (Postfix) with ESMTP id B087869001B
	for <nfs@lists.sourceforge.net>; Wed, 20 Jul 2005 16:34:54 -0600 (MDT)
Received: from [192.168.0.38] (unknown [192.168.0.38])
	by mail.aspsys.com (Postfix) with ESMTP id 0DC6B69000B
	for <nfs@lists.sourceforge.net>; Wed, 20 Jul 2005 16:34:54 -0600 (MDT)
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

I'm not sure if this is a bug or what, but I am experiencing severe 
performace problems between an IA64 NFS server and IA32 NFS client. I 
have tried every combination of socket buffer sizes as well as many 
other nfs options, but none of them seem to have any effect. I have 
tried RHEL21 to RHEL3U5 with all of these socket combos and still no 
difference. The command I am running is:

time dd if=/dev/zero of=/scratch_dir_across_nfs bs=1M count=128

Between two IA32 machines this takes 4-5 seconds. Between IA64 server 
and IA32 client this takes on the order of minutes. Network performance 
has been eliminated from the equation as after kernel tuning we have 
achieved consistent 94% of peak tcp throughput and 95.7% of peak udp 
throughput on our GigE network.  This is both between IA32 and IA64 
systems.

Let me know if there is an other info I should provide to help 
troubleshoot this problem.

Any help is appreciated.
Thanks, Brett P


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
