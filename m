From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Status of NFS/RDMA in mainline kernel?
Date: Tue, 15 Jan 2008 15:08:38 -0500
Message-ID: <1200427718.12663.10.camel@heimdal.trondhjem.org>
References: <478D0747.1050301@charter.net>  <478D0AA1.6020603@charter.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: laytonjb-xwVYE8SWAR3R7s880joybQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44405 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940AbYAOUJR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 15:09:17 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JEs5v-0003xs-0r
	for linux-nfs@vger.kernel.org; Wed, 16 Jan 2008 07:09:11 +1100
In-Reply-To: <478D0AA1.6020603-xwVYE8SWAR3R7s880joybQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-01-15 at 14:33 -0500, Jeffrey B. Layton wrote:
> Jeffrey B. Layton wrote:
> > I haven't seen anything about NFS over RDMA lately. What's the current
> > status of this on both the server and client side?
> >   
> Sorry - I was thinking NFSv3 support, but I wouldn't mind learning
> about NFSv4 as well.

The client side support has already been merged into Linus' mainline
tree. It will be part of 2.6.24.

Server side support is lacking, so the client NFSv4 callback channels,
and NFSv3 sideband services like NLM and the MOUNT protocol will go over
standard tcp channels.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

