From: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Mon, 18 May 2009 11:18:06 +0200
Message-ID: <4A1127CE.5030701@bio.ifi.lmu.de>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>
	<c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be@mail.gmail.com>
	<4A02FDC3.9090709@bio.ifi.lmu.de>
	<4a02ffdf.1ac1f10a.637d.ffffbc3a@mx.google.com>
	<4A03CB1C.7020703@bio.ifi.lmu.de>
	<4a083d44.85c2f10a.4cf7.ffff85fb@mx.google.com>
	<4A0D0DFE.6040108@bio.ifi.lmu.de>
	<4a0d72a6.c5c2f10a.368f.5cc5@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>,
	nfs@lists.sourceforge.net
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57222 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822AbZERJSt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 05:18:49 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M5yze-0004nw-Pu
	for linux-nfs@vger.kernel.org; Mon, 18 May 2009 19:18:47 +1000
In-Reply-To: <4a0d72a6.c5c2f10a.368f.5cc5-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Talpey wrote

> Great! If you want the full NFSv4 benefit, you'll also need to enable
> delegation callbacks, which requires a TCP port in the other direction.
> This port is chosen by the client, but the server makes the connection,
> so you'll need to configure it in both the client and the firewall.
> 
> The port is set by an NFS sysctl parameter named "nfs_callback_tcpport",
> which by default is 0 (any). You'll need to set it to some value with
> 
> 	sysctl -w fs.nfs.nfs_callback_tcpport = <value>
> 
> and also in your firewall from the server->client. The range is 0 to 65535,
> you can choose any convenient unused value (e.g. 2050).

Your mails really help :-) I've read many notes about that problem and that
the  firewall must be opened etc., but none stated how to fix those ports!

> It could be any number of things, but probably harmless and properly
> ignored for NFSv4. I will guess it's something to do with the SLES11
> client and other daemons.

Ok, good to know.

> 
> Can you capture a trace of these messages with wireshark? The
> contents of the portmapper request the client is sending will tell us
> exactly what services it's trying to resolve.
> 
> Alternatively you could turn on kernel portmap debug and watch the
> log. I'm not sure if SLES11 has the "rpcdebug" command installed, but
> if so, on the client you could try
> 
> 	rpcdebug -m rpc -s bind
> 
> then watch the syslog.

The server and clients in charge are still running SLES 10 SP2, and it
doesn't have the rpcdebug command. However, SLES 11 has it, so I will
check when all the servers and clients have been upgraded.

So far, thanks a lot again :-)
cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *

------------------------------------------------------------------------------
Crystal Reports - New Free Runtime and 30 Day Trial
Check out the new simplified licensing option that enables 
unlimited royalty-free distribution of the report engine 
for externally facing server and web deployment. 
http://p.sf.net/sfu/businessobjects
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

