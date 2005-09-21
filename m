From: Reuti <reuti@staff.uni-marburg.de>
Subject: Re: NFS client got stale NFS handle after server reboot
Date: Wed, 21 Sep 2005 18:49:42 +0200
Message-ID: <43318F26.2030001@staff.uni-marburg.de>
References: <433027F7.1030702@staff.uni-marburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EI7n8-0007gp-Rw
	for nfs@lists.sourceforge.net; Wed, 21 Sep 2005 09:49:54 -0700
Received: from vhrz24.hrz.uni-marburg.de ([137.248.1.34])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EI7n7-0002K3-BV
	for nfs@lists.sourceforge.net; Wed, 21 Sep 2005 09:49:55 -0700
Received: from staff.uni-marburg.de (pc15218.Chemie.Uni-Marburg.DE [137.248.152.52])
	by vhrz24.hrz.uni-marburg.de (8.13.4/8.13.4/Debian-3) with ESMTP id j8LGngUI018603
	for <nfs@lists.sourceforge.net>; Wed, 21 Sep 2005 18:49:42 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <433027F7.1030702@staff.uni-marburg.de>
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

Hi again,

Reuti wrote:
> Hi all,
> 
> I set up a NFS server using kernel NFS in kernel 2.6.11.4-21.9 from
> SuSE. I defined three directories to be exported using netgroups and all
> is working fine, as they can be mounted as intended by all the nodes in
> the cluster.
> 
> Up to now I was used to have the NFS feature, that a "hard" mount on the
> nodes will survive a reboot of the NFS server. This is now no longer the
> case. If I reboot the server, all the nodes get a stale NFS handle. I
> can achieve the same effect by simple stopping and starting the nfsd -
> same result.
> 
> As we use a RAID card for the disks in the server, I got the idea of
> changed major-minor numbers and also tried to give in the "exports"
> file a chosen "fsid=" for each of the three exports. (Although
> starting/stopping the nfsd won't change the major-minor numbers I
> think.) No change.
> 
> Now the funny part: login to a node. Choose any of the three imported
> directories. Make an "umount" and "mount" on this dir - and also the
> other two dirs reappear and are accessible again.
> 
> Does anyone has an explanation and/or solution for this setup, to get
> the surviving feature back?
> 
> CU - Reuti
> 
> (BTW: all partitions are ext2 on Linux x86 machines, mounted with NFSv3)

as a followup to my own posting:

I did some more testing: downloaded the latest stable kernel (2.6.13.2) 
and compiled for server and client, no success.

Then I installed a conventional IDE harddisk - same result. So it's not 
AACRAID to blame for.

Then I tried with another server, but a 32 bit machine. And with this it 
was working.

So my conclusion:

Server 64 bit and client 32 bit will not survive a stop/start of the NFS 
server. But if you unmount/mount one of the imported dirs, all will 
reappear as already stated.

Is this a known issue, and/or any solution to this?

Tomorrow I'll try to get another 64 bit machine as client, to check 
whether this would behave the same with the 64 bit server.

TIA - Reuti



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
