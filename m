Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37303 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753163AbZEGOFy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2009 10:05:54 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M24EU-0006cL-0H
	for linux-nfs@vger.kernel.org; Fri, 08 May 2009 00:05:54 +1000
In-Reply-To: <4A02DAA8.6050005@bio.ifi.lmu.de>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>
Date: Thu, 7 May 2009 10:34:51 -0300
Message-ID: <c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be@mail.gmail.com>
From: Leonardo Chiquitto <leonardo.lists@gmail.com>
To: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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
>   that could cause this behaviour?

By default it is now using UDP to connect to mountd.

> Is there a way to prevent those UDP connects?

Yes, add "mountproto=tcp" to your mount options.

Regards,
Leonardo

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

