From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Mon, 18 May 2009 08:53:05 -0400
Message-ID: <4a115a4c.47c1f10a.53d0.ffff96cc@mx.google.com>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>
	<c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be@mail.gmail.com>
	<4A02FDC3.9090709@bio.ifi.lmu.de>
	<4a02ffdf.1ac1f10a.637d.ffffbc3a@mx.google.com>
	<4A03CB1C.7020703@bio.ifi.lmu.de>
	<4a083d44.85c2f10a.4cf7.ffff85fb@mx.google.com>
	<4A0D0DFE.6040108@bio.ifi.lmu.de>
	<4a0d72a6.c5c2f10a.368f.5cc5@mx.google.com>
	<4A1127CE.5030701@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49014 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272AbZERMyW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 08:54:22 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M62MF-0005eS-0w
	for linux-nfs@vger.kernel.org; Mon, 18 May 2009 22:54:19 +1000
In-Reply-To: <4A1127CE.5030701-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 05:18 AM 5/18/2009, Frank Steiner wrote:
>Tom Talpey wrote
...
>> Alternatively you could turn on kernel portmap debug and watch the
>> log. I'm not sure if SLES11 has the "rpcdebug" command installed, but
>> if so, on the client you could try
>> 
>> 	rpcdebug -m rpc -s bind
>> 
>> then watch the syslog.
>
>The server and clients in charge are still running SLES 10 SP2, and it
>doesn't have the rpcdebug command. However, SLES 11 has it, so I will
>check when all the servers and clients have been upgraded.

If the rpcdebug command isn't available, you can alternatively set
set the RPCDBG_BIND bit with

	echo 32 >/proc/sys/sunrpc/rpc_debug

and clear it by echoing 0. Many other bits are accessible btw, defined
in the kernel include/sunrpc/debug.h file.

Tom.


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

