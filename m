From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Mon, 11 May 2009 10:59:07 -0400
Message-ID: <4a083d44.85c2f10a.4cf7.ffff85fb@mx.google.com>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>
	<c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be@mail.gmail.com>
	<4A02FDC3.9090709@bio.ifi.lmu.de>
	<4a02ffdf.1ac1f10a.637d.ffffbc3a@mx.google.com>
	<4A03CB1C.7020703@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Leonardo Chiquitto <leonardo.lists@gmail.com>,
	nfs@lists.sourceforge.net
To: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:58207 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756515AbZEKO75 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 May 2009 10:59:57 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M3Wyx-0002Rt-5p
	for linux-nfs@vger.kernel.org; Tue, 12 May 2009 00:59:55 +1000
In-Reply-To: <4A03CB1C.7020703-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 02:03 AM 5/8/2009, Frank Steiner wrote:
>Tom Talpey wrote
>
>
>> In particular, if you do NLM file locking, there is a server callback (NLM
>> "granted") which the server may choose to issue via UDP. If this callback
>> is not seen by the client due to firewall blocking, there may be a 30-second
>> pause before a client retry unblocks the caller.
>> 
>> Also, the NSM (status monitor) exchanges are often performed via UDP.
>> Again, if you are using NLM and the server reboots, the client may not
>> become aware of this promptly, and lock reclaim will be affected.
>> 
>> OTOH, if your applications don't use locking on the NFS mounts, you'll
>> probably be fine.
>
>We do use locking on nfs mounts, so I wonder what that would mean for the
>firewall. Currently I see connections from the NFS server *from* port 700
>and 111 (we've fixed mountd port to 700) to (it seems) arbitrary udp
>ports on the NFS clients.
>
>Would that be enough to allow those? Or could the source ports be arbitrary
>with NLM, too? I.e., would we have to open all udp traffic from the NFS
>servers to all the NFS clients?

The calls from the server to client port 111 are portmapper lookups, very likely
while setting up the NSM callback that the server performs when it boots up.
If the portmap call succeeds, then a second NSM call will occur, to whatever
port the client NSM is using (700 sounds reasonable, but it's not guaranteed).

NLM callbacks on blocking lock collision will be similar, but will happen any time
not just at server reboot. The server will resolve the client NLM daemon using
port 111, then perform a call to the result on whatever port is returned.

There are very likely many ways to make these calls work through a firewall,
but unfortunately not very many ways to guarantee it. The big problem is
that the callbacks will be nearly silent on failure, so success is hard to detect!

Depending on how criticial the application is, I would make different
recommendations. But the safest option from a reliability standpoint might be
to, yes, open up all UDP traffic. Ouch. There are other ways, but they're
likely to be more fragile, and not all server/client combinations might work
with a single solution.

You might want to think through the DNS issues of this firewall, too. Are
all the clients using hostnames in the same DNS domain as the server? And,
do any of them use DHCP or other dynamic assignment? You want to be
sure to use FQDNs as the client hostname(2), to ensure the server can
always resolve them properly.

I made a presentation on some of the NSM issues a few years back for
Connectathon, if you're brave :-) you can check out:
	http://www.connectathon.org/talks06/talpey-cthon06-nsm.pdf

The very best solution, by the way, would be to use NFSv4. It has no
side protocols, and therefore no UDP issue. It does have a callback
connection from the server to the client, but is done with TCP and is
configurable.

Tom.


------------------------------------------------------------------------------
The NEW KODAK i700 Series Scanners deliver under ANY circumstances! Your
production scanning environment may not be a perfect world - but thanks to
Kodak, there's a perfect scanner to get the job done! With the NEW KODAK i700
Series Scanner you'll get full speed at 300 dpi even with all image 
processing features enabled. http://p.sf.net/sfu/kodak-com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

