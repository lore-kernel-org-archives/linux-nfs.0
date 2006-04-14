From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: No UDP NFS over bridges in Linux 2.6.16.x?
Date: Fri, 14 Apr 2006 13:53:21 -0700
Message-ID: <20060414135321.53e60516@dxpl.pdx.osdl.net>
References: <20060414094042.2a36d377@localhost.localdomain>
	<20060414192656.870.qmail@web52914.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bridge@osdl.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUVIJ-0005af-44
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 13:53:31 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FUVIH-0001sM-Ik
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 13:53:31 -0700
To: Chris Rankin <rankincj@yahoo.com>
In-Reply-To: <20060414192656.870.qmail@web52914.mail.yahoo.com>
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

On Fri, 14 Apr 2006 20:26:56 +0100 (BST)
Chris Rankin <rankincj@yahoo.com> wrote:

> --- Stephen Hemminger <shemminger@osdl.org> wrote:
> > Most likely the problem is that the MTU on the two devices in the bridge is different.
> > The bridge will silently drop packets if they are too large for the destination port (it's in
> > the 802.1d standard). TCP has path mtu discovery and is smart enough to recover.  UDP doesn't do
> > that.
> 
> Hi,
> 
> Thanks for the top about the dangers of NFS and UDP. However, I don't think that the MTU is the
> problem. All the ethernet devices (including the bridge) have an MTU of 1500, and according to my
> routing table, only the default route has a lower MTU. Both servers are configured like this:
> 
> 192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.x
> 169.254.0.0/16 dev eth0  scope link
> default via 192.168.0.1 dev eth0  src 192.168.0.x  advmss 1452
> 
> eth0      Link encap:Ethernet  HWaddr nn:nn:nn:nn:nn:nn
>           inet addr:192.168.0.x  Bcast:192.168.0.255  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:6817 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:4951 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:1840267 (1.7 MiB)  TX bytes:678873 (662.9 KiB)
>           Base address:0xdcc0 Memory:ff6e0000-ff700000
> 
> So all traffic between 192.168.0.x machines should be routed with an MTU of 1500.
> 
> Cheers,
> Chris

What is the mtu of eth0 and eth1 on the bridge?

> 
> 
> 
> 		
> ___________________________________________________________ 
> Switch an email account to Yahoo! Mail, you could win FIFA World Cup tickets. http://uk.mail.yahoo.com
> 
> 
> 		
> ___________________________________________________________ 
> Switch an email account to Yahoo! Mail, you could win FIFA World Cup tickets. http://uk.mail.yahoo.com


-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
