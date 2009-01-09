From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
 than 120 seconds"
Date: Fri, 09 Jan 2009 12:59:26 -0500
Message-ID: <1231523966.7179.67.camel@heimdal.trondhjem.org>
References: <1228090631.7112.11.camel@heimdal.trondhjem.org>
	 <1228091380.7112.17.camel@heimdal.trondhjem.org>
	 <20081202152256.GI47559@fit.vutbr.cz>
	 <1228232222.3090.5.camel@heimdal.trondhjem.org>
	 <20081202162625.GM47559@fit.vutbr.cz>
	 <1228241407.3090.7.camel@heimdal.trondhjem.org>
	 <20081204102314.GW47559@fit.vutbr.cz>
	 <1229284201.6463.98.camel@heimdal.trondhjem.org>
	 <20081216120547.GS47559@fit.vutbr.cz>
	 <1230071647.17701.27.camel@heimdal.trondhjem.org>
	 <20090109145638.GC47559@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Kasparek Tomas <kasparek@fit.vutbr.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10354 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751345AbZAISHC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jan 2009 13:07:02 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n09I06MY013425
	for <linux-nfs@vger.kernel.org>; Fri, 9 Jan 2009 10:00:06 -0800 (PST)
In-Reply-To: <20090109145638.GC47559@fit.vutbr.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-01-09 at 15:56 +0100, Kasparek Tomas wrote:
> On Tue, Dec 23, 2008 at 05:34:07PM -0500, Trond Myklebust wrote:
> > On Tue, 2008-12-16 at 13:05 +0100, Kasparek Tomas wrote:
> > > Hm, not happy to say that but it still does not work after some time. Now
> > > the problem is opposite there are no connections to the server according to
> > > netstat on client, just time to time there is
> > > 
> > > pcnlp1.fit.vutbr.cz.15234 > kazi.fit.vutbr.cz.nfs: 40 null
> > > kazi.fit.vutbr.cz.nfs > pcnlp1.fit.vutbr.cz.15234: reply ok 24 null
> > > 
> > > (kazi is server). Will try to investigate more details.
> > 
> > OK. Here is one more try. I've tightened up some locking issues with the
> > previous patch.
> 
> Did tried this new version. Applied it to 2.6.27.10, but the behaviour is
> the same like with the first version - when old mounts are removed by amd
> new one are not created, fter a while, there are no sockets on the client
> and just CLOSED sockets on server. Client is issuing null RPC checks each
> 30sec and they are OK, but no other communication between client and server
> takes place.
> 
> 15:45:41.238796 IP pcnlp1.897490 > kazi.nfs: 40 null
> 15:45:41.239009 IP kazi.nfs > pcnlp1.897490: reply ok 24 null
> 
> 
> I will try to get more info, but if you have some idea where to look or
> what to try, it will be helpful.
> 
> Thanks for your help

Wait. You're using amd when testing? Could you please rather retry using
just a static mount? amd has historically had way too many bugs
(particularly w.r.t. tcp) to be considered a reliable test.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
