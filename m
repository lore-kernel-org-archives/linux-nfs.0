From: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Fri, 15 May 2009 08:38:54 +0200
Message-ID: <4A0D0DFE.6040108@bio.ifi.lmu.de>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>
	<c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be@mail.gmail.com>
	<4A02FDC3.9090709@bio.ifi.lmu.de>
	<4a02ffdf.1ac1f10a.637d.ffffbc3a@mx.google.com>
	<4A03CB1C.7020703@bio.ifi.lmu.de>
	<4a083d44.85c2f10a.4cf7.ffff85fb@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:42631 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753412AbZEOGjw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2009 02:39:52 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M4r5E-0005tF-IE
	for linux-nfs@vger.kernel.org; Fri, 15 May 2009 16:39:52 +1000
In-Reply-To: <4a083d44.85c2f10a.4cf7.ffff85fb-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Talpey wrote

> The very best solution, by the way, would be to use NFSv4. It has no
> side protocols, and therefore no UDP issue. It does have a callback
> connection from the server to the client, but is done with TCP and is
> configurable.

I've indeed switched our through-firewall-nfsservers to NFSv4 and
the problems are gone. Thanks a lot for pointing me there!
I only open port 2049/tcp and everything works.

However, I still see blocked connections on the firewall, coming from
the NFS client to the NFS server: 
...PROTO=TCP SPT=55598 DPT=111...
rpcinfo tells me the portmapper is running at port 111 (udp and tcp).

I didn't find a clear statement when googling if that should happen
with NFSv4 or not. It doesn't seem to block the NFS share in any way,
at least as far as I can see. 

I wouldn't mind to open tcp port 111 to the NFS server. I'm just curios
if that behaviour is correct or not with NFSv4.

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

