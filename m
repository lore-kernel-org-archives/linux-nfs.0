From: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Fri, 22 May 2009 13:05:29 +0200
Message-ID: <4A1686F9.8030307@bio.ifi.lmu.de>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>	<c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be@mail.gmail.com>	<4A02FDC3.9090709@bio.ifi.lmu.de>	<4a02ffdf.1ac1f10a.637d.ffffbc3a@mx.google.com>	<4A03CB1C.7020703@bio.ifi.lmu.de>	<4a083d44.85c2f10a.4cf7.ffff85fb@mx.google.com>	<4A0D0DFE.6040108@bio.ifi.lmu.de>	<4a0d72a6.c5c2f10a.368f.5cc5@mx.google.com>	<4A1127CE.5030701@bio.ifi.lmu.de>
	<4a115a4c.47c1f10a.53d0.ffff96cc@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54125 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753117AbZEVLGM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 May 2009 07:06:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M7SZn-0003Aw-VD
	for linux-nfs@vger.kernel.org; Fri, 22 May 2009 21:06:12 +1000
In-Reply-To: <4a115a4c.47c1f10a.53d0.ffff96cc-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Talpey wrote

> If the rpcdebug command isn't available, you can alternatively set
> set the RPCDBG_BIND bit with
> 
> 	echo 32 >/proc/sys/sunrpc/rpc_debug
> 
> and clear it by echoing 0. Many other bits are accessible btw, defined
> in the kernel include/sunrpc/debug.h file.

Thanks :-) Looking at the debug output I found it was a different
program but NFS that was trying to contact the portmapper :-)

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *

------------------------------------------------------------------------------
Register Now for Creativity and Technology (CaT), June 3rd, NYC. CaT
is a gathering of tech-side developers & brand creativity professionals. Meet
the minds behind Google Creative Lab, Visual Complexity, Processing, & 
iPhoneDevCamp asthey present alongside digital heavyweights like Barbarian
Group, R/GA, & Big Spaceship. http://www.creativitycat.com 
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

