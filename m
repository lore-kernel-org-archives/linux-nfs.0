From: Dexter Filmore <Dexter.Filmore@gmx.de>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Thu, 27 May 2004 14:39:19 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040527143919.4bdda5d7@shodan.citadel>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTKAR-00044o-Ne
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 05:39:27 -0700
Received: from pop.gmx.de ([213.165.64.20] helo=mail.gmx.net)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BTKAQ-0004Xp-WA
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 05:39:27 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
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


How are the GB NICs attached? Onboard? Integrated into Southbridge? PCI?
PCI-X? 
If it's plain old PCI, you won't get more, PCI maxes out here. 


On Thu, 27 May 2004 13:31:57 +0300 (EEST)
Harald Hannelius <harald+nfs@arcada.fi> wrote:

> 
> Hi there,
> 
> I'm running two servers, both Dual Opterons with Broadcom Gb NICs. I'm
> using the bcm5700 driver and I see no errors whatsoever with 'ifconfig'.
> 
> I'm using nfs-utils-1.0.6 and the 2.6.6 kernel, compiled with both NFSv3
> and NFSv4 support. The client and servers are identical except for the
> server having a scsi-raid under /home and the client being and IDE-box.
> 
> Distribution slackware-9.1 on both computers.
> 
> /etc/exports;
> 
>    /home   193.167.32.175(ro,no_root_squash,async)
> 
> /etc/fstab;
> 
>   193.167.32.187:/home    /home   nfs     \
>  defaults,noauto,rsize=32768,wsize=32768,nfsvers=3 0 0
> 
> (as you can see I have experimented with different rsize,wsize without any
> noticeable effect, same goes for nfsvers 2 and 3. I even mounted the
> filesystem as ext2 on the server and as ext3 with data=journal with no
> effect)
> 
> The computers are connected through a HP 8-port Gb switch and are on the
> same subnet.
> 
> rsync over ssh gives me roughly 200Mbps (37 GB dataset)
> netcat over tcp with a 2GB file gives me 457 Mbps
> netcat over udp with a 2GB file gives me 640 Mbps
> 
> But dd'ing the 2GB file over nfs as some NFS-HOWTO suggests takes over 5
> minutes. That should equal to something around 49 Mbps, correct?
> 
> The netcat takes 25 secs to transfer 2GB file.
> 
> Is there some way I can look at the nfs-server what it's doing? Any
> suggestions on solutions for this?
> 
> And what datarates over NFS could I expect on a setup like this?
> Half-wirespeed maybe?
> 
> Thanks in advance,
> 
>   Harald
> 
> 
> -- 
> A: Top Posters
> Q: What is the most annoying thing on mailing lists?
> 
> Harald H Hannelius | harald/a\arcada.fi      | GSM +358 50 594 1020
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: Oracle 10g
> Get certified on the hottest thing ever to hit the market... Oracle 10g. 
> Take an Oracle 10g class now, and we'll give you the exam FREE.
> http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-- 
-----BEGIN GEEK CODE BLOCK-----
Version: 3.12
GCS d--(+)@ s-:+ a- C+++(++++) UL+>++++ P+>++ L+++>++++ E-- W++ N o? K-
w--(---) !O M+ V- PS++(+) PE(-) Y+ PGP(-) t++(---)@ 5 X+(++) R+(++) tv--(+)@ 
b+(+++) DI+++ D G++ e* h>++ r%>* y?
------END GEEK CODE BLOCK------

http://www.againsttcpa.com - nothing fights like the opposition


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
