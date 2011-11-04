Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:41827 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143Ab1KDNVA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 09:21:00 -0400
Date: Fri, 4 Nov 2011 09:20:50 -0400
From: Jim Rees <rees@umich.edu>
To: Lukas Razik <linux@razik.name>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Message-ID: <20111104132050.GB13788@umich.edu>
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com>
 <1320353685.18396.119.camel@lade.trondhjem.org>
 <20111103211100.GA8393@umich.edu>
 <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com>
 <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com>
 <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com>
 <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com>
 <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>
 <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's still a mystery to me because I use nfsroot all the time and it works
for me.  But I was never able to get static addressing to work and have had
to depend on the in-kernel dhcp.  And I have a different ethernet card that
maybe resets faster.  I have run into problems later in the boot, when user
space remounts the root, but that's not what you're seeing.

As for a fix...  we're trying to move away from udp transport anyway.  Maybe
someone should figure out a way to get it to work with tcp?  I have zero
experience with nfs over udp, at least on linux.  Just for fun, have you
tried tcp transport (proto=tcp)?

As we move toward nfs4 someone will have to give some thought to nfsroot.
It's hard to imagine we could put enough nfs4 cruft into the kernel (gssd,
idmapd) to make it work.
