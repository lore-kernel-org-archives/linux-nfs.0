From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
 than 120 seconds"
Date: Tue, 16 Dec 2008 07:59:09 -0500
Message-ID: <1229432349.7257.2.camel@heimdal.trondhjem.org>
References: <1227737539.31008.2.camel@localhost.localdomain>
	 <1228090631.7112.11.camel@heimdal.trondhjem.org>
	 <1228091380.7112.17.camel@heimdal.trondhjem.org>
	 <20081202152256.GI47559@fit.vutbr.cz>
	 <1228232222.3090.5.camel@heimdal.trondhjem.org>
	 <20081202162625.GM47559@fit.vutbr.cz>
	 <1228241407.3090.7.camel@heimdal.trondhjem.org>
	 <20081204102314.GW47559@fit.vutbr.cz>
	 <1229284201.6463.98.camel@heimdal.trondhjem.org>
	 <20081216120547.GS47559@fit.vutbr.cz> <20081216121011.GT47559@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Kasparek Tomas <kasparek@fit.vutbr.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44301 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443AbYLPNAR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2008 08:00:17 -0500
In-Reply-To: <20081216121011.GT47559@fit.vutbr.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-12-16 at 13:10 +0100, Kasparek Tomas wrote:
> On Tue, Dec 16, 2008 at 01:05:47PM +0100, Kasparek Tomas wrote:
> > On Sun, Dec 14, 2008 at 02:50:01PM -0500, Trond Myklebust wrote:
> > > On Thu, 2008-12-04 at 11:23 +0100, Kasparek Tomas wrote:
> > > > On Tue, Dec 02, 2008 at 01:10:07PM -0500, Trond Myklebust wrote:
> > > > > On Tue, 2008-12-02 at 17:26 +0100, Kasparek Tomas wrote:
> > > > > 
> > > > > > Did tried. The number should be seconds and defaults to 60, These
> > > > > > connections are still there after several hours. Changing it to 10 (sec)
> > > > > > and same behaviour. (BTW The server did not changed in last several months)
> > > > > 
> > > > > Are you seeing the same behaviour with 'netstat -t'?
> > > > 
> > > > yes:
> > > > 
> > > > root@pckasparek: ~# ssh root@pcnlp1 'netstat -pan | grep WAIT' | cut -c-85
> > > > tcp    0   0 147.229.12.146:989          147.229.176.14:2049 FIN_WAIT2
> > > > root@pckasparek: ~# ssh root@pcnlp1 'netstat -t | grep WAIT' | cut -c-85
> > > > tcp    0   0 pcnlp1.fit.vutbr.:ftps-data eva.fit.vutbr.cz:nfs FIN_WAIT2
> > > > 
> > > > but it should be the same, did't it? -t just selects TCP connections and
> > > > this is TCP connection so it shows the same
> > > 
> > > Right, but the point is that the client is in the state FIN_WAIT2, which
> > > means that it has closed the socket on its end, and is waiting for the
> > > server to close on its end. The fact that the server is failing to do
> > > this is a server bug.
> > > 
> > > That said, we can't wait forever for buggy servers. I see now why the
> > > linger2 stuff isn't working. I believe that the appended patch should
> > > help...
> > 
> > Hm, not happy to say that but it still does not work after some time. Now
> > the problem is opposite there are no connections to the server according to
> > netstat on client, just time to time there is
> > 
> > pcnlp1.fit.vutbr.cz.15234 > kazi.fit.vutbr.cz.nfs: 40 null
> > kazi.fit.vutbr.cz.nfs > pcnlp1.fit.vutbr.cz.15234: reply ok 24 null
> > 
> > (kazi is server). Will try to investigate more details.
> > 
> > (just to remember the same kernel with reversed
> > e06799f958bf7f9f8fae15f0c6f519953fb0257c works fine - exact patch is
> > included - it was slightly modified to fit 2.6.27.x kernels)
> > 
> > Thank you very much for your help so far.
> 
> just the forgoten patch promised.

NACK. That takes us right back to the previous broken behaviour.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
