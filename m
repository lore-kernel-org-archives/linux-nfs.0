From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Sat, 10 Jan 2009 11:24:58 +0100
Message-ID: <20090110102458.GG47559@fit.vutbr.cz>
References: <20081202152256.GI47559@fit.vutbr.cz> <1228232222.3090.5.camel@heimdal.trondhjem.org> <20081202162625.GM47559@fit.vutbr.cz> <1228241407.3090.7.camel@heimdal.trondhjem.org> <20081204102314.GW47559@fit.vutbr.cz> <1229284201.6463.98.camel@heimdal.trondhjem.org> <20081216120547.GS47559@fit.vutbr.cz> <1230071647.17701.27.camel@heimdal.trondhjem.org> <20090109145638.GC47559@fit.vutbr.cz> <1231523966.7179.67.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:59040 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138AbZAJKZG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Jan 2009 05:25:06 -0500
In-Reply-To: <1231523966.7179.67.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2009 at 12:59:26PM -0500, Trond Myklebust wrote:
> On Fri, 2009-01-09 at 15:56 +0100, Kasparek Tomas wrote:
> > On Tue, Dec 23, 2008 at 05:34:07PM -0500, Trond Myklebust wrote:
> > > On Tue, 2008-12-16 at 13:05 +0100, Kasparek Tomas wrote:
> > > > Hm, not happy to say that but it still does not work after some time. Now
> > > > the problem is opposite there are no connections to the server according to
> > > > netstat on client, just time to time there is
> > > > 
> > > > pcnlp1.fit.vutbr.cz.15234 > kazi.fit.vutbr.cz.nfs: 40 null
> > > > kazi.fit.vutbr.cz.nfs > pcnlp1.fit.vutbr.cz.15234: reply ok 24 null
> > > > 
> > > > (kazi is server). Will try to investigate more details.
> > > 
> > > OK. Here is one more try. I've tightened up some locking issues with the
> > > previous patch.
> > 
> > Did tried this new version. Applied it to 2.6.27.10, but the behaviour is
> > the same like with the first version - when old mounts are removed by amd
> > new one are not created, fter a while, there are no sockets on the client
> > and just CLOSED sockets on server. Client is issuing null RPC checks each
> > 30sec and they are OK, but no other communication between client and server
> > takes place.
> > 
> > 15:45:41.238796 IP pcnlp1.897490 > kazi.nfs: 40 null
> > 15:45:41.239009 IP kazi.nfs > pcnlp1.897490: reply ok 24 null
> > 
> > 
> > I will try to get more info, but if you have some idea where to look or
> > what to try, it will be helpful.
> > 
> > Thanks for your help
> 
> Wait. You're using amd when testing? Could you please rather retry using
> just a static mount? amd has historically had way too many bugs
> (particularly w.r.t. tcp) to be considered a reliable test.

Will try, but with static mount there is one stable TCP connection between
client and server so this problem can not happen at all isn't it? 

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

