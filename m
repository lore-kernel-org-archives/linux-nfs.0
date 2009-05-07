From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Thu, 07 May 2009 09:52:06 -0400
Message-ID: <1241704326.4884.10.camel@heimdal.trondhjem.org>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:39325 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761484AbZEGNyd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2009 09:54:33 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M243R-0006ZL-2g
	for linux-nfs@vger.kernel.org; Thu, 07 May 2009 23:54:29 +1000
In-Reply-To: <4A02DAA8.6050005-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-05-07 at 14:57 +0200, Frank Steiner wrote:
> Hi,
> 
> I'm fighting with my firewall to get nfs-over-tcp through. 
> 
> The server is outside the firewall, the client is inside. The firewall
> allows all tcp back-connections (without syn), no UDPs. Mount on the
> client side worked fine with kernel 2.6.16 in SLES 10.
> 
> Now when the NFS client is running SLES 11 with its kernel 2.6.27, 
> the NFS server tries to make UDP connections from its ports 111 and 
> 700 to different ports on the client.
> 
> If the client is running SLES 10 with 2.6.16, those connections are
> not tried from the server, no matter if the server runs 2.6.16 or
> 2.6.27.
> 
> So I've two questions:
> 1) Should nfs-over-tcp still use any UDP ports at all?
> 2) What has been changed in the client code between 2.6.16 and 2.6.27
>    that could cause this behaviour?
> 
> Is there a way to prevent those UDP connects?

The default behaviour is to always try to use UDP to talk to mountd and
the portmapper in order to minimize the number of ports that get left in
the TIME_WAIT state. If you only want to use TCP, then you might try
using '-omountproto=tcp'

Cheers
  Trond

PS: Note that nfs@lists.sourceforge.net is deprecated due to poor
anti-spam filtering. You should rather send posts directly to
linux-nfs@vger.kernel.org



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

