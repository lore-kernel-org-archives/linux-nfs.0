From: Harald Hannelius <harald+nfs@arcada.fi>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Thu, 27 May 2004 16:03:39 +0300 (EEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0405271558300.12353@penti.sit.fi>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
 <20040527143919.4bdda5d7@shodan.citadel>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTKXu-0000RP-VD
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 06:03:42 -0700
Received: from penti.sit.fi ([193.167.33.237])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BTKXu-00010e-3e
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 06:03:42 -0700
Received: from penti.sit.fi (harald@localhost [127.0.0.1])
	by penti.sit.fi (8.12.10/8.12.10) with ESMTP id i4RD3dgT012509
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 16:03:39 +0300
Received: from localhost (harald@localhost)
	by penti.sit.fi (8.12.10/8.12.9/Submit) with ESMTP id i4RD3dPJ012506
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 16:03:39 +0300
To: nfs@lists.sourceforge.net
In-Reply-To: <20040527143919.4bdda5d7@shodan.citadel>
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


On Thu, 27 May 2004, Dexter Filmore wrote:

> How are the GB NICs attached? Onboard? Integrated into Southbridge? PCI?
> PCI-X?

It's a Tyan K8S PRo, dual tigon 3 NICs onboard.

eth0: Tigon3 [partno(BCM95704A7) rev 2003 PHY(5704)] (PCIX:100MHz:64-bit)
10/100/1000BaseT Ethernet 00:e0:81:28:cf:89

> If it's plain old PCI, you won't get more, PCI maxes out here.

Oh, and why do netcat transfer the 2GB file in 25 secs? With the same NIC
and network ofcourse.. As stated in my original message.

I tried linux-2.4.26 kernel instead. Now the 'time cat file > /dev/null'
takes 1 min 3s on the client which is more like I wanted it. That should
equal to something around 254Mbps..

Since I don't have any real reason for a 2.6 kernel right now (32bit
distro) I will rest my case here. Just thought someone would like to
know..

  Cheers, and many thanks

	Harald


-- 
A: Top Posters
Q: What is the most annoying thing on mailing lists?

Harald H Hannelius | harald/a\arcada.fi      | GSM +358 50 594 1020


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
