Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:59184 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab1KCX73 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 19:59:29 -0400
Date: Thu, 3 Nov 2011 19:59:22 -0400
From: Jim Rees <rees@umich.edu>
To: Lukas Razik <linux@razik.name>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Message-ID: <20111103235922.GA12527@umich.edu>
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com>
 <1320353685.18396.119.camel@lade.trondhjem.org>
 <20111103211100.GA8393@umich.edu>
 <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com>
 <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com>
 <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com>
 <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I suspect some kind of timing problem, where the network interface hasn't
come up yet at the time the portmap request is made.  What does your nfsroot
kernel option look like?  What happens if you add ",port=2049" to the end of
your nfsroot kernel option?
