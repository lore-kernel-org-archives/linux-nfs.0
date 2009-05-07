From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Thu, 07 May 2009 11:35:43 -0400
Message-ID: <4a02ffdf.1ac1f10a.637d.ffffbc3a@mx.google.com>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>
	<c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be@mail.gmail.com>
	<4A02FDC3.9090709@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Leonardo Chiquitto <leonardo.lists@gmail.com>,
	nfs@lists.sourceforge.net
To: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43923 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753469AbZEGPhZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2009 11:37:25 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M25f3-0006rN-09
	for linux-nfs@vger.kernel.org; Fri, 08 May 2009 01:37:25 +1000
In-Reply-To: <4A02FDC3.9090709-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 11:26 AM 5/7/2009, Frank Steiner wrote:
>Leonardo Chiquitto wrote
>
>>> Is there a way to prevent those UDP connects?
>> 
>> Yes, add "mountproto=tcp" to your mount options.
>
>I was only aware of "proto=tcp" and indeed missed the mountproto option.
>
>Thanks both Leonardo and Trond for your answers!
>

There is one small caveat to using mountproto=tcp through firewalls:
while the mount will succeed, there are some side protocol exchanges
which may not.

In particular, if you do NLM file locking, there is a server callback (NLM
"granted") which the server may choose to issue via UDP. If this callback
is not seen by the client due to firewall blocking, there may be a 30-second
pause before a client retry unblocks the caller.

Also, the NSM (status monitor) exchanges are often performed via UDP.
Again, if you are using NLM and the server reboots, the client may not
become aware of this promptly, and lock reclaim will be affected.

OTOH, if your applications don't use locking on the NFS mounts, you'll
probably be fine.

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

