Return-Path: linux-nfs-owner@vger.kernel.org
Received: from c2bthomr09.btconnect.com ([213.123.20.127]:2635 "EHLO
	mail.btconnect.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752168AbaHYKEA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2014 06:04:00 -0400
From: "lux-integ" <lux-integ@btconnect.com>
To: linux-nfs@vger.kernel.org
Subject: nfs4/KINK/racoon2/linux-3.x  series kernels
Date: Mon, 25 Aug 2014 10:57:38 +0100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Message-Id: <201408251057.38218.lux-integ@btconnect.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings

I have an application for NFS4 over IPv6/IPsec tunnel(s).  And it is THIS: (A 
remote user login to kerberised NFS4 server) In this instance  the remote user 
logs in to  an Ipsec gateway which is connected to another gateway to a 
kerberised  nfs4 server. )

I would like to know if this is possible.    Having   the gateway as a kdc 
might help and I looked at   racoon2 ( http://www.racoon2.wide.ad.jp/w/ )
but it  seems to be implemented for the linux-2.6x series kernel only.  I 
would be graeful  to know if this or any other similar kerberos  
implementations  is  available for linux-3.x  (particularly linux-3.1x )  
series  kernels.

Any other advice on  how my application  (THIS above ) might be carried out 
will be gratefully received.


sincerely

luxInteg
