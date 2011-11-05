Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:34454 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751228Ab1KENF0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Nov 2011 09:05:26 -0400
Date: Sat, 5 Nov 2011 09:05:17 -0400
From: Jim Rees <rees@umich.edu>
To: Lukas Razik <linux@razik.name>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Message-ID: <20111105130517.GA16090@umich.edu>
References: <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com>
 <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com>
 <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>
 <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>
 <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com>
 <1320450001.87605.YahooMailNeo@web24706.mail.ird.yahoo.com>
 <1320455965.2750.9.camel@lade.trondhjem.org>
 <1320459252.59518.YahooMailNeo@web24716.mail.ird.yahoo.com>
 <1320460311.2750.21.camel@lade.trondhjem.org>
 <1320465106.61111.YahooMailNeo@web24710.mail.ird.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320465106.61111.YahooMailNeo@web24710.mail.ird.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lukas Razik wrote:

  > So, once again...
  > 
  > What kind of switch is this client connected to, and how is that switch
  > configured?
  
  I can't answer this question because I have no physical access to the
  hardware.  Hence I think it's logical to stop here until the nodes are
  connected directly (without any hardware between them).  I'll write here
  as soon as I know if it works...
  
  For the rest I thank all contributors for the fast help!

I think the implication here is that you're plugged in to a port that's
running spanning tree (stp) and is not set to portfast.  Such a port can
take up to a minute to start forwarding packets.  If so, you should fix
that, but it would also be nice if nfsroot could be made to work in this
setup.

By the way, if you want to send me that machine with its 64 processors and
32GB of memory, I'd be glad to investigate.
