From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Fri, 15 May 2009 09:48:16 -0400
Message-ID: <4a0d72a6.c5c2f10a.368f.5cc5@mx.google.com>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>
	<c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be@mail.gmail.com>
	<4A02FDC3.9090709@bio.ifi.lmu.de>
	<4a02ffdf.1ac1f10a.637d.ffffbc3a@mx.google.com>
	<4A03CB1C.7020703@bio.ifi.lmu.de>
	<4a083d44.85c2f10a.4cf7.ffff85fb@mx.google.com>
	<4A0D0DFE.6040108@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:39022 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753372AbZEON4M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2009 09:56:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M4xtT-00074g-Qw
	for linux-nfs@vger.kernel.org; Fri, 15 May 2009 23:56:11 +1000
In-Reply-To: <4A0D0DFE.6040108-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 02:38 AM 5/15/2009, Frank Steiner wrote:
>Tom Talpey wrote
>
>> The very best solution, by the way, would be to use NFSv4. It has no
>> side protocols, and therefore no UDP issue. It does have a callback
>> connection from the server to the client, but is done with TCP and is
>> configurable.
>
>I've indeed switched our through-firewall-nfsservers to NFSv4 and
>the problems are gone. Thanks a lot for pointing me there!
>I only open port 2049/tcp and everything works.

Great! If you want the full NFSv4 benefit, you'll also need to enable
delegation callbacks, which requires a TCP port in the other direction.
This port is chosen by the client, but the server makes the connection,
so you'll need to configure it in both the client and the firewall.

The port is set by an NFS sysctl parameter named "nfs_callback_tcpport",
which by default is 0 (any). You'll need to set it to some value with

	sysctl -w fs.nfs.nfs_callback_tcpport = <value>

and also in your firewall from the server->client. The range is 0 to 65535,
you can choose any convenient unused value (e.g. 2050).

BTW when NFSv4.1 is in use, this reverse connection will no longer occur.
But that's a ways off in the distribution kernels.

>However, I still see blocked connections on the firewall, coming from
>the NFS client to the NFS server: 
>...PROTO=TCP SPT=55598 DPT=111...
>rpcinfo tells me the portmapper is running at port 111 (udp and tcp).
>
>I didn't find a clear statement when googling if that should happen
>with NFSv4 or not. It doesn't seem to block the NFS share in any way,
>at least as far as I can see. 

It could be any number of things, but probably harmless and properly
ignored for NFSv4. I will guess it's something to do with the SLES11
client and other daemons.

Can you capture a trace of these messages with wireshark? The
contents of the portmapper request the client is sending will tell us
exactly what services it's trying to resolve.

Alternatively you could turn on kernel portmap debug and watch the
log. I'm not sure if SLES11 has the "rpcdebug" command installed, but
if so, on the client you could try

	rpcdebug -m rpc -s bind

then watch the syslog.

>I wouldn't mind to open tcp port 111 to the NFS server. I'm just curios
>if that behaviour is correct or not with NFSv4.

It's not part of NFSv4. But it could be a side effect of the client NFS
implementation, which also supports v2 and v3 plus NSM, NLM, etc etc.

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

