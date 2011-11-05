Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43293 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753199Ab1KECcf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 22:32:35 -0400
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Lukas Razik <linux@razik.name>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Fri, 04 Nov 2011 22:30:44 -0400
In-Reply-To: <1320459252.59518.YahooMailNeo@web24716.mail.ird.yahoo.com>
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com>
	  <1320353685.18396.119.camel@lade.trondhjem.org>
	  <20111103211100.GA8393@umich.edu>
	  <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com>
	  <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com>
	  <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com>
	  <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com>
	  <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>
	  <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>
	  <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com>
	  <1320450001.87605.YahooMailNeo@web24706.mail.ird.yahoo.com>
	 <1320455965.2750.9.camel@lade.trondhjem.org>
	 <1320459252.59518.YahooMailNeo@web24716.mail.ird.yahoo.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320460244.2750.19.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2011-11-05 at 02:14 +0000, Lukas Razik wrote: 
> ***IMPORTANT HINT***
> 
> In the test belowI've tried to ping the NFS client (cluster2) as soon as I've got the
> 
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> message.
> 
> 
> And at first I've got no answers from the client. But 10-20sec later I've got pongs back.
> So the NIC comes up some seconds later than the message "link becomes ready" is shown...
> In the case of 'mountproto=tcp' it comes up after the kernel panic. So that's much too late.
> 

So, once again...

What kind of switch is this client connected to, and how is that switch
configured?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

