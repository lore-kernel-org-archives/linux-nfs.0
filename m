From: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Thu, 07 May 2009 17:26:59 +0200
Message-ID: <4A02FDC3.9090709@bio.ifi.lmu.de>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>
	<c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Leonardo Chiquitto <leonardo.lists@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57128 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754768AbZEGP2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2009 11:28:05 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M25Vz-0006pg-Eg
	for linux-nfs@vger.kernel.org; Fri, 08 May 2009 01:28:03 +1000
In-Reply-To: <c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Leonardo Chiquitto wrote

>> Is there a way to prevent those UDP connects?
> 
> Yes, add "mountproto=tcp" to your mount options.

I was only aware of "proto=tcp" and indeed missed the mountproto option.

Thanks both Leonardo and Trond for your answers!

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *

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

