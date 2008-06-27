From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] NFS performance debugging
Date: Fri, 27 Jun 2008 14:12:36 -0400
Message-ID: <1214590356.9235.1.camel@localhost>
References: <48624F34.1070108@RedHat.com>
	<OFDFC449CB.7BDDC7DB-ON65257475.0028A009-65257475.002936C0@in.ibm.com>
	<76bd70e30806270644j3e67c83and7b1f7fd6cc2f5f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34567 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756214AbYF0SMu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Jun 2008 14:12:50 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KCIRE-0003Fo-Nl
	for linux-nfs@vger.kernel.org; Sat, 28 Jun 2008 04:12:48 +1000
In-Reply-To: <76bd70e30806270644j3e67c83and7b1f7fd6cc2f5f5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-06-27 at 09:44 -0400, Chuck Lever wrote:

> >
> > (KK: for some reason, the real NFS mount gives all zero. Also, for
> > loopback, the read/write
> > BW is very poor: less than 40 Kb/s).
> 
> As an aside, Jim Rees pointed out to me that that should be KB/s, not
> Kb/s.  I will post a patch to address that.

Strictly speaking, neither of the above are correct: the SI abbreviation
for kilo is 'k'. IOW it should be 'kB/s'

Cheers
  Trond


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

