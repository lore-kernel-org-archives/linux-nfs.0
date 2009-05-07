From: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Subject: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Thu, 07 May 2009 14:57:12 +0200
Message-ID: <4A02DAA8.6050005@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:39770 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754517AbZEGN05 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2009 09:26:57 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M23cm-0006U0-5O
	for linux-nfs@vger.kernel.org; Thu, 07 May 2009 23:26:56 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm fighting with my firewall to get nfs-over-tcp through. 

The server is outside the firewall, the client is inside. The firewall
allows all tcp back-connections (without syn), no UDPs. Mount on the
client side worked fine with kernel 2.6.16 in SLES 10.

Now when the NFS client is running SLES 11 with its kernel 2.6.27, 
the NFS server tries to make UDP connections from its ports 111 and 
700 to different ports on the client.

If the client is running SLES 10 with 2.6.16, those connections are
not tried from the server, no matter if the server runs 2.6.16 or
2.6.27.

So I've two questions:
1) Should nfs-over-tcp still use any UDP ports at all?
2) What has been changed in the client code between 2.6.16 and 2.6.27
   that could cause this behaviour?

Is there a way to prevent those UDP connects?

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

